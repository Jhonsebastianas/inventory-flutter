class StockDetail {
  String id;
  String provider;
  double purchasePrice;
  int quantity;

  StockDetail({
    required this.id,
    required this.provider,
    required this.purchasePrice,
    required this.quantity,
  });

  factory StockDetail.fromJson(Map<String, dynamic> json) {
    return StockDetail(
      id: json['id'],
      provider: json['provider'],
      purchasePrice: json['purchasePrice'].toDouble(),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'provider': provider,
      'purchasePrice': purchasePrice,
      'quantity': quantity,
    };
  }
}

class Product {
  String id;
  String name;
  String description;
  double price;
  int stock;
  double percentageTax;
  List<StockDetail> stockDetails;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.percentageTax,
    required this.stockDetails,
  });

  // Convertir JSON a objeto Product
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'] is Map<String, dynamic> 
          ? double.parse(json['price']) // Para Decimal128
          : json['price'].toDouble(), // Para Number normal
      description: json['description'],
      stock: json['stock'],
      percentageTax: json['percentageTax'] is Map<String, dynamic> 
          ? (json['percentageTax'] != null) ? double.parse(json['percentageTax']) : 0.0 // Para Decimal128
          : (json['percentageTax'] != null) ? json['percentageTax'].toDouble() : 0.0, // Para Number normal
      stockDetails: (json['stockDetails'] as List)
          .map((detail) => StockDetail.fromJson(detail))
          .toList(),
    );
  }

  // Convertir objeto Product a JSON
  Map<String, dynamic> toJson() {
    Map<String, dynamic> map = {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'percentageTax': percentageTax,
      'stockDetails': stockDetails.map((detail) => detail.toJson()).toList(),
    };

    print("MAP ${map}");
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'percentageTax': percentageTax,
      'stockDetails': stockDetails.map((detail) => detail.toJson()).toList(),
    };
  }

  
}