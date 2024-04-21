import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/models/shoppinglist_item.dart';
import 'package:meal_planning/repository/recipe_repo.dart';
import 'package:meal_planning/screens/main_screen/widgets/show_dialog.dart';
import 'package:meal_planning/screens/meal_plan.dart/meal_plan.dart';
import 'package:meal_planning/screens/recipe/bloc/recipe_bloc.dart';
import 'package:meal_planning/screens/recipe/recipe.dart';
import 'package:meal_planning/screens/shopping_list/bloc/shopping_list_bloc.dart';
import 'package:meal_planning/screens/shopping_list/shopping_list.dart';
import 'package:meal_planning/styles.dart';
import 'package:meal_planning/widgets/Drawer.dart';
import 'package:meal_planning/widgets/bottom_nav_bar.dart';
import 'package:meal_planning/widgets/snackbar.dart';

ValueNotifier<int> navBarInd = ValueNotifier(1);

class MainScreen extends StatelessWidget {
  // static String route = 'main_screen';
  MainScreen({super.key});

  List screens = [
    const ShoppingListScreen(),
    const MealPlanScreen(),
    const RecipeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    SizeConfig sizeConfig = SizeConfig();
    sizeConfig.init(context);
    return ValueListenableBuilder(
        valueListenable: navBarInd,
        builder: (BuildContext context, int ind, _) {
          return Scaffold(
              backgroundColor: kClrSecondary,
              body: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: screens[ind],
              ),
              bottomNavigationBar: const BottomNavBarWidget(),
              floatingActionButton: Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: _buildAddButton(ind, context)));
        });
  }

  Visibility _buildAddButton(int ind, BuildContext context) {
    return Visibility(
      visible: ind == 0 || ind == 2,
      child: FloatingActionButton(
          backgroundColor: kClrSecondary,
          child: Image.asset(
            'assets/icons/app_icons/add.png',
            width: 30,
            height: 30,
          ),
          onPressed: () {
            if (ind == 0) {
              _buildAddShoppingItemDialog(context);
            } else if (ind == 2) {
              buildShowDialog(
                context: context,
                title: 'Enter the link to the recipe from website here.',
                btnText: 'add Recipe',
                onTap: () {
                  if (formKey1.currentState!.validate()) {
                    Navigator.pop(context);
                    context
                        .read<RecipeBloc>()
                        .add(AddNewRecipeEvent(url: showDialogTxtCtrl1.text));
                    showDialogTxtCtrl1.text = '';
                  }
                },
              );
            }
          }),
    );
  }

  _buildAddShoppingItemDialog(BuildContext context) {
    TextEditingController itemNameCtrl = TextEditingController();
    TextEditingController qtyCtrl = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: SizedBox(
              height: 200.0,
              width: 300.0,
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    TextFormField(
                      controller: itemNameCtrl,
                      decoration: const InputDecoration(
                        hintText: 'Item name',
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Item name cannot be empty';
                        }
                        return null; // Return null if validation passes
                      },
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        hintText: 'Qty',
                      ),
                    ),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          Navigator.pop(context);
                          final item = ShopingListItem(
                            name: itemNameCtrl.text.trim(),
                            quantity: qtyCtrl.text.isEmpty ? '1' : qtyCtrl.text,
                          );
                          context.read<ShoppingListBloc>().add(
                                ShoppingListAddEvent(item: item),
                              );
                        }
                      },
                      child: const Text('Add'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
