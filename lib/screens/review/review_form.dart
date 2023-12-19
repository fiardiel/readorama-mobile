// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, unused_import

import 'dart:convert';
import 'package:readoramamobile/models/review.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
// Import the previously created drawer
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:readoramamobile/screens/review/review.dart';
import 'package:readoramamobile/widgets/admin/leftdrawer_admin.dart';
import 'package:readoramamobile/widgets/leftdrawer.dart'; // Import your LeftDrawer widget here
import 'package:shared_preferences/shared_preferences.dart';

class ReviewFormPage extends StatefulWidget {
  final int booktoReview;
  ReviewFormPage({required this.booktoReview});

  @override
  _ReviewFormPageState createState() => _ReviewFormPageState();
}

class _ReviewFormPageState extends State<ReviewFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _review_title = "";
  TextEditingController _book_title = TextEditingController();
  int _rating = 0;
  String _review = "";
  late String userid = '';
  late String usernameloggedin = '';
  late bool isSuperuser = false;

  get http => null;

  @override
  void initState() {
    super.initState();
    getSession();
    fetchBookDetails(context);
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
      isSuperuser = pref.getBool('is_superuser')!;
    });
  }

fetchBookDetails(BuildContext context) async {
    final response = await context.read<CookieRequest>().get(
        'http://127.0.0.1:8000/review/load-books-id/${widget.booktoReview}');
    String bookName = response['book_name'];
    _book_title.text = bookName;
    return bookName;

  }


  @override
  Widget build(BuildContext context) {
    Widget drawerWidget;

    if (isSuperuser) {
      drawerWidget = LeftDrawerAdmin(isLoggedIn: usernameloggedin);
    } else {
      drawerWidget = LeftDrawer(isLoggedIn: usernameloggedin);
    }

    final request = context.watch<CookieRequest>();


    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text('Add Review'),
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      // Add the previously created drawer here
      drawer: drawerWidget,
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Review Title",
                    labelText: "Review Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _review_title = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Review Title cannot be empty!";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _book_title,
                  decoration: InputDecoration(
                    hintText: "Book Title",
                    labelText: "Book Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {});
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Book Title cannot be empty!";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Rating",
                    labelText: "Rating",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _rating = int.tryParse(value ?? "0") ?? 0;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Rating cannot be empty!";
                    }
                    if (int.tryParse(value) == null) {
                      return "Rating must be a number!";
                    }
                    return null;
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Review",
                    labelText: "Review",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _review = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Review cannot be empty!";
                    }
                    return null;
                  },
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Send request to Django and wait for the response
                        final response = await request.postJson(
                            "http://127.0.0.1:8000/review/add-review-flutter/${widget.booktoReview}",
                            jsonEncode(<String, dynamic>{
                              'reviewTitle': _review_title,
                              'review': _review,
                              'ratingNew': _rating.toString(),
                              'bookName': _book_title.text,
                              'user': userid
      
                            }));

                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content: Text("New Review has saved successfully!"),
                          ));
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ReviewListPage()),
                          );
                        } else {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            content:
                                Text("Something went wrong, please try again."),
                          ));
                        }
                      }
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(color: Colors.amber),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
