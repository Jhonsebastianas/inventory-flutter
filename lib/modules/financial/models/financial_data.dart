class FinancialData {
  final double totalRevenue;
  final double totalProfit;

  FinancialData({
    required this.totalRevenue,
    required this.totalProfit,
  });

  // Método factory para crear una instancia a partir de un JSON
  factory FinancialData.fromJson(Map<String, dynamic> json) {
    return FinancialData(
      totalRevenue: json['totalRevenue']?.toDouble() ?? 0.0,
      totalProfit: json['totalProfit']?.toDouble() ?? 0.0,
    );
  }
}
