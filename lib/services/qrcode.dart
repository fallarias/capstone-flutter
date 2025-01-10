import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../variables/ip_address.dart';

class QRService {
  Future<bool> sendQRDataToBackend(dynamic data) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('token');
    final String? department = prefs.getString('department');
    String userId = prefs.getInt('userId').toString();
    if (token == null) {
      print('Token is null. Please login first.');
      return false; // Indicate failure due to no token
    }

    try {
      final response = await http.post(
        Uri.parse('$ipaddress/scanned_data/${department.toString()}/${userId.toString()}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'scanned_data': data is List ? data : [data], // Convert to array if not already
        }),
      );

      if (response.statusCode == 200) {
        print('Data successfully sent to the backend.');
        return true; // Indicate success
      }else if (response.statusCode == 404) {
        print('Failed: ${response.body}');
        return false; // Indicate success
      } else {
        print('Failed: ${response.body}');
        return false; // Indicate failure
      }
    } catch (e) {
      print('Error while sending data: $e');
      return false; // Indicate failure
    }
  }
}

