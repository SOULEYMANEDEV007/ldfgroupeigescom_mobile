part of 'login_bloc.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

class LoginSubmitted extends LoginEvent {
  final String matricule;
  final String agence;
  final String password;

  const LoginSubmitted(this.matricule, this.agence, this.password);

  @override
  List<Object> get props => [matricule, agence, password];
}
