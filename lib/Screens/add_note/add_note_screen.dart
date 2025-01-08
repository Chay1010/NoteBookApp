import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:notebook_projectf/models/note.dart';
import 'package:notebook_projectf/providers/notes/notes_provider.dart';
import 'package:provider/provider.dart';

class AddNoteScreen extends StatefulWidget {
  final Note? note;
  const AddNoteScreen({super.key, this.note});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _title = TextEditingController();
  final _description = TextEditingController();
  bool _isTitleEmpty = false;


  @override
  void initState() {
    if(widget.note != null){
      _title.text = widget.note!.title;
      _description.text = widget.note!.description;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.note != null ? 'Modify/Delete Note' : 'Add Note'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                Color(0xFFFAF7F5),
              ],
            ),
          ),
        ),
        actions: [
          widget.note != null? IconButton(
            onPressed: (){
              showDialog(context: context, builder: (context) => AlertDialog(
                content: const Text('Are you sure you want to delete this note?'),
                actions: [
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                  },
                    child: const Text('Cancel'),
                  ),
                  TextButton(onPressed: (){
                    Navigator.pop(context);
                    _deleteNote();
                  },
                    child: const Text('Yes'),
                  )
                ],
              ));
            },
            icon: const Icon(Icons.delete_outline),
          ): const SizedBox(),
          IconButton(
              onPressed: widget.note == null? _insertNote: _updateNote,
              icon: const Icon(Icons.done),
          ),
        ],
      ),
      backgroundColor: Color(0xFFFAF7F5),

      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            TextFormField(
              controller: _title,
              decoration: InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                ),
                errorText: _isTitleEmpty ? 'Title cannot be empty' : null,
                errorStyle: const TextStyle(color: Colors.red),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isTitleEmpty ? Colors.red : Colors.blue,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: _isTitleEmpty ? Colors.red : Colors.grey,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15,),
            Expanded(
              child: TextField(
                controller: _description,
                decoration: InputDecoration(
                    hintText: 'Start typing here...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))
                ),
                maxLines: 50,
              ),
            )
          ],
        ),
      ),
    );
  }

  _insertNote() async{
    setState(() {
      _isTitleEmpty = _title.text.trim().isEmpty;
    });

    if (_isTitleEmpty) {
      return;
    }

    final title = _title.text.trim();
    final description = _description.text;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final note = Note(
        title: title,
        description: description,
        createdAt: DateTime.now(),
        modifiedAt: DateTime.now(),
        uid: uid,
    );
    Provider.of<NotesProvider>(context, listen: false).insert(note: note);
    Navigator.pop(context, note);
  }

  _updateNote() async{
    setState(() {
      _isTitleEmpty = _title.text.trim().isEmpty;
    });

    if (_isTitleEmpty) {
      return;
    }
    final title = _title.text.trim();
    final description = _description.text;

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Title cannot be empty')),
      );
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final note = Note(
      id: widget.note!.id!,
      title: title,
      description: description,
      createdAt: DateTime.now(),
      modifiedAt: DateTime.now(),
      uid: uid,
    );
    Provider.of<NotesProvider>(context, listen: false).update(note: note);
    Navigator.pop(context, note);
  }

  _deleteNote() async{
    Provider.of<NotesProvider>(context, listen: false).delete(note: widget.note!).then((isDone){});
    Navigator.pop(context);
  }
}
