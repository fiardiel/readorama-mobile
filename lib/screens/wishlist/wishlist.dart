// ignore_for_file: prefer_const_constructors, avoid_print, use_build_context_synchronously, duplicate_ignore

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:readoramamobile/models/wishlist.dart';
import 'package:readoramamobile/widgets/leftdrawer.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WishlistState createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  Future<List<WishlistModels>> fetchProduct() async {
    var url = Uri.parse('http://127.0.0.1:8000/wishlist/wishlistmodels/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    var data = jsonDecode(utf8.decode(response.bodyBytes));

    List<WishlistModels> listProduct = [];
    for (var d in data) {
      if (d != null) {
        listProduct.add(WishlistModels.fromJson(d));
      }
    }

    List<WishlistModels> filteredList = listProduct
        .where((wishlistModel) => wishlistModel.flag == false)
        .toList();

    return filteredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.amber,
      ),
      drawer: LeftDrawer(),
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
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5, // Jumlah kartu per baris
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
              ),
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
                        Text(
                          snapshot.data![index].flag.toString(),
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
                            GestureDetector(
                              onTap: () {},
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
                                      'http://localhost:8000/read_page/delete-flutter/${snapshot.data![index].wishlistId}'),
                                  headers: {"Content-Type": "application/json"},
                                );
                                if (response.statusCode == 200) {
                                  // ignore: use_build_context_synchronously
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Wishlist deleted successfully!"),
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
                                          "Failed to delete the wishlist."),
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
                                // Implement the 'Mark as Read' functionality
                                final response = await http.post(
                                  Uri.parse(
                                      'http://localhost:8000/wishlist/mark-as-read/${snapshot.data![index].wishlistId}/'),
                                  headers: {"Content-Type": "application/json"},
                                );

                                if (response.statusCode == 200) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Book marked as read!"),
                                    ),
                                  );
                                  // You may want to refresh the product list after marking as read
                                  setState(() {
                                    snapshot.data![index].flag = true;
                                  });
                                } else {
                                  print(
                                      'Failed to mark as read. Status code: ${response.statusCode}');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          "Failed to mark the book as read."),
                                    ),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                // ignore: deprecated_member_use
                                primary:
                                    Colors.green, // Set the button color to red
                                padding: EdgeInsets.zero, // Remove padding
                                textStyle: TextStyle(
                                    fontSize: 0), // Set text size to zero
                              ),
                              child: Icon(
                                Icons.check,
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
          }
        },
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: Wishlist(),
  ));
}
