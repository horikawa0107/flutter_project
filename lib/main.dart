import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import  'create.dart';
import 'in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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


  _addNameToList(String name) async{
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('names')
          .orderBy("number",descending: true)
          .get();
      if (querySnapshot.docs.isNotEmpty  ) {
        int count=querySnapshot.docs.length;
        print(count);
        FirebaseFirestore.instance
            .collection('names')
            .add({'name': name,"number":count+1})
            .then((value) => print("Name Added"))
            .catchError((error) => print("Failed to add name: $error"));

      }
      else{
        FirebaseFirestore.instance
            .collection('names')
            .add({'name': name,"number":1})
            .then((value) => print("First Name Added"))
            .catchError((error) => print("Failed to first add name: $error"));
        print("first messeage");
      }
    }catch(e){
      print(e);
    }
  }

  final _controller = TextEditingController();
  String _myname="";
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          title: new Text("User Name Input Screen"),
          backgroundColor: Colors.red
      ),
        body:Center(
          child:Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                        _myname= value;
                      });
                    },
                    decoration: InputDecoration(
                      fillColor:Color(0xFFD9D9D9),
                      filled: true,
                      contentPadding: EdgeInsets.all(30),
                      labelText: '名前',
                      labelStyle: TextStyle(
                        fontSize: 35,
                      ),
                      border: OutlineInputBorder(),
                      // counterStyle: TextStyle(
                      //   fontSize: 50,
                      //   color: Color(0xFFD9D9D9),
                      // )
                    ),
                  ),
                ),
                ElevatedButton(
                  child: const Text('作成',
                    style: TextStyle(
                      fontSize: 35,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200, 100),
                    // primary: Color(0xFF89A64B),
                    // onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(
                        builder: (context) => CreatePage(_myname)
                    ));
                  },
                ),
                ElevatedButton(
                  child: const Text('入室',style: TextStyle(
                    fontSize: 35,
                  ),),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200, 100),
                    // primary: Color(0xFF89A64B),
                    // onPrimary: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (builder) => InPage(_myname)));
                    // _addNameToList(_controller.text);
                  },
                ),
              ]
          ),
        )

    );
  }
}


