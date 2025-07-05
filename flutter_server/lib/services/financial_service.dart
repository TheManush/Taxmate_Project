import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/financial_models.dart';

class FinancialService {
  final String baseUrl;

  FinancialService(this.baseUrl);

  Future<FinancialData?> getFinancialData(int clientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/financial-data/$clientId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FinancialData.fromJson(data);
      } else if (response.statusCode == 404) {
        return null; // No financial data found
      } else {
        throw Exception('Failed to load financial data');
      }
    } catch (e) {
      throw Exception('Error fetching financial data: $e');
    }
  }

  Future<FinancialData> saveFinancialData(int clientId, FinancialData financialData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/financial-data/$clientId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(financialData.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return FinancialData.fromJson(data);
      } else {
        throw Exception('Failed to save financial data');
      }
    } catch (e) {
      throw Exception('Error saving financial data: $e');
    }
  }

  Future<FinancialSummary> getFinancialSummary(int clientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/financial-summary/$clientId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FinancialSummary.fromJson(data);
      } else {
        throw Exception('Failed to load financial summary');
      }
    } catch (e) {
      throw Exception('Error fetching financial summary: $e');
    }
  }

  Future<String> sendChatMessage(int clientId, String message) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/chat/$clientId'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': message}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'];
      } else {
        throw Exception('Failed to send chat message');
      }
    } catch (e) {
      throw Exception('Error sending chat message: $e');
    }
  }

  Future<List<ChatMessage>> getChatHistory(int clientId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/chat-history/$clientId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load chat history');
      }
    } catch (e) {
      throw Exception('Error fetching chat history: $e');
    }
  }
}