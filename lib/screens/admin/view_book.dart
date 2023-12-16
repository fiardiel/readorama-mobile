import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:readoramamobile/models/books.dart';
import 'package:readoramamobile/screens/admin/book_detail.dart';
import 'package:readoramamobile/screens/admin/edit_book.dart';
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

  Future<void> navigateToEditProductPage(int productId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditProductPage(productId: productId),
      ),
    );
  
    if (result != null && result == true) {
      setState(() {
        fetchProduct(); // Triggering fetchProduct() to refresh the list
      });
    }
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
                    child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: GridView.builder(
                            shrinkWrap: true,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 30.0,
                              mainAxisSpacing: 60.0,
                            ),
                            itemCount: snapshot.data!.length,
                            itemBuilder: (_, index) => Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.1,
                                  child: InkWell(
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
                                      width: MediaQuery.of(context).size.width *
                                          0.1, // Set width based on screen width
                                      height: MediaQuery.of(context)
                                              .size
                                              .height *
                                          0.05, // Adjust the height as needed
                                      child: Card(
                                        margin: const EdgeInsets.all(2.0),
                                        elevation: 4.0,
                                        child: Padding(
                                          padding: EdgeInsets.all(
                                              MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.01),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Text(
                                                "${snapshot.data![index].fields.name}",
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.01,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                                maxLines:
                                                    2, // Limits to 2 lines
                                                overflow: TextOverflow
                                                    .ellipsis, // Shows ellipsis when overflow
                                              ),
                                              const SizedBox(height: 3),
                                              Text(
                                                "${snapshot.data![index].fields.author}",
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize:
                                                      MediaQuery.of(context)
                                                              .size
                                                              .width *
                                                          0.009,
                                                ),
                                                maxLines: 1, // Limits to 1 line
                                                overflow: TextOverflow
                                                    .ellipsis, // Shows ellipsis when overflow
                                              ),
                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2, // Set width based on screen width
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  child: ElevatedButton(
                                                    onPressed: () async {
                                                      // Implement the 'Delete Book' functionality
                                                      final bookToDeletePK =
                                                          snapshot
                                                              .data![index].pk;
                                                      // Send request to Django and wait for the response
                                                      final response =
                                                          await http.delete(
                                                        Uri.parse(
                                                            'http://localhost:8000/landing-admin/delete-book-flutter/$bookToDeletePK'),
                                                        headers: {
                                                          "Content-Type":
                                                              "application/json"
                                                        },
                                                      );
                                                      if (response.statusCode ==
                                                          200) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                          content: Text(
                                                              "Product deleted successfully!"),
                                                        ));
                                                        // You may want to refresh the product list after deletion
                                                        setState(() {
                                                          snapshot.data!.remove(
                                                              (book) =>
                                                                  book.pk ==
                                                                  bookToDeletePK);
                                                        });
                                                      } else {
                                                        print(
                                                            'Failed to delete product. Status code: ${response.statusCode}');
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                                const SnackBar(
                                                          content: Text(
                                                              "Failed to delete the product."),
                                                        ));
                                                      }
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: Colors
                                                          .red, // Set the button color to red
                                                      padding: EdgeInsets.all(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.001), // Set padding based on screen width
                                                    ),
                                                    child: Text(
                                                      'Delete Book',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .white, // Set text color to white
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.01,
                                                      ),
                                                    ),
                                                  )),

                                              Container(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.2, // Set width based on screen width
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.05,
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      final bookToEditPK =
                                                          snapshot
                                                              .data![index].pk;
                                                      navigateToEditProductPage(
                                                          bookToEditPK);
                                                    },
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor: Colors
                                                          .blue, // Set the button color to blue
                                                      padding: EdgeInsets.all(
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.001), // Add padding to the button
                                                    ),
                                                    child: Text(
                                                      'Edit Book',
                                                      style: TextStyle(
                                                        color: Colors
                                                            .white, // Set text color to white
                                                        fontSize: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.009, // Set font size based on screen width
                                                      ),
                                                    ),
                                                  )),
                                              // Add more content or adjust sizing as necessary
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ))),
                  );
                }
              }
            }));
  }
}
