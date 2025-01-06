import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:notebook_projectf/models/note.dart';
import 'package:notebook_projectf/repository/notes_repository.dart';

class NotesProvider with ChangeNotifier{
  List<Note> notes=[];

  NotesProvider(){
    getNotes();
  }

  getNotes() async{
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      notes = await NotesRepository.getNotes(uid);
      notifyListeners();
    }
  }

  insert({required Note note}) async{
    await NotesRepository.insert(note: note);
    getNotes();
  }

  update({required Note note})async{
    await NotesRepository.update(note: note);
    getNotes();
  }

  Future<bool> delete({required Note note}) async{
    await NotesRepository.delete(note: note);
    getNotes();
    return true;
  }
}