// To parse this JSON data, do
//
//     final wishlistModels = wishlistModelsFromJson(jsonString);

import 'dart:convert';

List<WishlistModels> wishlistModelsFromJson(String str) =>
    List<WishlistModels>.from(
        json.decode(str).map((x) => WishlistModels.fromJson(x)));

String wishlistModelsToJson(List<WishlistModels> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class WishlistModels {
  int bookId;
  String bookName;
  String bookAuthor;
  int bookNumReviews;
  double bookRating;
  String bookGenre;
  bool flag;
  int wishlistId;

  WishlistModels({
    required this.bookId,
    required this.bookName,
    required this.bookAuthor,
    required this.bookNumReviews,
    required this.bookRating,
    required this.bookGenre,
    required this.flag,
    required this.wishlistId,
  });

  factory WishlistModels.fromJson(Map<String, dynamic> json) => WishlistModels(
        bookId: json["book_id"],
        bookName: json["book_name"],
        bookAuthor: json["book_author"],
        bookNumReviews: json["book_num_reviews"],
        bookRating: json["book_rating"]?.toDouble(),
        bookGenre: json["book_genre"],
        flag: json["flag"],
        wishlistId: json["wishlist_id"],
      );

  Map<String, dynamic> toJson() => {
        "book_id": bookId,
        "book_name": bookName,
        "book_author": bookAuthor,
        "book_num_reviews": bookNumReviews,
        "book_rating": bookRating,
        "book_genre": bookGenre,
        "flag": flag,
        "wishlist_id": wishlistId,
      };
}
