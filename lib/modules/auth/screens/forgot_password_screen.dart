import 'package:flutter/material.dart';
import 'package:hola_mundo/config/api_config.dart';
import 'package:hola_mundo/shared/widgets/custom_button.dart';
import 'package:hola_mundo/shared/widgets/forms/text_fields/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'otp_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final String baseUrl = ApiConfig.baseUrl;
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  String? _errorMessage;

  Future<void> _saveSession(token, email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token_recover', token);
    await prefs.setString('email', email);
  }

  void _sendOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      String email = _emailController.text;
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/login/sendVerificationCodeRecoverAccount'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': email,
          }),
        );

        if (response.statusCode == 201) {
          // Si la respuesta es exitosa, procesa el token
          var jsonResponse = jsonDecode(response.body);
          String token = jsonResponse['data']['token'];
          String email = jsonResponse['data']['email'];

          // Aquí puedes guardar el token en la aplicación
          await _saveSession(token, email);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${jsonResponse['message']}')),
          );

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => OtpScreen()),
          );
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
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recuperar contraseña"),
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_errorMessage != null)
                  Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                CustomTextField(
                  controller: _emailController,
                  label: 'Correo electrónico',
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Ingrese su dirección de correo electrónico';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 20),
                CustomButton(
                  onPressed: _sendOtp,
                  text: "Enviar código de verificación",
                  type: ButtonType.primary,
                ),
              ],
            ),
          )),
    );
  }
}
