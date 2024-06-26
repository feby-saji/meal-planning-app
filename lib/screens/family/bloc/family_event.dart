part of 'family_bloc.dart';

@immutable
sealed class FamilyEvent {}

class CheckIfUserInFamilyEvent extends FamilyEvent {}

class CreateFamilyEvent extends FamilyEvent {}

class JoinFamilyEvent extends FamilyEvent {
  String familyId;
  JoinFamilyEvent({required this.familyId});
}
