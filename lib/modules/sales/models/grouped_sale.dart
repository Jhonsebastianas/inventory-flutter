import 'package:hola_mundo/shared/models/sale.dart';

class GroupedSale {
  final String productName;
  final double totalQuantity;
  final double totalInvoiced;
  final double? totalProfit;
  final List<Sale> sales;
  final double? profitPercentage;
      

  GroupedSale({
    required this.productName,
    required this.totalQuantity,
    required this.totalInvoiced,
    required this.sales,
    this.profitPercentage,
    this.totalProfit,
  });

  // Método auxiliar para agregar más datos a un grupo existente
  GroupedSale mergeWith(double quantity, double invoiced, double profit, Sale sale) {
    return GroupedSale(
      productName: productName,
      totalQuantity: totalQuantity + quantity,
      totalInvoiced: totalInvoiced + invoiced,
      totalProfit: totalProfit! + profit,
      profitPercentage: totalProfit! > 0 ? (totalProfit! / totalInvoiced) * 100 : 0,
      sales: [...sales, sale],
    );
  }
}
