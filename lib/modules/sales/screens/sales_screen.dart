import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:hola_mundo/modules/clients/models/register_client.dart';
import 'package:hola_mundo/modules/clients/screens/add_client_form.dart';
import 'package:hola_mundo/routes/app_routes.dart';
import 'package:hola_mundo/shared/models/file_dto.dart';
import 'package:hola_mundo/shared/services/sale_service.dart';
import 'package:hola_mundo/shared/widgets/custom_button.dart';
import 'package:hola_mundo/shared/widgets/forms/text_fields/custom_number_field.dart';
import 'package:image_picker/image_picker.dart'; // Importa image_picker
import 'package:hola_mundo/shared/models/product.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:hola_mundo/shared/models/sale.dart';
import 'package:hola_mundo/shared/providers/product_provider.dart';

class SalesScreen extends StatefulWidget {
  @override
  _SalesScreenState createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  RegisterClient? _clientData; // Almacena los datos del cliente seleccionados
  final String EFECTIVO = "Efectivo";
  List<SaleProduct> _selectedProducts =
      []; // Productos seleccionados para la venta
  double _totalAmount = 0.0;
  double _returned = 0.0;
  List<PaymentMethod> _paymentMethods = [];
  XFile? _receiptFile; // Cambia a XFile para trabajar con image_picker
  final ImagePicker _picker = ImagePicker(); // Instancia de ImagePicker
  bool _isSearching = false;
  bool _isLoading = false; // Estado de carga

  // Método para buscar productos
  void _searchProduct(String query) {
    setState(() {
      _isSearching = query.isNotEmpty;
    });
    Provider.of<ProductProvider>(context, listen: false).searchProducts(query);
  }

