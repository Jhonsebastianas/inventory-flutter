import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpForm extends StatelessWidget {
  const OtpForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Form(
        child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildOtpBox(context, "pin1"),
        _buildOtpBox(context, "pin2"),
        _buildOtpBox(context, "pin3"),
        _buildOtpBox(context, "pin4"),
      ],
    ));
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
