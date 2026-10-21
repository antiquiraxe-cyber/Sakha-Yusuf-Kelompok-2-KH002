import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../core/errors/app_exception.dart';
import '../../domain/entities/milestone_entity.dart';
import '../../domain/repositories/milestone_repository.dart';
import '../models/milestone_model.dart';

class MilestoneRepositoryImpl implements MilestoneRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  MilestoneRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> _milestonesRef(String childId) {
    final user = _auth.currentUser;
    if (user == null) {
      throw const AppException(message: 'Pengguna belum masuk');
    }
    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('children')
        .doc(childId)
        .collection('milestones');
  }

  @override
  Future<void> saveMilestoneResult(MilestoneResultEntity result) async {
    try {
      final ref = _milestonesRef(result.childId);
      final docRef = result.id.isEmpty ? ref.doc() : ref.doc(result.id);
      final model = MilestoneResultModel(
        id: docRef.id,
        childId: result.childId,
        ageMonthEvaluated: result.ageMonthEvaluated,
        answers: result.answers,
        totalYes: result.totalYes,
        status: result.status,
        evaluatedAt: result.evaluatedAt,
      );
      await docRef.set(model.toFirestore());
    } catch (e) {
      if (e is AppException) rethrow;
      throw FirestoreException(
        message: 'Gagal menyimpan hasil KPSP: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<MilestoneResultEntity>> getMilestoneHistory(String childId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return [];

      final snapshot = await _milestonesRef(childId)
          .orderBy('evaluatedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => MilestoneResultModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw FirestoreException(
        message: 'Gagal mengambil riwayat KPSP: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<MilestoneResultEntity>> watchMilestoneHistory(String childId) {
    final user = _auth.currentUser;
    if (user == null) {
      return Stream.value([]);
    }

    return _milestonesRef(childId)
        .orderBy('evaluatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MilestoneResultModel.fromFirestore(doc))
            .toList());
  }

  @override
  Future<MilestoneResultEntity?> getLatestMilestoneResult(String childId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final snapshot = await _milestonesRef(childId)
          .orderBy('evaluatedAt', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) return null;
      return MilestoneResultModel.fromFirestore(snapshot.docs.first);
    } catch (e) {
      return null;
    }
  }
}
