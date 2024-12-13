import 'package:flutter/material.dart';
import 'package:hola_mundo/core/utils/numer_formatter.dart';
import 'package:hola_mundo/modules/financial/models/financial_data.dart';
import 'package:hola_mundo/modules/financial/services/finances_service.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // Importamos shimmer

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({Key? key}) : super(key: key);

  @override
  _FinanceScreenState createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  final FinancesService _financesService = FinancesService();

  FinancialData? dailyData;
  FinancialData? weeklyData;
  FinancialData? yearlyData;
  FinancialData? totalData;

  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchAllFinancialData();
  }

  Future<void> fetchAllFinancialData() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final now = DateTime.now().toUtc();
      final date = DateFormat('yyyy-MM-dd').format(now);

      final daily = await _financesService.fetchFinancialData('day', date);
      final weekly = await _financesService.fetchFinancialData('week', date);
      final yearly = await _financesService.fetchFinancialData('year', date);
      final total = await _financesService.fetchFinancialData('total', date);

      setState(() {
        dailyData = daily;
        weeklyData = weekly;
        yearlyData = yearly;
        totalData = total;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = "Error: $e";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finanzas'),
      ),
      body: isLoading
          ? _buildSkeletonLoader() // Usamos el loader con shimmer
          : errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchAllFinancialData,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : _buildFinanceContent(),
    );
  }

  // Widget del Skeleton Loader
  Widget _buildSkeletonLoader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          children: List.generate(
            4,
            (index) => _buildSkeletonCard(), // Placeholder para cada tarjeta
          ),
        ),
      ),
    );
  }

  // Placeholder de una tarjeta usando Shimmer
  Widget _buildSkeletonCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 20,
                width: 150,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 8.0),
              Container(
                height: 20,
                width: double.infinity,
                color: Colors.grey[300],
              ),
              const SizedBox(height: 8.0),
              Container(
                height: 20,
                width: 200,
                color: Colors.grey[300],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Contenido real cuando los datos están disponibles
  Widget _buildFinanceContent() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSummaryCard(
              title: "Hoy",
              revenue: dailyData?.totalRevenue ?? 0,
              profit: dailyData?.totalProfit ?? 0,
            ),
            _buildSummaryCard(
              title: "Esta semana",
              revenue: weeklyData?.totalRevenue ?? 0,
              profit: weeklyData?.totalProfit ?? 0,
            ),
            _buildSummaryCard(
              title: "Este año",
              revenue: yearlyData?.totalRevenue ?? 0,
              profit: yearlyData?.totalProfit ?? 0,
            ),
            _buildTotalCard(
              totalProfit: totalData?.totalProfit ?? 0,
              totalRevenue: totalData?.totalRevenue ?? 0,
            ),
          ],
        ),
      ),
    );
  }

  // Widget para las tarjetas de resumen
  Widget _buildSummaryCard({
    required String title,
    required double revenue,
    required double profit,
  }) {
    final totalRevenue = totalData?.totalRevenue ?? 1;
    final revenueContribution =
        totalRevenue > 0 ? (revenue / totalRevenue) * 100 : 0;
    final profitMargin = revenue > 0 ? (profit / revenue) * 100 : 0;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 24.0, // Incremento del tamaño de fuente
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              "Ingresos: \$${NumberFormatter.format(context, revenue)}",
              style: const TextStyle(
                fontSize: 18.0, // Tamaño más grande para valores
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              "Ganancias: \$${NumberFormatter.format(context, profit)}",
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              "Margen de Ganancia: ${profitMargin.toStringAsFixed(2)}%",
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: profitMargin >= 0 ? Colors.green : Colors.red,
              ),
            ),
            Text(
              "Contribución al Total: ${revenueContribution.toStringAsFixed(2)}%",
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

// Widget para la tarjeta de resumen total
  Widget _buildTotalCard({
    required double totalRevenue,
    required double totalProfit,
  }) {
    final totalProfitMargin =
        totalRevenue > 0 ? (totalProfit / totalRevenue) * 100 : 0;

    return Card(
      color: Colors.blueAccent,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4.0,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Resumen Total",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              "Ingresos Totales: \$${NumberFormatter.format(context, totalRevenue)}",
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              "Ganancias Totales: \$${NumberFormatter.format(context, totalProfit)}",
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.lightGreenAccent,
              ),
            ),
            const SizedBox(height: 12.0),
            Text(
              "Margen de Ganancia Total: ${totalProfitMargin.toStringAsFixed(2)}%",
              style: const TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w500,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
