import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:readoramamobile/models/wishlist.dart'; // Models Aren't Done
import 'package:readoramamobile/widgets/leftdrawer.dart';

class ProductPage extends StatefulWidget {
  const ProductPage({Key? key}) : super(key: key);

  @override
  _ProductPageState createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  Future<List<WishlistModels>> fetchProduct() async {
    var url = Uri.parse(
        'http://127.0.0.1:8000/wishlist/wishlistmodels/'); // Repo link
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    // decode the response to JSON
    var data = jsonDecode(utf8.decode(response.bodyBytes));

    // convert the JSON to Product object
    List<WishlistModels> list_product = [];
    for (var d in data) {
      if (d != null) {
        list_product.add(WishlistModels.fromJson(d));
      }
    }
    return list_product;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Read Books'),
      ),
      drawer: LeftDrawer(), // Left Drawer Here
      body: FutureBuilder(
        future: fetchProduct(),
        builder: (context, AsyncSnapshot<List<WishlistModels>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "There Are No Books Yet.",
                style: TextStyle(color: Color(0xff59A5D8), fontSize: 20),
              ),
            );
          } else {
            return DataTable(
              columns: [
                DataColumn(label: Text('Read Books')),
                DataColumn(label: Text('Write a Review')),
                DataColumn(label: Text('Delete Book')),
              ],
              rows: snapshot.data!.map((product) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        "${product.bookName}",
                        style: const TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          // Implement the 'Write a Review' functionality
                        },
                        style: ElevatedButton.styleFrom(
                          primary:
                              Colors.green, // Set the button color to green
                          padding: EdgeInsets.zero, // Remove padding
                          textStyle:
                              TextStyle(fontSize: 0), // Set text size to zero
                        ),
                        child: Text(''), // Empty text
                      ),
                    ),
                    DataCell(
                      ElevatedButton(
                        onPressed: () {
                          // Implement the 'Delete Book' functionality
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red, // Set the button color to red
                          padding: EdgeInsets.zero, // Remove padding
                          textStyle:
                              TextStyle(fontSize: 0), // Set text size to zero
                        ),
                        child: Text(''), // Empty text
                      ),
                    ),
                  ],
                );
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
