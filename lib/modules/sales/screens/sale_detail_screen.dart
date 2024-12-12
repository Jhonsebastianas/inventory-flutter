import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hola_mundo/modules/sales/models/sale_detail_dto.dart';
import 'package:hola_mundo/routes/app_routes.dart';
import 'package:hola_mundo/shared/models/sale.dart';
import 'package:hola_mundo/shared/services/sale_service.dart';
import 'package:hola_mundo/shared/widgets/custom_button.dart';
import 'package:hola_mundo/shared/widgets/custom_snake_bar.dart';
import 'package:http/http.dart' as http;

class SaleDetailScreen extends StatefulWidget {
  final String idSale;
  final bool
      isRecent; // Parámetro para diferenciar entre venta recién registrada y consulta

  SaleDetailScreen({required this.idSale, required this.isRecent});

  @override
  _SaleDetailScreenState createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  late SaleService _apiService;
  late Future<SaleDetailDTO> saleDetailFuture;

  @override
  void initState() {
    super.initState();
    _apiService = SaleService();
    saleDetailFuture = fetchSaleDetail(widget.idSale);
  }

  Future<SaleDetailDTO> fetchSaleDetail(String idSale) async {
    return _apiService.fetchSaleDetail(idSale);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Detalle de la Venta'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_square),
            onPressed: () {
              // Implementar lógica de modificación
              CustomSnackBar.showInfo(context, 'Opción en construcción 🏗️');
            },
          ),
        ],
      ),
      body: FutureBuilder<SaleDetailDTO>(
        future: saleDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Error al cargar el detalle de la venta',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        saleDetailFuture = fetchSaleDetail(widget.idSale);
                      });
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasData) {
            final saleDetail = snapshot.data!;
            return _buildDetailContent(saleDetail);
          } else {
            return const Center(child: Text('Sin datos disponibles'));
          }
        },
      ),
    );
  }

  Widget _buildDetailContent(SaleDetailDTO saleDetail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Información General'),
          _buildInfoCard(saleDetail),
          _buildSectionTitle('Productos Vendidos'),
          _buildProductsCard(saleDetail.products),
          _buildSectionTitle('Resumen de la Venta'),
          _buildSummaryCard(saleDetail),
          _buildSectionTitle('Métodos de Pago'),
          _buildPaymentMethodsCard(saleDetail.paymentMethods),
          const SizedBox(height: 16),
          CustomButton(
            type: ButtonType.primary,
            text: 'Volver',
            onPressed: () {
              Navigator.pop(context);
            },
            minimumSize: const Size(double.infinity, 48),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(SaleDetailDTO saleDetail) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Factura', saleDetail.invoiceIdentifier),
            _buildDetailRow(
                'Fecha',
                DateFormat('yyyy/MM/dd - hh:mm a')
                    .format(saleDetail.createdAt.toLocal())),
            if (saleDetail.client !=
                null) // Solo se muestra si el cliente no es null
              _buildDetailRow('Cliente', saleDetail.client!.names),
            _buildDetailRow('Vendido por', saleDetail.userSold.names),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsCard(List<SaleProduct> products) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
            title: Text(product.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
                'Cantidad: ${product.quantity} - Precio: \$${product.price}'),
            trailing: Text(
              'Subtotal: \$${(product.quantity * product.price).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(SaleDetailDTO saleDetail) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(
                'Total Productos', saleDetail.totalProducts.toString()),
            _buildDetailRow('Total Facturado',
                '\$${saleDetail.totalInvoiced.toStringAsFixed(2)}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodsCard(List<PaymentMethod> paymentMethods) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: paymentMethods.length,
        itemBuilder: (context, index) {
          final method = paymentMethods[index];
          return ListTile(
            title: Text('Método: ${method.type}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Monto: \$${method.amount.toStringAsFixed(2)}'),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blueAccent),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
