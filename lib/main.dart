import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'dart:math' as math;
// void callbackDispatcher() {
//   Workmanager().executeTask((task, inputData) async {
//     await Firebase.initializeApp();
//     var db = FirebaseFirestore.instance;
//     await db.collection("ChatApp").add({
//       "username": "you",
//       "sent_text": "message",
//       "time": DateTime.now()
//     });
//     return Future.value(true);
//   });
// }


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Workmanager().initialize(callbackDispatcher);
  // Workmanager().registerPeriodicTask(
  //   "1",
  //   "simplePeriodicTask",
  //   frequency: Duration(days: 1),
  // );
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Chat App',
      theme: new ThemeData(
          primaryColor: Colors.red
      ),
      home: new UserPage(),
    );
  }
}

class UserPage extends StatefulWidget {

  @override
  _UserPageState createState() => new _UserPageState();
}

class _UserPageState extends State<UserPage> {

  final _controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("User Name Input Screen"),
          backgroundColor: Colors.red
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: EdgeInsets.all(12.0),
            child: TextFormField(
              controller: _controller,
              decoration: InputDecoration(
                  labelText: 'User Name'
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (builder) => ChatPage(_controller.text)));
            },
            child: Text("Setup complete", style: TextStyle(color: Colors.white),),
          )
        ],
      ),
    );
  }
}


class ChatPage extends StatefulWidget {
  ChatPage(this._userName);

  final String _userName;

  @override
  _ChatPageState createState() => new _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  Timer? _timer;
  var random = math.Random();
  var db = FirebaseFirestore.instance;
  final list=["今日の一言","今日の気分は？"];
  var now = DateTime.now();

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // 1分ごとにデータを送信するタイマーを設定
    _timer = Timer.periodic(Duration(minutes: 60), (timer) {
      sendDataToFirebase();
    });
  }
  Future<void> sendDataToFirebase() async {
      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('ChatApp')
            .where('day', isEqualTo: "${now.year}/${now.month}/${now.day}")
            .get();
        if (querySnapshot.docs.isEmpty) {
          await FirebaseFirestore.instance.collection('ChatApp').add({
            "username": "bot",
            "sent_text": list[random.nextInt(list.length)],
            "day": "${now.year}/${now.month}/${now.day}",
            "time": DateTime.now()
          });
          print('Data sent to Firebase');
        }
        else{
          print("document is already here");
        }
      } catch (e) {
        print('Error sending data to Firebase: $e');
      }

  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
            title: new Text("chat page"),
            backgroundColor: Colors.red
        ),
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Column(
            children: <Widget>[
              Container(

              ),
              Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("ChatApp")
                      .orderBy("time", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return Container();
                    return new ListView.builder(
                      padding: new EdgeInsets.all(8.0),
                      reverse: true,
                      itemBuilder: (_, int index) {
                        DocumentSnapshot document =
                        snapshot.data!.docs[index];

                        bool isSelfText = false;
                        if (document['username'] == widget._userName) {
                          isSelfText = true;
                        }
                        return isSelfText
                            ? _SelfText(
                            document['sent_text'], document['username'])
                            : _OtherText(
                            document['sent_text'], document['username']);

                      },
                      itemCount: snapshot.data!.docs.length,
                    );
                  },
                ),
              ),
              new Divider(height: 1.0),
              Container(
                margin: EdgeInsets.only(bottom: 20.0, right: 10.0, left: 10.0),
                child: Row(
                  children: <Widget>[
                    new Flexible(
                      child: new TextField(
                        controller: _controller,
                        onSubmitted: _handleSubmit,
                        decoration:
                        new InputDecoration.collapsed(hintText: "send text"),
                      ),
                    ),
                    new Container(
                      child: new IconButton(
                          icon: new Icon(
                            Icons.chat,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            _handleSubmit(_controller.text);
                          }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  Widget _SelfText(String message, String userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 12.0,),
            Text(userName, style: TextStyle(color: Colors.red)),
            Text(message),
          ],
        ),
        Icon(Icons.person, color:Colors.red),
      ],
    );
  }

  Widget _OtherText(String message, String userName) {
    return Row(
      children: <Widget>[
        Icon(Icons.person_outline),
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(height: 12.0,),
            Text(userName),
            Text(message),
          ],
        )
      ],
    );
  }

  _handleSubmit(String message) {
    _controller.text = "";
    var db = FirebaseFirestore.instance;
    db.collection("ChatApp").add({
      "username": widget._userName,
      "sent_text": message,
      "day":"${now.year}/${now.month}/${now.day}",
      "time": DateTime.now()
    }).then((val) {
      print("Success");
    }).catchError((err) {
      print(err);
    });
  }
}
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp();
//   Workmanager().initialize(callbackDispatcher);
//   Workmanager().registerPeriodicTask(
//     "1",
//     "simplePeriodicTask",
//     frequency: Duration(days: 1),
//   );
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: Scaffold(
//         appBar: AppBar(
//           title: Text('Daily Firebase Sender'),
//         ),
//         body: Center(
//           child: Text('Flutter Firebase Scheduler'),
//         ),
//       ),
//     );
//   }
// }