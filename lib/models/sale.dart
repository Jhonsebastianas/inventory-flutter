import 'dart:io';

class Sale {
  final String id;
  final DateTime creationDate;
  final String invoiceId;
  final List<SaleProduct> products;
  final List<PaymentMethod> paymentMethods;
  final double totalAmount;
  final int totalProducts;
  final File? paymentReceipt;

  Sale({
    required this.id,
    required this.creationDate,
    required this.invoiceId,
    required this.products,
    required this.paymentMethods,
    required this.totalAmount,
    required this.totalProducts,
    this.paymentReceipt,
  });
}

class SaleProduct {
  final String id;
  final String name;
  double price;
  int quantity;

  SaleProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class PaymentMethod {
  String type;
  double amount;

  PaymentMethod({
    required this.type,
    required this.amount,
  });
}
