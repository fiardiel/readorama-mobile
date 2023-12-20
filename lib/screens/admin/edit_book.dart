import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:readoramamobile/screens/auth/login.dart';
import 'package:readoramamobile/screens/landinguser/booklist.dart';
import 'package:readoramamobile/widgets/admin/leftdrawer_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  late String userid = '';
  late String usernameloggedin = '';
  late bool isSuperuser = false;

  @override
  void initState() {
    super.initState();
    getSession();
    fetchProductDetails();
  }

  @override
  dispose() {
    super.dispose();
  }

  getSession() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      userid = pref.getString("userid")!;
      usernameloggedin = pref.getString("username")!;
      isSuperuser = pref.getBool("is_superuser")!;
    });
  }

  Future<void> fetchProductDetails() async {
    final response = await http.get(Uri.parse(
        'http://35.226.89.131/landing-admin/loadbooks-by-id/${widget.productId}'));

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

  Future<void> clearSharedPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  Future<void> performLogout(BuildContext context) async {
    final request = context.read<CookieRequest>();
    try {
      final response =
          await request.logout("http://35.226.89.131/auth/logout/");

      if (response['status']) {
        print('Logout successful');
        // Lakukan update state atau clear data sesuai kebutuhan
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
                content: Text("Successfully Logout! Bye, $usernameloggedin")),
          );
        await clearSharedPreferences();
      } else {
        print('Failed to logout. Status code: ${response['message']}');
      }
    } catch (error) {
      print('Error during logout: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Book Page'),
        backgroundColor: const Color.fromARGB(255, 25, 29, 37),
        foregroundColor: Colors.white,
        actions: [
          if (usernameloggedin.isNotEmpty)
            PopupMenuButton(
              icon: Row(
                children: [
                  const Icon(Icons.account_circle),
                  const SizedBox(width: 4), // Spacer
                  Text(
                    usernameloggedin,
                    style: const TextStyle(
                      color: Colors.white, // Warna amber untuk nama pengguna
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              onSelected: (value) async {
                if (value == 'logout') {
                  await performLogout(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => BookPage()),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(
                    value: 'logout',
                    child: Text('Logout'),
                  ),
                ];
              },
            ),
          if (usernameloggedin.isEmpty)
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
              ),
              child: Text('Login'),
            ),
        ],
      ),
      drawer: LeftDrawerAdmin(
        isLoggedIn: usernameloggedin,
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
                  if (double.tryParse(value)! < 0.0 ||
                      double.tryParse(value)! > 5) {
                    return "Rating must be between 0 and 5";
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
                          'http://35.226.89.131/landing-admin/edit-product-flutter/${widget.productId}'),
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text("Book edited successfully!"),
                      ));
                      // Product updated successfully
                      Navigator.pop(
                          context, true); // Passing 'true' to indicate success
                    } else {
                      // Handle error
                    }
                  }
                  ;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
