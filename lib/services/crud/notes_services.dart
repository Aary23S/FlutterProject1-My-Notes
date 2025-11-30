// ignore_for_file: unused_import, constant_identifier_names, unused_local_variable, unused_element

import 'dart:async';
import 'dart:core';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;
import 'package:registration_form/services/crud/crud_exceeptions.dart';

class NotesServices 
{
    Database? _db;

    List<DatabaseNotes> _notes=[];

    final _notesStreamController = StreamController<List<DatabaseNotes>>.broadcast();

    NotesServices._sharedInstance();
    static final NotesServices _instance = NotesServices._sharedInstance();
    factory NotesServices () => _instance;

    Stream<List<DatabaseNotes>> get allNotes => _notesStreamController.stream;
    
    Future<void> _cacheNotes () async{
    final allNotes = await fetchAllNotes();
    _notes = allNotes.toList();
    _notesStreamController.add(_notes);
    }

    Future<DatabaseUser> getOrCreateUser({required String email}) async{
    try{
      final user = await fetchUser(email: email);
      return user;
    } on CanNotFindUser {
      final createdUser = await createUser(email: email);
      return createdUser;
    } catch (e)
    {
      rethrow;
    }
    }

    Database _getDatabaseOrThrow() 
    {
        final db=_db;
        if(db==null){
          throw DatabaseIsNotOpen();
        }
        else{
          return db;
        }
    }

    Future <void> deleteUser({required String email}) async
    {
      await _ensureDBisOpen();
      final db = _getDatabaseOrThrow();
      final deleteCount = await db.delete(
        'userTable',
        where : 'email=?',
        whereArgs: [email.toLowerCase()]
      );
      if(deleteCount!=1){
        throw CouldNotDeleteUser();
      }
      
    } 

    Future <DatabaseUser> createUser({required String email}) async 
    {
        await _ensureDBisOpen();
        final db= _getDatabaseOrThrow();
        final result = await db.query(userTable,where: 'email=?', whereArgs: [email.toLowerCase()]);
        if(result.isNotEmpty){
          throw UserAlreadyExsists();
        }
        final userId = await db.insert(userTable, {
          'emailCol' :email.toLowerCase()
        });
        return DatabaseUser (
          id:userId,
          email : email,
        );
    }

    Future <DatabaseUser> getUser({required String email}) async {
      await _ensureDBisOpen();
      final db = _getDatabaseOrThrow();
      final results = await db.query(
        userTable,
        limit: 1,
        where: 'email = ?',
        whereArgs: [email.toLowerCase()],
      );
      if (results.isEmpty) {
        throw UserDoesNotExists();
      } else {
        return DatabaseUser.fromRow(results.first);
      }
    }

    Future <DatabaseUser> fetchUser ({required String email}) async
    {
      await _ensureDBisOpen();
      final db = _getDatabaseOrThrow();
      final result = await db.query(userTable, limit: 1, where: 'email=?', whereArgs: [email.toLowerCase()]);
      if(result.isEmpty){
        throw UserDoesNotExists();
      }
      // List<Map<String, Object?>>
      return DatabaseUser.fromRow(result.first);
    }

    Future <DatabaseNotes> createNote({required DatabaseUser owner}) async
    {
      await _ensureDBisOpen();
      final db = _getDatabaseOrThrow();

      final dbUser = await getUser(email : owner.email);
      if(dbUser!=owner){
        throw CanNotFindUser();
      }

      const text ='';

      final noteId = await db.insert( noteTable, 
      {
          userIdCol : owner.id,
          textCol : text
          
      });
      
      final note =  DatabaseNotes(id: noteId, userId: owner.id, noteTxt: text);

      _notes.add(note);
      _notesStreamController.add(_notes);

      return note;
    }

    Future <void> deleteNote ({required int id}) async
    {
        await _ensureDBisOpen();
        final db = _getDatabaseOrThrow();

        final deleteCount = await db.delete( noteTable,
            where : 'id = ?',
            whereArgs : [id]
        );

        if(deleteCount == 0){
          throw CanNotdDeleteNote();
        }else{
          _notes.removeWhere((note) => note.id==id);
          _notesStreamController.add(_notes);
        }


    }

    Future <int> deleteNotesofUser ({required int userIdCol}) async{
      await _ensureDBisOpen();
      final db = _getDatabaseOrThrow();
      return await db.delete(noteTable, where: 'userIdCol = ?' , whereArgs: [userIdCol]);
    }

