import 'package:bloc/bloc.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';

part 'internet_connection_event.dart';
part 'internet_connection_state.dart';

class InternetConnectionBloc extends Bloc<NetworkEvent, NetworkState> {
  InternetConnectionBloc() : super(ConnectionInitial()) {
    on<CheckConnection>(_oncheckConnection);
  }
  _oncheckConnection(CheckConnection event, Emitter<NetworkState> emit) async {
    final List<ConnectivityResult> connectivityResult =
        await (Connectivity().checkConnectivity());

    if (connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi)) {
    return  emit(Connected());
    } else {
      return emit(Disconnected());
    }
  }
}
