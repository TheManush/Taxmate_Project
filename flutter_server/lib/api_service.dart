import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';
class ApiService {
  final String baseUrl;

  ApiService(this.baseUrl);

  Future<http.Response> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );
      return response;
    } catch (e) {
      throw Exception('Failed to connect to server: ${e.toString()}');
    }
  }

  Future<http.Response> get(String endpoint, {String? token}) async {
    try {
      final headers = {'Content-Type': 'application/json'};
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: headers,
      );
      return response;
    } catch (e) {
      throw Exception('Failed to connect to server: ${e.toString()}');
    }
  }
  Future<List<Map<String, dynamic>>> getCharteredAccountants() async {
    final response = await get("chartered_accountants");

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load Chartered Accountants: ${response.body}');
    }
  }
  // Fetch service requests for a CA
  Future<List<Map<String, dynamic>>> fetchCARequests(int caId) async {
    final response = await http.get(Uri.parse('$baseUrl/ca/$caId/requests'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load requests');
    }
  }

// Update request status
  Future<void> updateRequestStatus(int requestId, String newStatus) async {
    final response = await http.patch(
      Uri.parse('$baseUrl/requests/$requestId'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': newStatus}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update request');
    }
  }
  Future<void> sendServiceRequest({
    required int clientId,
    required int caId,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/requests/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'client_id': clientId,
        'ca_id': caId,
      }),
    );

    if (response.statusCode == 201) {
      return; // success
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to send request');
    }
  }
  Future<Map<String, dynamic>?> checkExistingRequest(int clientId, int caId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/client/$clientId/requests'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      for (final request in data) {
        if (request['ca']['id'] == caId) {
          return request;
        }
      }

      return null; // No matching request
    } else {
      throw Exception('Failed to fetch client requests');
    }
  }
  Future<List<Map<String, dynamic>>> fetchApprovedClients(int caId) async {
    final response = await http.get(Uri.parse('$baseUrl/ca/$caId/approved_clients'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load approved clients');
    }
  }

  Future<String> getDownloadUrl(int clientId, int caId, String docType) async {
    final encodedDocType = Uri.encodeComponent(docType);
    final response = await http.get(Uri.parse(
      '$baseUrl/download-url/$clientId/$caId?doc_type=$encodedDocType',
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    } else {
      throw Exception('Failed to get download URL: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> uploadFile({
    required int userId,
    required int caId,
    required List<int> fileBytes,
    required String fileName,
    required String contentType,
    required String docType,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/upload/$userId/$caId?doc_type=${Uri.encodeComponent(docType)}');

      var request = http.MultipartRequest('POST', url);

      // Add the file
      request.files.add(http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
        contentType: MediaType.parse(contentType),
      ));

      // Add headers if token is provided
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Upload failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Upload error: ${e.toString()}');
    }
  }

  // Helper method to get content type from file extension
  String getContentType(String filePath) {
    final extension = filePath.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      default:
        return 'application/octet-stream';
    }
  }
  Future<bool> checkAuditReportExists(int clientId, int caId) async {
    final url = Uri.parse('$baseUrl/check-file-exists/$clientId/$caId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['exists'] ?? false;
    } else {
      return false;
    }
  }
  Future<List<Map<String, dynamic>>> getChatHistory(int user1, int user2) async {
    final response = await http.get(Uri.parse(
      '$baseUrl/chat-history/$user1/$user2',
    ));

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load chat history');
    }
  }

}

