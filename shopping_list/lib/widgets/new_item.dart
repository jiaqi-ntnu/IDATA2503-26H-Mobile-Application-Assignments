import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/data/database.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';

/// A screen presenting a form to allow the user to create and submit a new grocery item.
/// It sends the new item data to Firebase Realtime Database via HTTP POST and returns
/// the resulting [GroceryItem] back to the previous screen.
class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<NewItem> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  // Global key used to access, validate, and save the Form widget's state.
  final _formKey = GlobalKey<FormState>();

  // Stores the entered item name from the form field.
  var _enteredName = '';

  // Stores the entered quantity (default is 1).
  var _enteredQuantity = 1;

  // Stores the currently selected category (default is vegetables).
  var _selectedCategory = categories[Categories.vegetables]!;

  // Tracks whether the HTTP request is currently in-flight to prevent duplicate submissions
  // and to display a loading indicator on the submit button.
  var _isSending = false;

  /// Validates form inputs, sends data to the Firebase database, and navigates back.
  void _saveItem() async {
    // Trigger validation for all Form fields.
    if (_formKey.currentState!.validate()) {
      // Save current form values, triggering onSaved callbacks on each field.
      _formKey.currentState!.save();

      // Indicate loading state so UI can disable buttons and show progress.
      setState(() {
        _isSending = true;
      });

      // Construct Firebase database endpoint for grocery items.
      final url = Uri.https(databaseHost, 'shopping-list.json');

      // Send HTTP POST request with JSON encoded body.
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': _enteredName,
          'quantity': _enteredQuantity,
          'category': _selectedCategory.title,
        }),
      );

      // Firebase returns a JSON payload containing the auto-generated unique ID in the 'name' field.
      final Map<String, dynamic> resData = json.decode(response.body);

      // Ensure the widget is still mounted in the widget tree before interacting with context.
      if (!context.mounted) {
        return;
      }

      // Pop the screen and return the newly created GroceryItem to the caller.
      Navigator.of(context).pop(
        GroceryItem(
          id: resData['name'],
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new item')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Text input field for the grocery item name.
              TextFormField(
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Name')),
                validator: (value) {
                  // Ensure name is non-empty and between 2 and 50 characters long.
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters.';
                  }
                  return null;
                },
                onSaved: (value) {
                  // Save the entered name.
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Text input field for the quantity.
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(
                        label: Text('Quantity'),
                      ),
                      keyboardType: TextInputType.number,
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        // Ensure input is a valid positive integer greater than zero.
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.tryParse(value)! <= 0) {
                          return 'Must be a valid, positive number.';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        // Save the parsed integer quantity.
                        _enteredQuantity = int.parse(value!);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Dropdown selection for item category.
                  Expanded(
                    child: DropdownButtonFormField(
                      value: _selectedCategory,
                      items: [
                        // Map each available category to a dropdown menu item.
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                // Colored indicator representing the category.
                                Container(
                                  width: 16,
                                  height: 16,
                                  color: category.value.color,
                                ),
                                const SizedBox(width: 6),
                                Text(category.value.title),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {
                        // Update the selected category in state.
                        setState(() {
                          _selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Action buttons (Reset and Add Item).
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Reset button resets all form fields to their initial states.
                  TextButton(
                    onPressed: _isSending
                        ? null
                        : () {
                            _formKey.currentState!.reset();
                          },
                    child: const Text('Reset'),
                  ),
                  // Submit button triggers form validation and Firebase submission.
                  ElevatedButton(
                    onPressed: _isSending ? null : _saveItem,
                    child: _isSending
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(),
                          )
                        : const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
