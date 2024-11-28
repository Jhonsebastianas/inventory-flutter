import 'package:flutter/material.dart';
import 'package:hola_mundo/config/api_config.dart';
import 'package:hola_mundo/modules/auth/screens/login_screen.dart';
import 'package:hola_mundo/shared/widgets/custom_button.dart';
import 'package:hola_mundo/shared/widgets/forms/text_fields/custom_text_field.dart';
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
  final _passwordFocusNode = FocusNode(); // FocusNode para la nueva contraseña

  bool hasUppercase = false;
  bool hasDigits = false;
  bool hasSpecialCharacters = false;
  bool hasMinLength = false;
  bool showRequirements = false; // Variable para mostrar/ocultar requisitos

  @override
  void initState() {
    super.initState();
    _loadRecoverInfo();

// Escucha cambios en el controlador de la contraseña
    _passwordController.addListener(() {
      _validatePassword(_passwordController.text);
    });
    // Listener para mostrar requisitos solo cuando el campo tiene el foco
    _passwordFocusNode.addListener(() {
      setState(() {
        showRequirements = _passwordFocusNode.hasFocus;
      });
    });
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
    setState(() {
      hasUppercase = password!.contains(RegExp(r'[A-Z]'));
      hasDigits = password.contains(RegExp(r'[0-9]'));
      hasSpecialCharacters =
          password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
      hasMinLength = password.length >= 8;
    });
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
          title: const Text(
            "Cambiar contraseña",
            style: TextStyle(color: Color(0xFF757575)),
          ),
        ),
        body: SafeArea(
            child: SizedBox(
          width: double.infinity,
          child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SingleChildScrollView(
                  child: Column(
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    "Nueva contraseña",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Ingrese su nueva contraseña'),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Contraseña nueva',
                          obscureText: true,
                          validator: _validatePassword,
                          focusNode: _passwordFocusNode, // Asigna el FocusNode
                        ),
                        // Agrega las instrucciones de ayuda aquí
                        const SizedBox(height: 10),
                        const SizedBox(height: 8),
                        if (showRequirements) ...[
                          // Mostrar requisitos solo cuando showRequirements es true
                          const Row(
                            children: [
                              Text(
                                'La contraseña debe tener al menos:',
                                style:
                                    TextStyle(fontSize: 12, color: Colors.grey),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildRequirement(
                              'Al menos 8 caracteres', hasMinLength),
                          _buildRequirement(
                              'Una letra mayúscula', hasUppercase),
                          _buildRequirement('Un número', hasDigits),
                          _buildRequirement(
                              'Un carácter especial', hasSpecialCharacters),
                        ],
                        const SizedBox(height: 20),
                        CustomTextField(
                          controller: _confirmPasswordController,
                          label: 'Confirmar nueva contraseña',
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
                        const SizedBox(height: 50),
                        CustomButton(
                          onPressed: () => _changePassword(context),
                          text: 'Cambiar contraseña',
                          type: ButtonType.primary,
                        ),
                      ],
                    ),
                  ),
                  
                ],
              ))),
        )));
  }
}

Widget _buildRequirement(String text, bool isValid) {
  return Row(
    children: [
      Icon(
        isValid ? Icons.check_circle : Icons.cancel,
        color: isValid ? Colors.green : Colors.red,
        size: 18,
      ),
      const SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: isValid ? Colors.green : Colors.grey,
        ),
      ),
    ],
  );
}

// class NoAccountText extends StatelessWidget {
//   const NoAccountText({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         const Text(
//           "¿No tienes una cuenta? ",
//           style: TextStyle(color: Color(0xFF757575)),
//         ),
//         GestureDetector(
//           onTap: () {
//             // Handle navigation to Sign Up
//           },
//           child: const Text(
//             "Regístrate",
//             style: TextStyle(
//               color: Colors.blue,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
