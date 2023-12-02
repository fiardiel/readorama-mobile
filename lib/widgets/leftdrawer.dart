// drawer_widget.dart
// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:readoramamobile/screens/landinguser/booklist.dart';
import 'package:readoramamobile/screens/review/review.dart';
import 'package:readoramamobile/screens/wishlist/wishlist.dart';
import 'package:readoramamobile/screens/review/review_form.dart';
import 'package:readoramamobile/screens/read_page/read_books.dart';

class LeftDrawer extends StatelessWidget {
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
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Wishlist()));
            },
          ),
          ListTile(
            title: Text('Your Review'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReviewListPage()));
            },
          ),
          ListTile(
            title: Text('Review Form'),
            onTap: () {
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const ReviewFormPage()));
            },
          ),
          ListTile(
            title: Text('Read Books'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const ProductPage()));
            },
          ),
        ],
      ),
    );
  }
}
