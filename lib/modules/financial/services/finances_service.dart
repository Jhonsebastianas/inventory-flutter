import 'dart:convert';
import 'package:hola_mundo/config/api_config.dart';
import 'package:hola_mundo/modules/financial/models/financial_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class FinancesService {
  final String baseUrl = ApiConfig.baseUrl;

  // Método para obtener el token desde SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Método para obtener los datos financieros según rango y fecha
  Future<FinancialData?> fetchFinancialData(String range, String date) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/financial/$range/$date'),
        headers: {
          'Cookie': 'fz_token=$token',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return FinancialData.fromJson(data);
      } else {
        throw Exception('Error al cargar los datos: ${response.reasonPhrase}');
      }
    } catch (error) {
      print('Error en fetchFinancialData: $error');
      return null;
    }
  }
}
