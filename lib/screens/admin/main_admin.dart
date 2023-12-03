import 'package:flutter/material.dart';
import 'package:readoramamobile/widgets/admin/leftdrawer_admin.dart';
import 'package:readoramamobile/widgets/admin/home_admin.dart';
// import drawer widget

class AdminHomePage extends StatelessWidget {
  AdminHomePage({Key? key}) : super(key: key);

  final List<AdminHomeItem> items = [
    AdminHomeItem("View Books", Icons.book, Colors.indigo.shade400),
    AdminHomeItem("Add Book", Icons.add_circle_outline_rounded, Colors.blue.shade400),
    AdminHomeItem("Logout", Icons.logout, Colors.red.shade400),
  ];

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Readorama',
        ),
        backgroundColor: const Color.fromARGB(255, 25, 29, 37) ,
        foregroundColor: Colors.white,
      ),
      drawer: LeftDrawerAdmin(),
      body: SingleChildScrollView(
        // Scrolling wrapper widget
        child: Padding(
          padding: const EdgeInsets.all(10.0), // Set padding for the page
          child: Column(
            // Widget to display children vertically
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                // Text widget to display text with center alignment and appropriate style
                child: Text(
                  'Readorama', // Text indicating the shop name
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Grid layout
              GridView.count(
                // Container for our cards.
                primary: true,
                padding: const EdgeInsets.all(20),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 3,
                shrinkWrap: true,
                children: items.map((AdminHomeItem item) {
                  // Iteration for each item
                  return AdminHomeCard(item);
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
