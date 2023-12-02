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
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      // drawer: const LeftDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              review.reviewTitle,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text("Book Title: ${review.bookName}"),
            const SizedBox(height: 10),
            Text("Your Rating: ${review.ratingNew}"),
            const SizedBox(height: 10),
            Text("Your Review: ${review.review}"),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Navigate back to the item list page
              },
              child: const Text('Back to Book List'),
            ),
          ],
        ),
      ),
    );
  }
}
