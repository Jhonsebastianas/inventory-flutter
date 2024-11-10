import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'change_password_screen.dart';

class OtpScreen extends StatelessWidget {
  final String email;
  OtpScreen({required this.email});

  void _verifyOtp(BuildContext context) {
    // Aquí iría la lógica para verificar el OTP ingresado
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ChangePasswordScreen(email: email)),
    );
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
            Text("Código de verificación (OTP) ha sido enviado a $email"),
            Form(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildOtpBox(context, "pin1"),
                _buildOtpBox(context, "pin2"),
                _buildOtpBox(context, "pin3"),
                _buildOtpBox(context, "pin4"),
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

  Widget _buildOtpBox(BuildContext context, String fieldName) {
    return SizedBox(
      height: 68,
      width: 64,
      child: TextFormField(
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
