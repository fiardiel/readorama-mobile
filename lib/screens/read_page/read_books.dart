import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:readoramamobile/models/wishlist.dart';
import 'package:readoramamobile/screens/review/review_form.dart';
import 'package:readoramamobile/widgets/admin/leftdrawer_admin.dart';
import 'package:readoramamobile/widgets/leftdrawer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  late String userid = '';
  late String usernameloggedin = '';
  late bool isSuperuser = false;

  int calculateCrossAxisCount(double screenWidth) {
    // Calculate the number of columns based on screen width
    double cardWidth = 200.0; // Desired card width
    int crossAxisCount = screenWidth ~/ cardWidth;
    return crossAxisCount;
  }

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
      isSuperuser = pref.getBool("is_superuser")!;
    });
  }

  Future<List<WishlistModels>> fetchProduct() async {
    var url = Uri.parse(
        'http://35.226.89.131/wishlist/wishlistmodels/$userid/'); // Repo link
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    // decode the response to JSON
    var data = jsonDecode(utf8.decode(response.bodyBytes));

    // convert the JSON to WishlistModels objects
    List<WishlistModels> list_product = [];
    for (var d in data) {
      if (d != null) {
        list_product.add(WishlistModels.fromJson(d));
      }
    }

    // Filter the list based on the flag property
    List<WishlistModels> filteredList = list_product
        .where((wishlistModel) => wishlistModel.flag == true)
        .toList();

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    Widget drawerWidget;

    if (isSuperuser) {
      drawerWidget = LeftDrawerAdmin(isLoggedIn: usernameloggedin);
    } else {
      drawerWidget = LeftDrawer(isLoggedIn: usernameloggedin);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Books'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      drawer: drawerWidget,
      body: FutureBuilder(
        future: fetchProduct(),
        builder: (context, AsyncSnapshot<List<WishlistModels>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "No books available.",
                    style: TextStyle(color: Colors.amber, fontSize: 20),
                  ),
                  SizedBox(height: 8),
                ],
              ),
            );
          } else {
            return LayoutBuilder(builder: (context, constraints) {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (_, index) {
                  return Card(
                    color: Colors.black87,
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snapshot.data![index].bookName,
                            style: const TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.amber,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReadBooksDetails(
                                        book: snapshot.data![index],
                                      ),
                                    ),
                                  );
                                },
                                child: Text(
                                  'View Details',
                                  style: TextStyle(color: Colors.blue),
                                ),
                              ),
                              // Delete button
                              ElevatedButton(
                                onPressed: () async {
                                  // Implement the 'Delete Book' functionality
                                  final response = await http.delete(
                                    Uri.parse(
                                        'http://35.226.89.131/read_page/delete-flutter/${snapshot.data![index].wishlistId}'),
                                    headers: {
                                      "Content-Type": "application/json"
                                    },
                                  );
                                  if (response.statusCode == 200) {
                                    // ignore: use_build_context_synchronously
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Book deleted successfully!"),
                                      ),
                                    );
                                    // You may want to refresh the product list after deletion
                                    setState(() {
                                      snapshot.data!.removeAt(index);
                                    });
                                  } else {
                                    print(
                                        'Failed to delete product. Status code: ${response.statusCode}');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Failed to delete the book."),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  // ignore: deprecated_member_use
                                  primary:
                                      Colors.red, // Set the button color to red
                                  padding: EdgeInsets.zero, // Remove padding
                                  textStyle: TextStyle(
                                      fontSize: 0), // Set text size to zero
                                ),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ReviewFormPage(
                                        booktoReview: snapshot.data![index].bookId,
                                      )));
                                },
                                style: ElevatedButton.styleFrom(
                                  // ignore: deprecated_member_use
                                  primary: Colors
                                      .green, // Set the button color to red
                                  padding: EdgeInsets.zero, // Remove padding
                                  textStyle: TextStyle(
                                      fontSize: 0), // Set text size to zero
                                ),
                                child: Icon(
                                  Icons.rate_review,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            });
          }
        },
      ),
    );
  }
}

class ReadBooksDetails extends StatelessWidget {
  final WishlistModels book;

  const ReadBooksDetails({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(book.bookName),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          color: Colors.black,
          elevation: 5.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name: ${book.bookName}",
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Author: ${book.bookAuthor}",
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Rating: ${book.bookRating}",
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Number of Reviews: ${book.bookNumReviews}",
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Year: ${book.bookRating}",
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Genre: ${book.bookGenre}",
                  style: TextStyle(
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: ProductPage(),
  ));
}