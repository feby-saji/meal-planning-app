import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_planning/screens/premium/premium.dart';
import 'package:meal_planning/styles.dart';
import 'package:meal_planning/widgets/main_appbar.dart';
import 'package:meal_planning/widgets/main_container.dart';

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
                  SizedBox(height: 50),
                  //
                  OptionTileWidget(
                    iconPath: 'assets/icons/app_icons/premium1.png',
                    title: 'Go Premium',
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => PremiumScreen(),
                        )),
                  ),
                  OptionTileWidget(
                    iconPath: 'assets/icons/app_icons/people.png',
                    title: 'family',
                    onTap: () {},
                  ),
                  OptionTileWidget(
                    iconPath: 'assets/icons/app_icons/log-out.png',
                    title: 'log out',
                    onTap: () async {
                      await FirebaseAuth.instance.signOut();
// TODO
//  logout the user
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class OptionTileWidget extends StatelessWidget {
  OptionTileWidget({
    super.key,
    required this.iconPath,
    required this.title,
    required this.onTap,
  });

  String iconPath;
  String title;
  void Function() onTap;

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
