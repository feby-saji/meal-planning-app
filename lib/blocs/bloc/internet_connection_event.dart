part of 'internet_connection_bloc.dart';

@immutable
sealed class NetworkEvent {}


class CheckConnection extends NetworkEvent {}
