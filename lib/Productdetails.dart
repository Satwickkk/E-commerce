import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ProductDetailsScreen extends StatelessWidget {
  final int productId;

  ProductDetailsScreen({required this.productId});

  Future<Map<String, dynamic>> fetchProductDetails() async {
    try {
      final response = await http.get(Uri.parse('https://dummyjson.com/products/$productId'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load product details');
      }
    } catch (e) {
      throw Exception('Error fetching product details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Product Details')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchProductDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final product = snapshot.data!;
            final images = product['images'];
            return ListView(
              children: [
                if (images.isNotEmpty) Image.network(images[0]),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product['title'], style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      Text('\$${product['price']}', style: TextStyle(fontSize: 20, color: Colors.green)),
                      SizedBox(height: 16),
                      Text(product['description'], style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ],
            );
          }
          return Center(child: Text('No data found'));
        },
      ),
    );
  }
}
