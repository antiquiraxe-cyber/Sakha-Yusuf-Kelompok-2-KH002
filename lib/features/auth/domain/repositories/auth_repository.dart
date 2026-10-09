import 'package:langkahawal/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity?> getCurrentUser();
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  });
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  });
  Future<void> signOut();
}
