import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:notebook_projectf/Screens/add_note/add_note_screen.dart';
import 'package:notebook_projectf/Screens/home/widgets/item_note.dart';
import 'package:notebook_projectf/authentication_page.dart';
import 'package:notebook_projectf/models/note.dart';
import 'package:notebook_projectf/repository/notes_repository.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _allNotes = [];
  List<Note> _filteredNotes = [];
  final TextEditingController _searchController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadNotes();
    _searchController.addListener(() {
      _filterNotes(_searchController.text);
    });
  }

  void _loadNotes() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    String? uid = currentUser?.uid;

    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No user is logged in')),
      );
      return;
    }

    final notes = await NotesRepository.getNotes(uid); // Récupération des notes depuis le repository
    setState(() {
      _allNotes = notes;
      _filteredNotes = notes;
    });
  }


  void _filterNotes(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredNotes = _allNotes; // Affiche toutes les notes si aucune lettre n'est tapée
      });
      return;
    }

    final filtered = _allNotes.where((note) {
      final titleLower = note.title.toLowerCase();
      final descriptionLower = note.description.toLowerCase();
      final searchLower = query.toLowerCase();
      return titleLower.contains(searchLower) || descriptionLower.contains(searchLower);
    }).toList();

    setState(() {
      _filteredNotes = filtered;
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthPage()),
            (route) => false, // Remove all previous routes
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during logout: $e')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Notes',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFFAF7F5),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.black),
            onPressed: _logout,
          ),
        ],
      ),

      backgroundColor: Color(0xFFFAF7F5),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: _filteredNotes.isEmpty
                ? const Center(child: Text('Note does not exist'))
                : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              children: _filteredNotes.map((note) => ItemNote(note: note, searchQuery: _searchController.text,onRefresh: _loadNotes,)).toList(),
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async{
          await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddNoteScreen()));
          _loadNotes();
          },
        backgroundColor: Color(0xFF69E6E8),
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}
