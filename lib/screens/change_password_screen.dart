import 'package:flutter/material.dart';


class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {

  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _changePassword(BuildContext context) {
    if (_passwordController.text == _confirmPasswordController.text) {
      // Lógica para cambiar la contraseña del usuario usando el email proporcionado
      Navigator.popUntil(context, ModalRoute.withName('/login'));
    } else {
      // Mostrar error si las contraseñas no coinciden
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cambiar contraseña"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Contraseña nueva'),
              obscureText: true,
            ),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirmar nueva contraseña'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _changePassword(context),
              child: Text("Cambiar contraseña"),
            ),
          ],
        ),
      ),
    );
  }
}
