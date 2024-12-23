import 'package:flutter/material.dart';
import 'package:hola_mundo/core/utils/date_util_helper.dart';
import 'package:hola_mundo/core/utils/numer_formatter.dart';
import 'package:hola_mundo/modules/sales/models/filter_sale_list.dart';
import 'package:hola_mundo/modules/sales/models/grouped_sale.dart';
import 'package:hola_mundo/routes/app_routes.dart';
import 'package:hola_mundo/shared/models/sales_consultation.dart';
import 'package:hola_mundo/shared/models/sales_inquiries.dart';
import 'package:hola_mundo/shared/services/sale_service.dart';
import 'package:hola_mundo/shared/widgets/custom_filter_chip.dart';
import '../../../shared/models/sale.dart';

class SalesListScreen extends StatefulWidget {
  @override
  _SalesListScreenState createState() => _SalesListScreenState();
}

class _SalesListScreenState extends State<SalesListScreen> {
  late SaleService _apiService;
  late Future<List<Sale>>? _sales;
  late List<FilterSaleList> filters;
  SalesInquiries? _salesInquiries;
  DateTimeRange? _selectedDateRange;
  List<GroupedSale>? _groupedSales;

  bool filterGroupedSales = false;
  final String filterbByProduct = "Por producto";

  @override
  void initState() {
    super.initState();
    _apiService = SaleService();
    _loadSalesForCurrentMonth();

    filters = [
      FilterSaleList(
        label: "Por producto",
        icon: Icons.inventory,
        onTap: () => _groupSalesByProduct(),
        isSelected: filterGroupedSales,
      ),
    ];
  }

  void _loadSalesForCurrentMonth() async {
    try {
      setState(() {
        _sales = null; // Indicar que se está cargando
      });
      _selectedDateRange = DateTimeRange(
          start: DateUtilsHelper.startOfDay(DateTime.now()),
          end: DateUtilsHelper.endOfDay(DateTime.now()));
      final salesConsultation = SalesConsultation(
        startDate: _selectedDateRange!.start.toUtc(),
        endDate: _selectedDateRange!.end.toUtc(),
      );
      // Llamar a la API
      final inquiries =
          await _apiService.consultationSales(salesConsultation.toJson());

      // Actualizar el estado con los nuevos datos
      setState(() {
        _salesInquiries = inquiries; // Guardar los datos completos
        _sales = Future.value(inquiries.sales ?? []);
        _groupedSales = null; // Reiniciar agrupación
        filterGroupedSales = false;
      });
    } catch (e) {
      print('Error al cargar las ventas del mes actual: $e');
      // Manejar errores
      setState(() {
        _sales = Future.value([]); // Vaciar la lista de ventas
        _groupedSales = null; // Reiniciar agrupación
        filterGroupedSales = false;
      });
    }
  }

  void _groupSalesByProduct() {
    if (filterGroupedSales) {
      setState(() {
        _groupedSales = null;
        filterGroupedSales = false;
        filters[0].isSelected = filterGroupedSales;
      });
      return;
    }
    if (_salesInquiries?.sales == null) return;

    final grouped = <String, GroupedSale>{};

    for (var sale in _salesInquiries!.sales!) {
      for (var product in sale.products) {
        final key = product.name;
        final totalInvoiced = product.price * product.quantity;
        if (!grouped.containsKey(key)) {
          grouped[key] = GroupedSale(
            productName: product.name,
            totalQuantity: product.quantity,
            totalInvoiced: totalInvoiced,
            totalProfit: product.totalProfit,
            profitPercentage: (product.totalProfit! / totalInvoiced) * 100,
            sales: [sale],
          );
        } else {
          grouped[key] = grouped[key]!.mergeWith(
            product.quantity,
            totalInvoiced,
            NumberFormatter.parseDouble(product.totalProfit),
            sale,
          );
        }
      }
    }

    setState(() {
      filterGroupedSales = true;
      _groupedSales = grouped.values.toList();
      filters[0].isSelected = filterGroupedSales;
    });
  }

