// drawer_widget.dart
// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:readoramamobile/screens/admin/main_admin.dart';
import 'package:readoramamobile/screens/landinguser/booklist.dart';
import 'package:readoramamobile/screens/read_page/read_books.dart';
import 'package:readoramamobile/screens/review/review.dart';
import 'package:readoramamobile/screens/review/review_form.dart';
import 'package:readoramamobile/screens/wishlist/wishlist.dart';

class LeftDrawerAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 25, 29, 37) ,
            ),
            child: Text(
              'ReadORama',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home_outlined),
            title: Text('Home'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const BookPage()));
            },
          ),
          ListTile(
            leading: const Icon(Icons.shopping_basket),
            title: Text('Wishlist'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const Wishlist()));
            },
          ),
          ListTile(
            leading : Icon(Icons.book),
            title: Text('Admin Page'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => AdminHomePage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.rate_review),
            title: Text('Your Review'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const ReviewListPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.rate_review),
            title: Text('Review Form'),
            onTap: () {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) => const ReviewFormPage()));
            },
          ),
          ListTile(
            leading: Icon(Icons.checklist_rounded),
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
