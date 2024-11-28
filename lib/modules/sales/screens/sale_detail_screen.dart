// lib/screens/sale_detail_screen.dart

import 'package:flutter/material.dart';
import '../../../shared/models/sale.dart';

class SaleDetailScreen extends StatelessWidget {
  final Sale sale;

  SaleDetailScreen({required this.sale});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de la Venta'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Factura: ${sale.invoiceIdentifier}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Fecha: ${sale.createdAt}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Total Productos: ${sale.totalProducts}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Total Facturado: \$${sale.totalInvoiced}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Productos Vendidos:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Expanded(
              child: ListView.builder(
                itemCount: sale.products.length,
                itemBuilder: (context, index) {
                  final product = sale.products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text('Cantidad: ${product.quantity} - Precio: \$${product.price}'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Aquí se implementa la lógica para modificar y guardar los cambios de la venta
              },
              child: Text('Modificar Venta'),
            ),
          ],
        ),
      ),
    );
  }
}
