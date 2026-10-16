import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/network/token_manager.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

@injectable
class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;
  final TokenManager _tokenManager;

  ProfileCubit(this._profileRepository, this._tokenManager)
      : super(ProfileInitial());

  Future<void> loadProfile() async {
    if (isClosed) return;
    emit(ProfileLoading());

    final codeAgent = _tokenManager.getCodeAgent() ?? '9991317331';
    final result = await _profileRepository.getProfile(codeAgent);

    if (isClosed) return;

    result.fold(
      (failure) => emit(ProfileError(failure)),
      (profile) {
        // Enregistrer le nom complet et rôle en session
        if (profile.nomComplet.isNotEmpty) {
          _tokenManager.setFullName(profile.nomComplet);
        }
        if (profile.role.isNotEmpty) {
          _tokenManager.setUserRole(profile.role);
        }
        emit(ProfileLoaded(profile));
      },
    );
  }

  Future<bool> updateProfile(UserProfile updatedProfile) async {
    final current = state;
    UserProfile? previousProfile;
    if (current is ProfileLoaded) {
      previousProfile = current.profile;
      emit(ProfileUpdating(previousProfile));
    } else {
      emit(ProfileLoading());
    }

    final result = await _profileRepository.updateProfile(updatedProfile);

    if (isClosed) return false;

    return result.fold(
      (failure) {
        emit(ProfileError(
          failure,
          fallbackProfile: previousProfile ?? updatedProfile,
        ));
        return false;
      },
      (_) {
        emit(ProfileLoaded(
          updatedProfile,
          successMessage: 'Informations modifiées avec succès',
        ));
        return true;
      },
    );
  }

  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final current = state;
    UserProfile? currentProfile;
    if (current is ProfileLoaded) {
      currentProfile = current.profile;
      emit(ProfilePasswordUpdating(currentProfile));
    }

    final codeAgent = _tokenManager.getCodeAgent() ?? '9991317331';
    final result = await _profileRepository.changePassword(
      codeAgent,
      oldPassword,
      newPassword,
    );

    if (isClosed) return false;

    return result.fold(
      (failure) {
        emit(ProfileError(
          failure,
          fallbackProfile: currentProfile,
        ));
        return false;
      },
      (_) {
        if (currentProfile != null) {
          emit(ProfileLoaded(
            currentProfile,
            successMessage: 'Mot de passe modifié avec succès',
          ));
        }
        return true;
      },
    );
  }
}
