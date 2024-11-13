import 'package:flutter/material.dart';
import 'package:hola_mundo/config/api_config.dart';
import 'package:hola_mundo/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final String baseUrl = ApiConfig.baseUrl;
  String? _email;
  String? _token;
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecoverInfo();
  }

  Future<void> _loadRecoverInfo() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _email = prefs.getString('email');
      _token = prefs.getString('token_recover');
    });
  }

  Future<void> _goToLogin(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('email');
    await prefs.remove('token_recover'); // Eliminar el nombre al cerrar sesión
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  void _changePassword(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text == _confirmPasswordController.text) {
        try {
          final response = await http.post(
            Uri.parse('$baseUrl/login/changePasswordRecoverAccount'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'email': _email ?? '',
              'newPassword': _passwordController.text,
              'token': _token ?? '',
            }),
          );

          if (response.statusCode == 201) {
            var jsonResponse = jsonDecode(response.body);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${jsonResponse['message']}')),
            );

            _goToLogin(context);
          } else {
            var jsonResponse = jsonDecode(response.body);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${jsonResponse['message']}')),
            );
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $error')),
          );
        }
      } else {
        // Mostrar error si las contraseñas no coinciden
      }
    }
  }

  // Función de validación de la contraseña
  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'La contraseña no puede estar vacía';
    }
    if (password.length < 8) {
      return 'La contraseña debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      return 'Debe contener al menos una letra mayúscula';
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      return 'Debe contener al menos un número';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      return 'Debe contener al menos un carácter especial';
    }
    return null; // Contraseña válida
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cambiar contraseña"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Contraseña nueva'),
                  obscureText: true,
                  validator: _validatePassword
                ),
                // Agrega las instrucciones de ayuda aquí
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'La contraseña debe tener al menos 8 caracteres, incluir una letra mayúscula, '
                    'un número y un carácter especial.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.start,
                  ),
                ),
                TextFormField(
                  controller: _confirmPasswordController,
                  decoration:
                      InputDecoration(labelText: 'Confirmar nueva contraseña'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor confirma la contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                
                ElevatedButton(
                  onPressed: () => _changePassword(context),
                  child: Text("Cambiar contraseña"),
                ),
              ],
            ),
          )),
    );
  }
}
