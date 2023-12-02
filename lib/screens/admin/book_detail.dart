import 'package:flutter/material.dart';
// import 'package:rafis_inventory_mobile/widgets/left_drawer.dart';
import 'package:readoramamobile/models/books.dart';

class BookDetailPage extends StatelessWidget {
  final Books book;

  const BookDetailPage({Key? key, required this.book}) : super(key: key);

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
              book.fields.name,
              style: const TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text("Author: ${book.fields.author}"),
            const SizedBox(height: 10),
            Text("Rating: ${book.fields.rating}"),
            const SizedBox(height: 10),
            Text("Review amount: ${book.fields.numReview}"),
            const SizedBox(height: 10),
            Text("Price: ${book.fields.price}"),
            const SizedBox(height: 10),
            Text("Year: ${book.fields.year}"),
            const SizedBox(height: 10),
            Text("Genre: ${book.fields.genre}"),
            const SizedBox(height: 20),
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
