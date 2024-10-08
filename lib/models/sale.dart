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

  // Convertir objeto Sale a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

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

  // Convertir objeto PaymentMethod a JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'amount': amount,
    };
  }

  PaymentMethod({
    required this.type,
    required this.amount,
  });
}
