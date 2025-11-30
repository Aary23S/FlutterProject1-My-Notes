// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:registration_form/constants/routes.dart';
import 'package:registration_form/enum/action_menu.dart';
import 'package:registration_form/main.dart';
import 'package:registration_form/services/auth/auth_service.dart';
import 'package:registration_form/services/crud/notes_services.dart';
// ignore: unused_import
import 'package:registration_form/view/note/new_note_view.dart';

class MyNotesView extends StatefulWidget {
  const MyNotesView({super.key});

  @override
  State<MyNotesView> createState() => _MyNotesViewState();
}

class _MyNotesViewState extends State<MyNotesView> {
  late final NotesServices _notesService;
  String get userEmail => AuthService.firebase().currentUser!.email!;
  
  @override
  void initState (){
    super.initState();
    _notesService = NotesServices();
    // _notesService.open();
    
  }

  @override
  void dispose (){
    super.dispose();
    _notesService.close();

  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold
    (
      appBar: AppBar(
        title: const Text("My Notes"),
        actions: [
          IconButton
          (
            onPressed: (){
              Navigator.of(context).pushNamed(newNoteRoute);
            }, 
            icon: const Icon(Icons.add)
          ),
          PopupMenuButton<MenuAction>(
            onSelected: (value) async {
              switch (value) {
                case MenuAction.logout:
                  final shouldLogout = await showLogOutDialog(context);
                  if (shouldLogout) {
                    await AuthService.firebase().logout();
                    if (!mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      loginRoute,
                      (_) => false,
                    );
                  }
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text("Log Out"),
              )
            ],
          )
        ],
      ),
      body: FutureBuilder
      (
        future: _notesService.getOrCreateUser(email: userEmail), 
        builder:(context, snapshot) {
          switch (snapshot.connectionState) {
            
            case ConnectionState.done:
              // return Text('Hello User!');
              return StreamBuilder
              (
                stream: _notesService.allNotes, 
                builder: (context, snapshot) 
                {
                    switch (snapshot.connectionState){
                      case ConnectionState.waiting:
                      case ConnectionState.active:
                        return const Text("Waiting for the notes to reload!!!");
                      default :
                        return CircularProgressIndicator();
                    }  
                },
              );
            default:
              return const CircularProgressIndicator();
              
          }
        }
      )
    );
    
  }
}
