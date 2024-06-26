import 'package:bloc/bloc.dart';
import 'package:meal_planning/functions/network_connection.dart';
import 'package:meal_planning/hive_db/db_functions.dart';
import 'package:meal_planning/main.dart';
import 'package:meal_planning/models/hive_models/family.dart';
import 'package:meal_planning/repository/firestore.dart';
import 'package:meta/meta.dart';
part 'family_event.dart';
part 'family_state.dart';

class FamilyBloc extends Bloc<FamilyEvent, FamilyState> {
  final FireStoreFunctions _firestore = FireStoreFunctions();
  FamilyBloc() : super(LoadingStateFamily()) {
    on<CheckIfUserInFamilyEvent>(_checkIfUserInFamily);
    on<CreateFamilyEvent>(_createFamilyEvent);
    on<JoinFamilyEvent>(_joinFamilyEvent);
  }

  _checkIfUserInFamily(
      CheckIfUserInFamilyEvent event, Emitter<FamilyState> emit) async {
    final inFamily = await _firestore.checkIfUserInFam();

    if (inFamily.isNotEmpty) {
      Family? family;
      if (await connectedToInternet() && userType == UserType.premium) {
        // get family info from firestore to hive
        family = await _firestore.fetchFamilyDetails();
      } else {
        family = await HiveDb.getFamilyHive();
      }
      return emit(UserInFamily(family: family!));
    } else {
      return emit(UserNotInFamily());
    }
  }

  _createFamilyEvent(CreateFamilyEvent event, Emitter<FamilyState> emit) async {
    if (await connectedToInternet()) {
      emit(LoadingStateFamily());
      await _firestore.createFamily();
      return add(CheckIfUserInFamilyEvent());
    } else {
      return emit(ErrorStateFamily(error: 'no internet'));
    }
  }

  _joinFamilyEvent(JoinFamilyEvent event, Emitter<FamilyState> emit) async {
    if (await connectedToInternet()) {
      emit(LoadingStateFamily());

      if (await _firestore.familyExist(event.familyId)) {
        await _firestore.joinFamily(event.familyId);

        return add(CheckIfUserInFamilyEvent());
      } else {
        return emit(ErrorStateFamily(error: 'no family found'));
      }
    } else {
      return emit(ErrorStateFamily(error: 'no internet'));
    }
  }
}
