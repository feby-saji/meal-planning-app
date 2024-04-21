// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'meal_plan_bloc.dart';

@immutable
sealed class MealPlanEvent {}

class MealPlanSerchEvent extends MealPlanEvent {
  String val;
  MealPlanSerchEvent({
    required this.val,
  });
}

class AddMealToPlanEvent extends MealPlanEvent {
  MealPlanModel meal;
  AddMealToPlanEvent({
    required this.meal,
  });
}

class GetAllMealToPlanEvent extends MealPlanEvent {
  // DateTime date;
  // GetAllMealToPlanEvent({
  //   required this.date,
  // });
}
