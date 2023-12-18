// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:readoramamobile/screens/auth/login.dart';
import 'package:readoramamobile/screens/landinguser/booklist.dart';
import 'package:readoramamobile/screens/review/review.dart';
import 'package:readoramamobile/screens/wishlist/wishlist.dart';
import 'package:readoramamobile/screens/review/review_form.dart';
import 'package:readoramamobile/screens/read_page/read_books.dart';

class LeftDrawer extends StatelessWidget {
  final String isLoggedIn;

  const LeftDrawer({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.black,
            ),
            child: Text(
              'ReadORama',
              style: TextStyle(
                color: Colors.amber,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const BookPage()));
            },
          ),
          ListTile(
            title: Text('Wishlist'),
            onTap: () {
              _navigateToPage(context, const Wishlist());
            },
          ),
          ListTile(
            title: Text('Your Review'),
            onTap: () {
              _navigateToPage(context, const ReviewListPage());
            },
          ),
          ListTile(
            title: Text('Review Form'),
            onTap: () {
              _navigateToPage(context, const ReviewFormPage());
            },
          ),
          ListTile(
            title: Text('Read Books'),
            onTap: () {
              _navigateToPage(context, const ProductPage());
            },
          ),
        ],
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    if (isLoggedIn.isNotEmpty) {
      print(isLoggedIn);
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}
