import 'package:flutter/material.dart';
import 'package:hola_mundo/config/api_config.dart';
import 'package:hola_mundo/core/constants/constants.dart';
import 'package:hola_mundo/routes/app_routes.dart';
import 'package:hola_mundo/shared/providers/product_provider.dart';
import 'package:hola_mundo/modules/products/screens/product_form_screen.dart';
import 'package:hola_mundo/modules/sales/screens/sales_list_screen.dart';
import 'package:hola_mundo/shared/widgets/layout/custom_bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/screens/login_screen.dart';
import '../../products/screens/product_list_screen.dart';
import '../../sales/screens/sales_screen.dart'; // Nueva pantalla de ventas

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('names'); // Cargar el nombre
    });
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('names'); // Eliminar el nombre al cerrar sesión
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  _onTap(String routeName) {
    Navigator.pushNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Inventarios'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mostrar el mensaje de bienvenida
            if (_userName != null) // Verificar si el nombre está disponible
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Saludos, $_userName!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Expanded(
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Dos tarjetas por fila
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                children: <Widget>[
                  // Card para acceder a productos
                  _buildCard(
                    context,
                    title: 'Productos',
                    icon: Icons.inventory_2,
                    color: Colors.blueAccent,
                    onTap: () {
                      AppRoutes.onTabChangeRoute(
                          context, AppRoutes.products);
                    },
                  ),
                  // Card para acceder a ventas
                  _buildCard(
                    context,
                    title: 'Ventas',
                    icon: Icons.point_of_sale,
                    color: Colors.deepPurpleAccent,
                    onTap: () {
                      AppRoutes.onTabChangeRoute(
                          context, AppRoutes.sales);
                    },
                  ),
                  _buildCard(
                    context,
                    title: 'Histórico ventas',
                    icon: Icons.history,
                    color: Colors.grey,
                    onTap: () {
                      AppRoutes.onTabChangeRoute(
                          context, AppRoutes.salesHistory);
                    },
                  ),
                  _buildCard(
                    context,
                    title: 'Estado financiero',
                    icon: Icons.monetization_on,
                    color: Colors.green,
                    onTap: () {
                      AppRoutes.onTabChangeRoute(
                          context, AppRoutes.finances);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: Constants.menuIndexHome,
      ),
    );
  }

  // Método para construir las tarjetas
  Widget _buildCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Pantalla de productos con opciones de CRUD y un botón de volver
class ProductScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Productos'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Botón para regresar al Home
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Dos tarjetas por fila
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          children: <Widget>[
            _buildCard(
              context,
              title: 'Crear Producto',
              icon: Icons.add_box,
              color: Colors.green,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductFormScreen(),
                  ),
                );
              },
            ),
            _buildCard(
              context,
              title: 'Ver Productos',
              icon: Icons.list,
              color: Colors.blue,
              onTap: () {
                // update products
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductListScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNavBar(
        currentIndex: Constants.menuIndexProducts,
      ),
    );
  }

  // Reutilizamos el mismo método de _buildCard para construir las tarjetas
  Widget _buildCard(BuildContext context,
      {required String title,
      required IconData icon,
      required Color color,
      required Function() onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 5,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                size: 40,
                color: Colors.white,
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
