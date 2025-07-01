import 'package:http/http.dart' as http;
import 'dart:convert';

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
}