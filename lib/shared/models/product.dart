class StockDetail {
  String id;
  String provider;
  double purchasePrice;
  double quantity;
  double quantityPurchased;
  double totalGrossProfit;
  double totalPurchasePrice;

  StockDetail({
    required this.id,
    required this.provider,
    required this.purchasePrice,
    required this.quantity,
    required this.quantityPurchased,
    required this.totalGrossProfit,
    required this.totalPurchasePrice,
  });

  factory StockDetail.fromJson(Map<String, dynamic> json) {
    print(json['purchasePrice'].runtimeType);
    return StockDetail(
      id: json['id'],
      provider: json['provider'] ?? '',
      purchasePrice: json['purchasePrice'] != null
          ? (json['purchasePrice'] is int
              ? json['purchasePrice'].toDouble()
              : (json['purchasePrice'] is String
                  ? double.parse(json['purchasePrice'])
                  : json['purchasePrice']))
          : 0.0,
      quantity: json['quantity'] != null
          ? (json['quantity'] is int
              ? json['quantity'].toDouble()
              : (json['quantity'] is String
                  ? double.parse(json['quantity'])
                  : json['quantity']))
          : 0.0,
      quantityPurchased: json['quantityPurchased'] != null
          ? (json['quantityPurchased'] is int
              ? json['quantityPurchased'].toDouble()
              : (json['quantityPurchased'] is String
                  ? double.parse(json['quantityPurchased'])
                  : json['quantityPurchased']))
          : 0.0,
      totalGrossProfit: json['totalGrossProfit'] is Map<String, dynamic>
          ? (json['totalGrossProfit'] != null)
              ? double.parse(json['totalGrossProfit'])
              : 0.0 // Para Decimal128
          : (json['totalGrossProfit'] != null)
              ? json['totalGrossProfit'].toDouble()
              : 0.0, // Para Number normal
      totalPurchasePrice: json['totalPurchasePrice'] is Map<String, dynamic>
          ? (json['totalPurchasePrice'] != null)
              ? double.parse(json['totalPurchasePrice'])
              : 0.0 // Para Decimal128
          : (json['totalPurchasePrice'] != null)
              ? json['totalPurchasePrice'].toDouble()
              : 0.0, // Para Number normal
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'purchasePrice': purchasePrice,
      'quantity': quantity,
      'quantityPurchased': quantityPurchased,
      'totalGrossProfit': totalGrossProfit,
      'totalPurchasePrice': totalPurchasePrice,
    };
  }
}

class Product {
  String id;
  String businessId;
  String name;
  String description;
  double price;
  double stock;
  double percentageTax;
  String? presentation;
  List<StockDetail> stockDetails;
  double weightedAveragePurchasePrice;

  Product({
    required this.id,
    required this.businessId,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.percentageTax,
    this.presentation,
    required this.stockDetails,
    required this.weightedAveragePurchasePrice,
  });

  // Convertir JSON a objeto Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      businessId: json['businessId'],
      name: json['name'],
      price: json['price'] is Map<String, dynamic>
          ? double.parse(json['price']) // Para Decimal128
          : json['price'].toDouble(), // Para Number normal
      description: json['description'],
      stock: json['stock'] != null
          ? (json['stock'] is int
              ? json['stock'].toDouble()
              : (json['stock'] is String
                  ? double.parse(json['stock'])
                  : json['stock']))
          : 0.0,
      percentageTax: json['percentageTax'] is Map<String, dynamic>
          ? (json['percentageTax'] != null)
              ? double.parse(json['percentageTax'])
              : 0.0 // Para Decimal128
          : (json['percentageTax'] != null)
              ? json['percentageTax'].toDouble()
              : 0.0, // Para Number normal
      presentation: json['presentation'] ?? 'unidad',
      stockDetails: (json['stockDetails'] as List)
          .map((detail) => StockDetail.fromJson(detail))
          .toList(),
      weightedAveragePurchasePrice:
          json['weightedAveragePurchasePrice'] is Map<String, dynamic>
              ? (json['weightedAveragePurchasePrice'] != null)
                  ? double.parse(json['weightedAveragePurchasePrice'])
                  : 0.0 // Para Decimal128
              : (json['weightedAveragePurchasePrice'] != null)
                  ? json['weightedAveragePurchasePrice'].toDouble()
                  : 0.0, // Para Number normal
    );
  }

  // Convertir objeto Product a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'businessId': businessId,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'percentageTax': percentageTax,
      'presentation': presentation,
      'stockDetails': stockDetails.map((detail) => detail.toJson()).toList(),
      'weightedAveragePurchasePrice': weightedAveragePurchasePrice,
    };
  }
}
