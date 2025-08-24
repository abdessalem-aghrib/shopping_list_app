import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shopping_list_app/models/grocery_item.dart';

var groceryProvider =
    StateNotifierProvider<GroceryListNotifier, List<GroceryItem>>(
      (ref) => GroceryListNotifier(),
    );

class GroceryListNotifier extends StateNotifier<List<GroceryItem>> {
  GroceryListNotifier() : super([]);

  addItem(GroceryItem groceryItem) {
    state = List.of(state..add(groceryItem));
  }

  removeItem(GroceryItem groceryItem) {
    state = List.of(state..remove(groceryItem));
  }
}
