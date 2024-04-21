part of 'meal_plan_bloc.dart';

@immutable
sealed class MealPlanState {}

final class MealPlanInitial extends MealPlanState {}

final class MealPlanLoadSuccess extends MealPlanState {
  List<MealPlanModel> meals;
  MealPlanLoadSuccess({required this.meals});
}

final class MealPlanSearchResultsState extends MealPlanState {
  List<RecipeModel> recipes;
  MealPlanSearchResultsState({required this.recipes});
}

final class MealPlanFailureState extends MealPlanState {
  String err;
  MealPlanFailureState({required this.err});
}
