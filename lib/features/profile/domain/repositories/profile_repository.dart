import 'package:dartz/dartz.dart';
import '../entities/user_profile.dart';

abstract class ProfileRepository {
  Future<Either<String, UserProfile>> getProfile(String codeAgent);
  Future<Either<String, Unit>> updateProfile(UserProfile profile);
  Future<Either<String, Unit>> changePassword(
    String codeAgent,
    String oldPassword,
    String newPassword,
  );
}
