import 'dart:async';
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:meal_planning/models/recipe_model.dart';

class RecipeRepository {
  Future<dynamic> getRecipeContent(String url) async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

    // check network connection
    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
      Map<String, dynamic> map = {};
      RecipeModel? recipe;

      try {
        http.Response response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          var document = parser.parse(response.body);
          // Extract recipe data
          var scriptTags =
              document.querySelectorAll('script[type="application/ld+json"]');
          if (scriptTags.isNotEmpty) {
            var jsonText = scriptTags.first.text;
            var decJson = json.decode(jsonText);
            // check if decJson in valid
            if (decJson != null && decJson.isNotEmpty) {
              map = decJson[0];
              // Create RecipeModel
              recipe = RecipeModel.fromMap(map);
            } else {
              print('fetch failed try recipes from another websites');
              return 'try recipes from another websites';
            }
          } else {
            return 'Recipe data not found in the HTML';
          }
        } else if (response.statusCode == 400) {
          return 'Bad request: ${response.statusCode}';
        } else if (response.statusCode == 404) {
          return 'Not found: ${response.statusCode}';
        } else if (response.statusCode == 500) {
          return 'Server error: ${response.statusCode}';
        } else {
          return 'Unexpected error occured : ${response.statusCode}';
        }
      } catch (e) {
        // not working as expected

        print('printing the try catch error ${e.toString()}');
        return e.toString();
      }
      return recipe;
    } else {
      print('fetch failed No active internet connection');

      return 'No active internet connection';
    }
  }
}
