import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class ChatPage extends StatefulWidget {
  final int senderId;
  final int receiverId;
  final String receiverName;
  final ApiService apiService;

  const ChatPage({
    super.key,
    required this.senderId,
    required this.receiverId,
    required this.receiverName,
    required this.apiService,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  late WebSocketChannel _channel;

  @override
  void initState() {
    super.initState();
    _loadChatHistory();
  }

  Future<void> _loadChatHistory() async {
    try {
      final history = await widget.apiService.getChatHistory(
        widget.senderId,
        widget.receiverId,
      );
      setState(() {
        _messages.addAll(history);
      });
      _connectWebSocket();
      // Scroll to bottom after loading history
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      print('Failed to load history: $e');
    }
  }

  void _connectWebSocket() {
    _channel = IOWebSocketChannel.connect(
      Uri.parse('ws://192.168.0.101:8000/ws/chat/${widget.senderId}'),
      //Uri.parse('ws://10.0.2.2:8000/ws/chat/${widget.senderId}'),
    );

    _channel.stream.listen((event) {
      final data = jsonDecode(event);
      setState(() {
        _messages.add({
          'sender_id': data['sender_id'],
          'receiver_id': widget.senderId,
          'message': data['message'],
          'timestamp': DateTime.now().toIso8601String(),
        });
      });
      _scrollToBottom();
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;
    final message = _controller.text.trim();

    _channel.sink.add(jsonEncode({
      'receiver_id': widget.receiverId,
      'message': message,
    }));

    setState(() {
      _messages.add({
        'sender_id': widget.senderId,
        'receiver_id': widget.receiverId,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      });
    });

    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0, // For reversed ListView, 0 is the bottom
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isMe = msg['sender_id'] == widget.senderId;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe ? Colors.lightBlue[300] : Colors.blue[700],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          msg['message'],
          style: TextStyle(
            fontSize: 16,
            color: isMe ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.receiverName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      resizeToAvoidBottomInset: true, // This ensures the scaffold resizes when keyboard appears
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(vertical: 10),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                // Reverse the index to show newest messages at bottom
                final reversedIndex = _messages.length - 1 - index;
                return _buildMessageBubble(_messages[reversedIndex]);
              },
            ),
          ),
          const Divider(height: 1),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    onTap: () {
                      // Scroll to bottom when user taps to type
                      Future.delayed(const Duration(milliseconds: 500), () {
                        _scrollToBottom();
                      });
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}