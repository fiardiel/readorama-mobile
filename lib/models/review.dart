// To parse this JSON data, do
//
//     final reviews = reviewsFromJson(jsonString);

import 'dart:convert';

List<Reviews> reviewsFromJson(String str) => List<Reviews>.from(json.decode(str).map((x) => Reviews.fromJson(x)));

String reviewsToJson(List<Reviews> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Reviews {
    int bookId;
    String bookName;
    String bookAuthor;
    int bookNumReviews;
    double bookRating;
    String bookGenre;
    String reviewTitle;
    String review;
    int ratingNew;
    int reviewCount;
    DateTime dateAdded;
    int reviewPk;

    Reviews({
        required this.bookId,
        required this.bookName,
        required this.bookAuthor,
        required this.bookNumReviews,
        required this.bookRating,
        required this.bookGenre,
        required this.reviewTitle,
        required this.review,
        required this.ratingNew,
        required this.reviewCount,
        required this.dateAdded,
        required this.reviewPk,
    });

    factory Reviews.fromJson(Map<String, dynamic> json) => Reviews(
        bookId: json["book_id"],
        bookName: json["book_name"],
        bookAuthor: json["book_author"],
        bookNumReviews: json["book_num_reviews"],
        bookRating: json["book_rating"]?.toDouble(),
        bookGenre: json["book_genre"],
        reviewTitle: json["review_title"],
        review: json["review"],
        ratingNew: json["rating_new"],
        reviewCount: json["review_count"],
        dateAdded: DateTime.parse(json["date_added"]),
        reviewPk: json["review_pk"],
    );

    Map<String, dynamic> toJson() => {
        "book_id": bookId,
        "book_name": bookName,
        "book_author": bookAuthor,
        "book_num_reviews": bookNumReviews,
        "book_rating": bookRating,
        "book_genre": bookGenre,
        "review_title": reviewTitle,
        "review": review,
        "rating_new": ratingNew,
        "review_count": reviewCount,
        "date_added": "${dateAdded.year.toString().padLeft(4, '0')}-${dateAdded.month.toString().padLeft(2, '0')}-${dateAdded.day.toString().padLeft(2, '0')}",
        "review_pk": reviewPk,
    };
}
