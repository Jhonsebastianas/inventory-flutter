import 'sale.dart'; // Asegúrate de que este archivo tenga el modelo `Sale`.

class SalesInquiries {
  List<Sale>? sales;
  MetricsSalesConsultation? metrics;

  SalesInquiries({
    this.sales,
    this.metrics,
  });

  factory SalesInquiries.fromJson(Map<String, dynamic> json) {
    return SalesInquiries(
      sales: (json['sales'] as List<dynamic>?)
          ?.map((item) => Sale.fromJson(item as Map<String, dynamic>))
          .toList(),
      metrics: json['metrics'] != null
          ? MetricsSalesConsultation.fromJson(
              json['metrics'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MetricsSalesConsultation {
  double? totalInvoiced;

  MetricsSalesConsultation({this.totalInvoiced});

  factory MetricsSalesConsultation.fromJson(Map<String, dynamic> json) {
    return MetricsSalesConsultation(
      totalInvoiced: (json['totalInvoiced'] as num?)?.toDouble(),
    );
  }
}