import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';


class CreatePage extends StatefulWidget{
  final String myname;
  const CreatePage(this.myname, {Key? key})
      : super(key: key);
  @override
  _CreatePageState createState() => new _CreatePageState();
}
class _CreatePageState extends State<CreatePage> {
  // Future<void> _signInAnonymously() async {
  //   try {
  //     final userCredential = await FirebaseAuth.instance.signInAnonymously();
  //     print(
  //         "Signed in with temporary account. uid: ${userCredential.user!.uid}");
  //   } on FirebaseAuthException catch (e) {
  //     switch (e.code) {
  //       case "operation-not-allowed":
  //         print("Anonymous auth hasn't been enabled for this project.");
  //         break;
  //       default:
  //         print("Unknown error.");
  //     }
  //   }
  // }
  String _RoomName = '';
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor: Color(0xFF93c9ff),
            title : Text("作成",style: TextStyle(
              fontSize: 25,
              color: Colors.white,
            ),)
        ),
        body: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[

              SizedBox(
                width: 300,
                height: 100,
                child: TextFormField(
                  style: TextStyle(
                    fontSize:35,
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _RoomName= value;
                    });
                  },
                  decoration: InputDecoration(
                    fillColor:Colors.white,
                    filled: true,
                    contentPadding: EdgeInsets.all(30),
                    labelText: '部屋名',
                    labelStyle: TextStyle(
                      fontSize: 35,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),

              ElevatedButton(
                onPressed: () async {
                  // データベースにデータを追加
                  // _signInAnonymously();
                  Navigator.push(
                      context, MaterialPageRoute(builder: (context) => ChatPage(_RoomName,widget.myname,0)));
                  FirebaseFirestore firestore = FirebaseFirestore.instance;
                  final snapshot = await firestore.collection(_RoomName).doc("members").set({widget.myname: 0
                  });
                  await firestore.collection(_RoomName).doc("setting").set({"isTurn":0,"isCon":true}

                  );
                },
                child: Text("作成", style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                ),
                ),
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 100),
                  backgroundColor: Color(0xFF93c9ff),
                  // primary: Color(0xFF89A64B),
                  // onPrimary: Colors.white,
                ),
              )
            ],
          ),
        )
    );
  }
}
