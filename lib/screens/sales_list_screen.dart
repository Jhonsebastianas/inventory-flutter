import 'package:flutter/material.dart';
import 'package:hola_mundo/models/sales_consultation.dart';
import 'package:hola_mundo/models/sales_inquiries.dart';
import 'package:hola_mundo/services/sale_service.dart';
import 'package:hola_mundo/widgets/custom_button.dart';
import '../models/sale.dart';
import 'sale_detail_screen.dart';

class SalesListScreen extends StatefulWidget {
  @override
  _SalesListScreenState createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  late SaleService _apiService;
  late Future<List<Sale>>? _sales;
  SalesInquiries? _salesInquiries;
  String _totalInvoiced = "0";
  DateTimeRange? _selectedDateRange;

  @override
  void initState() {
    super.initState();
    _apiService = SaleService();
    _loadSalesForCurrentMonth();
  }

  void _loadSalesForCurrentMonth() async {
    try {
      setState(() {
        _sales = null; // Indicar que se está cargando
      });
      _selectedDateRange = DateTimeRange(
          start: DateTime.now().copyWith(hour: 0, minute: 0, second: 0),
          end: DateTime.now().copyWith(hour: 23, minute: 59, second: 59));
      final salesConsultation = SalesConsultation(
        startDate: _selectedDateRange!.start,
        endDate: _selectedDateRange!.end,
      );
      // Llamar a la API
      final inquiries =
          await _apiService.consultationSales(salesConsultation.toJson());

      // Actualizar el estado con los nuevos datos
      setState(() {
        _salesInquiries = inquiries; // Guardar los datos completos
        _totalInvoiced =
            inquiries.metrics?.totalInvoiced?.toStringAsFixed(2) ?? "0";
        _sales = Future.value(inquiries.sales ?? []);
      });
    } catch (e) {
      print('Error al cargar las ventas del mes actual: $e');
      // Manejar errores
      setState(() {
        _totalInvoiced = "0"; // Restablecer en caso de error
        _sales = Future.value([]); // Vaciar la lista de ventas
      });
    }
  }

  void _loadSales() async {
    if (_selectedDateRange == null) {
      return;
    }

    final salesConsultation = SalesConsultation(
      startDate: _selectedDateRange!.start,
      endDate: _selectedDateRange!.end,
    );

    try {
      // Llamar a la API y asignar el resultado a _salesInquiries
      final inquiries =
          await _apiService.consultationSales(salesConsultation.toJson());

      setState(() {
        _salesInquiries = inquiries; // Asignar los datos completos
        _totalInvoiced = inquiries.metrics!.totalInvoiced!.toStringAsFixed(2);
        _sales =
            Future.value(_salesInquiries?.sales ?? []); // Extraer las ventas
      });
    } catch (e) {
      setState(() {
        _sales = Future.value([]); // Vaciar la lista en caso de error
      });
      print('Error al cargar las ventas: $e');
    }
  }

  Future<void> _selectDateRange() async {
    final today = DateTime.now();
    final newDateRange = await showDateRangePicker(
      locale: const Locale('es'),
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(today.year - 5),
      lastDate: today,
    );
    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
        _loadSales();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Histórico de Ventas'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedDateRange == null
                      ? 'Seleccione un rango de fechas'
                      : 'Ventas del: ${_selectedDateRange!.start.toLocal().toString().split(' ')[0]} al ${_selectedDateRange!.end.toLocal().toString().split(' ')[0]}',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 8.0),
                CustomButton(
                  text: 'Cambiar fechas',
                  type: ButtonType.flat,
                  onPressed: _selectDateRange,
                  icon: const Icon(Icons.calendar_today),
                  minimumSize: const Size(double.infinity, 48),
                ),
                const SizedBox(height: 8.0),
                Text("Total facturado: $_totalInvoiced"),
              ],
            ),
          ),
          Expanded(
            child: _sales == null
                ? _buildSkeletonLoader() // Mostrar skeleton si está cargando
                : FutureBuilder<List<Sale>>(
                    future: _sales,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildSkeletonLoader(); // Skeleton Loader
                      } else if (snapshot.hasError) {
                        return const Center(
                            child: Text('Error al cargar las ventas'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(
                            child: Text('No hay ventas en este rango.'));
                      } else {
                        final sales = snapshot.data!;
                        return ListView.builder(
                          itemCount: sales.length,
                          itemBuilder: (context, index) {
                            final sale = sales[index];
                            return _buildSaleCard(sale);
                          },
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Tarjeta de diseño mejorado
  Widget _buildSaleCard(Sale sale) {
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de detalles de la venta
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SaleDetailScreen(sale: sale),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Icon(
                  Icons.receipt_long,
                  color: Colors.blue.shade700,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Factura: ${sale.invoiceIdentifier}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    _buildDetailSale(
                      context,
                      icon: Icons.attach_money,
                      label: 'Total:',
                      value: '\$${sale.totalInvoiced.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 4),
                    _buildDetailSale(
                      context,
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha:',
                      value: sale.createdAt.toLocal().toString().split(' ')[0],
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade700,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSale(BuildContext context,
      {required IconData icon, required String label, required String value}) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue.shade400),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  // Skeleton Loader
  Widget _buildSkeletonLoader() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 12,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 12,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 100,
                        height: 12,
                        color: Colors.grey.shade300,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
