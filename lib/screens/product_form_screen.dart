import 'package:flutter/material.dart';
import 'package:hola_mundo/widgets/forms/text_fields/custom_number_field.dart';
import 'package:hola_mundo/widgets/forms/text_fields/custom_text_field.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../models/product.dart';

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
  late int _stock;
  late double _percentageTax;
  List<StockDetail> _stockDetails = [];
  late double _weightedAveragePurchasePrice;

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
      _weightedAveragePurchasePrice = widget.product!.weightedAveragePurchasePrice;
    } else {
      _name = '';
      _description = '';
      _price = 0.0;
      _stock = 0;
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
    int totalStock = 0;
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
              TextFormField(
                controller: _providerController,
                decoration:
                    const InputDecoration(labelText: 'Proveedor (opcional)'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(
                    labelText: 'Precio de compra (unitario)'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _quantityController,
                decoration: const InputDecoration(labelText: 'Cantidad'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final provider = _providerController.text;
                final price = double.tryParse(_priceController.text) ?? 0.0;
                final quantity = int.tryParse(_quantityController.text) ?? 0;

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
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.product == null ? 'Agregar Producto' : 'Editar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 20),
              CustomTextField(
                initialValue: _name,
                label: 'Nombre',
                onSaved: (value) {
                  _name = value!;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingrese un nombre.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              CustomTextField(
                initialValue: _description,
                label: 'Descripción (opcional)',
                onSaved: (value) {
                  _description = value!;
                },
              ),
              SizedBox(height: 20),
              CustomNumberField(
                initialValue: _price.toString(),
                label: 'Precio de venta',
                onSaved: (value) {
                  _price = double.parse(value!);
                },
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Por favor ingrese un precio válido.';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              CustomNumberField(
                initialValue: _percentageTax.toString(),
                label: 'IVA (opcional)',
                onSaved: (value) {
                  _percentageTax = double.parse(value!);
                },
                validator: (value) {
                  if (value == null || double.tryParse(value) == null) {
                    return 'Por favor ingrese un precio válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Text(
                'En inventario: $_stock',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                'Precio promedio ponderado: \$${_weightedAveragePurchasePrice.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              // Botón para añadir detalles de inventario
              ElevatedButton(
                onPressed: () => _showStockDetailDialog(),
                child: const Text('Añadir detalle de inventario'),
              ),
              // Mostrar los detalles del stock en una lista
              // Mostrar los detalles del stock en una lista
              Expanded(
                child: ListView.builder(
                  itemCount: _stockDetails.length,
                  itemBuilder: (context, index) {
                    final stockDetail = _stockDetails[index];
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Información de los detalles del stock organizada en una columna
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Proveedor: ${stockDetail.provider}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                      'Precio de compra: \$${stockDetail.purchasePrice.toStringAsFixed(2)}'),
                                  const SizedBox(height: 5),
                                  Text('Unidades compradas: ${stockDetail.quantityPurchased}'),
                                  const SizedBox(height: 5),
                                  Text('En inventario: ${stockDetail.quantity}'),
                                  const SizedBox(height: 5),
                                  Text(
                                      'Ganancia bruta total: \$${stockDetail.totalGrossProfit.toStringAsFixed(2)}'),
                                ],
                              ),
                            ),
                            // Botones de acción (Editar, Eliminar)
                            Expanded(
                              flex: 1,
                              child: Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      // Abrir ventana para modificar detalle
                                      _showStockDetailDialog(
                                        stockDetail: stockDetail,
                                        index: index,
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      setState(() {
                                        _stockDetails.removeAt(index);
                                        updateStock();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}