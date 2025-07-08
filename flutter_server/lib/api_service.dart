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
  // Fetch service requests for a BLO
  Future<List<Map<String, dynamic>>> fetchBLORequests(int officerId) async {
    final response = await http.get(Uri.parse('$baseUrl/bank_loan_officer/$officerId/requests'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load BLO requests');
    }
  }

  // Alias method for BLO dashboard compatibility
  Future<List<Map<String, dynamic>>> fetchBankLoanOfficerRequests(int officerId) async {
    return fetchBLORequests(officerId);
  }

  // Update bank loan request status - alias for BLO dashboard compatibility
  Future<void> updateBankLoanRequestStatus(int requestId, String newStatus) async {
    return updateRequestStatus(requestId, newStatus);
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
    int? caId,
    int? bloId,
  }) async {
    final Map<String, dynamic> requestData = {
      'client_id': clientId,
      if (caId != null) 'ca_id': caId,
      if (bloId != null) 'blo_id': bloId,
    };

    final response = await http.post(
      Uri.parse('$baseUrl/requests/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(requestData),
    );

    if (response.statusCode == 201) {
      return; // success
    } else {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Failed to send request');
    }
  }
  Future<Map<String, dynamic>?> checkExistingRequest(int clientId, int? caId, int? bloId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/client/$clientId/requests'),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        for (final request in data) {
          // Check for CA request
          if (caId != null && request['ca'] != null && request['ca']['id'] == caId) {
            return request;
          }
          // Check for BLO request
          if (bloId != null && request['blo'] != null && request['blo']['id'] == bloId) {
            return request;
          }
        }

        return null; // No matching request
      } else {
        print('Error response: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch client requests: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in checkExistingRequest: $e');
      throw Exception('Failed to fetch client requests: ${e.toString()}');
    }
  }
  Future<List<Map<String, dynamic>>> fetchApprovedClients(int caId) async {
    final response = await http.get(Uri.parse('http://192.168.49.106:8000/ca/$caId/approved_clients'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load approved clients');
    }
  }
  Future<List<Map<String, dynamic>>> fetchApprovedClientsForBLO(int officerId) async {
    final response = await http.get(Uri.parse('$baseUrl/bank_loan_officer/$officerId/approved_clients'));
    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load approved clients for BLO');
    }
  }

  Future<String> getDownloadUrl(int clientId, int caId, String docType) async {
    final encodedDocType = Uri.encodeComponent(docType);
    final response = await http.get(Uri.parse(
      '$baseUrl/download-url/$clientId/$caId?doc_type=$encodedDocType&service_type=ca',
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
      final url = Uri.parse('$baseUrl/upload/$userId/$caId?doc_type=${Uri.encodeComponent(docType)}&service_type=ca');

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

  // BLO File Upload method
  Future<Map<String, dynamic>> uploadFileToBLO({
    required int userId,
    required int bloId,
    required List<int> fileBytes,
    required String fileName,
    required String contentType,
    required String docType,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/upload/$userId/$bloId?doc_type=${Uri.encodeComponent(docType)}&service_type=blo');

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

  // BLO File Download URL method
  Future<String> getDownloadUrlForBLO(int clientId, int bloId, String docType) async {
    final encodedDocType = Uri.encodeComponent(docType);
    final response = await http.get(Uri.parse(
      '$baseUrl/download-url/$clientId/$bloId?doc_type=$encodedDocType&service_type=blo',
    ));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    } else {
      throw Exception('Failed to get download URL: ${response.statusCode}');
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

}

