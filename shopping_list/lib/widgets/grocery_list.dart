import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/database.dart';
import 'package:shopping_list/models/category.dart';

import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';

/// The main screen displaying the list of grocery items.
/// It fetches existing items from Firebase Realtime Database and supports adding
/// new items as well as removing items via swipe-to-dismiss.
class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  // Local list of grocery items kept in state for optimistic updates during removal.
  final List<GroceryItem> _groceryItems = [];

  // Future that represents the asynchronous operation of loading items from Firebase.
  // Passed to FutureBuilder in the build method.
  late Future<List<GroceryItem>> _loadedItems;

  // Holds an optional error message if loading fails.
  String? _error;

  @override
  void initState() {
    super.initState();
    // Initiate the asynchronous fetch when the widget is first inserted into the tree.
    _loadedItems = _loadItems();
  }

  /// Fetches the current list of grocery items from the Firebase Realtime Database.
  /// Parses the returned JSON into a list of [GroceryItem] instances.
  Future<List<GroceryItem>> _loadItems() async {
    // Construct the Firebase Realtime Database endpoint URL.
    final url = Uri.https(databaseHost, 'shopping-list.json');

    // Send HTTP GET request to retrieve grocery items.
    final response = await http.get(url);

    // Check if the server returned an error status code.
    if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery items. Please try again later.');
    }

    // Firebase returns the string 'null' when the database node is empty.
    if (response.body == 'null') {
      return _groceryItems;
    }

    // Decode the response body into a map of item keys to item data maps.
    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];

    // Iterate over each item entry in the database.
    for (final item in listData.entries) {
      // Find the corresponding category object matching the stored category title.
      final Category category = categories.entries
          .firstWhere(
            (catItem) => catItem.value.title == item.value['category'],
          )
          .value;

      // Construct a GroceryItem and add it to the list.
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    return _groceryItems
      ..clear()
      ..addAll(loadedItems);
  }

  /// Opens the [NewItem] screen to let the user add a new grocery item.
  /// If an item is created, it is appended to the local state.
  void _addItem() async {
    // Navigate to the NewItem screen and await the newly created GroceryItem.
    final newItem = await Navigator.of(
      context,
    ).push<GroceryItem>(MaterialPageRoute(builder: (ctx) => const NewItem()));

    // If the user cancelled or navigated back without creating an item, do nothing.
    if (newItem == null) {
      return;
    }

    // Update state with the newly created item.
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  /// Deletes a grocery item both locally (optimistic update) and on the Firebase backend.
  /// If the backend deletion fails, the item is restored back to the list.
  void _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);

    // Optimistically remove the item from local state so UI updates immediately.
    setState(() {
      _groceryItems.remove(item);
    });

    // Construct the URL targeting the specific item ID in Firebase.
    final url = Uri.https(databaseHost, 'shopping-list/${item.id}.json');

    // Send HTTP DELETE request to delete the item from Firebase.
    final response = await http.delete(url);

    // If the request fails, rollback the optimistic deletion and reinsert the item.
    if (response.statusCode >= 400) {
      // Optional: Show error message
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          // Button to navigate to the Add Item screen.
          IconButton(onPressed: _addItem, icon: const Icon(Icons.add)),
        ],
      ),
      // FutureBuilder listens to the _loadedItems Future and rebuilds UI based on its state.
      body: FutureBuilder(
        future: _loadedItems,
        builder: (context, snapshot) {
          // Display loading spinner while waiting for the data.
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Display error message if the fetch failed.
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          // Display fallback message when there are no items in the database.
          if (snapshot.data!.isEmpty) {
            return const Center(child: Text('No items added yet.'));
          }

          // Render the scrollable list of grocery items.
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (ctx, index) => Dismissible(
                // Allow user to swipe the item to delete it.
                onDismissed: (direction) {
                  _removeItem(snapshot.data![index]);
                },
                key: ValueKey(snapshot.data![index].id),
                child: ListTile(
                  title: Text(snapshot.data![index].name),
                  // Colored box visually indicating the grocery item category.
                  leading: Container(
                    width: 24,
                    height: 24,
                    color: snapshot.data![index].category.color,
                  ),
                  // Display the quantity of the item.
                  trailing: Text(snapshot.data![index].quantity.toString()),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _reload() async{
    final future = _loadItems();
    setState(() {
      _loadedItems = future;
    });
    await future;
  }
}