  void _loadSales() async {
    if (_selectedDateRange == null) {
      return;
    }

    final salesConsultation = SalesConsultation(
        startDate:
            DateUtilsHelper.startOfDay(_selectedDateRange!.start).toUtc(),
        endDate: DateUtilsHelper.endOfDay(_selectedDateRange!.end).toUtc());

    try {
      // Llamar a la API y asignar el resultado a _salesInquiries
      final inquiries =
          await _apiService.consultationSales(salesConsultation.toJson());

      setState(() {
        _salesInquiries = inquiries; // Asignar los datos completos
        _sales =
            Future.value(_salesInquiries?.sales ?? []); // Extraer las ventas
        if (filterGroupedSales) {
          filterGroupedSales = false;
          _groupSalesByProduct();
        }
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
            color: Colors.white,
            icon: const Icon(Icons.date_range),
            onPressed: _selectDateRange,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(
              30), // Reducir el espacio entre el título y las fechas
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              _selectedDateRange == null
                  ? 'Seleccione un rango de fechas'
                  : '${_selectedDateRange!.start.toLocal().toString().split(' ')[0]}  al  ${_selectedDateRange!.end.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontSize: 16, // Aumentar el tamaño de la fuente
                    fontWeight: FontWeight.w500, // Cambiar peso de la fuente
                  ),
              textAlign:
                  TextAlign.center, // Centrado para mejorar la disposición
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildSummaryButton(context, _salesInquiries?.sales ?? []),
                const SizedBox(height: 8.0),
                Wrap(
                  spacing: 8.0,
                  runSpacing: 8.0,
                  children: filters.map((filter) {
                    return CustomFilterChip(
                      icon: filter.icon,
                      isSelected: filter.isSelected,
                      label: filter.label,
                      onTap: () => filter.onTap(),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          Expanded(
            child: _sales == null
                ? _buildSkeletonLoader() // Mostrar skeleton si está cargando
                : (filterGroupedSales == false)
                    ? FutureBuilder<List<Sale>>(
                        future: _sales,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return _buildSkeletonLoader(); // Skeleton Loader
                          } else if (snapshot.hasError) {
                            return const Center(
                                child: Text('Error al cargar las ventas'));
                          } else if (!snapshot.hasData ||
                              snapshot.data!.isEmpty) {
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
                      )
                    : _buildGroupedSalesList(),
          ),
        ],
      ),
    );
  }

  double _calculateTotalProfit(List<Sale> sales) {
    return sales.fold(0.0, (total, sale) {
      return total +
          sale.products.fold(0.0, (productTotal, product) {
            return productTotal + (product.totalProfit ?? 0.0);
          });
    });
  }

  double _calculateProfitMargin(double totalProfit, double totalInvoiced) {
    if (totalInvoiced == 0) return 0;
    return (totalProfit / totalInvoiced) * 100;
  }

  int _calculateTotalProductsSold(List<Sale> sales) {
    return sales.fold(0, (total, sale) {
      return total +
          sale.products.fold(0, (productTotal, product) {
            return productTotal + product.quantity.toInt();
          });
    });
  }

  void _showSummaryModal(BuildContext context, List<Sale> sales) {
    // Cálculos
    final totalInvoiced =
        sales.fold(0.0, (sum, sale) => sum + sale.totalInvoiced);
    final totalProfit = _calculateTotalProfit(sales);
    final profitMargin = _calculateProfitMargin(totalProfit, totalInvoiced);
    final totalSales = sales.length;
    final totalProductsSold = _calculateTotalProductsSold(sales);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      isScrollControlled: true, // Permitir mayor espacio al modal
      builder: (_) {
        return DraggableScrollableSheet(
          expand: false, // Permite que el modal sea desplazable
          initialChildSize: 0.5, // Tamaño inicial (50% de la pantalla)
          minChildSize: 0.3, // Tamaño mínimo del modal
          maxChildSize: 0.8, // Tamaño máximo (80% de la pantalla)
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController, // Controlador para el scroll
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "Resumen de Ventas",
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildStatItem(
                    context,
                    icon: Icons.attach_money_rounded,
                    label: "Facturado",
                    value:
                        '\$ ${NumberFormatter.format(context, totalInvoiced)}',
                    iconColor: Colors.green.shade400,
                  ),
                  _buildStatItem(
                    context,
                    icon: Icons.trending_up_rounded,
                    label: "Ganancia",
                    value: '\$ ${NumberFormatter.format(context, totalProfit)}',
                    iconColor: Colors.amber.shade400,
                  ),
                  _buildStatItem(
                    context,
                    icon: Icons.percent_rounded,
                    label: "Margen",
                    value: "${NumberFormatter.format(context, profitMargin)}%",
                    iconColor: Colors.blue.shade400,
                  ),
                  _buildStatItem(
                    context,
                    icon: Icons.shopping_cart_rounded,
                    label: "Productos",
                    value: "$totalProductsSold vendidos",
                    iconColor: Colors.orange.shade400,
                  ),
                  _buildStatItem(
                    context,
                    icon: Icons.receipt_long_rounded,
                    label: "Ventas",
                    value: "$totalSales",
                    iconColor: Colors.purple.shade400,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text("Cerrar", style: TextStyle(color: Colors.white),),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget buildSummaryButton(BuildContext context, List<Sale> sales) {
    // Cálculos
    final totalInvoiced =
        sales.fold(0.0, (sum, sale) => sum + sale.totalInvoiced);
    final totalSales = sales.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Wrap(
              spacing: 12.0, // Espacio horizontal entre elementos
              runSpacing: 8.0, // Espacio vertical entre elementos
              crossAxisAlignment: WrapCrossAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Facturado: \$${NumberFormatter.format(context, totalInvoiced)}",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                            fontSize: 14,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "$totalSales ventas",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _showSummaryModal(context, sales),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Ver Resumen",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: iconColor),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blueGrey.shade900,
                  ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildGroupedSalesList() {
    if (_groupedSales == null || _groupedSales!.isEmpty) {
      return const Center(
        child: Text(
          'No hay datos agrupados por producto.',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _groupedSales!.length,
      itemBuilder: (context, index) {
        final item = _groupedSales![index];
        return _buildGroupedSalesItem(item);
      },
    );
  }

  Widget _buildGroupedSalesItem(GroupedSale item) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              child: Text(
                item.productName[0], // Inicial del producto
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.productName,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              alignment: Alignment.bottomRight,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.blue.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item.sales.length} ventas',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              alignment: WrapAlignment.start,
              children: [
                _buildStatRow(
                  icon: Icons.attach_money_rounded,
                  color: Colors.green.shade400,
                  label:
                      "Ganancia ${item.profitPercentage?.toStringAsFixed(2)}%:",
                  value: '\$' +
                      NumberFormatter.format(context,
                              NumberFormatter.parseDouble(item.totalProfit))
                          .toString(),
                ),
                _buildStatRow(
                  icon: Icons.inventory,
                  color: Colors.blue.shade400,
                  label: "Cantidad",
                  value: item.totalQuantity.toString(),
                ),
                _buildStatRow(
                  icon: Icons.attach_money,
                  color: Colors.blue.shade400,
                  label: "Total vendido",
                  value: '\$' +
                      NumberFormatter.format(context, item.totalInvoiced)
                          .toString(),
                ),
              ],
            ),
          ],
        ),
        children: (item.sales).map((sale) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: _buildSaleCard(sale),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey.shade900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tarjeta de diseño mejorado
  Widget _buildSaleCard(Sale sale) {
    return GestureDetector(
      onTap: () {
        // Navegar a la pantalla de detalles de la venta
        Navigator.pushNamed(
          context,
          AppRoutes.saleDetail,
          arguments: {
            'idSale': sale.id,
            'isRecent': false,
          },
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
                      value: '\$${NumberFormatter.format(context, sale.totalInvoiced)}',
                    ),
                    const SizedBox(height: 4),
                    _buildDetailSale(
                      context,
                      icon: Icons.calendar_today_outlined,
                      label: 'Fecha:',
                      value: DateUtilsHelper.formatDate(
                          sale.createdAt.toLocal(),
                          format: DateUtilsHelper.yearMonthDayTimeAmPmFormat),
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
        Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ))),
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
