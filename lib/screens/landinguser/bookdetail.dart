// ignore_for_file: avoid_print, prefer_const_constructors, must_be_immutable, override_on_non_overriding_member, library_private_types_in_public_api, prefer_const_declarations, unused_local_variable, use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:readoramamobile/models/books.dart';
import 'package:readoramamobile/screens/auth/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class BookDetailPage extends StatefulWidget {
  final Books book;

  const BookDetailPage({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
  late String userId = '';
  late String usernameloggedin = '';
  late bool isSuperuser = false;

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
      userId = pref.getString("userid")!;
      usernameloggedin = pref.getString("username")!;
      isSuperuser = pref.getBool('is_superuser')!;
    });
  }

  Future<void> navigateToLoginPage() async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<String> getUserId() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String userId = pref.getString("userid") ?? "";
    return userId;
  }

  Future<void> addToWishlist() async {
    if (usernameloggedin.isEmpty) {
      navigateToLoginPage();
      return;
    }

    final String endpoint = 'http://localhost:8000/flutter/add-to-wishlist/';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        body: {
          'book_pk': widget.book.pk.toString(),
          'user_id': userId,
        },
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 &&
          responseData['message'] == 'Book added to wishlist successfully') {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text("Book added to Wishlist!")),
          );
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
      }
    } catch (error) {
      print('Error adding to Wishlist: $error');
    }
  }

  Future<void> markAsRead() async {
    if (usernameloggedin.isEmpty) {
      navigateToLoginPage();
      return;
    }

    final String endpoint = 'http://localhost:8000/flutter/add-to-read/';

    try {
      final response = await http.post(
        Uri.parse(endpoint),
        body: {
          'book_pk': widget.book.pk.toString(),
          'user_id': userId,
        },
      );
      final responseData = json.decode(response.body);

      if (response.statusCode == 200 &&
          responseData['message'] == 'Book marked as read successfully') {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text("Book Marked As Read!")),
          );
      } else {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
      }
    } catch (error) {
      print('Error adding to Wishlist: $error');
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
          await request.logout("http://localhost:8000/auth/logout/");

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
        title: Text(widget.book.fields.name),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          color: Colors.black,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name: ${widget.book.fields.name}",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                // ... (your other UI components)
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: addToWishlist,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        backgroundColor: Colors.black,
                      ),
                      child: Text("Add to Wishlist"),
                    ),
                    ElevatedButton(
                      onPressed: markAsRead,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.amber,
                        backgroundColor: Colors.black,
                      ),
                      child: Text("Mark as Read"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
