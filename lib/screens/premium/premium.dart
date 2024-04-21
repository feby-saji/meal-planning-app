import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:meal_planning/styles.dart';
import 'package:meal_planning/widgets/main_appbar.dart';
import 'package:meal_planning/widgets/main_container.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SizeConfig sizeConfig = SizeConfig();
    sizeConfig.init(context);

    return Scaffold(
      backgroundColor: kClrSecondary,
      body: Column(
        children: [
          KAppBarWidget(
            sizeConfig: sizeConfig,
            backBtn: true,
            title: 'Get Premium',
            imgPath: null,
          ),
          Expanded(
            child: KMainContainerWidget(
              sizeConfig: sizeConfig,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Features',
                    style: kMedText,
                  ),
                  SizedBox(height: 10),
                  FeautureTileWidget(title: 'Sync shopping cart'),
                  FeautureTileWidget(title: 'extract recipes from websites'),
                  FeautureTileWidget(
                      title: 'automatically sync upto 6 family members'),
                  FeautureTileWidget(title: 'Ad Free'),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Select Plan',
                        style: kMedText,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      PurchasePlanTileWidget(
                        sizeConfig: sizeConfig,
                        duration: 'Monthly',
                        money: '₹40/month',
                        onTap: () {},
                      ),
                      PurchasePlanTileWidget(
                        sizeConfig: sizeConfig,
                        duration: 'Yearly',
                        money: '₹200/month',
                        onTap: () {},
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PurchasePlanTileWidget extends StatelessWidget {
  PurchasePlanTileWidget({
    super.key,
    required this.sizeConfig,
    required this.duration,
    required this.money,
    required this.onTap,
  });

  final SizeConfig sizeConfig;
  String duration;
  String money;
  void Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: sizeConfig.screenWidth / 2.5,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: kClrSecondary,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Content fits within card
        children: [
          Text(
            duration,
            style: kMedText.copyWith(color: kClrPrimary),
          ),
          SizedBox(height: 10),
          Text(
            money,
            style: kSmallText.copyWith(color: kClrPrimary),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              print('Get Now button pressed');
            },
            child: const Text('GET NOW'),
          ),
        ],
      ),
    );
  }
}

class FeautureTileWidget extends StatelessWidget {
  FeautureTileWidget({super.key, required this.title});
  String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Image.asset(
        'assets/icons/app_icons/premium1.png',
        width: 35,
      ),
      title: Text(
        title,
        style: kSmallText,
      ),
    );
  }
}
