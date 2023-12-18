import 'package:flutter/material.dart';
import 'package:readoramamobile/widgets/admin/leftdrawer_admin.dart';
import 'package:readoramamobile/widgets/admin/home_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import drawer widget

class AdminHomePage extends StatefulWidget {
  AdminHomePage({Key? key}) : super(key: key);

  @override
  _AdminHomePageState createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final List<AdminHomeItem> items = [
    AdminHomeItem("View Books", Icons.book, Colors.indigo.shade400),
    AdminHomeItem("Add Book", Icons.add_circle_outline_rounded, Colors.blue.shade400),
    AdminHomeItem("Logout", Icons.logout, Colors.red.shade400),
  ];

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Readorama',
        ),
        backgroundColor: const Color.fromARGB(255, 25, 29, 37),
        foregroundColor: Colors.white,
      ),
      drawer: LeftDrawerAdmin(isLoggedIn: usernameloggedin,),
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
