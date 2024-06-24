import 'package:bloc/bloc.dart';
import 'package:meal_planning/functions/checkUserType.dart';
import 'package:meal_planning/hive_db/db_functions.dart';
import 'package:meal_planning/main.dart';
import 'package:meta/meta.dart';
part 'user_type_event.dart';
part 'user_type_state.dart';

class UserTypeBloc extends Bloc<UserTypeEvent, UserTypeState> {
  UserTypeBloc() : super(UserTypeInitial()) {
    on<CheckUserType>(_checkUserType);
  }
  _checkUserType(CheckUserType event, Emitter<UserTypeState> emit) async {
    emit(UserTypeLoadingState());

    if (userType == UserType.free) {
      print('emitting usertype $userType');
      emit(FreeUserState());
      return;
    } else {
      print('emitting usertype $userType');
      emit(PremiumUserState());
      return;
    }
  }
}
