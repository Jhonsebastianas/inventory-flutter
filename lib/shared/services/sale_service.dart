import 'package:hola_mundo/modules/sales/models/sale_detail_dto.dart';
import 'package:hola_mundo/shared/models/sale.dart';
import 'package:hola_mundo/shared/models/sales_inquiries.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart'; // Importar la configuración

class SaleService {
  final String baseUrl = ApiConfig.baseUrl;

  // Método para obtener el token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // POST: Crear una nueva venta
  Future<Map<String, dynamic>> createSale(Map<String, dynamic> sale) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/sales'),
      headers: {
        'Cookie': 'fz_token=$token',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(sale),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Error al registrar la venta: ${response.body}');
    }
  }

  // Obtener ventas por mes
  Future<List<Sale>> getSalesByMonth(int year, int month) async {
    final token = await _getToken();
    print("vamos a consular");
    final response = await http.get(
      // Uri.parse('$baseUrl/sales?year=$year&month=$month')
      Uri.parse('$baseUrl/sales'),
      headers: {
        'Cookie': 'fz_token=$token',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      print(data);
      print("VAMOS A MAPEAR");
      return data.map((sale) => Sale.fromJson(sale)).toList();
    } else {
      throw Exception('Error al obtener las ventas');
    }
  }

  Future<SalesInquiries> consultationSales(
      Map<String, dynamic> salesConsultation) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/sales/consultation'),
      headers: {
        'Cookie': 'fz_token=$token',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(salesConsultation),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      print(data);
      return SalesInquiries.fromJson(data);
    } else {
      throw Exception('Error al obtener las ventas');
    }
  }

  Future<SaleDetailDTO> fetchSaleDetail(String idSale) async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/sales/saleDetail?idSale=$idSale'),
      headers: {
        'Cookie': 'fz_token=$token',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      final salesDetail = SaleDetailDTO.fromJson(jsonDecode(response.body));
      return salesDetail;
    } else {
      throw Exception('Error al obtener el detalle de la venta');
    }
  }
}
