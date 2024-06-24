import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/screens/account/account.dart';
import 'package:meal_planning/screens/meal_plan.dart/functions/show_del_dialog.dart';
import 'package:meal_planning/screens/recipe/bloc/recipe_bloc.dart';
import 'package:meal_planning/screens/shopping_list/bloc/shopping_list_bloc.dart';
import 'package:meal_planning/styles.dart';
import 'package:meal_planning/widgets/Drawer.dart';

class KAppBarWidget extends StatelessWidget {
  KAppBarWidget({
    super.key,
    required this.sizeConfig,
    required this.title,
    required this.imgPath,
    this.delIconVisible = false,
    this.sortIconVidibility = false,
    this.backBtn = false,
  });

  final SizeConfig sizeConfig;
  final String title;
  final String? imgPath;
  bool backBtn;
  bool delIconVisible;
  bool sortIconVidibility;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: sizeConfig.blockSizeVer * 12,
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10, top: 45),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                  visible: backBtn,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Image.asset(
                      'assets/icons/app_icons/left-chevron.png',
                      width: 38,
                    ),
                  )),
              Text(
                title,
                style: kMedText.copyWith(color: kClrPrimary),
              ),
              Row(
                children: [
                  Visibility(
                    visible: delIconVisible,
                    child: IconButton(
                        onPressed: () => showDeleteConfirmation(
                              context: context,
                              contetText:
                                  'Are you sure you want to clear Shopping List? ',
                              onPressed: () => [
                                context
                                    .read<ShoppingListBloc>()
                                    .add(ClearShoppingListItemsEvent()),
                                Navigator.pop(context)
                              ],
                            ),
                        icon: Icon(
                          Icons.delete,
                          color: kClrPrimary,
                        )),
                  ),
                  Visibility(
                      visible: sortIconVidibility,
                      child: IconButton(
                        onPressed: () {
                          // Get the position of the sort icon
                          final RenderBox overlay = Overlay.of(context)
                              .context
                              .findRenderObject() as RenderBox;
                          final RenderBox button =
                              context.findRenderObject() as RenderBox;
                          final Offset position = button
                              .localToGlobal(Offset.zero, ancestor: overlay);

                          // Calculate the horizontal position for the dropdown menu
                          final double screenWidth =
                              MediaQuery.of(context).size.width;
                          const double menuWidth = 200.0;
                          final double menuX = (screenWidth - menuWidth) / 2;
                          // Show the dropdown menu
                          showMenu<String>(
                            context: context,
                            position: RelativeRect.fromLTRB(
                                menuX, position.dy + button.size.height, 0, 0),
                            items: <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: '1',
                                child: Text('All recipes'),
                              ),
                              const PopupMenuItem<String>(
                                value: '2',
                                child: Text('Favorite'),
                              ),
                            ],
                          ).then((String? value) {
                            if (value != null) {
                              isFavPage = value == '1' ? false : true;
                              context.read<RecipeBloc>().add(SortRecipesEvent(
                                  fav: value == '1' ? false : true));
                            }
                          });
                        },
                        icon: Icon(
                          Icons.sort,
                          color: kClrPrimary,
                        ),
                      )),
                  const SizedBox(width: 10),
// settings icon
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AccountScreen()));
                    },
                    child: imgPath != null
                        ? Image.asset(
                            imgPath!,
                            width: 25,
                            height: 25,
                          )
                        : const SizedBox(),
                  ),
                ],
              )
            ],
          ),
        ));
  }
}

class MyDropdown extends StatefulWidget {
  const MyDropdown({super.key});

  @override
  _MyDropdownState createState() => _MyDropdownState();
}

class _MyDropdownState extends State<MyDropdown> {
  String selectedItem = 'Option 1';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dropdown Example'),
      ),
      body: Center(
        child: DropdownButton<String>(
          value: selectedItem,
          onChanged: (String? newValue) {
            setState(() {
              selectedItem = newValue!;
            });
          },
          items: <String>['Option 1', 'Option 2', 'Option 3', 'Option 4']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ),
    );
  }
}
