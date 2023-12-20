// ignore_for_file: library_private_types_in_public_api, prefer_const_constructors, unnecessary_const, must_be_immutable

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:readoramamobile/models/review.dart'; // Replace with the correct path
import 'package:readoramamobile/screens/review/edit_review.dart';

class ReviewDetailAdminPage extends StatefulWidget {
  Reviews review;
  ReviewDetailAdminPage({Key? key, required this.review}) : super(key: key);

  @override
  _ReviewDetailAdminPageState createState() => _ReviewDetailAdminPageState();
}

class _ReviewDetailAdminPageState extends State<ReviewDetailAdminPage> {
  Future<Reviews?> fetchReviewDetails() async {
    var url = Uri.parse(
        'http://35.226.89.131/landing-admin/load-review-by-id/${widget.review.reviewPk}');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      // Check if the response is not empty
      if (response.body.isNotEmpty) {
        // Decode the response to a list of JSON objects
        List<dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));

        // Check if the list is not empty
        if (data.isNotEmpty) {
          // Take the first item from the list
          var firstItem = data[0];

          // Convert the JSON to a Reviews object
          Reviews review = Reviews.fromJson(firstItem);

          return review;
        }
      }
    }

    // If there's an issue with the response, or if the data is empty, return null
    return null;
  }

  Future<void> navigateToEditReviewPage(int reviewId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReviewPage(reviewId: reviewId),
      ),
    );

    if (result != null && result == true) {
      Reviews? listDetailReview = await fetchReviewDetails();
      if (listDetailReview != null) {
        setState(() {
          widget.review = listDetailReview;
          // Triggering fetchProduct() to refresh the list
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review Details'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<Reviews?>(
        future: fetchReviewDetails(),
        builder: (context, AsyncSnapshot<Reviews?> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error loading data'));
          } else if (snapshot.data == null) {
            return const Center(child: Text('No data available'));
          } else {
            Reviews reviewDetails =
                snapshot.data!; // Assuming you want the first item

            return Card(
              color: const Color.fromARGB(255, 25, 29, 37),
              elevation: 5.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewDetails.reviewTitle,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Book Title: ${reviewDetails.bookName}",
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 10),
                    Text("Your Rating: ${reviewDetails.ratingNew}",
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 10),
                    Text("Your Review: ${reviewDetails.review}",
                        style: TextStyle(color: Colors.white)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        navigateToEditReviewPage(reviewDetails.reviewPk);
                      },
                      child: Text('Edit Review',
                          style: TextStyle(color: const Color.fromARGB(255, 25, 29, 37),)),
                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
