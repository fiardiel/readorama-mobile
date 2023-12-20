import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class EditReviewPage extends StatefulWidget {
  final int reviewId;
  EditReviewPage({required this.reviewId});

  @override
  _EditReviewState createState() => _EditReviewState();
}

class _EditReviewState extends State<EditReviewPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _reviewTitleController = TextEditingController();
  TextEditingController _bookNameController = TextEditingController();
  TextEditingController _ratingNewController = TextEditingController();
  TextEditingController _reviewController = TextEditingController();

  @override
  void initState() {
    super.initState();

    fetchProductDetails();
  }

  Future<void> fetchProductDetails() async {
    final response = await http.put(Uri.parse(
        'http://35.226.89.131/review/load-review-id/${widget.reviewId}'));

    if (response.statusCode == 200) {
      final reviewList = jsonDecode(response.body) as List;
      final reviewData = reviewList.isNotEmpty ? reviewList.first : null;

      if (reviewData != null) {
        setState(() {
          _reviewTitleController.text = reviewData['review_title'];
          _bookNameController.text = reviewData['book_name'];
          _ratingNewController.text =
              reviewData['rating_new'].toString();
          _reviewController.text = reviewData['review'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text('Edit Review')),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView(
              children: <Widget>[
                TextFormField(
                  controller: _reviewTitleController,
                  decoration: const InputDecoration(labelText: 'Review Title'),
                  // Validation, onChanged, and other properties...
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Review title cannot be empty!";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _bookNameController,
                  decoration: const InputDecoration(labelText: 'Book Title'),
                  // Validation, onChanged, and other properties...
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Book title cannot be empty!";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _ratingNewController,
                  decoration: const InputDecoration(labelText: 'Your Rating'),
                  // Validation, onChanged, and other properties...
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Rating cannot be empty!";
                    }
                    if (int.tryParse(value) == null) {
                      return "Rating must be a number!";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _reviewController,
                  decoration: const InputDecoration(labelText: 'Review'),
                  // Validation, onChanged, and other properties...
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Your review cannot be empty!";
                    }

                    return null;
                  },
                ),

                // Other TextFormField widgets for different fields...
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final response = await http.post(
                        Uri.parse(
                            'http://35.226.89.131/review/edit-review-flutter/${widget.reviewId}'),
                        headers: {
                          'Content-Type': 'application/json',
                        },
                        body: jsonEncode({
                          'review_title': _reviewTitleController.text,
                          'book_name': _bookNameController.text,
                          'review': _reviewController.text,
                          'rating_new': int.parse(_ratingNewController.text),
                        }),
                      );

                      if (response.statusCode == 200) {
                        // Product updated successfully
                        Navigator.pop(context,
                            true); // Passing 'true' to indicate success
                      }
                    }
                    ;
                  },
                ),
              ],
            ),
          ),
        ));
  }
}
