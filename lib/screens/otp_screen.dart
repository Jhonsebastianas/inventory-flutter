import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hola_mundo/config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'change_password_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class OtpScreen extends StatefulWidget {
  @override
  _OtpScreenState createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  String? _email;
  String? _token;
  final String baseUrl = ApiConfig.baseUrl;
  final _formKey = GlobalKey<FormState>();

  final _pin1Controller = TextEditingController();
  final _pin2Controller = TextEditingController();
  final _pin3Controller = TextEditingController();
  final _pin4Controller = TextEditingController();

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

  Future<void> _saveSession(token, email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token_recover', token);
    await prefs.setString('email', email);
  }

  void _verifyOtp(BuildContext context) async {
    if (_formKey.currentState?.validate() ?? false) {
      String completedPin = _pin1Controller.text +
          _pin2Controller.text +
          _pin3Controller.text +
          _pin4Controller.text;

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/login/verifyRecoveryCode'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': _email ?? '',
            'code': completedPin,
            'token': _token ?? '',
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
            MaterialPageRoute(builder: (context) => ChangePasswordScreen()),
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
    // Aquí iría la lógica para verificar el OTP ingresado
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //       builder: (context) => ChangePasswordScreen(email: _email)),
    // );
  }

  @override
  void dispose() {
    _pin1Controller.dispose();
    _pin2Controller.dispose();
    _pin3Controller.dispose();
    _pin4Controller.dispose();
    super.dispose();
  }

  void _resendOtp() {
    // Lógica para reenviar el OTP
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ingresar OTP"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Código de verificación (OTP) ha sido enviado a ${_email}"),
            Form(
                key: _formKey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildOtpBox(context, "pin1", _pin1Controller),
                    _buildOtpBox(context, "pin2", _pin2Controller),
                    _buildOtpBox(context, "pin3", _pin3Controller),
                    _buildOtpBox(context, "pin4", _pin4Controller),
                  ],
                )),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _verifyOtp(context),
              child: Text("Verificar"),
            ),
            TextButton(
              onPressed: _resendOtp,
              child: Text("Volver a enviar código de verificación (OTP)"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtpBox(BuildContext context, String fieldName,
      TextEditingController _pinController) {
    return SizedBox(
      height: 68,
      width: 64,
      child: TextFormField(
        controller: _pinController,
        onSaved: (pin1) {},
        onChanged: (value) {
          if (value.length == 1) {
            FocusScope.of(context).nextFocus();
          }
        },
        decoration: InputDecoration(hintText: "0"),
        style: Theme.of(context).textTheme.headlineLarge,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
      ),
    );
  }
}
