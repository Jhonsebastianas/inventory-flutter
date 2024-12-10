import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart'; // Asegúrate de importar el servicio
import 'dart:convert';

class ProductProvider extends ChangeNotifier {
  bool isLoading = false;
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  final ApiService _apiService;

  ProductProvider(this._apiService) {
    fetchProducts();
  }

  List<Product> get products => _products;
  List<Product> get filteredProducts =>
      _filteredProducts.isEmpty ? _products : _filteredProducts;

  // Cargar productos desde la API
  Future<void> fetchProducts() async {
    isLoading = true;
    try {
      final response = await _apiService.getProducts();
      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        _products = data.map((product) => Product.fromJson(product)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load products');
      }
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // Agregar un nuevo producto
  Future<void> addProduct(Product product) async {
    final response = await _apiService.createProduct(product.toJson());
    print(response.body);
    if (response.statusCode == 201) {
      _products.add(product);
      notifyListeners();
    } else {
      throw Exception('Failed to add product');
    }
  }

  // Actualizar un producto existente
  Future<void> updateProduct(String id, Product updatedProduct) async {
    final response =
        await _apiService.updateProduct(id, updatedProduct.toJson());
    if (response.statusCode == 200) {
      int index = _products.indexWhere((prod) => prod.id == id);
      if (index != -1) {
        _products[index] = updatedProduct;
        notifyListeners();
      }
    } else {
      throw Exception('Failed to update product');
    }
  }

  // Eliminar un producto
  Future<void> deleteProduct(String id) async {
    final response = await _apiService.deleteProduct(id);
    if (response.statusCode == 200) {
      _products.removeWhere((prod) => prod.id == id);
      notifyListeners();
    } else {
      throw Exception('Failed to delete product');
    }
  }

  // Buscar productos por nombre
  Future<void> searchProducts(String query) async {
    final response = await _apiService.searchProducts(query);
    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      _filteredProducts =
          data.map((product) => Product.fromJson(product)).toList();
      notifyListeners();
    } else {
      throw Exception('Failed to search products');
    }
  }

  void clearFilters() {
    _filteredProducts = [];
    notifyListeners();
  }
}
