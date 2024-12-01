import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:isu_canner/variables/ip_address.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskService {
  final String baseUrl;

  TaskService(this.baseUrl);

  Future<List<dynamic>> fetchTasks(String? token) async {

    final response = await http.get(
      Uri.parse('$ipaddress/client_file'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );



    if (response.statusCode == 200) {
      return json.decode(response.body)['files'];
    } else {
      throw Exception('Failed to load tasks');
    }
  }

}
