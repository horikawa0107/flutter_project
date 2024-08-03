import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatPage extends StatefulWidget {
  final String _myname;
  final String _RoomName;
  final int _mynum;


  const ChatPage(this._RoomName,this._myname,this._mynum, {Key? key})
      : super(key: key);


  @override
  _ChatPageState createState() => new _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  bool isCon=true;
  int _num=0;




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
                margin: EdgeInsets.only(top: 20.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200, 100),
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () async{
                    if (isCon==false) {
                      await deleteAllDocuments(
                          widget._RoomName, widget._RoomName);
                      Navigator.of(context).pop();
                    }
                    else{
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text("エラー"),
                            content: Text("しりとりは終わってません。"),
                            actions: <Widget>[
                              TextButton(
                                child: Text("OK"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('終了',style: TextStyle(color: Colors.white,fontSize: 35),),
                ),
              ),
              Expanded(
                flex: 1,
                // StreamBuilder
                // 非同期処理の結果を元にWidgetを作れる
                child: StreamBuilder<DocumentSnapshot>(
                  // 投稿メッセージ一覧を取得（非同期処理）
                  // 投稿日時でソート
                  stream: FirebaseFirestore.instance
                      .collection(widget._RoomName)
                      .doc("isTurn")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData  && !snapshot.data!.exists) {
                      return Text('No Data Found');
                    } else {
                      var data = snapshot.data!.data() as Map<String, dynamic>;
                      bool text = data['isCon'] ?? 'No text available';
                      isCon=data['isCon'];
                      _num=data['_num'];
                      return Text(
                        text
                            ? (_num==widget._mynum ?"おなたの番です。" : "相手の番です。")
                            : "stop",
                        style: TextStyle(fontSize: 24),
                      );
                    }
                  },
                ),
              ),
              Flexible(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection(widget._RoomName)
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
                        if (document['username'] == widget._myname) {
                          isSelfText = true;
                        }
                        return isSelfText
                            ? _SelfText(document['sent_text'], document['username'])
                            : _OtherText(document['sent_text'], document['username']);
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
                        onSubmitted: (value){
                          if (isCon==true && _num==widget._mynum) {
                            String messeage = _controller.text;
                            _judg(messeage, widget._RoomName,widget._mynum);
                            _handleSubmit(_controller.text, widget._RoomName);
                          }
                          else{
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("エラー"),
                                  content: Text("入力できません。"),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text("OK"),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );

                          }

                        },
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
                            if (isCon==true && _num==widget._mynum) {
                              String messeage = _controller.text;
                              _judg(messeage, widget._RoomName,widget._mynum);
                              _handleSubmit(_controller.text, widget._RoomName);
                            }
                            else{
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text("エラー"),
                                    content: Text("入力できません"),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text("OK"),
                                        onPressed: () {
                                          if(isCon==true) {
                                            Navigator.of(context).pop();
                                          }
                                          else{

                                          }
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            }
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

  Widget _RedLine() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          width: 350,
          height: 10,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(16.0),
          ),
        ),
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



  _handleSubmit(String message,String _RoomName) async{
    DateTime now = DateTime.now();
    _controller.text = "";
    var db = FirebaseFirestore.instance;
    db.collection(_RoomName).add({
      "username": widget._myname,
      "sent_text": message,
      "time": now.toUtc()
    }).then((val) {
      print("Success");
    }).catchError((err) {
      print(err);
    });
  }
}



Future<void> deleteAllDocuments(String collectionPath,String _RoomName) async {
  // Firebaseの初期化

  // コレクションを取得
  CollectionReference collection = FirebaseFirestore.instance.collection(collectionPath);

  // コレクション内のすべてのドキュメントを取得
  QuerySnapshot snapshot = await collection.get();

  // 各ドキュメントを削除
  for (QueryDocumentSnapshot document in snapshot.docs) {
    await document.reference.delete();
  }
  await FirebaseFirestore.instance.collection(_RoomName).doc("isTurn").set({"_num":0,"isCon":true});



}





_stopSubmit() async{
  var db = FirebaseFirestore.instance;
  db.collection("ChatApp").add({
    "username": "host",
    "sent_text": "stop",
    "time": DateTime.now()
  }).then((val) {
    print("Success");
  }).catchError((err) {
    print(err);
  });
}
_change_num(String _RoomName,int _mynum)async{
  if (_mynum==1) {
    FirebaseFirestore.instance.collection(_RoomName).doc("isTurn").set({
      'isCon': true, "_num": 0
    });
  }
  else{
    FirebaseFirestore.instance.collection(_RoomName).doc("isTurn").set({
      'isCon': true, "_num": 1
    });
  }
}

_stop(String _RoomName) async{
  print("stop");
  FirebaseFirestore.instance.collection(_RoomName).doc("isTurn").set({
    'isCon' : false,"_num": 3
  });

}

_judg(String message,String _RoomName,int _mynum) async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(_RoomName)
        .orderBy("time", descending: true)
        .get();
    if (querySnapshot.docs.isNotEmpty) {
      print(querySnapshot.docs.length);
      if (querySnapshot.docs.length > 2) {
        QueryDocumentSnapshot firstDocument = querySnapshot.docs[1];
        print('Success');
        if (firstDocument["sent_text"][firstDocument["sent_text"].length - 1] ==
            message[0]) {
          print("hello");
          print(firstDocument["sent_text"][firstDocument["sent_text"].length - 1]);
          print(message[0]);
          _change_num(_RoomName,_mynum);
          print("countinu");
        }
        else {
          print("stop");
          _stop(_RoomName);
        }
      }
      else {
        _change_num(_RoomName,_mynum);
      }
    }
    else {
      _change_num(_RoomName,_mynum);
      print("first messeage");

    }
  } catch (e) {
    print(e);

  }
}
