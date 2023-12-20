// ignore_for_file: use_build_context_synchronously, unnecessary_string_interpolations, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:readoramamobile/screens/admin/review_admin.dart';
import 'package:readoramamobile/screens/admin/view_book.dart';
import 'package:readoramamobile/screens/admin/add_book.dart';

class AdminHomeItem {
  final String name;
  final IconData icon;
  final Color color;
  AdminHomeItem(this.name, this.icon, this.color);
}

class AdminHomeCard extends StatelessWidget {
  final AdminHomeItem item;

  const AdminHomeCard(this.item, {Key? key}); // Constructor

  @override
  Widget build(BuildContext context) {
    return Material(
      color: item.color,
      child: InkWell(
        // Area responsive to touch
        onTap: () async {
          // Show SnackBar when clicked
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(
                content: Text("You pressed the ${item.name} button!")));

          // Navigate to the appropriate route (depending on the button type)
          if (item.name == "Add Book") {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const BookFormPage(),
                ));
          } else if (item.name == "View Books") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminBookPage()),
            );
          } else if (item.name == "Reviews") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AdminReviewListPage()),
            );
          }
        },
        child: Container(
          // Container to hold Icon and Text
          padding: const EdgeInsets.all(8),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  color: Colors.white,
                  size: 30.0,
                ),
                const Padding(padding: EdgeInsets.all(3)),
                Text(
                  item.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
