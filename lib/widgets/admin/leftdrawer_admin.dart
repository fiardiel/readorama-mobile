// drawer_widget.dart
// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:readoramamobile/screens/admin/main_admin.dart';
import 'package:readoramamobile/screens/auth/login.dart';
import 'package:readoramamobile/screens/landinguser/booklist.dart';
import 'package:readoramamobile/screens/read_page/read_books.dart';
import 'package:readoramamobile/screens/review/review.dart';
import 'package:readoramamobile/screens/review/review_form.dart';
import 'package:readoramamobile/screens/wishlist/wishlist.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LeftDrawerAdmin extends StatefulWidget {
  final String isLoggedIn;

  const LeftDrawerAdmin({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  _LeftDrawerAdminState createState() => _LeftDrawerAdminState();
}

class _LeftDrawerAdminState extends State<LeftDrawerAdmin> {
  late String userid = '';
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
      userid = pref.getString("userid")!;
      usernameloggedin = pref.getString("username")!;
      isSuperuser = pref.getBool("is_superuser")!;
    });
  }

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
              'ReadORama \nfor $usernameloggedin',
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


  void _navigateToPage(BuildContext context, Widget page) {
    if (widget.isLoggedIn.isNotEmpty) {
      print(widget.isLoggedIn);
      Navigator.push(context, MaterialPageRoute(builder: (context) => page));
    } else {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LoginPage()));
    }
  }
}
