// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, list_remove_unrelated_type, avoid_print, library_private_types_in_public_api, non_constant_identifier_names, use_key_in_widget_constructors, annotate_overrides

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:readoramamobile/models/review.dart';
import 'package:readoramamobile/screens/admin/review_admin_detail.dart';
import 'package:readoramamobile/screens/auth/login.dart';
import 'package:readoramamobile/screens/landinguser/booklist.dart';
import 'package:readoramamobile/widgets/admin/leftdrawer_admin.dart';
import 'package:readoramamobile/widgets/leftdrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Review {
  final String book_title;
  final String review_title;
  final String review;
  final int your_rating;

  Review(this.book_title, this.review_title, this.review, this.your_rating);
}

void main() {
  runApp(const ReviewApp());
}

class ReviewApp extends StatelessWidget {
  const ReviewApp({Key? key});
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Review',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AdminReviewListPage(),
    );
  }
}

class AdminReviewListPage extends StatefulWidget {
  const AdminReviewListPage({Key? key}) : super(key: key);

  @override
  _AdminReviewListState createState() => _AdminReviewListState();
}

class _AdminReviewListState extends State<AdminReviewListPage> {
  late String userid = '';
  late String usernameloggedin = '';
  late bool isSuperuser = false;

  int calculateCrossAxisCount(double screenWidth) {
    // Calculate the number of columns based on screen width
    double cardWidth = 200.0; // Desired card width
    int crossAxisCount = screenWidth ~/ cardWidth;
    return crossAxisCount;
  }

  Future<void> navigateToAdminReviewDetailPage(Reviews rev) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReviewDetailAdminPage(review: rev),
      ),
    );

    if (result != null && result == true) {
      setState(() {
        fetchReview(); // Triggering fetchProduct() to refresh the list
      });
    }
  }

  Future<void> clearSharedPreferences() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.clear();
  }

  @override
  void initState() {
    super.initState();
    getSession();
    fetchReview();
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

  Future<List<Reviews>> fetchReview() async {
    var url = Uri.parse('http://35.226.89.131/landing-admin/load-all-review');

    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    var review_data = jsonDecode(utf8.decode(response.bodyBytes));

    List<Reviews> review_list = [];

    for (var review in review_data) {
      if (review != null) {
        review_list.add(Reviews.fromJson(review));
      }
    }

    return review_list;
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
    Widget drawerWidget;

    if (isSuperuser) {
      drawerWidget = LeftDrawerAdmin(isLoggedIn: usernameloggedin);
    } else {
      drawerWidget = LeftDrawer(isLoggedIn: usernameloggedin);
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Admin Review'),
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
        drawer: drawerWidget,
        body: Column(
          children: [
            Expanded(child: LayoutBuilder(builder: (context, constraints) {
              double screenWidth = constraints.maxWidth;

              return FutureBuilder(
                future: fetchReview(),
                builder: (context, AsyncSnapshot<List<Reviews>> snapshot) {
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
                        children: [
                          Text(
                            "No Review available.",
                            style: TextStyle(color: Colors.white, fontSize: 20),
                          ),
                          SizedBox(height: 8),
                        ],
                      ),
                    );
                  } else {
                    int crossAxisCount = calculateCrossAxisCount(screenWidth);
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: screenWidth /
                            crossAxisCount, // Jumlah kartu per baris
                        crossAxisSpacing: 16.0,
                        mainAxisSpacing: 16.0,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) => GestureDetector(
                        onTap: () {
                          navigateToAdminReviewDetailPage(
                              snapshot.data![index]);
                        },
                        child: Card(
                          color: Colors.black87,
                          margin: const EdgeInsets.all(8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  snapshot.data![index].reviewTitle,
                                  style: TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                                Text(
                                  snapshot.data![index].bookName,
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  // maxLines: 2,
                                ),
                                Text(
                                  "Rating: ${snapshot.data![index].ratingNew.toString()}",
                                  style: TextStyle(
                                    fontSize: 12.0,
                                    color: Colors.white,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  // maxLines: 2,
                                ),
                                ElevatedButton(
                                    onPressed: () async {
                                      final reviewDeletedpk = snapshot
                                          .data![index]
                                          .reviewPk; // implement the 'delete review' functionality in flutter
                                      final response = await http.delete(
                                        Uri.parse(
                                            'http://35.226.89.131/landing-admin/delete-review-flutter/$reviewDeletedpk'),
                                        headers: {
                                          "Content-Type": "application/json"
                                        },
                                      );

                                      if (response.statusCode == 200) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Review deleted successfully!"),
                                        ));
                                        // You may want to refresh the product list after deletion
                                        setState(() {
                                          snapshot.data!.remove((review) =>
                                              review.pk == reviewDeletedpk);
                                        });
                                      } else {
                                        print(
                                            'Failed to delete review. Status code: ${response.statusCode}');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Failed to delete the review."),
                                        ));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      padding: const EdgeInsets.all(12),
                                    ),
                                    child: const Text('Delete Review',
                                        style: TextStyle(
                                          color: Colors
                                              .white, // Set text color to white
                                          fontSize: 14,
                                        )))
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                },
              );
            }))
          ],
        ));
  }
}
