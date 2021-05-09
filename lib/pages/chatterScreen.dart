import 'dart:async';

import 'package:chat_app/models/users.dart';
import 'package:edge_alert/edge_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants.dart';

Timer timer;
final _firestore = Firestore.instance;
String username = 'User';
String chatname = 'User';
String email = 'user@example.com';
String messageText;
bool visibility = false;
bool status = false;
FirebaseUser loggedInUser;

class ChatterScreen extends StatefulWidget {
  @override
  _ChatterScreenState createState() => _ChatterScreenState();
}

class _ChatterScreenState extends State<ChatterScreen> {
  final chatMsgTextController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<bool> _onWillPop() async {
    return (await showDialog(
      context: context,
      builder: (context) => new AlertDialog(
        title: new Text('Are you sure?'),
        content: new Text('Do you want to log out'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: new Text('No'),
          ),
             TextButton(
              onPressed: () => new Timer(const Duration(milliseconds: 10), () {
                setUseroffline();
                new Timer(const Duration(milliseconds: 200), () {
                  _auth.signOut();
                new Timer(const Duration(milliseconds: 1000), () {
                  Navigator.of(context).pop(true);
                });
                });
                }),
              child: new Text('Yes'),
            ),
        ],
      ),
    )) ?? false;
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    getUsers();
    setUseronline();
    timer = Timer.periodic(Duration(seconds: 60), (Timer t) => getUsers());
    // getMessages();
  }

  void setUseronline() async{
    await _firestore.collection('users')
        .document(username)
        .updateData({
      'online': true,
      'username': username,
    }).then((result){
    print("USer online true");
    }).catchError((onError){
    print("onError");
    });
  }
  void setUseroffline() async{
    await _firestore.collection('users')
        .document(username)
        .updateData({
      'online': false,
      'username': username,
    }).then((result){
      print("USer offline true");
    }).catchError((onError){
      print("onError");
    });
  }
  visibility_toggle() {
    setState(() {
      visibility = !visibility;
    });
  }
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        setState(() {
          username = loggedInUser.displayName;
          email = loggedInUser.email;
        });
      }
    } catch (e) {
      EdgeAlert.show(context,
          title: 'Something Went Wrong',
          description: e.toString(),
          gravity: EdgeAlert.BOTTOM,
          icon: Icons.error,
          backgroundColor: Colors.deepPurple[900]);
    }
  }
  // void getMessages()async{
  //   final messages=await _firestore.collection('messages').getDocuments();
  //   for(var message in messages.documents){
  //     print(message.data);
  //   }
  // }
  void getUsers() async{
       final messages=await _firestore.collection('users').getDocuments();

       for(var message in messages.documents) {
         print(message.data);
         var chatuser = User.fromJson(message.data);

         if (chatuser.username != username) {
           setState(() {
             chatname = chatuser.username[0].toUpperCase() +
                 chatuser.username.substring(1);
             status = chatuser.online;
           });
         }
       }
     }

  // void messageStream() async {
  //   await for (var snapshot in _firestore.collection('messages').snapshots()) {
  //     snapshot.documents;
  //   }
  // }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.deepPurple),
          elevation: 0,
          backgroundColor: Colors.white10,
          // leading: Padding(
          //   padding: const EdgeInsets.all(12.0),
          //   child: CircleAvatar(backgroundImage: NetworkImage('https://cdn.clipart.email/93ce84c4f719bd9a234fb92ab331bec4_frisco-specialty-clinic-vail-health_480-480.png'),),
          // ),
          title: Row(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    chatname,
                    style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        color: Colors.deepPurple),
                  ),
                    Text(status? 'online':'offline',style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 10,
                        color: Colors.deepPurple),
                    ),
                ],
              ),
            ],
          ),
          actions: <Widget>[
            GestureDetector(
              child: Icon(Icons.more_vert),
            )
          ],
        ),
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.deepPurple[900],
                ),
                accountName: Text(username),
                accountEmail: Text(email),
                currentAccountPicture: CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://www.w3schools.com/howto/img_avatar.png"),
                ),
                onDetailsPressed: () {},
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text("Logout"),
                subtitle: Text("Sign out of this account"),
                onTap: () async {
                  await setUseroffline();
                  await _auth.signOut();
                  Navigator.pushReplacementNamed(context, '/');
                },
              ),
            ],
          ),
        ),
        body: GestureDetector(
          onDoubleTap: visibility_toggle,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ChatStream(),
              Container(
                padding: EdgeInsets.symmetric(vertical:10,horizontal: 10),
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: Material(
                        borderRadius: BorderRadius.circular(50),
                        color: Colors.white,
                        elevation:5,
                        child: Padding(
                          padding: const EdgeInsets.only(left:8.0,top:2,bottom: 2),
                          child: TextField(
                            onChanged: (value) {
                              messageText = value;
                            },
                            controller: chatMsgTextController,
                            decoration: kMessageTextFieldDecoration,
                          ),
                        ),
                      ),
                    ),
                    MaterialButton(
                      shape: CircleBorder(),
                      color: Colors.blue,
                      onPressed: () {
                        if(messageText == null){
                          chatMsgTextController.clear();
                          messageText = null;
                          {
                            EdgeAlert.show(context,
                                title: 'Uh oh!',
                                description:
                                'Please enter text to continue.',
                                gravity: EdgeAlert.TOP,
                                icon: Icons.warning,
                                backgroundColor: Colors.deepPurple[900]);
                          }
                        }
                        else{
                        chatMsgTextController.clear();
                        _firestore.collection('messages').add({
                          'sender': username,
                          'text': messageText,
                          'timestamp':DateTime.now().millisecondsSinceEpoch,
                          'senderemail': email
                        });
                        messageText = null;}
                      },
                      child:Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Icon(Icons.send,color: Colors.white,),
                      )
                      // Text(
                      //   'Send',
                      //   style: kSendButtonTextStyle,
                      // ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ChatStream extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _firestore.collection('messages').orderBy('timestamp').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final messages = snapshot.data.documents.reversed;
          List<MessageBubble> messageWidgets = [];
          for (var message in messages) {
            final msgText = message.data['text'];
            final msgSender = message.data['sender'];
            // final msgSenderEmail = message.data['senderemail'];
            final currentUser = loggedInUser.displayName;

            // print('MSG'+msgSender + '  CURR'+currentUser);
            final msgBubble = MessageBubble(
                msgText: msgText,
                msgSender: msgSender,
                user: currentUser == msgSender);
            messageWidgets.add(msgBubble);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
              children: messageWidgets,
            ),
          );
        } else {
          return Center(
            child:
                CircularProgressIndicator(backgroundColor: Colors.deepPurple),
          );
        }
      },
    );
  }
}

class MessageBubble extends StatelessWidget {
  final String msgText;
  final String msgSender;
  final bool user;
  MessageBubble({this.msgText, this.msgSender, this.user});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: ()=>{
        },
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Column(
          crossAxisAlignment:
              user ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Visibility(
                visible: visibility,
                child: Text(
                  msgSender,
                  style: TextStyle(
                      fontSize: 10, fontFamily: 'Poppins', color: Colors.black87),
                ),
              ),
            ),
            Material(
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                topLeft: user ? Radius.circular(50) : Radius.circular(0),
                bottomRight: Radius.circular(50),
                topRight: user ? Radius.circular(0) : Radius.circular(50),
              ),
              color: user ? Colors.blue : Colors.white,
              elevation: 5,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Text(
                  msgText,
                  style: TextStyle(
                    color: user ? Colors.white : Colors.blue,
                    fontFamily: 'Poppins',
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


}
