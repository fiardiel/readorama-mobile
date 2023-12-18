import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:readoramamobile/models/books.dart';
import 'package:readoramamobile/screens/auth/login.dart';
import 'package:readoramamobile/screens/landinguser/booklist.dart';
import 'package:readoramamobile/widgets/admin/leftdrawer_admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookDetailPage extends StatefulWidget {
  final Books book;

  const BookDetailPage({Key? key, required this.book}) : super(key: key);

  @override
  _BookDetailPageState createState() => _BookDetailPageState();
}

class _BookDetailPageState extends State<BookDetailPage> {
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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 4.0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.book.fields.name,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text("Author: ${widget.book.fields.author}"),
                  const SizedBox(height: 10),
                  Text("Rating: ${widget.book.fields.rating}"),
                  const SizedBox(height: 10),
                  Text("Review amount: ${widget.book.fields.numReview}"),
                  const SizedBox(height: 10),
                  Text("Price: ${widget.book.fields.price}"),
                  const SizedBox(height: 10),
                  Text("Year: ${widget.book.fields.year}"),
                  const SizedBox(height: 10),
                  Text("Genre: ${widget.book.fields.genre}"),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(
                          context); // Navigate back to the item list page
                    },
                    child: const Text('Back to Book List'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
