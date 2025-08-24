import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_app/providers/grocery_provider.dart';
import 'package:shopping_list_app/widgets/new_item_screen.dart';

class GroceryList extends ConsumerWidget {
  const GroceryList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var groceryItems = ref.watch(groceryProvider);

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
      body: ListView.builder(
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
            trailing: Text(groceryItems[index].quantity.toString()),
          ),
          onDismissed: (direction) {
            ref.read(groceryProvider.notifier).removeItem(groceryItems[index]);
          },
        ),
      ),
    );
  }
}
