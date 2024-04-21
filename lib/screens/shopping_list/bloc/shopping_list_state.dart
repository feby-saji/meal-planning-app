part of 'shopping_list_bloc.dart';

@immutable
sealed class ShoppingListState {}

final class ShoppingListInitial extends ShoppingListState {}

final class ShoppingListLoadingState extends ShoppingListState {}

final class ShoppingListItemsLoadedState extends ShoppingListState {
  Map<String, List<ShopingListItem>> categorizedItems;
  ShoppingListItemsLoadedState({required this.categorizedItems});
}

final class ShoppingListItemsFailedState extends ShoppingListState {
  String error;
  ShoppingListItemsFailedState({required this.error});
}
