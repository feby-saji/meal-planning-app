import 'package:bloc/bloc.dart';
import 'package:meal_planning/hive_db/db_functions.dart';
import 'package:meal_planning/models/hive_models/shoppinglist_item.dart';
import 'package:meal_planning/repository/firestore.dart';
import 'package:meal_planning/screens/family/bloc/family_bloc.dart';
import 'package:meta/meta.dart';
part 'shopping_list_event.dart';
part 'shopping_list_state.dart';

class ShoppingListBloc extends Bloc<ShoppingListEvent, ShoppingListState> {
  Map<String, List<ShopingListItem>> _cachedcategorizedList = {};

  ShoppingListBloc() : super(ShoppingListInitial()) {
    on<ShoppingListAddEvent>(_shoppingListAddEvent);
    on<LoadShoppingListEvent>(_loadShoppingListEvent);
    on<ShoppingListItemRemoveEvent>(_shoppingListItemRemove);
    on<ClearShoppingListItemsEvent>(_clearShoppingListItems);
    on<SyncShoppingListEvent>(_syncShoppingListEvent);
  }

  String emptyListTxt = 'Shopping list is empty.';

  _shoppingListAddEvent(
    ShoppingListAddEvent event,
    Emitter<ShoppingListState> emit,
  ) async {
    // add item to DB
    await HiveDb.addNewShoppingItem(event.item);

    try {
      // Categorize the item
      event.item.category = ingredientCategories[event.item.name] ?? 'others';

      if (!_cachedcategorizedList.containsKey(event.item.category)) {
        _cachedcategorizedList[event.item.category] = [];
      }

      int existingInd = _cachedcategorizedList[event.item.category]!
          .indexWhere((element) => element.name == event.item.name);

      // Check if item already exists
      if (existingInd != -1) {
        // Item exists, add the new quantity to the existing one
        // int newQuantity = int.parse(
        //         _cachedcategorizedList[event.item.category]![existingInd]
        //             .quantity) +
        //     int.parse(event.item.quantity);
        // print(
        //     'printin quantities old qty ${_cachedcategorizedList[event.item.category]![existingInd].quantity} , new qty ${event.item.quantity} total qty $newQuantity');
        _cachedcategorizedList[event.item.category]![existingInd].quantity =
            _cachedcategorizedList[event.item.category]![existingInd].quantity;
      } else {
        // Item doesn't exist, add it to the list
        _cachedcategorizedList[event.item.category]?.add(event.item);
      }

      emit(ShoppingListItemsLoadedState(
        categorizedItems: _cachedcategorizedList,
      ));
    } catch (e) {
      emit(ShoppingListItemsFailedState(error: e.toString()));
    }
  }

  _loadShoppingListEvent(
    LoadShoppingListEvent event,
    Emitter<ShoppingListState> emit,
  ) async {
    List<ShopingListItem>? allItems = HiveDb.loadAllShoppingItem();
    if (allItems != null && allItems.isNotEmpty) {
      // categorize items
      _cachedcategorizedList.clear();
      for (var item in allItems) {
        if (!_cachedcategorizedList.containsKey(item.category)) {
          _cachedcategorizedList[item.category] = [];
        }
        _cachedcategorizedList[item.category]?.add(item);
      }

      emit(ShoppingListItemsLoadedState(
          categorizedItems: _cachedcategorizedList));
    } else {
      emit(ShoppingListItemsFailedState(error: emptyListTxt));
    }
  }

  // shopping item functions

  _shoppingListItemRemove(
    ShoppingListItemRemoveEvent event,
    Emitter<ShoppingListState> emit,
  ) {
    // remove in DB
    HiveDb.removeShoppingListItem(event.item);

    // remove in cached list
    int? ind = _cachedcategorizedList[event.item.category]?.indexOf(event.item);
    if (ind != null) {
      _cachedcategorizedList[event.item.category]!.removeAt(ind);
    }
    // check if category is empty
    if (_cachedcategorizedList[event.item.category]!.isEmpty) {
      _cachedcategorizedList.remove(event.item.category);
    }
    if (_cachedcategorizedList.isNotEmpty) {
      return emit(
        ShoppingListItemsLoadedState(categorizedItems: _cachedcategorizedList),
      );
    } else {
      return emit(ShoppingListItemsFailedState(error: emptyListTxt));
    }
  }

  _clearShoppingListItems(
    ClearShoppingListItemsEvent event,
    Emitter<ShoppingListState> emit,
  ) async {
    // clear in Db
    HiveDb.clearShoppingListItems();

    // remove in cached list
    _cachedcategorizedList = {};
    if (_cachedcategorizedList.isNotEmpty) {
      emit(
        ShoppingListItemsLoadedState(categorizedItems: _cachedcategorizedList),
      );
    } else {
      emit(ShoppingListItemsFailedState(error: emptyListTxt));
    }
  }

  _syncShoppingListEvent(
    SyncShoppingListEvent event,
    Emitter<ShoppingListState> emit,
  ) async {
    emit(ShoppingListLoadingState());
    FireStoreFunctions firestore = FireStoreFunctions();

    // write every items to firestore
    List<ShopingListItem>? allItems = HiveDb.loadAllShoppingItem();

    if (allItems != null && allItems.isNotEmpty) {
      try {
        Map<String, dynamic> shoppingItemsMap = {};

        for (var item in allItems) {
          shoppingItemsMap[item.name] = {
            'category': item.category,
            'quantity': item.quantity,
          };
        }

        await firestore.writeShoppingListItems(shoppingItemsMap);
        // clear shopping list before getting items from firestore else quantity will conflict
        // HiveDb.clearShoppingListItems();

        // put items to hive
        List<ShopingListItem>? allItemsList =
            await firestore.readShoppingListItems();
        if (allItemsList != null && allItemsList.isNotEmpty) {
          for (var item in allItemsList) {
            await HiveDb.addNewShoppingItem(item);
          }
        }
        // call LoadShoppingListEvent after putting shoppping items in hive
        return add(LoadShoppingListEvent());
      } catch (e) {
        print(e);
      }
    }
  }
}
