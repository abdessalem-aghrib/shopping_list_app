import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_app/data/categories.dart';
import 'package:shopping_list_app/models/category.dart';
import 'package:shopping_list_app/models/grocery_item.dart';
import 'package:shopping_list_app/providers/grocery_provider.dart';
import 'package:shopping_list_app/widgets/my_progress_indicator.dart';
import 'package:shopping_list_app/widgets/new_item_screen.dart';

class GroceryList extends ConsumerStatefulWidget {
  const GroceryList({super.key});

  @override
  ConsumerState<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends ConsumerState<GroceryList> {
  Future<List<GroceryItem>> loadItems() async {
    try {
      var url = Uri.https(
        "shopping-list-app-639c5-default-rtdb.firebaseio.com",
        "shopping_list.json",
      );

      var response = await http.get(
        url,
        headers: {"Content-Type": "application/json"},
      );

      Map<String, dynamic> loadedData = json.decode(response.body);

      List<GroceryItem> loadedItems = [];

      for (var entry in loadedData.entries) {
        var categoryEntry = categories.entries.firstWhere(
          (item) => item.value.title == entry.value["category"],
        );

        Category category = categoryEntry.value;

        loadedItems.add(
          GroceryItem(
            id: entry.key,
            name: entry.value["name"],
            quantity: entry.value["quantity"],
            category: category,
          ),
        );
      }

      return loadedItems;
    } catch (error) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => NewItemScreen()));
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: loadItems(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: MyProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("There is an Error!"));
          }

          List<GroceryItem> items = snapshot.data ?? [];

          ref.read(groceryProvider.notifier).init(items);

          return Consumer(
            builder: (context, ref, __) {
              var groceryItems = ref.watch(groceryProvider);

              return groceryItems.isEmpty
                  ? Center(child: Text('No items added yet'))
                  : ListView.builder(
                      itemCount: groceryItems.length,
                      itemBuilder: (ctx, index) => Dismissible(
                        key: ValueKey(groceryItems[index].id),
                        child: ListTile(
                          title: Text(groceryItems[index].name),
                          leading: Container(
                            width: 24,
                            height: 24,
                            color: groceryItems[index].category.color,
                          ),
                          trailing: Text(
                            groceryItems[index].quantity.toString(),
                          ),
                        ),
                        onDismissed: (direction) async {
                          GroceryItem groceryItem = groceryItems[index];

                          ref
                              .read(groceryProvider.notifier)
                              .removeItem(groceryItem);

                          try {
                            // delete from database
                            var url = Uri.https(
                              "shopping-list-app-639c5-default-rtdb.firebaseio.com",
                              "shopping_list/${groceryItem.id}.json",
                            );

                            var response = await http.delete(
                              url,
                              headers: {"Content-Type": "application/json"},
                            );
                          } catch (error) {
                            ref
                                .read(groceryProvider.notifier)
                                .insertAt(index, groceryItem);
                          }
                        },
                      ),
                    );
            },
          );
        },
      ),
    );
  }
}
