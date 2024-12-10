import 'package:flutter/material.dart';
import 'package:hola_mundo/shared/models/product.dart';
import 'package:hola_mundo/shared/widgets/custom_button.dart';
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
                  builder: (context) => ProductFormScreen(),
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

class ProductTile extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ProductTile({
    Key? key,
    required this.product,
    this.onTap,
    this.onDelete,
  }) : super(key: key);

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmación'),
        content:
            const Text('¿Estás seguro de que deseas eliminar este producto?'),
        actions: [
          CustomButton(
            onPressed: () => Navigator.of(ctx).pop(),
            type: ButtonType.flat,
            text: 'Cancelar',
          ),
          CustomButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              if (onDelete != null) {
                onDelete!();
              }
            },
            type: ButtonType.flatDanger,
            text: 'Eliminar',
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(product.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.red.shade200,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 30,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirmación'),
            content: const Text(
                '¿Estás seguro de que deseas eliminar este producto?'),
            actions: [
              CustomButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                type: ButtonType.flat,
                text: 'Cancelar',
              ),
              CustomButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                  if (onDelete != null) {
                    onDelete!();
                  }
                },
                type: ButtonType.flatDanger,
                text: 'Eliminar',
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        if (onDelete != null) {
          onDelete!();
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Imagen de Producto o un Placeholder
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: Icon(
                    Icons.inventory_2,
                    color: Colors.grey.shade600,
                    size: 40,
                  ),
                ),
                const SizedBox(width: 16),

                // Información del Producto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildDetailSale(
                        context,
                        icon: Icons.inventory,
                        label: 'Existencias:',
                        value: "${product.stock}",
                      ),
                      const SizedBox(height: 4),
                      _buildDetailSale(
                        context,
                        icon: Icons.attach_money,
                        label: 'Venta:',
                        value: '\$${product.price.toStringAsFixed(2)}',
                      ),
                      const SizedBox(height: 4),
                      _buildDetailSale(
                        context,
                        icon: Icons.calculate_outlined,
                        label: 'Impuestos (IVA):',
                        value: '${product.percentageTax}%',
                      ),
                    ],
                  ),
                ),

                // Botón de Eliminar
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.red.shade300,
                  ),
                  onPressed: () => _showDeleteConfirmation(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSale(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade400),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
