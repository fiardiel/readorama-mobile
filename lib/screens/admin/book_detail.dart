// ignore_for_file: prefer_const_constructors, use_build_context_synchronously, library_private_types_in_public_api, avoid_print, non_constant_identifier_names

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:readoramamobile/models/books.dart';
import 'package:readoramamobile/screens/admin/edit_book.dart';
import 'package:readoramamobile/screens/auth/login.dart';
import 'package:readoramamobile/screens/landinguser/booklist.dart';
import 'package:readoramamobile/widgets/admin/leftdrawer_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BookDetailPage extends StatefulWidget {
  final int BookId;

  const BookDetailPage({Key? key, required this.BookId}) : super(key: key);

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late String userid = '';
  late String usernameloggedin = '';
  late bool isSuperuser = false;

  Future<void> navigateToEditProductPage(int productId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(productId: productId),
      ),
    );

    if (result != null && result == true) {
      setState(() {
        fetchBookDetails(); // Triggering fetchProduct() to refresh the list
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getSession();
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

  Future<void> clearSharedPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  Future<Books?> fetchBookDetails() async {
    var url = Uri.parse(
        'http://35.226.89.131/landing-admin/loadbooks-by-id/${widget.BookId}');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      // Check if the response is not empty
      if (response.body.isNotEmpty) {
        // Decode the response to a list of JSON objects
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        // Check if the list is not empty
        if (data.isNotEmpty) {
          // Take the first item from the list
          var firstItem = data[0];

          // Convert the JSON to a Reviews object
          Books book = Books.fromJson(firstItem);

          return book;
        }
      }
    }
    // If there's an issue with the response, or if the data is empty, return null
    return null;
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
      drawer: LeftDrawerAdmin(isLoggedIn: usernameloggedin),
      body: FutureBuilder<Books?>(
        future: fetchBookDetails(),
        builder: (context, AsyncSnapshot<Books?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (snapshot.data == null) {
            return const Center(child: Text('No data available'));
          } else {
            Books bookDetails =
                snapshot.data!; // Assuming you want the first item

            return LayoutBuilder(builder: (context, constraints) {
              bool isLargeScreen = constraints.maxWidth > 600;
              return SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          bookDetails.fields.name,
                          style: const TextStyle(
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text("Author: ${bookDetails.fields.author}",
                            style: TextStyle(color: Colors.black)),
                        const SizedBox(height: 10),
                        Text("Rating: ${bookDetails.fields.rating}",
                            style: TextStyle(color: Colors.black)),
                        const SizedBox(height: 10),
                        Text("Review amount: ${bookDetails.fields.numReview}",
                            style: TextStyle(color: Colors.black)),
                        const SizedBox(height: 10),
                        Text("Price: ${bookDetails.fields.price}",
                            style: TextStyle(color: Colors.black)),
                        const SizedBox(height: 10),
                        Text("Year: ${bookDetails.fields.year}",
                            style: TextStyle(color: Colors.black)),
                        const SizedBox(height: 10),
                        Text("Genre: ${bookDetails.fields.genre}",
                            style: TextStyle(color: Colors.black)),
                        ElevatedButton(
                          onPressed: () {
                            navigateToEditProductPage(bookDetails.pk);
                          },
                          child: Text(
                            'Edit Book',
                            style: TextStyle(
                              color: isLargeScreen
                                  ? Colors.white
                                  : const Color.fromARGB(255, 25, 29, 37),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            final bookToDeletePK = bookDetails.pk;
                            final response = await http.delete(
                              Uri.parse(
                                  'http://35.226.89.131/landing-admin/delete-book-flutter/$bookToDeletePK'),
                              headers: {"Content-Type": "application/json"},
                            );
                            if (response.statusCode == 200) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Product deleted successfully!"),
                                ),
                              );
                              Navigator.pop(context, true);
                            } else {
                              print(
                                  'Failed to delete product. Status code: ${response.statusCode}');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Failed to delete the product."),
                                ),
                              );
                            }
                          },
                          child: Text('Delete Book',
                              style: TextStyle(
                                color: isLargeScreen
                                    ? Colors.white
                                    : const Color.fromARGB(255, 25, 29, 37),
                              )),
                        ),
                      ],
                    )),
              );
            });
          }
        },
      ),
    );
  }
}
