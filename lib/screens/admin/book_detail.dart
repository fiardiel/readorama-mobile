import 'package:flutter/material.dart';
import 'package:readoramamobile/models/books.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: const Color.fromARGB(255, 25, 29, 37),
        foregroundColor: Colors.white,
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
