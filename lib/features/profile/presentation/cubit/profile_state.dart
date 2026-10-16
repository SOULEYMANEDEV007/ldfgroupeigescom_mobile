import 'package:equatable/equatable.dart';
import '../../domain/entities/user_profile.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile profile;
  final String? successMessage;

  const ProfileLoaded(this.profile, {this.successMessage});

  @override
  List<Object?> get props => [profile, successMessage];
}

class ProfileUpdating extends ProfileState {
  final UserProfile profile;

  const ProfileUpdating(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfilePasswordUpdating extends ProfileState {
  final UserProfile profile;

  const ProfilePasswordUpdating(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileError extends ProfileState {
  final String message;
  final UserProfile? fallbackProfile;

  const ProfileError(this.message, {this.fallbackProfile});

  @override
  List<Object?> get props => [message, fallbackProfile];
}
