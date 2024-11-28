import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/api_config.dart'; // Importar la configuración

class ApiService {
  final String baseUrl = ApiConfig.baseUrl;

  // Método para obtener el token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // GET: Obtener todos los productos
  Future<http.Response> getProducts() async {
    final token = await _getToken();
    return await http.get(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Cookie': 'fz_token=$token',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  // GET: Obtener un producto por ID
  Future<http.Response> getProductById(String id) async {
    final token = await _getToken();
    return await http.get(
      Uri.parse('$baseUrl/products/$id'),
      headers: {
        'Cookie': 'fz_token=$token',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  // POST: Crear un nuevo producto
  Future<http.Response> createProduct(Map<String, dynamic> product) async {
    final token = await _getToken();
    return await http.post(
      Uri.parse('$baseUrl/products'),
      headers: {
        'Cookie': 'fz_token=$token',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(product),
    );
  }

  // PUT: Actualizar un producto
  Future<http.Response> updateProduct(String id, Map<String, dynamic> product) async {
    final token = await _getToken();
    return await http.put(
      Uri.parse('$baseUrl/products/$id'),
      headers: {
        'Cookie': 'fz_token=$token',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(product),
    );
  }

  // DELETE: Eliminar un producto
  Future<http.Response> deleteProduct(String id) async {
    final token = await _getToken();
    return await http.delete(
      Uri.parse('$baseUrl/products/$id'),
      headers: {
        'Cookie': 'fz_token=$token',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }

  // GET: Búsqueda de productos con "like"
  Future<http.Response> searchProducts(String name) async {
    final token = await _getToken();
    return await http.get(
      Uri.parse('$baseUrl/products/like/$name'),
      headers: {
        'Cookie': 'fz_token=$token',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
  }
}
