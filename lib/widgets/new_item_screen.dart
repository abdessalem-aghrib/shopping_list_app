import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/providers/grocery_provider.dart';

class NewItemScreen extends ConsumerStatefulWidget {
  const NewItemScreen({super.key});

  @override
  ConsumerState<NewItemScreen> createState() => _NewItemScreenState();
}

class _NewItemScreenState extends ConsumerState<NewItemScreen> {
  var formKey = GlobalKey<FormState>();

  String? name;
  int? quantity;
  Category? category;

  addItem() async {
    bool isValid = formKey.currentState!.validate();

    if (isValid) {
      formKey.currentState!.save();

      // add this item to database
      var url = Uri.https(
        "shopping-list-app-639c5-default-rtdb.firebaseio.com",
        "shopping_list.json",
      );

      var response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "name": name!,
          "quantity": quantity!,
          "category": category!.title,
        }),
      );

      if (response.statusCode >= 400) {
        return;
      }

      Map<String, dynamic> data = json.decode(response.body);

      ref
          .read(groceryProvider.notifier)
          .addItem(
            GroceryItem(
              id: data["name"],
              name: name!,
              quantity: quantity!,
              category: category!,
            ),
          );

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add a new item')),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            spacing: 20,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: InputDecoration(label: Text('Name')),
                validator: (value) {
                  if (value!.isEmpty || value.length > 50) {
                    return "Name must be between 1 and 50";
                  }

                  return null;
                },
                onSaved: (value) {
                  name = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(label: Text('Quantity')),
                validator: (value) {
                  int? quantity = int.tryParse(value.toString());

                  if (quantity == null) {
                    return "Quantity must be a valid number";
                  }

                  if (quantity < 0) return "Quantity must be a positive number";

                  return null;
                },
                onSaved: (value) {
                  quantity = int.tryParse(value.toString());
                },
              ),
              DropdownButtonFormField(
                // value: categories.entries.first.value,
                decoration: InputDecoration(label: Text('Category')),
                items: categories.entries
                    .map(
                      (entry) => DropdownMenuItem(
                        value: entry.value,
                        child: Row(
                          spacing: 10,
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              color: entry.value.color,
                            ),
                            Text(entry.value.title),
                          ],
                        ),
                      ),
                    )
                    .toList(),

                validator: (value) {
                  if (value == null) return "You must select one category";

                  return null;
                },
                onSaved: (value) {
                  category = value;
                },
                onChanged: (value) {},
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      formKey.currentState!.reset();
                    },
                    child: Text('Reset'),
                  ),
                  ElevatedButton(onPressed: addItem, child: Text('Add Item')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
