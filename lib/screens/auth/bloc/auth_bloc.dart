import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meal_planning/hive_db/db_functions.dart';
import 'package:meal_planning/models/user_model.dart';
import 'package:meal_planning/repository/auth_repo.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<GoogleAuthEvent>(_googleSignIn);
    on<FacebookAuthEvent>(_fbSignIn);
    on<XAuthEvent>(_xSignIn);
  }

  _googleSignIn(GoogleAuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    bool internetConnected = await checkNetworkConnection();
    if (internetConnected) {
      UserCredential userCredential = await authRepository.signInWithGoogle();
      if (userCredential.user != null) {
        HiveDb.createUser(userCredential.user!);
        emit(AuthSuccess());
        return;
      } else {
        emit(AuthFailure(error: 'sign In failed'));
      }
    } else {
      emit(AuthFailure(error: 'no active internet connection'));
    }
  }

  _fbSignIn(FacebookAuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    try {
      UserCredential userCredential = await authRepository.signInWithFacebook();
      if (userCredential.user != null) {
        emit(AuthSuccess());
        return;
      } else {
        emit(AuthFailure(error: 'sign In failed'));
      }
    } catch (e) {
      emit(AuthFailure(error: 'sign In failed'));
      print(e);
    }
  }

  _xSignIn(XAuthEvent event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    UserCredential userCredential = await authRepository.signInWithTwitter();
    if (userCredential.user != null) {
      emit(AuthSuccess());
      return;
    } else {
      emit(AuthFailure(error: 'sign In failed'));
    }
  }
}

Future<bool> checkNetworkConnection() async {
  final List<ConnectivityResult> connectivityResult =
      await (Connectivity().checkConnectivity());

  // check network connection
  if (connectivityResult.contains(ConnectivityResult.mobile) ||
      connectivityResult.contains(ConnectivityResult.wifi)) {
    return true;
  } else {
    return false;
  }
}
