import 'package:bloc/bloc.dart';
import 'package:meal_planning/hive_db/db_functions.dart';
import 'package:meal_planning/models/meal_plan_model.dart';
import 'package:meal_planning/models/recipe_model.dart';
import 'package:meta/meta.dart';

part 'meal_plan_event.dart';
part 'meal_plan_state.dart';

class MealPlanBloc extends Bloc<MealPlanEvent, MealPlanState> {
  List<MealPlanModel> _cachedMealPlans = [];

  MealPlanBloc() : super(MealPlanInitial()) {
    on<MealPlanSerchEvent>(_mealPlanSearchEvent);
    on<AddMealToPlanEvent>(_addMealToPlanEvent);
    on<GetAllMealToPlanEvent>(_getAllMealToPlanEvent);
  }

  _mealPlanSearchEvent(
    MealPlanSerchEvent event,
    Emitter<MealPlanState> emit,
  ) async {
    if (event.val.isEmpty) {
      List<RecipeModel>? recipes = await HiveDb.loadAllRecipes();
      if (recipes != null) {
        emit(MealPlanSearchResultsState(recipes: recipes));
      }
    } else {
      List<RecipeModel> recipes = await HiveDb.getRecipes(event.val);
      if (recipes.isEmpty) {
        emit(MealPlanFailureState(err: 'no recipe found'));
      } else {
        emit(MealPlanSearchResultsState(recipes: recipes));
      }
    }
  }

  _addMealToPlanEvent(
    AddMealToPlanEvent event,
    Emitter<MealPlanState> emit,
  ) async {
    await HiveDb.addMealToPlan(event.meal);
    _cachedMealPlans.add(event.meal);
    emit(MealPlanLoadSuccess(meals: _cachedMealPlans));

    print('prinitng new meal plan added ');
  }

  _getAllMealToPlanEvent(
    GetAllMealToPlanEvent event,
    Emitter<MealPlanState> emit,
  ) async {
    List<MealPlanModel>? demoList = await HiveDb.getAllMealPlans();
    if (demoList != null) {
      _cachedMealPlans = demoList;
      if (_cachedMealPlans.isNotEmpty) {
        emit(MealPlanLoadSuccess(meals: _cachedMealPlans));
      } else {
        MealPlanFailureState(err: 'no meals');
      }
    }
  }
}
