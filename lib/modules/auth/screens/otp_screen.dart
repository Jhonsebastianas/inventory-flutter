import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hola_mundo/config/api_config.dart';
import 'package:hola_mundo/shared/widgets/custom_button.dart';
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
  }

  @override
  void dispose() {
    _pin1Controller.dispose();
    _pin2Controller.dispose();
    _pin3Controller.dispose();
    _pin4Controller.dispose();
    super.dispose();
  }

  void _resendOtp() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final response = await http.post(
          Uri.parse('$baseUrl/login/sendVerificationCodeRecoverAccount'),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode(<String, String>{
            'email': _email ?? '',
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
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Verificación OTP",
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      "Verificación OTP",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        "Enviamos su código de verificación a ${_email} \n\n Este código caducará en 5 minutos",
                        textAlign: TextAlign.center),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.1),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildOtpBox(context, "pin1", _pin1Controller),
                              _buildOtpBox(context, "pin2", _pin2Controller),
                              _buildOtpBox(context, "pin3", _pin3Controller),
                              _buildOtpBox(context, "pin4", _pin4Controller),
                            ],
                          ),
                          const SizedBox(height: 24),
                          CustomButton(
                            onPressed: () => _verifyOtp(context),
                            text: 'Continuar',
                            type: ButtonType.primary,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                    CustomButton(
                      onPressed: _resendOtp,
                      text: 'Volver a enviar código de verificación',
                      type: ButtonType.flat,
                    ),
                  ],
                ),
              )),
        )));
  }

  Widget _buildOtpBox(BuildContext context, String fieldName,
      TextEditingController _pinController) {
    const authOutlineInputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF757575)),
      borderRadius: BorderRadius.all(Radius.circular(12)),
    );

    return SizedBox(
      height: 68,
      width: 64,
      child: TextFormField(
        controller: _pinController,
        onSaved: (pin) {},
        onChanged: (value) {
          if (value.isNotEmpty) {
            FocusScope.of(context).nextFocus();
          }
        },
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
            hintText: "0",
            hintStyle: const TextStyle(color: Color(0xFF757575)),
            border: authOutlineInputBorder,
            enabledBorder: authOutlineInputBorder,
            focusedBorder: authOutlineInputBorder.copyWith(
                borderSide: const BorderSide(color: Colors.blue))),
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
