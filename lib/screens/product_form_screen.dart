import 'package:flutter/material.dart';
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
    } else {
      _name = '';
      _description = '';
      _price = 0.0;
      _stock = 0;
      _percentageTax = 0;
      _stockDetails = [];
    }
  }

  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (widget.product == null) {
        final newProduct = Product(
          id: DateTime.now().toString(),
          name: _name,
          description: _description,
          price: _price,
          stock: _stock,
          percentageTax: _percentageTax,
          stockDetails: _stockDetails,
        );
        Provider.of<ProductProvider>(context, listen: false)
            .addProduct(newProduct);
      } else {
        final updatedProduct = Product(
          id: widget.product!.id,
          name: _name,
          description: _description,
          price: _price,
          stock: _stock,
          percentageTax: _percentageTax,
          stockDetails: _stockDetails,
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
    for (var stockSum in _stockDetails) {
      totalStock += stockSum.quantity;
    }
    setState(() {
      _stock = totalStock;
      print(_stock);
    });
  }

  // Mostrar el formulario para añadir o editar detalles del inventario en una ventana emergente
  void _showStockDetailDialog({StockDetail? stockDetail, int? index}) {
    final _providerController = TextEditingController(text: stockDetail?.provider ?? '');
    final _priceController = TextEditingController(text: stockDetail?.purchasePrice.toString() ?? '0.0');
    final _quantityController = TextEditingController(text: stockDetail?.quantity.toString() ?? '0');

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(stockDetail == null ? 'Añadir Detalle de Inventario' : 'Modificar Detalle de Inventario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _providerController,
                decoration: const InputDecoration(labelText: 'Proveedor (opcional)'),
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Precio de compra'),
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
                      provider: provider,
                      purchasePrice: price,
                      quantity: quantity,
                    );
                  } else {
                    // Añadir nuevo detalle
                    _stockDetails.add(
                      StockDetail(
                        id: (_stockDetails.length + 1).toString(),
                        provider: provider,
                        purchasePrice: price,
                        quantity: quantity,
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
        title: Text(widget.product == null ? 'Agregar Producto' : 'Editar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Nombre'),
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
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Descripción (opcional)'),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              TextFormField(
                initialValue: _price.toString(),
                decoration: const InputDecoration(labelText: 'Precio'),
                keyboardType: TextInputType.number,
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
              TextFormField(
                initialValue: _percentageTax.toString(),
                decoration: const InputDecoration(labelText: 'IVA (opcional)'),
                keyboardType: TextInputType.number,
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
                    return ListTile(
                      title: Text('Proveedor: ${_stockDetails[index].provider}, Precio: ${_stockDetails[index].purchasePrice}, Cantidad: ${_stockDetails[index].quantity}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              // Abrir ventana para modificar detalle
                              _showStockDetailDialog(
                                stockDetail: _stockDetails[index],
                                index: index,
                              );
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              setState(() {
                                _stockDetails.removeAt(index);
                                updateStock();
                              });
                            },
                          ),
                        ],
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
