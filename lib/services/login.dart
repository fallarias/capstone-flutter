import 'dart:convert';
import 'package:http/http.dart' as http;

import '../variables/ip_address.dart';
import '../model/api_response.dart';
import '../model/user.dart';


Future<ApiResponse> login(String email, String password) async {
  ApiResponse apiResponse = ApiResponse();
  try {
    final response = await http.post(
      Uri.parse('$ipaddress/login'),
      headers: {'Accept':'application/json'},
      body: {'email':email,
       'password':password}
    );
    print("Response Body: ${response.body}");

    switch(response.statusCode){
      case 200:
        apiResponse.data = User.fromJson(jsonDecode(response.body));
        break;
      case 422:
        final errors = jsonDecode(response.body)['message'];
        apiResponse.error = errors;
        break;
      case 403:
        apiResponse.error = jsonDecode(response.body)['message'];
        break;
      default:
        apiResponse.error = 'Something went wrong.';
        break;
    }

  } catch(e){
    apiResponse.error = 'Something went wrong.';
  }
  return apiResponse;
}