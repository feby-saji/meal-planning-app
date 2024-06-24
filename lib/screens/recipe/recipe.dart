// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/user_type_bloc/bloc/user_type_bloc.dart';
import 'package:meal_planning/hive_db/db_functions.dart';
import 'package:meal_planning/main.dart';
import 'package:meal_planning/models/hive_models/recipe_model.dart';
import 'package:meal_planning/screens/auth/bloc/auth_bloc.dart';
import 'package:meal_planning/screens/meal_plan.dart/functions/show_del_dialog.dart';
import 'package:meal_planning/screens/premium/on_free_plan.dart';
import 'package:meal_planning/screens/recipe/bloc/recipe_bloc.dart';
import 'package:meal_planning/screens/recipe/detailed_recipe.dart';
import 'package:meal_planning/screens/recipe/widgets/recipe.dart';
import 'package:meal_planning/styles.dart';
import 'package:meal_planning/widgets/main_appbar.dart';
import 'package:meal_planning/widgets/main_container.dart';
import 'package:meal_planning/widgets/snackbar.dart';

bool navigatorPop = false;
List<RecipeModel> allRecipes = [];

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({Key? key}) : super(key: key);

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  @override
  Widget build(BuildContext context) {
    final SizeConfig sizeConfig = SizeConfig();
    sizeConfig.init(context);

    // check user type
    context.read<UserTypeBloc>().add(CheckUserType());

    return Column(
      children: [
        KAppBarWidget(
          sizeConfig: sizeConfig,
          title: 'Recipe',
          imgPath: 'assets/icons/app_icons/settings.png',
          sortIconVidibility: true,
        ),
        Expanded(
          child: KMainContainerWidget(
              sizeConfig: sizeConfig,
              child: BlocBuilder<UserTypeBloc, UserTypeState>(
                builder: (context, state) {
                  if (state is UserTypeLoadingState) {
                    // return _buildLoadingCircleProgressInd(context);
                  } else if (state is PremiumUserState) {
                    // 
                    context.read<RecipeBloc>().add(LoadRecipesEvent());
                    return _buildPremiumUser(sizeConfig, context);
                    // 
                  } else if (state is FreeUserState) {
                    return const OnFreePLanScreen();
                  }
                  return const Text('check internet connnection');
                },
              )),
        ),
      ],
    );
  }

  Column _buildPremiumUser(SizeConfig sizeConfig, BuildContext context) {
    return Column(
      children: [
        _buildSearchTextField(context),
        const SizedBox(height: 10),
        BlocConsumer<RecipeBloc, RecipeState>(
          listener: (context, state) {
            if (state is RecipeFetchingFailedState) {
              KShowSnackBar(context, state.err);
            }
          },
          builder: (context, state) {
            return _buildStateWidget(state, context, sizeConfig);
          },
        ),
      ],
    );
  }

  Widget _buildSearchTextField(BuildContext context) {
    return TextField(
      onChanged: (val) {
        context.read<RecipeBloc>().add(SearchRecipesEvent(val: val));
      },
      decoration: InputDecoration(
        hintText: 'Search recipes...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 10.0),
      ),
    );
  }

  Widget _buildStateWidget(
    RecipeState state,
    BuildContext context,
    SizeConfig sizeConfig,
  ) {
    if (state is RecipeLoadingState) {
      return _buildLoadingCircleProgressInd(context);
    } else if (state is RecipeLoadSuccessState) {
      allRecipes.clear();
      allRecipes.addAll(state.recipes);
      return _buildSuccessWidget(state.recipes, context, sizeConfig);
    } else if (state is RecipeLoadFailedState) {
      return _buildErrorWidget(state.err, context);
    } else if (state is RecipeFetchingFailedState) {
      return _buildFetchingFailedWidget(state.err, context, sizeConfig);
    } else {
      return allRecipes.isEmpty
          ? const Text('recipes are empty')
          : _buildSuccessWidget(allRecipes, context, sizeConfig);
    }
  }

  Widget _buildLoadingCircleProgressInd(BuildContext context) {
    Future.microtask(() {
      showDialog(
        context: context,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      navigatorPop = true;
    });
    return const SizedBox();
  }

  Widget _buildSuccessWidget(
    List<RecipeModel> recipes,
    BuildContext context,
    SizeConfig sizeConfig,
  ) {
    if (navigatorPop) Navigator.pop(context);
    navigatorPop = false;
    return Expanded(
      child: SizedBox(
        height: 200,
        child: ListView.builder(
          padding: const EdgeInsets.all(0),
          itemCount: recipes.length,
          itemBuilder: (BuildContext ctx, int ind) {
            RecipeModel recipe = recipes[ind];
            return KRecipeWidget(
              isFav: recipe.isFav,
              title: recipe.title,
              imgPath: recipe.img,
              sizeConfig: sizeConfig,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => DetailedRecipeScreen(recipe: recipe)),
              ),
              updateFav: () {
                context.read<RecipeBloc>().add(UpdateFavouriteEvent(
                      isFav: !recipe.isFav,
                      recipe: recipe,
                    ));
              },
              onLongPress: () => showDeleteConfirmation(
                  context: context,
                  contetText:
                      'Are you sure you want to delete "${recipe.title}"?',
                  onPressed: () => [
                        context
                            .read<RecipeBloc>()
                            .add(DeleteRecipeEvent(recipe: recipe)),
                        Navigator.pop(context),
                      ]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String err, BuildContext context) {
    if (navigatorPop) Navigator.pop(context);
    navigatorPop = false;
    return Expanded(child: Center(child: Text(err)));
  }

  Widget _buildFetchingFailedWidget(
    String err,
    BuildContext context,
    SizeConfig sizeConfig,
  ) {
    if (navigatorPop) Navigator.pop(context);
    navigatorPop = false;
    return allRecipes.isEmpty
        ? Expanded(child: Center(child: Text(err)))
        : _buildSuccessWidget(allRecipes, context, sizeConfig);
  }
}
