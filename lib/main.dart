import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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



  final _controller = TextEditingController();
  String _myname="";
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.white,
        appBar: new AppBar(
            title: new Text("しりとりアプリ"),
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
                      fillColor:Colors.white,
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
                      color: Colors.white,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200, 100),
                    backgroundColor: Colors.red,
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
                    color: Colors.white,
                  ),),
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200, 100),
                    backgroundColor: Colors.red,
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




