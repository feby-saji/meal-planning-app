import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/models/meal_plan_model.dart';
import 'package:meal_planning/models/recipe_model.dart';
import 'package:meal_planning/screens/meal_plan.dart/bloc/meal_plan_bloc.dart';
import 'package:meal_planning/screens/meal_plan.dart/functions/dateFormat.dart';
import 'package:meal_planning/styles.dart';
import 'package:meal_planning/widgets/main_appbar.dart';
import 'package:meal_planning/widgets/main_container.dart';
import 'package:meal_planning/widgets/snackbar.dart';

class MealPlanScreen extends StatelessWidget {
  const MealPlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SizeConfig sizeConfig = SizeConfig();
    sizeConfig.init(context);
    // context.read<MealPlanBloc>().add(GetAllMealToPlanEvent());

    return Column(
      children: [
        KAppBarWidget(
          sizeConfig: sizeConfig,
          title: 'Meal plan',
          imgPath: 'assets/icons/app_icons/settings.png',
        ),
        Expanded(
          child: KMainContainerWidget(
            sizeConfig: sizeConfig,
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 7,
              itemBuilder: (BuildContext context, int ind) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Text(
                        formattedDate(DateTime.now().add(Duration(days: ind))),
                        style: kSmallText,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _buildShowDialog(
                        context,
                        DateTime.now().add(Duration(days: ind)),
                      ),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        height: sizeConfig.screenHeight / 6,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: kClrSecondary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: BlocBuilder<MealPlanBloc, MealPlanState>(
                          builder: (context, state) {
                            if (state is MealPlanLoadSuccess) {
                              return _buildOnMealLoadSuccess(state, ind);
                            }
                            return const Center(child: Text('No meals '));
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOnMealLoadSuccess(MealPlanLoadSuccess state, int ind) {
    List<MealPlanModel> todayMeals = [];
    todayMeals = state.meals.where((meal) {
      final DateTime currentDate = DateTime.now().add(Duration(days: ind));
      return meal.mealDate.year == currentDate.year &&
          meal.mealDate.month == currentDate.month &&
          meal.mealDate.day == currentDate.day;
    }).toList();

    if (todayMeals.isEmpty) {
      // print('No meals for ${DateTime.now().add(Duration(days: ind))}');
      return const Text('No meals');
    } else {
      print(
          'Today\'s meals for ${DateTime.now().add(Duration(days: ind))}: $todayMeals');
      return ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(0),
        // physics: const NeverScrollableScrollPhysics(),
        itemCount: todayMeals.length,
        itemBuilder: (context, index) {
          final recipeTitle = todayMeals[index].recipe.title;
          return ListTile(
            contentPadding: const EdgeInsets.all(0),
            title: Text(recipeTitle),
            onTap: () {},
          );
        },
      );
    }
  }

  Future<void> _buildShowDialog(BuildContext context, DateTime date) async {
    final TextEditingController searchController = TextEditingController();
    context.read<MealPlanBloc>().add(MealPlanSerchEvent(val: ''));
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              height: 300.0,
              width: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextField(
                    controller: searchController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Search for meals',
                    ),
                    onChanged: (val) {
                      context
                          .read<MealPlanBloc>()
                          .add(MealPlanSerchEvent(val: val));
                    },
                  ),
                  BlocBuilder<MealPlanBloc, MealPlanState>(
                    builder: (context, state) {
                      if (state is MealPlanSearchResultsState) {
                        return Expanded(
                          child: ListView.builder(
                            itemCount: state.recipes.length,
                            itemBuilder: (_, ind) {
                              RecipeModel recipe = state.recipes[ind];
                              return ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(50),
                                  child: Image.file(
                                    File(recipe.img),
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(
                                  recipe.title,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  MealPlanModel meal = MealPlanModel(
                                    mealDate: date,
                                    recipe: recipe,
                                  );
                                  context.read<MealPlanBloc>().add(
                                        AddMealToPlanEvent(meal: meal),
                                      );
                                },
                              );
                            },
                          ),
                        );
                      }
                      if (state is MealPlanFailureState) {
                        return Text(state.err);
                      }
                      return const SizedBox();
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
