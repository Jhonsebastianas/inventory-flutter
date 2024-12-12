import 'dart:convert';

import 'package:hola_mundo/config/api_config.dart';
import 'package:hola_mundo/modules/clients/models/register_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ClientService {
  final String baseUrl = ApiConfig.baseUrl;

  // Método para obtener el token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  // Obtener cliente por tipo y número identificación
  Future<RegisterClient?> findClientByIdentification(
      String idType, String numberIdentification) async {
    try {
      final token = await _getToken();
      final response = await http.get(
        // Uri.parse('$baseUrl/sales?year=$year&month=$month')
        Uri.parse(
            '$baseUrl/clients/findClientByIdentification?idType=$idType&numberIdentification=$numberIdentification'),
        headers: {
          'Cookie': 'fz_token=$token',
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        // Validar si el cuerpo de la respuesta está vacío
        if (response.body.isEmpty || response.body == 'null') {
          return null; // Cliente no encontrado
        }
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        // Validar si los datos son válidos
        if (data.isEmpty) {
          return null;
        }

        return RegisterClient.fromJson(data);
      } else {
        // Puedes manejar otros códigos de estado aquí, por ejemplo, 404 o 500
        throw Exception('Error al obtener el cliente: ${response.statusCode}');
      }
    } catch (error) {
      // Manejo de errores generales (red, decodificación, etc.)
      print('Error: $error');
      return null; // O manejar de otra manera según tu lógica
    }
  }
}
