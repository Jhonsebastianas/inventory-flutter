// lib/screens/sale_detail_screen.dart

import 'package:easy_localization/easy_localization.dart';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Información General'),
            Card(
              elevation: 0,
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow('Factura', sale.invoiceIdentifier),
                    _buildDetailRow('Fecha', DateFormat('yyyy/MM/dd - hh:mm a').format(sale.createdAt.toLocal())),
                    //_buildDetailRow('Negocio', sale.businessId), // Asociar nombre real
                    //_buildDetailRow('Cliente', sale.clientId), // Asociar nombre real
                  ],
                ),
              ),
            ),
            _buildSectionTitle('Productos Vendidos'),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: sale.products.length,
                itemBuilder: (context, index) {
                  final product = sale.products[index];
                  return ListTile(
                    title: Text(product.name),
                    subtitle: Text(
                        'Cantidad: ${product.quantity} - Precio: \$${product.price}'),
                    trailing: Text(
                        'Subtotal: \$${(product.quantity * product.price).toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            _buildSectionTitle('Resumen de la Venta'),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(
                        'Total Productos', sale.totalProducts.toString()),
                    _buildDetailRow('Total Facturado',
                        '\$${sale.totalInvoiced.toStringAsFixed(2)}'),
                  ],
                ),
              ),
            ),
            _buildSectionTitle('Métodos de Pago'),
            Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: sale.paymentMethods.length,
                itemBuilder: (context, index) {
                  final method = sale.paymentMethods[index];
                  return ListTile(
                    title: Text('Método: ${method.type}'),
                    subtitle:
                        Text('Monto: \$${method.amount.toStringAsFixed(2)}'),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Aquí se implementa la lógica para modificar y guardar los cambios de la venta
              },
              child: Text('Modificar Venta'),
            ),
            SizedBox(height: 8),
            // ElevatedButton(
            //   onPressed: () {
            //     // Implementa la lógica para ver el comprobante de pago
            //   },
            //   child: Text('Ver Comprobante de Pago'),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
