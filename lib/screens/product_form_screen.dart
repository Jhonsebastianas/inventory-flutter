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

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _name = widget.product!.name;
      _description = widget.product!.description;
      _price = widget.product!.price;
      _stock = widget.product!.stock;
    } else {
      _name = '';
      _description = '';
      _price = 0.0;
      _stock = 0;
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
        );
        Provider.of<ProductProvider>(context, listen: false)
            .updateProduct(widget.product!.id, updatedProduct);
      }
      Navigator.of(context).pop();
    }
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
                decoration: const InputDecoration(labelText: 'Descripción'),
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
                initialValue: _stock.toString(),
                decoration: const InputDecoration(labelText: 'En inventario'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _stock = int.parse(value!);
                },
                validator: (value) {
                  if (value == null || int.tryParse(value) == null) {
                    return 'Por favor ingrese un precio válido.';
                  }
                  return null;
                },
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
