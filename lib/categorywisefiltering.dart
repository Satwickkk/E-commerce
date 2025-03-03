import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoryFilterScreen extends StatefulWidget {
  @override
  _CategoryFilterScreenState createState() => _CategoryFilterScreenState();
}

class _CategoryFilterScreenState extends State<CategoryFilterScreen> {
  List<dynamic> categories = [];
  String? selectedCategory;
  List<dynamic> filteredProducts = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products/categories'));
      if (response.statusCode == 200) {
        setState(() {
          categories = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      // Handle error gracefully
      print('Error fetching categories: $e');
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products/category/$category'));
      if (response.statusCode == 200) {
        setState(() {
          filteredProducts = json.decode(response.body)['products'];
        });
      } else {
        throw Exception('Failed to load products for category: $category');
      }
    } catch (e) {
      // Handle error gracefully
      print('Error fetching products by category: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Category Filter')),
      body: Column(
        children: [
          DropdownButton<String>(
            value: selectedCategory,
            hint: Text('Select a category'),
            items: categories.map((category) {
              return DropdownMenuItem<String>(
                value: category,
                child: Text(category),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedCategory = value;
                  fetchProductsByCategory(value);
                });
              }
            },
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return ListTile(
                  title: Text(product['title']),
                  subtitle: Text('\$${product['price']}'),
                  leading: Image.network(product['thumbnail']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
