import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:hola_mundo/shared/widgets/custom_button.dart';
import 'package:hola_mundo/shared/widgets/forms/text_fields/custom_number_field.dart';
import 'package:hola_mundo/shared/widgets/forms/text_fields/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../../../shared/providers/product_provider.dart';
import '../../../shared/models/product.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;
  const ProductFormScreen({Key? key, this.product}) : super(key: key);

  @override
  _ProductFormScreenState createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late double _price;
  late double _stock;
  late double _percentageTax;
  List<StockDetail> _stockDetails = [];
  late double _weightedAveragePurchasePrice;

  bool isModifyForm = false;

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name = widget.product!.name;
      _description = widget.product!.description;
      _price = widget.product!.price;
      _stock = widget.product!.stock;
      _percentageTax = widget.product!.percentageTax;
      _stockDetails = widget.product!.stockDetails;
      _weightedAveragePurchasePrice =
          widget.product!.weightedAveragePurchasePrice;
    } else {
      _name = '';
      _description = '';
      _price = 0.0;
      _stock = 0.0;
      _percentageTax = 0;
      _stockDetails = [];
      _weightedAveragePurchasePrice = 0.0;
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (widget.product == null) {
        final newProduct = Product(
          id: DateTime.now().toString(),
          businessId: DateTime.now().toString(),
          name: _name,
          description: _description,
          price: _price,
          stock: _stock,
          percentageTax: _percentageTax,
          stockDetails: _stockDetails,
          weightedAveragePurchasePrice: _weightedAveragePurchasePrice,
        );
        Provider.of<ProductProvider>(context, listen: false)
            .addProduct(newProduct);
      } else {
        final updatedProduct = Product(
          id: widget.product!.id,
          businessId: widget.product!.businessId,
          name: _name,
          description: _description,
          price: _price,
          stock: _stock,
          percentageTax: _percentageTax,
          stockDetails: _stockDetails,
          weightedAveragePurchasePrice: _weightedAveragePurchasePrice,
        );
        Provider.of<ProductProvider>(context, listen: false)
            .updateProduct(widget.product!.id, updatedProduct);
      }
      Navigator.of(context).pop();
    }
  }

  // STOCK INFORMATION
  void updateStock() {
    double totalStock = 0;
    double sumTotalPurchasePrices = 0;
    for (var stockSum in _stockDetails) {
      totalStock += stockSum.quantity;
      sumTotalPurchasePrices += stockSum.purchasePrice * stockSum.quantity;
    }
    setState(() {
      _stock = totalStock;
      _weightedAveragePurchasePrice = sumTotalPurchasePrices / totalStock;
    });
  }

  // Mostrar el formulario para añadir o editar detalles del inventario en una ventana emergente
  void _showStockDetailDialog({StockDetail? stockDetail, int? index}) {
    final _providerController =
        TextEditingController(text: stockDetail?.provider ?? '');
    final _priceController = TextEditingController(
        text: stockDetail?.purchasePrice.toString() ?? '0.0');
    final _quantityController =
        TextEditingController(text: stockDetail?.quantity.toString() ?? '0');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(stockDetail == null
              ? 'Añadir Detalle de Inventario'
              : 'Modificar Detalle de Inventario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: _providerController,
                label: 'Proveedor (opcional)',
              ),
              SizedBox(height: 20),
              CustomNumberField(
                controller: _priceController,
                label: 'Precio de compra (unitario)',
              ),
              SizedBox(height: 20),
              CustomNumberField(
                controller: _quantityController,
                label: 'Cantidad',
              ),
            ],
          ),
          actions: [
            CustomButton(
              onPressed: () => Navigator.of(ctx).pop(),
              text: 'Cancelar',
              type: ButtonType.flat,
            ),
            CustomButton(
              onPressed: () {
                final provider = _providerController.text;
                final price = double.tryParse(_priceController.text) ?? 0.0;
                final quantity =
                    double.tryParse(_quantityController.text) ?? 0.0;
                if (quantity == 0 || price == 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Diigencie la información')),
                  );
                  return;
                }

                setState(() {
                  if (index != null) {
                    // Editar detalle existente
                    _stockDetails[index] = StockDetail(
                      id: stockDetail!.id,
                      totalGrossProfit: stockDetail!.totalGrossProfit,
                      provider: provider,
                      purchasePrice: price,
                      quantity: quantity,
                      quantityPurchased: stockDetail!.quantityPurchased,
                      totalPurchasePrice: quantity * price,
                    );
                  } else {
                    print("index == null");
                    // Añadir nuevo detalle
                    _stockDetails.add(
                      StockDetail(
                        id: (_stockDetails.length + 1).toString(),
                        totalGrossProfit: 0.0,
                        provider: provider,
                        purchasePrice: price,
                        quantity: quantity,
                        quantityPurchased: quantity,
                        totalPurchasePrice: quantity * price,
                      ),
                    );
                  }
                  updateStock();
                });

                Navigator.of(ctx).pop();
              },
              text: 'Agregar',
              type: ButtonType.primary,
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteDetail(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Eliminar Detalle'),
          content: const Text(
            '¿Estás seguro de que deseas eliminar este detalle del inventario?',
          ),
          actions: [
            CustomButton(
              onPressed: () => Navigator.of(context).pop(),
              type: ButtonType.flat,
              text: 'Cancelar',
            ),
            CustomButton(
              onPressed: () {
                setState(() {
                  _stockDetails.removeAt(index);
                  updateStock();
                });
                Navigator.of(context).pop();
              },
              type: ButtonType.flatDanger,
              text: 'Eliminar',
            ),
          ],
        );
      },
    );
  }

  // Helper para crear elementos de detalle
  Widget _buildDetailItem(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade400),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, Object? result) async {
          if (didPop) {
            return;
          }
          if (!isModifyForm) {
            Navigator.pop(context, result);
            return;
          }
          final bool shouldPop =
              await _showExitConfirmationDialog(context) ?? false;
          if (context.mounted && shouldPop) {
            Navigator.pop(context, result);
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.product == null
                ? 'Agregar Producto'
                : 'Editar Producto'),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Información del Producto',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      initialValue: _name,
                      label: 'Nombre del Producto',
                      onSaved: (value) => _name = value!,
                      validator: (value) {
                        if (value == null || value.isEmpty)
                          return 'Por favor ingrese un nombre.';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    CustomTextField(
                      initialValue: _description,
                      label: 'Descripción (opcional)',
                      onSaved: (value) => _description = value!,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: CustomNumberField(
                            initialValue: _price.toString(),
                            label: 'Precio de Venta',
                            allowDecimals: true,
                            onSaved: (value) => _price = double.parse(value!),
                            validator: (value) {
                              if (value == null ||
                                  double.tryParse(value) == null) {
                                return 'Por favor ingrese un precio válido.';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: CustomNumberField(
                            initialValue: _percentageTax.toString(),
                            allowDecimals: true,
                            label: 'IVA (%)',
                            onSaved: (value) =>
                                _percentageTax = double.parse(value!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(thickness: 1),
                    const SizedBox(height: 10),
                    Text(
                      'Inventario',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text('En inventario: $_stock',
                              style: const TextStyle(fontSize: 16)),
                        ),
                        Expanded(
                          child: Text(
                            'Precio promedio: \$${_weightedAveragePurchasePrice.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Añadir inventario',
                      type: ButtonType.outline,
                      onPressed: () => _showStockDetailDialog(),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    const SizedBox(height: 20),
                    if (_stockDetails.isNotEmpty)
                      ExpansionTile(
                        initiallyExpanded: true,
                        title: Text(
                          'Detalles de inventario',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        children: _stockDetails.map((stockDetail) {
                          final index = _stockDetails.indexOf(stockDetail);
                          print("-----------------------||");
                          print(index);
                          print(_stockDetails[0]);
                          print(_stockDetails[0].provider);
                          return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                              child: InkWell(
                                onTap: () => _showStockDetailDialog(
                                  stockDetail: stockDetail,
                                  index: index,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Encabezado con inicial y nombre del proveedor
                                      Row(
                                        children: [
                                          // Avatar con la inicial del proveedor
                                          CircleAvatar(
                                            radius: 24,
                                            backgroundColor:
                                                Colors.blue.shade100,
                                            child: Text(
                                              (stockDetail.provider
                                                          .isNotEmpty &&
                                                      stockDetail.provider[0]
                                                          .isNotEmpty
                                                  ? stockDetail.provider[0]
                                                      .toUpperCase()
                                                  : 'I'),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 16),

                                          // Nombre del proveedor
                                          Text(
                                            stockDetail.provider,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),

                                          // Botones de acción (edit y delete) alineados a la derecha
                                          const Spacer(), // Asegura que los botones se alineen a la derecha
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_forever,
                                                color: Colors.red,
                                                size: 28),
                                            onPressed: () =>
                                                _confirmDeleteDetail(index),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      // Detalles del inventario
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildDetailItem(
                                            context,
                                            icon: Icons.attach_money,
                                            label: 'Precio Compra',
                                            value:
                                                '\$${stockDetail.purchasePrice.toStringAsFixed(2)}',
                                          ),
                                          _buildDetailItem(
                                            context,
                                            icon: Icons.inventory,
                                            label: 'En Inventario',
                                            value: '${stockDetail.quantity}',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          _buildDetailItem(
                                            context,
                                            icon: Icons.shopping_cart,
                                            label: 'Comprado',
                                            value:
                                                '${stockDetail.quantityPurchased}',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                  ),
                                ),
                              ));
                        }).toList(),
                      ),
                    const SizedBox(height: 20),
                    Center(
                      child: CustomButton(
                        onPressed: _saveForm,
                        text: 'Guardar Producto',
                        type: ButtonType.primary,
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: SpeedDial(
            animatedIcon: AnimatedIcons.menu_close,
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            overlayColor: Colors.black,
            overlayOpacity: 0.3,
            children: [
              SpeedDialChild(
                label: 'Añadir inventario',
                child: const Icon(Icons.add),
                onTap: () => _showStockDetailDialog(),
              ),
            ],
          ),
        ));
  }

  Future<bool?> _showExitConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¿Salir sin guardar?'),
          content: const Text(
            'Tienes cambios sin guardar. ¿Estás seguro de que deseas salir?',
          ),
          actions: [
            CustomButton(
                text: 'Cancelar',
                type: ButtonType.flatDanger,
                onPressed: () => Navigator.of(context).pop(false)),
            CustomButton(
              text: 'Salir',
              type: ButtonType.primary,
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }
}
