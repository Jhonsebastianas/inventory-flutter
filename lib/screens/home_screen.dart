import 'package:flutter/material.dart';
import 'package:hola_mundo/providers/product_provider.dart';
import 'package:hola_mundo/screens/product_form_screen.dart';
import 'package:hola_mundo/screens/sales_list_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'product_list_screen.dart';
import 'sales_screen.dart'; // Nueva pantalla de ventas

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? _userName;

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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => ProductScreen(), // Pantalla con las opciones de CRUD para productos
                        ),
                      );
                    },
                  ),
                  // Card para acceder a ventas
                  _buildCard(
                    context,
                    title: 'Ventas',
                    icon: Icons.point_of_sale,
                    color: Colors.deepPurpleAccent,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SalesScreen(), // Nueva pantalla de ventas
                        ),
                      );
                    },
                  ),
                  _buildCard(
                    context,
                    title: 'Histórico ventas',
                    icon: Icons.history,
                    color: Colors.grey,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => SalesListScreen(), // Nueva pantalla de ventas
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
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
            crossAxisCount: 2,  // Dos tarjetas por fila
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
            _buildCard(
              context,
              title: 'Modificar Producto',
              icon: Icons.edit,
              color: Colors.orange,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => ProductListScreen(),
                  ),
                );
              },
            ),
            _buildCard(
              context,
              title: 'Eliminar Producto',
              icon: Icons.delete,
              color: Colors.red,
              onTap: () {
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
