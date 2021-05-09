// import 'package:chat_app/pages/chat.dart';
import 'package:chat_app/pages/auth.dart';
import 'package:chat_app/pages/login.dart';
import 'package:chat_app/pages/novels_splash.dart';
import 'package:chat_app/pages/signup.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/pages/chatterScreen.dart';
import 'pages/splash.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(ChatterApp());
}
class ChatterApp extends StatefulWidget {
  const ChatterApp({Key key}) : super(key: key);

  @override
  _ChatterAppState createState() => _ChatterAppState();
}

class _ChatterAppState extends State<ChatterApp> {
  FirebaseMessaging _messaging = FirebaseMessaging();


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatter',

      theme: ThemeData(textTheme: TextTheme(body1: TextStyle(fontFamily: 'Poppins'),),),
      // home: ChatterHome(),
      initialRoute: '/',
      routes: {
        '/':(context)=>WelcomeScreen(),
        '/splash':(context)=>ChatterHome(),
        '/login':(context)=>ChatterLogin(),
        '/chat':(context)=>ChatterScreen(),
        '/auth':(context)=>LocalAuth(),
        // '/chats':(context)=>ChatterScreen()
      },
    );
  }
}

