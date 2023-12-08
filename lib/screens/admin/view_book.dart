import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:readoramamobile/models/books.dart';
import 'package:readoramamobile/screens/admin/book_detail.dart';
import 'package:readoramamobile/widgets/admin/leftdrawer_admin.dart';

class AdminBookPage extends StatefulWidget {
  const AdminBookPage({Key? key}) : super(key: key);

  @override
  _AdminBookPageState createState() => _AdminBookPageState();
}

class _AdminBookPageState extends State<AdminBookPage> {
  Future<List<Books>> fetchProduct() async {
    var url = Uri.parse('http://127.0.0.1:8000/loadbooks/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    // decode the response to JSON
    var data = jsonDecode(utf8.decode(response.bodyBytes));

    // convert the JSON to Product object
    List<Books> list_item = [];
    for (var d in data) {
      if (d != null) {
        list_item.add(Books.fromJson(d));
      }
    }
    return list_item;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Books'),
          backgroundColor: const Color.fromARGB(255, 25, 29, 37),
          foregroundColor: Colors.white,
        ),
        drawer: LeftDrawerAdmin(),
        body: FutureBuilder(
            future: fetchProduct(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.data == null) {
                return const Center(child: CircularProgressIndicator());
              } else {
                if (!snapshot.hasData) {
                  return const Column(
                    children: [
                      Text(
                        "No book data available.",
                        style:
                            TextStyle(color: Color(0xff59A5D8), fontSize: 20),
                      ),
                      SizedBox(height: 8),
                    ],
                  );
                } else {
                  // Existing code...
                  return Center(
                    child: GridView.builder(
                      shrinkWrap: true,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 3.0,
                        mainAxisSpacing: 3.0,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) => InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookDetailPage(
                                book: snapshot.data![index],
                              ),
                            ),
                          );
                        },
                        child: SizedBox(
                          width: 100, // Adjust the width as needed
                          height: 100, // Adjust the height as needed
                          child: Card(
                            margin: const EdgeInsets.all(20.0),
                            elevation: 4.0,
                            child: Padding(
                              padding: const EdgeInsets.all(30.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "${snapshot.data![index].fields.name}",
                                    style: const TextStyle(
                                      fontSize: 14.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 3, // Limits to 2 lines
                                    overflow: TextOverflow
                                        .ellipsis, // Shows ellipsis when overflow
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "${snapshot.data![index].fields.author}",
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 10.0,
                                    ),
                                    maxLines: 2, // Limits to 2 lines
                                    overflow: TextOverflow
                                        .ellipsis, // Shows ellipsis when overflow
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      // Implement the 'Delete Book' functionality
                                      final bookToDeletePK =
                                          snapshot.data![index].pk;
                                      // Send request to Django and wait for the response
                                      final response = await http.delete(
                                        Uri.parse(
                                            'http://localhost:8000/landing-admin/delete-book-flutter/$bookToDeletePK'),
                                        headers: {
                                          "Content-Type": "application/json"
                                        },
                                      );
                                      if (response.statusCode == 200) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Product deleted successfully!"),
                                        ));
                                        // You may want to refresh the product list after deletion
                                        setState(() {
                                          snapshot.data!.remove((book) =>
                                              book.pk == bookToDeletePK);
                                        });
                                      } else {
                                        print(
                                            'Failed to delete product. Status code: ${response.statusCode}');
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                          content: Text(
                                              "Failed to delete the product."),
                                        ));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors
                                          .red, // Set the button color to red
                                      padding: const EdgeInsets.all(
                                          12), // Add padding to the button
                                    ),
                                    child: const Text(
                                      'Delete Book',
                                      style: TextStyle(
                                        color: Colors
                                            .white, // Set text color to white
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  // Add more content or adjust sizing as necessary
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
              }
            }));
  }
}
