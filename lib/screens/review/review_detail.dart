

import 'dart:html';

import 'package:flutter/material.dart';
// import 'package:rafis_inventory_mobile/widgets/left_drawer.dart';
import 'package:readoramamobile/models/review.dart';

class ReviewDetailPage extends StatelessWidget {
  final Reviews review;

  const ReviewDetailPage({Key? key, required this.review}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      // drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: Colors.black,
          elevation: 5.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.reviewTitle,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.amber
              ),
            ),
            const SizedBox(height: 10),
            Text("Book Title: ${review.bookName}", style: TextStyle(color: Colors.amber)),
            const SizedBox(height: 10),
            Text("Your Rating: ${review.ratingNew}", style: TextStyle(color: Colors.amber)),
            const SizedBox(height: 10),
            Text("Your Review: ${review.review}", style: TextStyle(color: Colors.amber)),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to the item list page
              },
              child: const Text('Back to Review List'),
            ),
          ],
        ),
          ),
        )
      ),
    );
  }
}
