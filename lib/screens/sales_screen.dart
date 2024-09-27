import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Importa image_picker
import 'package:hola_mundo/models/product.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:hola_mundo/models/sale.dart';
import 'package:hola_mundo/providers/product_provider.dart'; // Ajusta el import a tu estructura de carpetas

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  final String EFECTIVO = "Efectivo";
  List<SaleProduct> _selectedProducts = []; // Productos seleccionados para la venta
  double _totalAmount = 0.0;
  List<PaymentMethod> _paymentMethods = [new PaymentMethod(type: "Efectivo", amount: 0)];
  XFile? _receiptFile; // Cambia a XFile para trabajar con image_picker
  final ImagePicker _picker = ImagePicker(); // Instancia de ImagePicker

  // Método para buscar productos
  void _searchProduct(String query) {
    Provider.of<ProductProvider>(context, listen: false).searchProducts(query);
  }

  // Método para actualizar el total
  void _updateTotal() {
    double total = 0;
    for (var product in _selectedProducts) {
      total += product.price * product.quantity;
    }
    PaymentMethod efectivoMethod = _paymentMethods.first;
    setState(() {
      _totalAmount = total;
      try {
        efectivoMethod.amount = _totalAmount;
      } catch (e) {}
      
    });
  }

  // Método para seleccionar un producto
  void _selectProduct(Product product) {
    for (var currentProduct in _selectedProducts) {
      if (product.id == currentProduct.id) {
        return;
      }
    }
    SaleProduct saleProduct = new SaleProduct(id: product.id, 
        name: product.name, price: product.price, quantity: 1);
    setState(() {
      _selectedProducts.add(saleProduct);
    });
    _updateTotal();
    _editProduct(saleProduct);
  }

  void _deleteProduct(SaleProduct product) {
    setState(() {
      _selectedProducts.removeWhere((prod) => prod.id == product.id);
    });
    _updateTotal();
  }

  // Método para editar cantidad y precio
  void _editProduct(SaleProduct product) {
    TextEditingController priceController = TextEditingController(text: product.price.toString());
    TextEditingController quantityController = TextEditingController(text: product.quantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Product'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  product.price = double.parse(priceController.text);
                  product.quantity = int.parse(quantityController.text);
                });
                _updateTotal();
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _editPaymentMethod(PaymentMethod paymentMethod) {
    TextEditingController typeController = TextEditingController(text: paymentMethod.type);
    TextEditingController amountController = TextEditingController(text: paymentMethod.amount.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: InputDecoration(labelText: 'Payment Type'),
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  paymentMethod.type = typeController.text;
                  paymentMethod.amount = double.parse(amountController.text);
                });
                Navigator.pop(context);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _deletePaymentMethod(PaymentMethod paymentMethod) {
    setState(() {
      _paymentMethods.removeWhere((method) => method.type == paymentMethod.type);
    });
    if (_paymentMethods.length == 1) {
      _updateTotal();
    }
  }

  // Método para añadir un método de pago
  void _addPaymentMethod() {
    TextEditingController typeController = TextEditingController();
    String? selectedPaymentType; // Variable de estado para el tipo de pago
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Payment Method'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedPaymentType,
                decoration: InputDecoration(labelText: 'Payment Type'),
                items: [
                  DropdownMenuItem(
                    child: Text('Efectivo'),
                    value: 'Efectivo',
                  ),
                  DropdownMenuItem(
                    child: Text('Transferencia'),
                    value: 'Transferencia',
                  ),
                  DropdownMenuItem(
                    child: Text('Tarjeta'),
                    value: 'Tarjeta',
                  ),
                  DropdownMenuItem(
                    child: Text('Otro'),
                    value: 'Otro',
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedPaymentType = value; // Actualiza el estado con el tipo de pago seleccionado
                  });
                },
              ),
              TextField(
                controller: amountController,
                decoration: InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _paymentMethods.add(
                    PaymentMethod(
                      type: selectedPaymentType.toString(),
                      amount: double.parse(amountController.text),
                    ),
                  );
                });
                Navigator.pop(context);
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  // Método para tomar una foto como comprobante de pago
  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100, // Puedes ajustar la calidad de la imagen
    );

    if (photo != null) {
      setState(() {
        _receiptFile = photo; // Asigna el archivo de la foto
      });
      // Aquí puedes agregar código para subir la foto automáticamente
      // await _uploadReceipt(photo); // Descomenta y implementa tu método de subida
    }
  }

  // Método para completar la venta
  void _completeSale() {
    double totalPaid = _paymentMethods.fold(0.0, (sum, method) => sum + method.amount);

    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No products selected.')),
      );
      return;
    }

    if (totalPaid < _totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment does not cover the total amount.')),
      );
      return;
    }

    if (totalPaid > _totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('The payment covers more than the total amount.')),
      );
      return;
    }

    // Aquí podrías guardar la venta en MongoDB o en tu base de datos local.
  }

  @override
  Widget build(BuildContext context) {
    // Obtenemos el ProductProvider para acceder a los productos filtrados
    var productProvider = Provider.of<ProductProvider>(context);
    var filteredProducts = productProvider.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Sales'),
      ),
      body: Column(
        children: [
          // Buscar producto
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search product',
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (query) {
                _searchProduct(query);
              },
            ),
          ),

          // Mostrar productos filtrados
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('Price: \$${product.price}'),
                  onTap: () => _selectProduct(product),
                );
              },
            ),
          ),

          // Lista de productos seleccionados
          Expanded(
            child: ListView.builder(
              itemCount: _selectedProducts.length,
              itemBuilder: (context, index) {
                final product = _selectedProducts[index];
                return ListTile(
                  title: Text(product.name),
                  subtitle: Text('Price: \$${product.price}, Quantity: ${product.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Para que el Row no ocupe todo el ancho
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editProduct(product),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete), // Icono para eliminar
                        onPressed: () => _deleteProduct(product), // Llama a tu función para eliminar
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Mostrar total
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text('Total: \$$_totalAmount'),
          ),

          // Botón para añadir método de pago
          ElevatedButton.icon(
            onPressed: _addPaymentMethod,
            icon: Icon(Icons.payment),
            label: Text('Add Payment Method'),
          ),

          // Lista de métodos de pago
          Expanded(
            child: ListView.builder(
              itemCount: _paymentMethods.length,
              itemBuilder: (context, index) {
                final method = _paymentMethods[index];
                return ListTile(
                  title: Text('${method.type}'),
                  subtitle: Text('Amount: \$${method.amount}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // Para que el Row no ocupe todo el ancho
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => _editPaymentMethod(method),
                      ),
                      if (_paymentMethods.length > 1) IconButton(
                        icon: Icon(Icons.delete), // Icono para eliminar
                        onPressed: () => _deletePaymentMethod(method), // Llama a tu función para eliminar
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Botón para tomar foto del comprobante
          ElevatedButton.icon(
            onPressed: _takePhoto,
            icon: Icon(Icons.camera_alt),
            label: Text(_receiptFile != null ? 'Receipt Captured' : 'Take Receipt Photo'),
          ),

          // Botón para completar la venta
          ElevatedButton(
            onPressed: _completeSale,
            child: Text('Complete Sale'),
          ),
        ],
      ),
    );
  }
}