    Future <int> deleteAllNotes () async{
      await _ensureDBisOpen();
      final db = _getDatabaseOrThrow();
      final noOfDeletations = await db.delete(noteTable);
      _notes = [];
      _notesStreamController.add(_notes);
      return noOfDeletations; 
    }

    Future <DatabaseNotes> fetchNote ({required int id})async{
    await _ensureDBisOpen();
    final db = _getDatabaseOrThrow();

    final result = await db.query(noteTable , where: 'id = ?', whereArgs: [id]);

    if(result.isEmpty){
      throw CanNotFindNote();
    }

    final note= DatabaseNotes.fromRow(result.first);
    _notes.removeWhere((note)=> note.id == id);
    _notes.add(note);
    _notesStreamController.add(_notes);

    return note; 
    }

    Future <List<DatabaseNotes>> fetchAllNotes () async {
      await _ensureDBisOpen();
      final db = _getDatabaseOrThrow();
      final result = await db.query(noteTable);

      if(result.isEmpty){
        throw NotesDoesNotExsits();
      }
      return result.map((row) => DatabaseNotes.fromRow(row)).toList();
    }
    
    Future <DatabaseNotes> updateNotes ({required DatabaseNotes note, required String text})async{
      await _ensureDBisOpen();
      final db=_getDatabaseOrThrow();
      final result=await db.update(noteTable,
        {
          noteTxtCol: text
        },
        where : 'id = ?',
        whereArgs: [note.id]
      );
      if(result==0){
        throw CanNotUpdateNote();
      } else{
        final updatedNote = await fetchNote(id: note.id);
        _notes.removeWhere((note) => note.id==updatedNote.id );
        _notes.add(updatedNote);
        _notesStreamController.add(_notes); 
        return updatedNote;
      }
      // return fetchNote(id: note.id);
    }
    
    Future <void> open() async
    {
      if(_db!=null){
        throw DatabaseIsAlreadyOpen;
      }
      
      try 
      {
          final docsPath = await getApplicationDocumentsDirectory();
          final dbPath = join(docsPath.path,dbName);
          final db = await openDatabase(dbPath);
          _db=db;
          
          const CreateUserTable = 
          '''
          create table IF NOT EXSISTS "user" 
          (
            "id" INTEGER NOT NULL,
            "email" TEXT NOT NULL,
            PRIMARY KEY ("id" AUTOINCREMENT)
          );
          ''';
          await db.execute(CreateUserTable);
          
          const CreateNoteTable = 
          ''' 
            create table IF NOT EXSISTS "note"
            (
              "id" INTEGER NOT NULL,
              "user_id" INTEGER NOT NULL,
              "note_txt" TEXT,
              PRIMARY KEY ("id" AUTOINCREMENT),
              FORIGEN KEY ("user_id") REFERENCES "user"("id") 
            ); 
          ''';
          await db.execute(CreateNoteTable);
          await _cacheNotes();
          
      } on MissingPlatformDirectoryException {
        throw UnableToGetDocumentDirectory();
      }
      
    }

    Future <void> close() async{
        final db=_db;
        if(db==null){
          throw DatabaseIsNotOpen();
        }else{
          await db.close();
          _db=null;
        }
      }

    Future <void> _ensureDBisOpen () async {
      try{
        await open();
      } on DatabaseIsAlreadyOpen {
          //empty
      }
    }
}

class DatabaseUser 
{
    final int id;
    final String email;
    DatabaseUser({required this.id, required this.email});

    DatabaseUser.fromRow(Map<String,Object?> map) : 
    id = map[idCol] as int,
    email = map[emailCol] as String;

    @override
    bool operator ==(covariant DatabaseUser other) => id == other.id;

    @override
    int get hashCode => id.hashCode;

    @override
    String toString() => 'User: $email and Id: $id';

}

class DatabaseNotes 
{
  final int id;
  final int userId;
  final String noteTxt;

  DatabaseNotes({required this.id,required this.userId,required this.noteTxt});

  DatabaseNotes.fromRow(Map<String,Object?> map) :
  id = map[idCol] as int,
  userId = map[userIdCol] as int,
  noteTxt = map[noteTxtCol] as String;

  @override
  String toString() => 'Id is : $id ,User id is : $userId and Notes are: $noteTxt';

  @override
    bool operator ==(covariant DatabaseNotes other) => id == other.id;

    @override
    int get hashCode => id.hashCode;

}

const dbName='user_notes.db';
const noteTable = 'notes';
const userTable = 'user';
const idCol = 'id';
const emailCol = 'email';
const userIdCol = 'user_id';
const noteTxtCol = 'note_txt';
const textCol = 'text';