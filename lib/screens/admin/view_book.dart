// ignore_for_file: use_build_context_synchronously, prefer_const_constructors, sized_box_for_whitespace, library_private_types_in_public_api, avoid_print, non_constant_identifier_names, unnecessary_string_interpolations

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:readoramamobile/models/books.dart';
import 'package:readoramamobile/screens/admin/book_detail.dart';
import 'package:readoramamobile/screens/admin/edit_book.dart';
import 'package:readoramamobile/screens/auth/login.dart';
import 'package:readoramamobile/screens/landinguser/booklist.dart';
import 'package:readoramamobile/widgets/admin/leftdrawer_admin.dart';
import 'package:readoramamobile/widgets/leftdrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminBookPage extends StatefulWidget {
  const AdminBookPage({Key? key}) : super(key: key);

  @override
  _AdminBookPageState createState() => _AdminBookPageState();
}

class _AdminBookPageState extends State<AdminBookPage> {
  late String userid = '';
  late String usernameloggedin = '';
  late bool isSuperuser = false;
  List<Books> _books = [];
  TextEditingController searchController = TextEditingController();

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

  Future<List<Books>> searchBooks(String query) async {
    var url =
        Uri.parse('http://35.226.89.131/landing-admin/search-books-flutter');
    var uri = Uri.http(url.authority, url.path, {"search_term": query});

    var response = await http.get(
      uri,
      headers: {"Content-Type": "application/json"},
    );

    var data = jsonDecode(utf8.decode(response.bodyBytes));

    List<Books> list_book = [];
    for (var d in data) {
      if (d != null) {
        list_book.add(Books.fromJson(d));
      }
    }
    list_book.sort((a, b) => b.fields.rating.compareTo(a.fields.rating));
    return list_book;
  }

  Future<List<Books>> fetchProduct() async {
    var url = Uri.parse('http://35.226.89.131/loadbooks/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    var data = jsonDecode(utf8.decode(response.bodyBytes));

    List<Books> list_item = [];
    for (var d in data) {
      if (d != null) {
        list_item.add(Books.fromJson(d));
      }
    }
    list_item.sort((a, b) => b.fields.rating.compareTo(a.fields.rating));
    return list_item;
  }

  Future<void> navigateToEditProductPage(int productId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(productId: productId),
      ),
    );

    if (result != null && result == true) {
      setState(() {
        fetchProduct(); // Triggering fetchProduct() to refresh the list
      });
    }
  }

  Future<void> navigateToBookDetailPage(int productId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookDetailPage(BookId: productId),
      ),
    );

    if (result != null && result == true) {
      setState(() {
        fetchProduct(); // Triggering fetchProduct() to refresh the list
      });
    }
  }

  Future<void> clearSharedPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  Future<void> performLogout(BuildContext context) async {
    final request = context.read<CookieRequest>();
    try {
      final response =
          await request.logout("http://35.226.89.131/auth/logout/");

      if (response['status']) {
        print('Logout successful');
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
                  const SizedBox(width: 4),
                  Text(
                    usernameloggedin,
                    style: const TextStyle(
                      color: Colors.white,
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
      drawer: isSuperuser
          ? LeftDrawerAdmin(isLoggedIn: usernameloggedin)
          : LeftDrawer(isLoggedIn: usernameloggedin),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (String value) async {
                if (value.isEmpty) {
                  List<Books> allBooks = await fetchProduct();
                  setState(() {
                    _books = allBooks;
                  });
                } else {
                  try {
                    List<Books> searchedBooks = await searchBooks(value);
                    setState(() {
                      _books = searchedBooks;
                    });
                  } catch (error) {
                    print('Error during search: $error');
                  }
                }
              },
              decoration: InputDecoration(
                hintText: 'Search books...',
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () async {},
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: searchController.text.isEmpty && _books.isEmpty
                  ? fetchProduct()
                  : searchBooks(searchController.text),
              builder: (context, AsyncSnapshot<List<Books>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "No books available.",
                          style: TextStyle(
                            color: Color.fromARGB(255, 25, 29, 37),
                            fontSize: 20,
                          ),
                        ),
                        SizedBox(height: 8),
                      ],
                    ),
                  );
                } else {
                  return LayoutBuilder(builder: (context, constraints) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) {
                        return Card(
                          color: Color.fromARGB(255, 25, 29, 37),
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data![index].fields.name,
                                  style: const TextStyle(
                                      fontSize: 18.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        navigateToBookDetailPage(
                                            snapshot.data![index].pk);
                                      },
                                      child: Text(
                                        'View Details',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
