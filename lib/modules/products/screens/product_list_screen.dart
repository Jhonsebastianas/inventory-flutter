import 'package:flutter/material.dart';
import 'package:hola_mundo/modules/products/widgets/product_card_widget.dart';
import 'package:hola_mundo/shared/models/product.dart';
import 'package:hola_mundo/shared/widgets/forms/text_fields/custom_search_field.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../../../shared/providers/product_provider.dart';
import 'product_form_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  _ProductListScreenState createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  String _searchQuery = ""; // Consulta de búsqueda
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    productProvider
        .fetchProducts(); // Llama a la función para obtener productos
  }

  void _searchProduct(String query) {
    setState(() {
      _searchQuery = query.toLowerCase(); // Actualiza la consulta de búsqueda
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context, listen: true);

    // Filtrar productos en función de la búsqueda
    final filteredProducts = productProvider.products
        .where((product) => product.name.toLowerCase().contains(_searchQuery))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              "Tus productos",
              style: TextStyle(color: Colors.black),
            ),
            Text(
              "${filteredProducts.length} productos",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProductFormScreen(),
                ),
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CustomSearchField(
              controller: _searchController,
              hintText: 'Buscar producto',
              onChanged: (query) {
                _searchProduct(query);
              },
              onClear: () {
                _searchController.clear();
                _searchProduct('');
              },
            ),
          ),
          Expanded(
            child: productProvider.isLoading
                ? _buildShimmerLoading()
                : // Mostrar shimmer si está cargando
                _buildProductList(
                    filteredProducts), // Mostrar lista de productos,
          )
        ],
      ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      itemCount: 5, // Número de elementos de esqueleto para mostrar
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.6,
                    height: 65,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: 14,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 14,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return const Center(child: Text('No se encontraron productos.'));
    } else {
      return ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ProductTile(
            product: product,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProductFormScreen(product: product),
                ),
              );
            },
            onDelete: () {
              final productProvider =
                  Provider.of<ProductProvider>(context, listen: false);
              productProvider.deleteProduct(product.id);
            },
          );
        },
      );
    }
  }
}

