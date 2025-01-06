import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:notebook_projectf/models/note.dart';

class NotesRepository{
  static insert({required Note note}) async{
    final _firestore = FirebaseFirestore.instance;
    await _firestore.collection('notes').add(note.toMap());
  }

  static Future<List<Note>>getNotes(String uid) async {
    final _firestore = FirebaseFirestore.instance;

    final snapshot = await _firestore
        .collection('notes')
        .where('uid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      return Note(
        id: doc.id,
        title: data['title'],
        description: data['description'],
        createdAt: DateTime.parse(data['createdAt']),
        modifiedAt: DateTime.parse(data['modifiedAt']),
        uid: data['uid'],
      );
    }).toList();
  }

  static Future<void> update({required Note note}) async {
    final _firestore = FirebaseFirestore.instance;

    if (note.id == null) {
      throw Exception("Document ID cannot be null");
    }

    final docRef = _firestore.collection('notes').doc(note.id.toString());

    final docSnapshot = await docRef.get();
    if (!docSnapshot.exists) {
      print("Document with ID ${note.id} does not exist.");
      throw Exception("Document with ID ${note.id} does not exist");
    }

    // Update the document
    try {
      await docRef.update(note.toMap());
      print("Note updated successfully: ${note.id}");
    } catch (e) {
      print("Error updating note: $e");
      rethrow;
    }
  }


  static delete({required Note note}) async
  {
    final _firestore = FirebaseFirestore.instance;

    await _firestore.collection('notes').doc(note.id.toString()).delete();
    
  }
}