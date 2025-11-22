// ignore_for_file: unused_import, constant_identifier_names, unused_local_variable, unused_element

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart' show MissingPlatformDirectoryException, getApplicationDocumentsDirectory;
import 'package:path/path.dart' show join;

class DatabaseIsAlreadyOpen implements Exception {}
class UnableToGetDocumentDirectory implements Exception {}
class DatabaseIsNotOpen implements Exception {}

class NotesServices 
{
    Database? _db;

    Future<void> open() async
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
          
      } on MissingPlatformDirectoryException {
        throw UnableToGetDocumentDirectory();
      }
      
      Future<void> close() async{
        final db=_db;
        if(db==null){
          throw DatabaseIsNotOpen();
        }else{
          await db.close();
          _db=null;
        }
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