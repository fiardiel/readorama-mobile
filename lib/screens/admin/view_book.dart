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

  Future<List<Books>> fetchProduct() async {
    var url = Uri.parse('http://localhost:8000/loadbooks/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    // decode the response to JSON
    var data = jsonDecode(utf8.decode(response.bodyBytes));

    // convert the JSON to Product object
    List<Books> list_item = [];
    for (var d in data) {
      if (d != null) {
        list_item.add(Books.fromJson(d));
      }
    }
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
        drawer: isSuperuser ? LeftDrawerAdmin(isLoggedIn: usernameloggedin) : LeftDrawer(isLoggedIn: usernameloggedin),
        body: FutureBuilder(
            future: fetchProduct(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (!snapshot.hasData) {
                  return const Column(
                    children: [
                      Text(
                        "No book data available.",
                        style:
                            TextStyle(color: Color(0xff59A5D8), fontSize: 20),
                      ),
                      SizedBox(height: 8),
                    ],
                  );
                } else {
                  // Existing code...
                  return Center(
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 30.0,
                              mainAxisSpacing: 60.0,
                            ),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (_, index) => Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => BookDetailPage(
                                            book: snapshot.data![index],
                                          ),
                                        ),
                                      );
                                    },
                                    child: SizedBox(
                                      width: MediaQuery.of(context).size.width *
                                          0.1, // Set width based on screen width
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.05, // Adjust the height as needed
                                      child: Card(
                                        margin: const EdgeInsets.all(2.0),
                                        elevation: 4.0,
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.01),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${snapshot.data![index].fields.name}",
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.01,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines:
                                                    2, // Limits to 2 lines
                                                overflow: TextOverflow
                                                    .ellipsis, // Shows ellipsis when overflow
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                "${snapshot.data![index].fields.author}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.009,
                                                ),
                                                maxLines: 1, // Limits to 1 line
                                                overflow: TextOverflow
                                                    .ellipsis, // Shows ellipsis when overflow
                                              ),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2, // Set width based on screen width
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      // Implement the 'Delete Book' functionality
                                                      final bookToDeletePK =
                                                          snapshot
                                                              .data![index].pk;
                                                      // Send request to Django and wait for the response
                                                      final response =
                                                          await http.delete(
                                                        Uri.parse(
                                                            'http://localhost:8000/landing-admin/delete-book-flutter/$bookToDeletePK'),
                                                        headers: {
                                                          "Content-Type":
                                                              "application/json"
                                                        },
                                                      );
                                                      if (response.statusCode ==
                                                          200) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                          content: Text(
                                                              "Product deleted successfully!"),
                                                        ));
                                                        // You may want to refresh the product list after deletion
                                                        setState(() {
                                                          snapshot.data!.remove(
                                                              (book) =>
                                                                  book.pk ==
                                                                  bookToDeletePK);
                                                        });
                                                      } else {
                                                        print(
                                                            'Failed to delete product. Status code: ${response.statusCode}');
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                          content: Text(
                                                              "Failed to delete the product."),
                                                        ));
                                                      }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: Colors
                                                          .red, // Set the button color to red
                                                      padding: EdgeInsets.all(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.001), // Set padding based on screen width
                                                    ),
                                                    child: Text(
                                                      'Delete Book',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .white, // Set text color to white
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.01,
                                                      ),
                                                    ),
                                                  )),

                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2, // Set width based on screen width
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      final bookToEditPK =
                                                          snapshot
                                                              .data![index].pk;
                                                      navigateToEditProductPage(
                                                          bookToEditPK);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: Colors
                                                          .blue, // Set the button color to blue
                                                      padding: EdgeInsets.all(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.001), // Add padding to the button
                                                    ),
                                                    child: Text(
                                                      'Edit Book',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .white, // Set text color to white
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.009, // Set font size based on screen width
                                                      ),
                                                    ),
                                                  )),
                                              // Add more content or adjust sizing as necessary
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ))),
                  );
                }
              }
            }));
  }
}
