import 'package:flutter/material.dart';
import 'package:hola_mundo/modules/account/widgets/setting_item.dart';

class AccountSettingsScreen extends StatelessWidget {
  
  const AccountSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Account Settings',
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: ListView(
        children: const [
          SettingItem(
            icon: Icons.person_outline,
            title: 'Profile Information',
            subtitle: 'Change your account information',
          ),
          SettingItem(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Change your password',
          ),
          SettingItem(
            icon: Icons.credit_card_outlined,
            title: 'Payment Methods',
            subtitle: 'Add your credit & debit cards',
          ),
          SettingItem(
            icon: Icons.location_on_outlined,
            title: 'Locations',
            subtitle: 'Add or remove your delivery locations',
          ),
          SettingItem(
            icon: Icons.link,
            title: 'Add Social Account',
            subtitle: 'Add Facebook, Twitter etc',
          ),
          SettingItem(
            icon: Icons.share_outlined,
            title: 'Refer to Friends',
            subtitle: 'Get \$10 for referring friends',
          ),
        ],
      ),
    );
  }
}