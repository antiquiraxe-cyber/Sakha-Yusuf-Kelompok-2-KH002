import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return _mapFirebaseUser(user);
  }

  @override
  Future<UserEntity> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Pengguna tidak ditemukan.',
      );
    }

    // Pastikan dokumen profil di Firestore tetap ada/sinkron
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email ?? email.trim(),
      if (user.displayName != null && user.displayName!.isNotEmpty)
        'name': user.displayName,
    }, SetOptions(merge: true));

    return _mapFirebaseUser(user);
  }

  @override
  Future<UserEntity> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? name,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'Gagal membuat pengguna baru.',
      );
    }

    final trimmedName = name?.trim();
    if (trimmedName != null && trimmedName.isNotEmpty) {
      await user.updateDisplayName(trimmedName);
      await user.reload();
    }

    // Simpan data profil pengguna ke Firestore document users/{uid}
    await _firestore.collection('users').doc(user.uid).set({
      'email': email.trim(),
      'name': trimmedName ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    return _mapFirebaseUser(_auth.currentUser ?? user);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  UserEntity _mapFirebaseUser(User user) {
    return UserEntity(
      id: user.uid,
      email: user.email ?? '',
      name: user.displayName,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
    );
  }
}
