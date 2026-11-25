import '../entities/child_entity.dart';

abstract class ChildRepository {
  Stream<List<ChildEntity>> watchChildren(String parentId);
  Future<List<ChildEntity>> getChildren(String parentId);
  Future<void> addChild(ChildEntity child);
  Future<void> updateChild(ChildEntity child);
  Future<void> deleteChild(String parentId, String childId);
}

/// Subkoleksi di bawah children/{childId} yang harus ikut terhapus.
/// Harus sama dengan path di firestore.rules.
const List<String> childSubcollections = ['growth_records', 'milestones'];
