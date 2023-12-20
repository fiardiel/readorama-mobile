import 'dart:convert';
import 'dart:html';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:readoramamobile/models/review.dart';
import 'package:readoramamobile/screens/review/review.dart'; // Replace with the correct path
import 'package:readoramamobile/screens/review/edit_review.dart';

class ReviewDetailPage extends StatefulWidget {
  Reviews review;
  ReviewDetailPage({Key? key, required this.review}) : super(key: key);

  @override
  _ReviewDetailPageState createState() => _ReviewDetailPageState();
}

class _ReviewDetailPageState extends State<ReviewDetailPage> {
  Future<Reviews?> fetchReviewDetails() async {
    var url = Uri.parse('http://35.226.89.131/review/load-review-id/${widget.review.reviewPk}');
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
        foregroundColor: Colors.amber,
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
            Reviews reviewDetails = snapshot.data!; // Assuming you want the first item

            return Card(
              color: Colors.black,
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
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text("Book Title: ${reviewDetails.bookName}",
                        style: TextStyle(color: Colors.amber)),
                    const SizedBox(height: 10),
                    Text("Your Rating: ${reviewDetails.ratingNew}",
                        style: TextStyle(color: Colors.amber)),
                    const SizedBox(height: 10),
                    Text("Your Review: ${reviewDetails.review}",
                        style: TextStyle(color: Colors.amber)),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        navigateToEditReviewPage(reviewDetails.reviewPk);
                      },
                      child: Text(
                        'Edit Review', style: TextStyle(color:Colors.black)
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ReviewListPage()));
                      },
                      child: const Text('Back to Review List', style: TextStyle(color:Colors.black)),
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
