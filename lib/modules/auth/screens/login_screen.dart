// lib/screens/login_screen.dart

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hola_mundo/config/api_config.dart';
import 'package:hola_mundo/modules/auth/screens/forgot_password_screen.dart';
import 'package:hola_mundo/shared/widgets/custom_button.dart';
import 'package:hola_mundo/shared/widgets/forms/text_fields/custom_text_field.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../home/screens/home_screen.dart';
import 'package:http/http.dart' as http;
import 'package:easy_localization/easy_localization.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final String baseUrl = ApiConfig.baseUrl;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveSession(token, names) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('token', token);
    await prefs.setString('names', names);
  }

  void _login() async {
    setState(() {
      _errorMessage = null;
    });

    if (_formKey.currentState?.validate() ?? false) {
      String username = _usernameController.text;
      String password = _passwordController.text;

      // Realiza la solicitud a la API
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        // Si la respuesta es exitosa, procesa el token
        var jsonResponse = jsonDecode(response.body);
        String token = jsonResponse['token'];
        String names = jsonResponse['names'];

        // Aquí puedes guardar el token en la aplicación
        await _saveSession(token, names);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // Si la respuesta no es 200, muestra un mensaje de error
        setState(() {
          _errorMessage = 'auth.login.usuario_o_clave_no_validos'.tr();
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(child: LayoutBuilder(builder: (context, constraints) {
      return SingleChildScrollView(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: constraints.maxHeight * 0.12),
              Image.asset(
                'assets/images/logo.png',
                height: 100,
              ),
              SizedBox(height: constraints.maxHeight * 0.06),
              Text(
                'auth.login.iniciar_sesion'.tr(),
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: constraints.maxHeight * 0.05),
              Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomTextField(
                      controller: _usernameController,
                      label: 'auth.login.usuario'.tr(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'auth.login.ingresar_usuario'.tr();
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      controller: _passwordController,
                      label: 'auth.login.clave'.tr(),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'auth.login.ingresar_clave'.tr();
                        }
                        return null;
                      },
                    ),
                    if (_errorMessage != null)
                      Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    const SizedBox(height: 20),
                    CustomButton(
                      onPressed: _login,
                      text: 'auth.login.ingresar'.tr(),
                      type: ButtonType.primary,
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    const SizedBox(height: 16.0),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ForgotPasswordScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'auth.login.olvido_clave'.tr(),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withOpacity(0.64),
                            ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text.rich(
                        TextSpan(
                          text: "${'auth.login.no_tiene_cuenta'.tr()} ",
                          children: [
                            TextSpan(
                              text: 'auth.login.registrate'.tr(),
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyLarge!
                                  .color!
                                  .withOpacity(0.64),
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    })));
  }
}
