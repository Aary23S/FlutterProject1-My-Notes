
// ignore_for_file: avoid_print, unused_import
// import 'firebase_options.dart';
import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:registration_form/firebase_options.dart';
import 'package:flutter/material.dart'; 
import 'package:registration_form/constants/routes.dart';
import 'package:registration_form/view/login_view.dart';
import 'package:registration_form/view/note/new_note_view.dart';
import 'package:registration_form/view/note/notes_view.dart';
import 'package:registration_form/view/register_view.dart';
import 'package:registration_form/view/verify_email_view.dart';
import 'package:registration_form/services/auth/auth_service.dart';
import 'dart:developer' as console show log;

//main function returning void consists of asyc function which initialize the firebase and run MyApp
void main() async{
  WidgetsFlutterBinding.ensureInitialized(); 
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(const MyApp());  
}

//MyApp class is a widget which is inherited from the SLW and it wont change(immutable)
class MyApp extends StatelessWidget 
{
  const MyApp({super.key});

  //overriding the parent build function and returning the MaterialApp widget 
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login-Registartion Form',
      theme: ThemeData
      (
        // primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
      ),
      //here we are returning/calling the page which we want as a home screen 
      home: const HomePage(),
      //decalration of the routes (nameed routes)
      routes: {
        loginRoute: (context)=>LoginView(),
        registerRoute:(context)=>RegisterView(),
        verifyRoute:(context)=>VerifyEmailView(),
        notesRoute:(context)=>MyNotesView(),
        newNoteRoute:(context)=>NewNoteView(),
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      // future: AuthService.firebase().initialize(),
      future: AuthService.firebase().initialize(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.done:
            final user = AuthService.firebase().currentUser;

            if (user != null) {
              if (user.isEmailVerified) {
                return const MyNotesView();  
              } else {
                return const VerifyEmailView();
              }
            } else {
              return const LoginView();    
            }

          default:
            return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}


Future<bool> showLogOutDialog(BuildContext context)
{
    return showDialog
    (
      context: context, 
      builder: (context) 
      {
          return AlertDialog
          (
              title: const Text("Log Out"),
              content: const Text("Are you sure you want to proceed?"),
              actions:
              [
                  TextButton(onPressed: (){Navigator.of(context).pop(false);}, child: const Text("Cancel")),
                  TextButton(onPressed: (){Navigator.of(context).pop(true);}, child: const Text("Quit"))
              ],
          );
      }
    ).then((onValue) => onValue ?? false);
}






























//-----------------------------------***----------------------------------------------------

//homepage class is getting inherited from stateless widget which means this class is immutable 
// class HomePage extends StatelessWidget 
// {
//   //homepage is construtor accessing the key from its parent 
//   const HomePage({super.key});

//  //build function is overriding its parent class build() and returning the widget which is stateless
//   @override
//   Widget build(BuildContext context) {
//     // return Container(color: Colors.blue);
//     return Scaffold
//     (
//       //scaffold and appbar are SFW and text is a SLW
//       appBar: AppBar(title: const Text('Registration Page'),),

//       body: 

//       //body has a widget Centre which tales hgt,wdt and child as parameters
//       //TextButton is a child of the Centre 
//       //after Centre widget child widget will be at the centre of the scaffold
//       // Center
//       // (
//       //   child: TextButton
//       //   (
//       //     //onPress is async task as until all the fields wont filled and submited registration wont complete
//       //     onPressed: () async 
//       //     {        
//       //     },
//       //     child:const Text('Registered')
//       //   ),
//       // ),


//       //Coloumn is SLW in which we can stack the components vertically
//       Column(
//         children: 
//         [
//           TextField
//           (
//           ),
//           TextField
//           (            
//           ),
//           TextButton
//           (
//             //onPress is async task as until all the fields wont filled and submited registration wont complete
//             onPressed: () async
//             {

//             }, 
//             child: const Text("Registered")
//           )
//         ],
//       )
//     );
//   }
// }

//-------------------------------***-----------------------------------------

