import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/repositories/child_repository.dart';
import '../models/child_model.dart';

class ChildRepositoryImpl implements ChildRepository {
  final FirebaseFirestore _firestore;

  ChildRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _childrenRef(String parentId) {
    return _firestore.collection('users').doc(parentId).collection('children');
  }

  @override
  Stream<List<ChildEntity>> watchChildren(String parentId) {
    return _childrenRef(parentId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => ChildModel.fromFirestore(doc)).toList());
  }

  @override
  Future<List<ChildEntity>> getChildren(String parentId) async {
    final snapshot = await _childrenRef(parentId)
        .orderBy('createdAt', descending: false)
        .get();
    return snapshot.docs.map((doc) => ChildModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> addChild(ChildEntity child) async {
    final ref = _childrenRef(child.parentId);
    final docRef = child.id.isEmpty ? ref.doc() : ref.doc(child.id);
    final model = ChildModel(
      id: docRef.id,
      parentId: child.parentId,
      name: child.name,
      birthDate: child.birthDate,
      gender: child.gender,
      childOrder: child.childOrder,
      photoUrl: child.photoUrl,
      createdAt: child.createdAt,
    );
    await docRef.set(model.toFirestore());
  }

  @override
  Future<void> updateChild(ChildEntity child) async {
    final model = ChildModel(
      id: child.id,
      parentId: child.parentId,
      name: child.name,
      birthDate: child.birthDate,
      gender: child.gender,
      childOrder: child.childOrder,
      photoUrl: child.photoUrl,
      createdAt: child.createdAt,
    );
    await _childrenRef(child.parentId).doc(child.id).update(model.toFirestore());
  }

  @override
  Future<void> deleteChild(String parentId, String childId) async {
    await _childrenRef(parentId).doc(childId).delete();
  }
}
