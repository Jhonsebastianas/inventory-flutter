// lib/screens/sales_list_screen.dart

import 'package:flutter/material.dart';
import 'package:hola_mundo/services/sale_service.dart';
import '../services/api_service.dart';
import '../models/sale.dart';
import 'sale_detail_screen.dart';

class SalesListScreen extends StatefulWidget {
  @override
  _SalesListScreenState createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  late SaleService _apiService;
  late Future<List<Sale>> _sales;

  @override
  void initState() {
    super.initState();
    _apiService = SaleService();
    _sales = _apiService.getSalesByMonth(DateTime.now().year, DateTime.now().month);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ventas del Mes'),
      ),
      body: FutureBuilder<List<Sale>>(
        future: _sales,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error al cargar las ventas'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay ventas registradas este mes.'));
          } else {
            final sales = snapshot.data!;
            return ListView.builder(
              itemCount: sales.length,
              itemBuilder: (context, index) {
                final sale = sales[index];
                return ListTile(
                  title: Text('Factura: ${sale.invoiceIdentifier}'),
                  subtitle: Text('Total: \$${sale.totalInvoiced.toStringAsFixed(2)}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SaleDetailScreen(sale: sale),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
