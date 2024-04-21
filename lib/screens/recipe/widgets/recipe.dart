import 'dart:io';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/screens/recipe/bloc/recipe_bloc.dart';
import 'package:meal_planning/styles.dart';

class KRecipeWidget extends StatelessWidget {
  KRecipeWidget({
    Key? key,
    required this.sizeConfig,
    required this.imgPath,
    required this.title,
    required this.onTap,
    required this.isFav,
    required this.updateFav,
  }) : super(key: key);

  final SizeConfig sizeConfig;
  String? imgPath;
  String title;
  void Function() onTap;
  void Function() updateFav;
  bool isFav;

  @override
  Widget build(BuildContext context) {
    
    return GestureDetector(
      // TODO slide to delete
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        width: double.infinity,
        height: sizeConfig.blockSizeVer * 8,
        decoration: BoxDecoration(
            color: kClrSecondary,
            borderRadius: const BorderRadius.all(
              Radius.circular(20),
            )),
        child: Row(
          children: [
            imgPath != null ? buildRecipeImage() : buildDefaultImage(),
            const SizedBox(width: 10),
            SizedBox(
              width: 200,
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: kSmallText.copyWith(color: kClrPrimary),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: updateFav,
              child: SizedBox(
                child: isFav
                    ? Image.asset(
                        'assets/icons/app_icons/fav.png',
                        width: 20,
                        height: 20,
                      )
                    : Image.asset(
                        'assets/icons/app_icons/no-fav.png',
                        width: 20,
                        height: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Image buildDefaultImage() {
    return Image.asset(
      'assets/icons/app_icons/dish.png',
      width: 30,
      height: 30,
    );
  }

  ClipRRect buildRecipeImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: Image.file(
        File(imgPath!),
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    );
  }
}
