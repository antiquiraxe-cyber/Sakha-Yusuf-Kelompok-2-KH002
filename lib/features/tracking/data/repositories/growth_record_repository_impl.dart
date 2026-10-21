import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/growth_record_entity.dart';
import '../../domain/repositories/growth_record_repository.dart';
import '../models/growth_record_model.dart';

class GrowthRecordRepositoryImpl implements GrowthRecordRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  GrowthRecordRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _recordsRef(String childId) {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AppException(message: 'Pengguna belum masuk');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('children')
        .doc(childId)
        .collection('growth_records');
  }

  @override
  Stream<List<GrowthRecordEntity>> watchRecords(String childId) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _recordsRef(childId)
        .orderBy('recordDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GrowthRecordModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<List<GrowthRecordEntity>> getRecordsByChildId(String childId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _recordsRef(childId)
          .orderBy('recordDate', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => GrowthRecordModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreException(
        message: 'Gagal mengambil catatan pertumbuhan: ${e.toString()}',
      );
    }
  }

  @override
  Future<GrowthRecordEntity?> getLatestRecord(String childId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot = await _recordsRef(childId)
          .orderBy('recordDate', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return GrowthRecordModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> addRecord(GrowthRecordEntity record) async {
    try {
      final ref = _recordsRef(record.childId);
      final docRef = record.id.isEmpty ? ref.doc() : ref.doc(record.id);
      final model = GrowthRecordModel(
        id: docRef.id,
        childId: record.childId,
        recordDate: record.recordDate,
        weightKg: record.weightKg,
        heightCm: record.heightCm,
        headCircumferenceCm: record.headCircumferenceCm,
        note: record.note,
        photoUrl: record.photoUrl,
        createdAt: record.createdAt,
      );
      await docRef.set(model.toFirestore());
    } catch (e) {
      if (e is AppException) rethrow;
      throw FirestoreException(
        message: 'Gagal menyimpan catatan pertumbuhan: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> deleteRecord(String childId, String recordId) async {
    try {
      await _recordsRef(childId).doc(recordId).delete();
    } catch (e) {
      throw FirestoreException(
        message: 'Gagal menghapus catatan pertumbuhan: ${e.toString()}',
      );
    }
  }

  @override
  Future<String?> uploadPhoto({
    required String childId,
    required String fileName,
    required List<int> bytes,
    String contentType = 'image/jpeg',
  }) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AppException(message: 'Pengguna belum masuk');
    }

    // Validasi batas ukuran file 2MB
    if (bytes.length > 2 * 1024 * 1024) {
      throw const StorageException(
        message: 'Ukuran foto melebihi batas maksimal 2MB',
      );
    }

    try {
      final storageRef = _storage
          .ref()
          .child('users')
          .child(user.uid)
          .child('children')
          .child(childId)
          .child('growth_records')
          .child(fileName);

      final uploadTask = await storageRef.putData(
        Uint8List.fromList(bytes),
        SettableMetadata(contentType: contentType),
      );

      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw StorageException(
        message: 'Gagal mengunggah foto pertumbuhan: ${e.toString()}',
      );
    }
  }
}
