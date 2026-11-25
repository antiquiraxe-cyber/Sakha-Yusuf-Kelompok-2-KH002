import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../domain/entities/child_entity.dart';
import '../../domain/repositories/child_repository.dart';
import '../models/child_model.dart';

class ChildRepositoryImpl implements ChildRepository {
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  ChildRepositoryImpl({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

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
    final childRef = _childrenRef(parentId).doc(childId);

    // Firestore tidak menghapus subkoleksi otomatis.
    for (final sub in childSubcollections) {
      await _deleteCollection(childRef.collection(sub));
    }

    await childRef.delete();

    // Foto profil & catatan bersifat opsional; kegagalan Storage
    // tidak boleh menggagalkan penghapusan data utama.
    try {
      await _storage
          .ref('users/$parentId/children/$childId')
          .listAll()
          .then((result) async {
        for (final item in result.items) {
          await item.delete();
        }
        for (final prefix in result.prefixes) {
          final nested = await prefix.listAll();
          for (final item in nested.items) {
            await item.delete();
          }
        }
      });
    } catch (_) {
      // abaikan: data Firestore sudah terhapus
    }
  }

  Future<void> _deleteCollection(
    CollectionReference<Map<String, dynamic>> ref,
  ) async {
    while (true) {
      final snapshot = await ref.limit(400).get();
      if (snapshot.docs.isEmpty) return;

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
