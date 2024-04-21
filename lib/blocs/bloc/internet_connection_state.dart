part of 'internet_connection_bloc.dart';

@immutable
abstract class NetworkState {}

class ConnectionInitial extends NetworkState {}

class Connected extends NetworkState {}

class Disconnected extends NetworkState {}
