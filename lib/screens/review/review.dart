import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readoramamobile/models/review.dart';
import 'package:readoramamobile/screens/review/review_detail.dart';
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
      home: const ReviewListPage(),
    );
  }
}

class ReviewListPage extends StatefulWidget {
  const ReviewListPage({Key? key}) : super(key: key);

  @override
  _ReviewListState createState() => _ReviewListState();
}

class _ReviewListState extends State<ReviewListPage> {
  late String userid = '';
  late String usernameloggedin = '';

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
    });
  }

  Future<List<Reviews>> fetchReview() async {
    var url = Uri.parse('http://127.0.0.1:8000/review/get-review-flutter/');

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Review'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      drawer: LeftDrawer(
        isLoggedIn: usernameloggedin,
      ),
      body: FutureBuilder(
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
                    style: TextStyle(color: Colors.amber, fontSize: 20),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            );
          } else {
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // Jumlah kartu per baris
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
              itemCount: snapshot.data!.length,
              itemBuilder: (_, index) => InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReviewDetailPage(review: snapshot.data![index]),
                    ),
                  );
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
                          "${snapshot.data![index].reviewTitle}",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        Text(
                          "${snapshot.data![index].bookName}",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.amber,
                          ),
                          overflow: TextOverflow.ellipsis,
                          // maxLines: 2,
                        ),
                        Text(
                          "Rating: ${snapshot.data![index].ratingNew}",
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.amber,
                          ),
                          overflow: TextOverflow.ellipsis,
                          // maxLines: 2,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
