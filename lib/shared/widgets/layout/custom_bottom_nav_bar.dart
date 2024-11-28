import 'package:flutter/material.dart';
import 'package:hola_mundo/config/api_config.dart';
import 'package:hola_mundo/core/constants/constants.dart';
import 'package:hola_mundo/modules/account/screens/account_settings_screen.dart';
import 'package:hola_mundo/modules/home/screens/home_screen.dart';
import 'package:hola_mundo/modules/sales/screens/sales_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavBar({
    required this.currentIndex,
  });

  void _changeScreen(BuildContext context, int index) {
    if (index == currentIndex) {
      return;
    }
    switch (index) {
      case Constants.menuIndexHome:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
        break;
      case Constants.menuIndexProducts:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                ProductScreen(), // Pantalla con las opciones de CRUD para productos
          ),
        );
        break;
      case Constants.menuIndexSales:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SalesScreen(), // Nueva pantalla de ventas
          ),
        );
        break;
      case Constants.menuIndexAccount:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AccountSettingsScreen(), // Nueva pantalla de ventas
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        _changeScreen(context, index);
      },
      showSelectedLabels: false,
      showUnselectedLabels: false,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home_filled),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          activeIcon: Icon(Icons.inventory_2),
          label: 'Productos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.point_of_sale_outlined),
          activeIcon: Icon(Icons.point_of_sale),
          label: 'Vender',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Perfil',
        ),
      ],
    );
  }
}
