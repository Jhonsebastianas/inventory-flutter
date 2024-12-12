import 'dart:io';

import 'package:hola_mundo/shared/models/file_dto.dart';

class Sale {
  final String id;
  final String? idUser;
  final DateTime createdAt;
  final String invoiceIdentifier;
  final List<SaleProduct> products;
  final List<PaymentMethod> paymentMethods;
  final double totalInvoiced;
  final int totalProducts;
  final FileDTO? paymentReceipt;

  Sale({
    required this.id,
    this.idUser,
    required this.createdAt,
    required this.invoiceIdentifier,
    required this.products,
    required this.paymentMethods,
    required this.totalInvoiced,
    required this.totalProducts,
    this.paymentReceipt,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      idUser: json['idUser'],
      createdAt: DateTime.parse(json['createdAt']),
      invoiceIdentifier: json['invoiceIdentifier'],
      products: (json['products'] as List).map((product) => SaleProduct.fromJson(product)).toList(),
      paymentMethods: (json['paymentMethods'] as List).map((method) => PaymentMethod.fromJson(method)).toList(),
      totalInvoiced: json['totalInvoiced'].toDouble(),
      totalProducts: json['totalProducts'],
      paymentReceipt: json['proofPayment'] != null ? FileDTO.fromJson(json['proofPayment']) : null,
    );
  }
}

class SaleProduct {
  final String id;
  final String name;
  final String? description;
  double price;
  double quantity;

  // Convertir objeto Sale a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory SaleProduct.fromJson(Map<String, dynamic> json) {
    return SaleProduct(
      id: json['idProducto'],
      name: json['name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'].toDouble(),
    );
  }

  SaleProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    this.description
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

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      type: json['type'],
      amount: json['amount'].toDouble(),
    );
  }

  PaymentMethod({
    required this.type,
    required this.amount,
  });
}
