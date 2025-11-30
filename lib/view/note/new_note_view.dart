// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import 'package:registration_form/services/auth/auth_service.dart';
import 'package:registration_form/services/crud/notes_services.dart';

class NewNoteView extends StatefulWidget {
  const NewNoteView({super.key});

  @override
  State<NewNoteView> createState() => _NewNoteViewState();
}

class _NewNoteViewState extends State<NewNoteView> 
{
  DatabaseNotes? _notes;
  late final NotesServices _notesServices;
  late final TextEditingController _textController;

    @override
    void initState() {
      _notesServices = NotesServices();
      _textController = TextEditingController();
      super.initState();
      
    }
    void _textControlListener() async{
      final note = _notes;
      if(note == null){
        return ;
      }
      final text = _textController.text;
      await _notesServices.updateNotes(note: note, text: text);
    }

    void _setupTextControllerListener(){
      _textController.removeListener(_textControlListener);
      _textController.addListener(_textControlListener);
    }

  Future<DatabaseNotes> createNote() async{
    final exsistingNote = _notes;
    if(exsistingNote!=null){
      return exsistingNote;
    }
    final currentUser = AuthService.firebase().currentUser!;
    final email = currentUser.email!;
    final owner = await _notesServices.fetchUser(email: email);
    return await _notesServices.createNote(owner: owner);
  } 

  void _deleteNoteIfTextIsEmpty(){
    final note = _notes;
    if(_textController.text.isEmpty && note!=null){
      _notesServices.deleteNote(id: note.id);
    }
  }

  void _saveNoteIfTextIsNotEmpty()async {
    final note =_notes;
    final text = _textController.text;
    if(text.isNotEmpty && note != null){
      await _notesServices.updateNotes(note: note, text: text);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _deleteNoteIfTextIsEmpty();
    _saveNoteIfTextIsNotEmpty();
    _textController.dispose();
  }


  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('New Note'),
      ),
      body: FutureBuilder
      (
        future: createNote(), 
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.done:
            _notes = snapshot.data as DatabaseNotes;
            _setupTextControllerListener();
            return TextField
            (
              controller: _textController, 
              keyboardType: TextInputType.multiline,
              maxLines: null, 
              decoration: const InputDecoration(
                hintText: "Enter your notes..."
              ),
            );
            
            default:
            return const CircularProgressIndicator();
          }
        },
      )
    );
  }
}