  // Función para reiniciar el estado de la pantalla
  void resetScreenState() {
    setState(() {
      _selectedProducts.clear();
      _selectedProducts = [];
      _totalAmount = 0.0;
      _paymentMethods = [];
      _isSearching = false;
      _clientData = null;
      _returned = 0;
      _receiptFile = null;
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  // Método para actualizar el total
  void _updateTotal() {
    double total = 0;
    double totalPayments = 0;
    for (var product in _selectedProducts) {
      total += product.price * product.quantity;
    }
    for (var payment in _paymentMethods) {
      totalPayments += payment.amount;
    }
    setState(() {
      _totalAmount = total;
      _returned = totalPayments - total;
    });
  }

  // Función callback que se pasará a AddClientForm
  void _handleClientUpdate(RegisterClient client) {
    setState(() {
      _clientData = client;
    });
  }

  // Método para seleccionar un producto
  void _selectProduct(Product product) {
    for (var currentProduct in _selectedProducts) {
      if (product.id == currentProduct.id) {
        return;
      }
    }
    SaleProduct saleProduct = new SaleProduct(
        id: product.id, name: product.name, price: product.price, quantity: 1);
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
    TextEditingController priceController =
        TextEditingController(text: product.price.toString());
    TextEditingController quantityController =
        TextEditingController(text: product.quantity.toString());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar Producto'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 20),
              CustomNumberField(
                controller: priceController,
                label: 'Precio',
              ),
              const SizedBox(height: 20),
              CustomNumberField(
                controller: quantityController,
                label: 'Cantidad',
              ),
            ],
          ),
          actions: [
            CustomButton(
              onPressed: () {
                setState(() {
                  product.price = double.parse(priceController.text);
                  product.quantity = int.parse(quantityController.text);
                });
                _updateTotal();
                Navigator.pop(context);
              },
              text: 'Confirmar',
              type: ButtonType.flat,
            ),
          ],
        );
      },
    );
  }

  void _editPaymentMethod(PaymentMethod paymentMethod) {
    TextEditingController amountController =
        TextEditingController(text: paymentMethod.amount.toString());
    String? selectedPaymentType =
        paymentMethod.type; // Variable de estado para el tipo de pago

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Editar método de pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedPaymentType,
                decoration: const InputDecoration(labelText: 'Forma de pago'),
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
                    selectedPaymentType =
                        value; // Actualiza el estado con el tipo de pago seleccionado
                  });
                },
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            CustomButton(
              onPressed: () {
                setState(() {
                  paymentMethod.type = selectedPaymentType.toString();
                  paymentMethod.amount = double.parse(amountController.text);
                  _updateTotal();
                });
                Navigator.pop(context);
              },
              text: 'Confirmar',
              type: ButtonType.flat,
            ),
          ],
        );
      },
    );
  }

  void _deletePaymentMethod(PaymentMethod paymentMethod) {
    setState(() {
      _paymentMethods
          .removeWhere((method) => method.type == paymentMethod.type);
    });
    if (_paymentMethods.length == 1) {
      _updateTotal();
    }
  }

  // Método para añadir un método de pago
  void _addPaymentMethod() {
    String? selectedPaymentType; // Variable de estado para el tipo de pago
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Añadir método de pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedPaymentType,
                decoration: const InputDecoration(labelText: 'Forma de pago'),
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
                    selectedPaymentType =
                        value; // Actualiza el estado con el tipo de pago seleccionado
                  });
                },
              ),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: 'Monto'),
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
                  _updateTotal();
                });
                Navigator.pop(context);
              },
              child: const Text('Confirmar'),
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

  void _paymentIsProcessed(bool state) {
    setState(() {
      _isLoading = state; // Bloquea el botón
    });
  }

  // Método para completar la venta
  void _completeSale() async {
    _paymentIsProcessed(true);

    double totalPaid =
        _paymentMethods.fold(0.0, (sum, method) => sum + method.amount);

    if (_selectedProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No hay productos seleccionados.')),
      );
      _paymentIsProcessed(false);
      return;
    }

    if (totalPaid < _totalAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('El pago no cubre el valor total de la venta.')),
      );
      _paymentIsProcessed(false);
      return;
    }

    // Construir el objeto de la venta
    Map<String, dynamic> sale = {
      'products': _selectedProducts.map((product) => product.toJson()).toList(),
      'paymentMethods':
          _paymentMethods.map((method) => method.toJson()).toList(),
      'proofPayment': _receiptFile != null
          ? (await createFileDTO(File(_receiptFile!.path))).toMap()
          : null,
      'client': _clientData != null ? _clientData?.toJson() : null,
    };

    // Consumir el servicio de creación de venta
    SaleService saleService = SaleService();
    try {
      final response = await saleService.createSale(sale);

      if (response['statusCode'] == 201) {
        final saleId = response['data']; // Obtiene el ID de la venta
        // Venta creada exitosamente
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('¡Venta realizada con éxito!')),
        );

        resetScreenState();
        // Aquí puedes usar `saleId` para redirigir al detalle, guardar en local, etc.
        Navigator.pushNamed(
          context,
          AppRoutes.saleDetail,
          arguments: {'idSale': saleId, 'isRecent': true},
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'No se ha podido completar la venta. Error: ${response['message']}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    } finally {
      _paymentIsProcessed(false);
    }
    // Aquí podrías guardar la venta en MongoDB o en tu base de datos local.
  }

  @override
  Widget build(BuildContext context) {
    bool _customTileExpanded = false;
    var productProvider = Provider.of<ProductProvider>(context);
    var filteredProducts = productProvider.filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: Text('Venta'),
      ),
      body: Column(
        children: [
          // Barra de búsqueda con fondo
          AnimatedContainer(
            duration: Duration(milliseconds: 300),
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: CustomDropdown.search(
                    searchHintText: 'Buscar producto',
                    hintText: 'Buscar producto',
                    items: filteredProducts
                        .map((product) => product.name)
                        .toList(),
                    onChanged: (value) {
                      final selectedProduct = filteredProducts.firstWhere(
                        (product) => product.name == value,
                      );
                      if (selectedProduct != null) {
                        _selectProduct(selectedProduct);
                      }
                      setState(() {
                        _isSearching = false; // Cierra la búsqueda
                      });
                    },
                  ),
                ),
                if (_isSearching)
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () {
                      setState(() {
                        _isSearching = false;
                        _searchProduct(''); // Limpia la búsqueda
                      });
                    },
                  ),
              ],
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                // Sección de Productos
                ExpansionTile(
                  title: NumOfItems(
                    icon: const Icon(Icons.sell_outlined),
                    numOfItem: _selectedProducts.length,
                    title: 'Productos',
                  ),
                  //title: Text("${_selectedProducts.length} - Productos"),
                  initiallyExpanded: true,
                  children: [
                    if (_isSearching)
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          final product = filteredProducts[index];
                          return ListTile(
                            title: Text(product.name),
                            subtitle: Text('Precio: \$${product.price}'),
                            onTap: () => _selectProduct(product),
                          );
                        },
                      ),
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _selectedProducts.length,
                      itemBuilder: (context, index) {
                        final product = _selectedProducts[index];

                        return ListTile(
                          title: Text(product.name),
                          subtitle: Text(
                            '\$${product.price} - Cantidad: ${product.quantity}',
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editProduct(product),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () => _deleteProduct(product),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),

                // Sección de Métodos de Pago
                ExpansionTile(
                  title: NumOfItems(
                    icon: Icon(Icons.payment_outlined),
                    numOfItem: _paymentMethods.length,
                    title: 'Métodos de Pago',
                  ),
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _paymentMethods.length,
                      itemBuilder: (context, index) {
                        final method = _paymentMethods[index];
                        return ListTile(
                          title: Text('${method.type}'),
                          subtitle: Text('\$${method.amount}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit),
                                onPressed: () => _editPaymentMethod(method),
                              ),
                              if (_paymentMethods.length > 1)
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () => _deletePaymentMethod(method),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                    CustomButton(
                      text: 'Añadir método de pago',
                      type: ButtonType.flat,
                      onPressed: _addPaymentMethod,
                      icon: const Icon(
                        Icons.payment,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                  ],
                ),

                // Sección del cliente
                ExpansionTile(
                  title: NumOfItems(
                    icon: const Icon(Icons.person_2_outlined),
                    numOfItem: _receiptFile != null ? 1 : 0,
                    title: 'Cliente (opcional)',
                  ),
                  children: [
                    const SizedBox(height: 10),
                    AddClientForm(
                      onClientUpdated: _handleClientUpdate,
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 15.0),
                  child: Column(
                    children: [
                      Text('Total: \$$_totalAmount',
                          style: const TextStyle(fontSize: 16)),
                      Text(
                        _returned > 0
                            ? 'Cambio: \$$_returned'
                            : 'Falta: \$${_returned.abs()}',
                        style: TextStyle(
                          fontSize: 16,
                          color:
                              (_returned > 0) ? Colors.green : Colors.redAccent,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 50,
        margin: const EdgeInsets.all(10),
        child: CustomButton(
          onPressed: _isLoading
              ? () {}
              : _completeSale, // Deshabilita el botón si está cargando
          text: _isLoading
              ? 'Procesando...' // Muestra un mensaje de carga
              : 'Confirmar Venta ($_totalAmount COP)',
          type: ButtonType.primary,
          minimumSize: const Size(double.infinity, 48),
        ),
      ),
    );
  }
}

class NumOfItems extends StatelessWidget {
  const NumOfItems({
    super.key,
    required this.numOfItem,
    required this.title,
    required this.icon,
  });

  final int numOfItem;
  final String title;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 24,
              width: 24,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(6)),
                border: Border.all(
                    width: 0.5,
                    color: const Color(0xFF868686).withOpacity(0.3)),
              ),
              child: Text(
                numOfItem.toString(),
                style: Theme.of(context)
                    .textTheme
                    .labelLarge!
                    .copyWith(color: Colors.blueAccent),
              ),
            ),
            const SizedBox(width: 8),
            icon,
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        )
      ],
    );
  }
}
