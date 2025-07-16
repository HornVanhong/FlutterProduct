import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class ProductProvider with ChangeNotifier {
  final String apiUrl = "http://localhost:3000/products";

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];

  String _searchQuery = '';
  Timer? _debounce;

  int _page = 1;
  final int _limit = 10;
  bool _isFetchingMore = false;

  List<Product> get filteredProducts => _filteredProducts;

  // Fetch first page & reset
  Future<void> fetchProducts() async {
    _page = 1;
    final response = await http.get(
      Uri.parse("$apiUrl?page=$_page&limit=$_limit"),
    );
    if (response.statusCode == 200) {
      _allProducts = (json.decode(response.body) as List)
          .map((p) => Product.fromJson(p))
          .toList();
      _applyFilters();
    } else {
      // handle error
      throw Exception('Failed to load products');
    }
  }

  Future<void> fetchMoreProducts() async {
    if (_isFetchingMore) return;
    _isFetchingMore = true;
    _page++;
    final response = await http.get(
      Uri.parse("$apiUrl?page=$_page&limit=$_limit"),
    );
    if (response.statusCode == 200) {
      final List<Product> newProducts = (json.decode(response.body) as List)
          .map((p) => Product.fromJson(p))
          .toList();

      print('Fetching page $_page');
      print('New products fetched: ${newProducts.length}');
      print('Total products before append: ${_allProducts.length}');

      // Append only unique products (avoid duplicates)
      for (var newProduct in newProducts) {
        final exists = _allProducts.any((p) => p.id == newProduct.id);
        if (!exists) {
          _allProducts.add(newProduct);
        }
      }

      if (newProducts.isEmpty) {
        _page--; // revert page if no new products
      }

      _applyFilters();
    } else {
      _page--;
      throw Exception('Failed to load more products');
    }
    _isFetchingMore = false;
  }

  // Apply search filter on _allProducts
  void _applyFilters() {
    if (_searchQuery.isEmpty) {
      _filteredProducts = List.from(_allProducts);
    } else {
      _filteredProducts = _allProducts
          .where(
            (p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _debounce?.cancel();
    _debounce = Timer(Duration(milliseconds: 500), () {
      _applyFilters();
    });
  }

  void sortBy(String key) {
    if (key == 'price') {
      _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
    } else if (key == 'stock') {
      _filteredProducts.sort((a, b) => a.stock.compareTo(b.stock));
    }
    notifyListeners();
  }

  Future<void> addProduct(Product product) async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      await fetchProducts();
    } else {
      throw Exception('Failed to add product');
    }
  }

  Future<void> updateProduct(Product product) async {
    final response = await http.put(
      Uri.parse("$apiUrl?id=${product.id}"),
      headers: {"Content-Type": "application/json"},
      body: json.encode(product.toJson()),
    );
    if (response.statusCode == 200) {
      await fetchProducts();
    } else {
      throw Exception('Failed to update product');
    }
  }

  Future<void> deleteProduct(int id) async {
    final response = await http.delete(Uri.parse("$apiUrl?id=$id"));
    if (response.statusCode == 200) {
      await fetchProducts();
    } else {
      throw Exception('Failed to delete product');
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
