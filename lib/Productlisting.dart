import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CartScreen extends StatelessWidget {
  final List<Map<String, dynamic>> cart;
  final Function(Map<String, dynamic>) removeFromCart;
  final Function(Map<String, dynamic>) increaseQuantity;
  final Function(Map<String, dynamic>) decreaseQuantity;

  CartScreen({
    required this.cart,
    required this.removeFromCart,
    required this.increaseQuantity,
    required this.decreaseQuantity,
  });

  double getTotalAmount() {
    return cart.fold(0, (total, item) => total + (item['price'] * item['quantity']));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shopping Cart')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: cart.length,
              itemBuilder: (context, index) {
                final item = cart[index];
                return ListTile(
                  title: Text(item['title']),
                  subtitle: Text('\$${item['price']} x ${item['quantity']}'),
                  trailing: IconButton(
                    icon: Icon(Icons.remove_shopping_cart),
                    onPressed: () {
                      removeFromCart(item);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item['title']} removed from cart')),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text('Total: \$${getTotalAmount().toStringAsFixed(2)}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class ProductListingScreen extends StatefulWidget {
  const ProductListingScreen({super.key});

  @override
  _ProductListingScreenState createState() => _ProductListingScreenState();
}

class _ProductListingScreenState extends State<ProductListingScreen> {
  List<dynamic> products = [];
  List<Map<String, dynamic>> cart = [];
  double minPrice = 0;
  double maxPrice = 10000; // Set a reasonable default max price
  String searchQuery = ''; // Define the searchQuery variable

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    final response = await http.get(Uri.parse('https://dummyjson.com/products'));
    if (response.statusCode == 200) {
      setState(() {
        products = json.decode(response.body)['products'];
      });
    }
  }

  void addToCart(Map<String, dynamic> product) {
    bool exists = false;
    for (var item in cart) {
      if (item['id'] == product['id']) {
        item['quantity'] += 1;
        exists = true;
        break;
      }
    }
    if (!exists) {
      cart.add({...product, 'quantity': 1});
    }
    setState(() {});
  }

  void removeFromCart(Map<String, dynamic> item) {
    setState(() {
      cart.removeWhere((cartItem) => cartItem['id'] == item['id']);
    });
  }

  void increaseQuantity(Map<String, dynamic> item) {
    setState(() {
      item['quantity'] += 1;
    });
  }

  void decreaseQuantity(Map<String, dynamic> item) {
    setState(() {
      if (item['quantity'] > 1) {
        item['quantity'] -= 1;
      } else {
        cart.removeWhere((cartItem) => cartItem['id'] == item['id']);
      }
    });
  }

  void openFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Filter Products'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Min Price:'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  minPrice = double.tryParse(value) ?? 0;
                },
              ),
              Text('Max Price:'),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  maxPrice = double.tryParse(value) ?? 10000;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  products = products.where((product) {
                    double price = product['price'];
                    return price >= minPrice && price <= maxPrice;
                  }).toList();
                });
              },
              child: Text('Apply Filter'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> filteredProducts = products.where((product) {
      return product['title'].toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();

    // Sort the filtered products to show matching ones at the top
    filteredProducts.sort((a, b) {
      return a['title'].toLowerCase().indexOf(searchQuery.toLowerCase())
          .compareTo(b['title'].toLowerCase().indexOf(searchQuery.toLowerCase()));
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: openFilterDialog,
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    cart: cart,
                    removeFromCart: removeFromCart,
                    increaseQuantity: increaseQuantity,
                    decreaseQuantity: decreaseQuantity,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search Products',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
              ),
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];
                return Card(
                  child: Column(
                    children: [
                      Image.network(product['thumbnail']),
                      Text(product['title'], style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('\$${product['price']}'),
                      ElevatedButton(
                        onPressed: () => addToCart(product),
                        child: Text('Add to Cart'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
