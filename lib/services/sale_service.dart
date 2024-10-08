import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SaleService {

  final String baseUrl;

  SaleService(this.baseUrl);

  // Método para obtener el token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // POST: Crear una nueva venta
  Future<http.Response> createSale(Map<String, dynamic> sale) async {
    print(sale);
    
    final token = await _getToken();
    print(token);
    return await http.post(
      Uri.parse('$baseUrl/sales'),
      headers: {
        'Cookie': 'fz_token=$token',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(sale),
    );
  }

}