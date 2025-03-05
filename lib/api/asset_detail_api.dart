import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiAssetDetail {
  static const String _baseUrl = 'http://203.175.11.163/api';

  Future<Map<String, dynamic>> getAssetDetail(String assetId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('X-USER-MEMO');

      if (userId == null) {
        throw Exception('User ID not found in local storage');
      }

      final response = await http.get(
        Uri.parse('$_baseUrl/detail-asset/$assetId'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse.containsKey('data')) {
          return jsonResponse;
        } else {
          throw Exception("Invalid response format: 'data' key is missing");
        }
      } else {
        throw Exception('Failed to load asset details');
      }
    } catch (e) {
      throw Exception('Error fetching asset details: $e');
    }
  }

  Future<Map<String, dynamic>> updateAssetDetail(
    String assetId,
    Map<String, dynamic> payload,
  ) async {
    final Uri url = Uri.parse("$_baseUrl/update-asset/$assetId");

    try {
      final response = await http
          .put(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 10), // Timeout 10 detik
            onTimeout: () {
              throw Exception(
                "Request timeout. Please check your internet connection.",
              );
            },
          );

      // Periksa kode status HTTP
      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw Exception("Invalid response format from server.");
        }
      } else {
        throw Exception(
          "Failed to update asset, Status Code: ${response.statusCode}",
        );
      }
    } catch (error) {
      throw Exception("Error updating asset: $error");
    }
  }

  Future<Map<String, dynamic>> updateStockAsset(
    String id,
    String assetId,
    Map<String, dynamic> payload,
  ) async {
    final Uri url = Uri.parse(
      "$_baseUrl/update-stock-opname-3/$id/update/$assetId",
    );

    try {
      final response = await http
          .put(
            url,
            headers: {"Content-Type": "application/json"},
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(seconds: 10), // Timeout 10 detik
            onTimeout: () {
              throw Exception(
                "Request timeout. Please check your internet connection.",
              );
            },
          );

      // Periksa kode status HTTP
      if (response.statusCode == 200) {
        try {
          return jsonDecode(response.body);
        } catch (e) {
          throw Exception("Invalid response format from server.");
        }
      } else {
        throw Exception(
          "Failed to update asset, Status Code: ${response.statusCode}",
        );
      }
    } catch (error) {
      throw Exception("Error updating asset: $error");
    }
  }
}
