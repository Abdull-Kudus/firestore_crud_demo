import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TodoService {
  static FirebaseFirestore get _firestore => FirebaseFirestore.instance;

  // Each user gets their own todos under users/{uid}/todos.
  // A getter (not a final field) so it always uses the current user.
  static CollectionReference get _todosCollection {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user is signed in');
    }
    return _firestore.collection('users/${user.uid}/todos');
  }

  // TODO 1: CREATE - Add new todo to Firestore
  // Instructions:
  // 1. Use _todosCollection.add() to create a new document
  // 2. The document should have these fields:
  // - 'task' (String): the todo text
  // - 'completed' (boolean): false by default
  // - 'timestamp': use FieldValue.serverTimestamp()
  // 3. Return the DocumentReference
  static Future<DocumentReference> addTodo(String task) async {
    return await _todosCollection.add({
      'task': task,
      'completed': false,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  // TODO 2: READ - Get todos stream for real-time updates
  // Instructions:
  // 1. Return a stream from _todosCollection
  // 2. Order by 'timestamp' in descending order
  // 3. Use .snapshots() for real-time updates
  static Stream<QuerySnapshot> getTodosStream() {
    return _todosCollection
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // TODO 3: UPDATE - Toggle todo completion status
  // Instructions:
  // 1. Use _todosCollection.doc(id).update() to update specific document
  // 2. Update the 'completed' field to the opposite of currentStatus
  // 3. Also update 'updatedAt' timestamp
  static Future<void> toggleTodo(String id, bool currentStatus) async {
    await _todosCollection.doc(id).update({
      'completed': !currentStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // TODO 4: UPDATE - Edit todo text
  // Instructions:
  // 1. Use _todosCollection.doc(id).update() to update specific document
  // 2. Update the 'task' field with newTask
  // 3. Also update 'updatedAt' timestamp
  static Future<void> updateTodo(String id, String newTask) async {
    await _todosCollection.doc(id).update({
      'task': newTask,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // TODO 5: DELETE - Remove a todo
  // Instructions:
  // 1. Use _todosCollection.doc(id).delete() to remove the document
  static Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }

  // TODO 6: BONUS - Delete all completed todos
  // Instructions:
  // 1. Query todos where 'completed' is true
  // 2. Use a batch to delete all matching documents
  static Future<void> deleteCompletedTodos() async {
    final querySnapshot = await _todosCollection
        .where('completed', isEqualTo: true)
        .get();

    final batch = _firestore.batch();
    for (final doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}
