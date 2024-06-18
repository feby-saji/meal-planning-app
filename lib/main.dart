import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meal_planning/blocs/bloc/internet_connection_bloc.dart';
import 'package:meal_planning/blocs/observer.dart';
import 'package:meal_planning/firebase_options.dart';
import 'package:meal_planning/hive_db/db_functions.dart';
import 'package:meal_planning/models/meal_plan_model.dart';
import 'package:meal_planning/models/recipe_model.dart';
import 'package:meal_planning/models/shoppinglist_item.dart';
import 'package:meal_planning/models/user_model.dart';
import 'package:meal_planning/repository/auth_repo.dart';
import 'package:meal_planning/repository/recipe_repo.dart';
import 'package:meal_planning/screens/auth/auth.dart';
import 'package:meal_planning/screens/auth/bloc/auth_bloc.dart';
import 'package:meal_planning/screens/main_screen/main_screen.dart';
import 'package:meal_planning/screens/meal_plan.dart/bloc/meal_plan/meal_plan_bloc.dart';
import 'package:meal_planning/screens/meal_plan.dart/bloc/meal_search/meal_search_bloc.dart';
import 'package:meal_planning/screens/meal_plan.dart/meal_plan.dart';
import 'package:meal_planning/screens/recipe/bloc/recipe_bloc.dart';
import 'package:meal_planning/screens/recipe/recipe.dart';
import 'package:meal_planning/screens/shopping_list/bloc/shopping_list_bloc.dart';
import 'package:meal_planning/screens/splash/splash.dart';
import 'package:meal_planning/styles.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  Hive
    ..initFlutter()
    ..registerAdapter(UserModelAdapter())
    ..registerAdapter(RecipeModelAdapter())
    ..registerAdapter(ShopingListItemAdapter())
    ..registerAdapter(MealPlanModelAdapter());
  // await Hive.deleteBoxFromDisk('ptD1YPjvgOX7Vv5oBRHdVG4P2R83');
  Bloc.observer = MyBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(create: (_) => AuthRepository()),
        RepositoryProvider(create: (_) => RecipeRepository()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => RecipeBloc(
              recipeRepository:
                  RepositoryProvider.of<RecipeRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => MealPlanSearchBloc(),
          ),
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            ),
          ),
          BlocProvider(
            create: (context) => ShoppingListBloc(),
          ),
          BlocProvider(
            create: (context) => MealPlanBloc(),
          ),
          BlocProvider(
            create: (context) => InternetConnectionBloc(),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              dialogTheme: DialogTheme(
            backgroundColor: kClrSecondary,
            titleTextStyle: kMedText,
            contentTextStyle: kSmallText,
          )),
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
