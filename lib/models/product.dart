class Product {
  String id;
  String name;
  String description;
  double price;
  int stock;
  double percentageTax;

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
      percentageTax: json['percentageTax'],
    );
  }

  // Convertir objeto Product a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'percentageTax': percentageTax,
    };
  }

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.percentageTax,
  });
}