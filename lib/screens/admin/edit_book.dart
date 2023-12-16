import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditProductPage extends StatefulWidget {
  final int productId; // Assuming this is the unique ID for the product to edit

  EditProductPage({required this.productId});

  @override
  _EditProductPageState createState() => _EditProductPageState();
}

class _EditProductPageState extends State<EditProductPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _authorController = TextEditingController();
  TextEditingController _ratingController = TextEditingController();
  TextEditingController _numReviewController = TextEditingController();
  TextEditingController _priceController = TextEditingController();
  TextEditingController _yearController = TextEditingController();
  TextEditingController _genreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch product details using widget.productId and set the TextEditingController values
    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    final response = await http.get(Uri.parse(
        'http://127.0.0.1:8000/landing-admin/loadbooks-by-id/${widget.productId}'));

    if (response.statusCode == 200) {
      final productList = jsonDecode(response.body) as List; // Parse as a List
      final productData = productList.isNotEmpty
          ? productList.first
          : null; // Access the first item

      if (productData != null) {
        setState(() {
          _nameController.text = productData['fields']['name'];
          _authorController.text = productData['fields']['author'];
          _ratingController.text = productData['fields']['rating'].toString();
          _numReviewController.text =
              productData['fields']['num_review'].toString();
          _priceController.text = productData['fields']['price'].toString();
          _yearController.text = productData['fields']['year'].toString();
          _genreController.text = productData['fields']['genre'];
        });
      } else {
        // Handle case where no product data is retrieved
      }
    } else {
      // Handle error or show a message that product details couldn't be fetched
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
                // Validation, onChanged, and other properties...
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Name cannot be empty!";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _authorController,
                decoration: const InputDecoration(labelText: 'Author'),
                // Validation, onChanged, and other properties...
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Author cannot be empty!";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _ratingController,
                decoration: const InputDecoration(labelText: 'Rating'),
                // Validation, onChanged, and other properties...
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Rating cannot be empty!";
                  }
                  if (double.tryParse(value) == null) {
                    return "Rating must be a number!";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _numReviewController,
                decoration: const InputDecoration(labelText: 'Review Amount'),
                // Validation, onChanged, and other properties...
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Review amount cannot be empty!";
                  }
                  if (int.tryParse(value) == null) {
                    return "Review amount must be a number!";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Price'),
                // Validation, onChanged, and other properties...
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Price cannot be empty!";
                  }
                  if (int.tryParse(value) == null) {
                    return "Price must be a number!";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _yearController,
                decoration: const InputDecoration(labelText: 'Year'),
                // Validation, onChanged, and other properties...
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Year cannot be empty!";
                  }
                  if (int.tryParse(value) == null) {
                    return "Year must be a number!";
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _genreController,
                decoration: const InputDecoration(labelText: 'Genre'),
                // Validation, onChanged, and other properties...
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return "Genre cannot be empty!";
                  }
                  return null;
                },
              ),
              // Other TextFormField widgets for different fields...
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final response = await http.put(
                      Uri.parse(
                          'http://127.0.0.1:8000/landing-admin/edit-product-flutter/${widget.productId}'),
                      headers: {
                        'Content-Type': 'application/json',
                      },
                      body: jsonEncode({
                        'name': _nameController.text,
                        'author': _authorController.text,
                        'rating': double.parse(_ratingController.text),
                        'num_review': int.parse(_numReviewController.text),
                        'price': int.parse(_priceController.text),
                        'year': int.parse(_yearController.text),
                        'genre': _genreController.text,
                      }),
                    );

                    if (response.statusCode == 200) {
                      // Product updated successfully
                      Navigator.pop(context, true); // Passing 'true' to indicate success
                    } else {
                      // Handle error
                    }
                  }
                ;},
              ),
            ],
          ),
        ),
      ),
    );
  }
}
