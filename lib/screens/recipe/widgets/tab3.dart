import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_planning/models/recipe_model.dart';
import 'package:meal_planning/styles.dart';

Widget buildTab3(BuildContext context, RecipeModel recipe) {
  return ListView.builder(
      itemCount: recipe.steps.length,
      itemBuilder: (BuildContext context, int ind) {
        String step = recipe.steps[ind];
        return ListTile(
          leading: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: kClrAccent,
              borderRadius: BorderRadius.circular(50.0),
            ),
            child: Center(child: Text((ind + 1).toString())),
          ),
          title: Text(step),
        );
      });
}
