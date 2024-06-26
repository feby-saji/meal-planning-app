import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:meal_planning/models/hive_models/family.dart';
import 'package:meal_planning/screens/family/bloc/family_bloc.dart';
import 'package:meal_planning/screens/family/widgets/family_member_tile.dart';
import 'package:meal_planning/screens/family/widgets/join_fam.dart';
import 'package:meal_planning/styles.dart';

class FamilyScreen extends StatelessWidget {
  const FamilyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FamilyBloc>().add(CheckIfUserInFamilyEvent());
    return Scaffold(
      appBar: AppBar(title: const Text('Family')),
//
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: BlocBuilder<FamilyBloc, FamilyState>(
            builder: (context, state) {
              //
              if (state is UserInFamily) {
                return _buildUserInFamily(state.family);
              } else if (state is UserNotInFamily) {
                return _buildUserNotInFamily(context);
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ),
      ),
    );
  }

  SizedBox _buildUserNotInFamily(BuildContext ctx) {
    return SizedBox(
      width: double.maxFinite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 50),
          Text(
            'You are not in family',
            style: kMedText,
          ),
          const SizedBox(height: 30),
          _buildTextBtn('create Family',
              () => ctx.read<FamilyBloc>().add(CreateFamilyEvent())),
          const SizedBox(height: 10),
          _buildTextBtn('join Family', () {
            showDialog(
                context: ctx,
                builder: (ctx) {
                  return const JoinFamilyDialog();
                });
          }),
        ],
      ),
    );
  }

  Column _buildUserInFamily(Family family) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        //
        Text.rich(TextSpan(children: [
          TextSpan(text: 'ID : ', style: kMedText.copyWith(fontSize: 18)),
          TextSpan(
              text: family.familyId, style: kMedText.copyWith(fontSize: 20))
          // TextSpan(text: family.members.length.toString()),
        ])),
        const SizedBox(height: 10),
        Text(
          'Members :',
          style: kMedText.copyWith(fontSize: 18),
        ),
        //
        SizedBox(
          height: 400,
          child: ListView.builder(
              itemCount: family.members.length,
              itemBuilder: (context, ind) {
                return MinimalListTile(title: family.members[ind]);
              }),
        )
      ],
    );
  }

  TextButton _buildTextBtn(text, Function() onPressed) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: Colors.black,
      ),
      child: Text(
        text,
        style: const TextStyle(
            color: Colors.white), // White text for better contrast
      ),
    );
  }
}
