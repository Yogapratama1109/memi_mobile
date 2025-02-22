import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthAPI {
  static const String _baseUrl = "http://127.0.0.1:8000/api";

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final String apiUrl = "$_baseUrl/login";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        return {"success": true, "data": responseData};
      } else {
        return {
          "success": false,
          "message": jsonDecode(response.body)["message"] ?? "Invalid email or password"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "An error occurred: ${e.toString()}"
      };
    }
  }
}
