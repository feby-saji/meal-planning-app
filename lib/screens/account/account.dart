import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/blocs/user_type_bloc/bloc/user_type_bloc.dart';
import 'package:meal_planning/consants/revenue_cat.dart';
import 'package:meal_planning/functions/checkUserType.dart';
import 'package:meal_planning/hive_db/db_functions.dart';
import 'package:meal_planning/main.dart';
import 'package:meal_planning/screens/account/functions/url_launcher.dart';
import 'package:meal_planning/screens/family/family.dart';
import 'package:meal_planning/screens/premium/on_premium_plan.dart';
import 'package:meal_planning/styles.dart';
import 'package:meal_planning/widgets/main_appbar.dart';
import 'package:meal_planning/widgets/main_container.dart';
import 'package:purchases_flutter/models/customer_info_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    String userName = FirebaseAuth.instance.currentUser!.displayName!;
    String userEmail = FirebaseAuth.instance.currentUser!.email!;
    final SizeConfig sizeConfig = SizeConfig();
    sizeConfig.init(context);
    return Scaffold(
      backgroundColor: kClrSecondary,
      body: Column(
        children: [
          KAppBarWidget(
            sizeConfig: sizeConfig,
            backBtn: true,
            title: 'Accounts',
            imgPath: null,
          ),
          Expanded(
            child: KMainContainerWidget(
              sizeConfig: sizeConfig,
              child: Column(
                children: [
                  ListTile(
                    title: Text(
                      userName,
                      style: kLargeText.copyWith(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(userEmail),
                  ),
                  const SizedBox(height: 50),
                  //
                  OptionTileWidget(
                      iconPath: 'assets/icons/app_icons/premium1.png',
                      title: 'Go Premium',
                      onTap: () async {
                        if (userType == UserType.premium) {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const OnPremiumPlanScreen(),
                            ),
                          );
                        } else {
                          await presentPayWall();
                          context.read<UserTypeBloc>().add(CheckUserType());
                        }
                      }),

                  OptionTileWidget(
                    iconPath: 'assets/icons/app_icons/people.png',
                    title: 'family',
                    onTap: () async {
                      if (userType == UserType.free) {
                        await presentPayWall();
                        context.read<UserTypeBloc>().add(CheckUserType());
                      } else {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const FamilyScreen(),
                          ),
                        );
                      }
                    },
                  ),

                  OptionTileWidget(
                    iconPath: 'assets/icons/app_icons/privacy.png',
                    title: 'Privacy Policy',
                    onTap: () async {
                      Uri uri = Uri.parse(
                          'https://github.com/feby-saji/meal_planning_policy/blob/main/privacy_policy');
                      await launchInBrowser(uri);
                    },
                  ),

                  OptionTileWidget(
                    iconPath: 'assets/icons/app_icons/log-out.png',
                    title: 'log out',
                    onTap: () async {
                      // await FirebaseAuth.instance.signOut();
//  logout the user in hive
                    },
                  ),
                  const Spacer(),
                  const Text('version 1.3.0'),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  presentPayWall() async {
    Offerings? offerings;
    try {
      offerings = await Purchases.getOfferings();
    } on PlatformException catch (e) {
      print('error $e');
    }
    await RevenueCatUI.presentPaywallIfNeeded("premium");
    await getUserType().then((usertyp) {
      if (usertyp != null) {
        userType = usertyp;
      }
    });
  }
}

class OptionTileWidget extends StatelessWidget {
  const OptionTileWidget({
    super.key,
    required this.iconPath,
    required this.title,
    required this.onTap,
  });

  final String iconPath;
  final String title;
  final void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ListTile(
        leading: SizedBox(
          child: Image.asset(
            iconPath,
            width: 30,
            height: 30,
          ),
        ),
        title: Text(
          title,
          style: kSmallText,
        ),
        trailing: Image.asset(
          'assets/icons/app_icons/r-chevron.png',
          width: 30,
        ),
      ),
    );
  }
}
