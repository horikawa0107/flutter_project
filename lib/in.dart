import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'chat.dart';
class InPage extends StatefulWidget{
  final String myname;
  const InPage(this.myname, {Key? key})
      : super(key: key);
  @override
  _InPageState createState() => new _InPageState();
}
class _InPageState extends State<InPage> {
  String _RoomName = '';
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
            backgroundColor:  Color(0xFF93c9ff),
            title : Text("入室",style: TextStyle(
              fontSize: 25,
              color: Colors.white,
            ),)
        ),
        body: Center(
          child:Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              SizedBox(
                width: 300,
                height: 100,
                child:TextFormField(
                  style: TextStyle(
                    fontSize: 35,
                  ),
                  onChanged: (String value) {
                    setState(() {
                      _RoomName= value;
                    });
                  },
                  decoration: InputDecoration(
                    labelText: '部屋名',
                    labelStyle: TextStyle(
                      fontSize: 35,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(200, 100),
                  backgroundColor: Color(0xFF93c9ff),
                ),
                onPressed: () async {
                  // データベースにデータを検索
                  DocumentSnapshot DocSnapshot = await FirebaseFirestore.instance
                      .collection(_RoomName)
                      .doc("members")
                      .get();
                  var data = DocSnapshot.data() as Map<String, dynamic>?;
                  if (DocSnapshot.exists) {
                    if (data != null && data.containsKey(widget.myname)) {
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) =>
                            ChatPage(_RoomName, widget.myname,0)));
                      }
                      else{
                        FirebaseFirestore.instance.collection(_RoomName).doc(
                            "members").update({
                          widget.myname: 1
                        });
                        Navigator.push(
                            context, MaterialPageRoute(builder: (context) =>
                            ChatPage(_RoomName, widget.myname,1)));
                      }
                    } else {
                    //部屋がなかった時の処理
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("エラー"),
                          content: Text("部屋が存在しません。"),
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
                child: Text("入室", style: TextStyle(
                  color: Colors.white,
                  fontSize: 35,
                ),
                ),
              )
            ],
          ),
        )
    );
  }
}
