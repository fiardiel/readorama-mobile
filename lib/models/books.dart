// To parse this JSON data, do
//
//     final books = booksFromJson(jsonString);

import 'dart:convert';

List<Books> booksFromJson(String str) => List<Books>.from(json.decode(str).map((x) => Books.fromJson(x)));

String booksToJson(List<Books> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Books {
    Model model;
    int pk;
    Fields fields;

    Books({
        required this.model,
        required this.pk,
        required this.fields,
    });

    factory Books.fromJson(Map<String, dynamic> json) => Books(
        model: modelValues.map[json["model"]]!,
        pk: json["pk"],
        fields: Fields.fromJson(json["fields"]),
    );

    Map<String, dynamic> toJson() => {
        "model": modelValues.reverse[model],
        "pk": pk,
        "fields": fields.toJson(),
    };
}

class Fields {
    String name;
    String author;
    double rating;
    int numReview;
    int price;
    int year;
    Genre genre;

    Fields({
        required this.name,
        required this.author,
        required this.rating,
        required this.numReview,
        required this.price,
        required this.year,
        required this.genre,
    });

    factory Fields.fromJson(Map<String, dynamic> json) => Fields(
        name: json["name"],
        author: json["author"],
        rating: json["rating"]?.toDouble(),
        numReview: json["num_review"],
        price: json["price"],
        year: json["year"],
        genre: genreValues.map[json["genre"]]!,
    );

    Map<String, dynamic> toJson() => {
        "name": name,
        "author": author,
        "rating": rating,
        "num_review": numReview,
        "price": price,
        "year": year,
        "genre": genreValues.reverse[genre],
    };
}

enum Genre {
    FICTION,
    NON_FICTION
}

final genreValues = EnumValues({
    "Fiction": Genre.FICTION,
    "Non Fiction": Genre.NON_FICTION
});

enum Model {
    MAIN_BOOKS
}

final modelValues = EnumValues({
    "main.books": Model.MAIN_BOOKS
});

class EnumValues<T> {
    Map<String, T> map;
    late Map<T, String> reverseMap;

    EnumValues(this.map);

    Map<T, String> get reverse {
        reverseMap = map.map((k, v) => MapEntry(v, k));
        return reverseMap;
    }
}
