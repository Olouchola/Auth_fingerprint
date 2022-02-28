import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../model/user_model.dart';
import 'login.dart';
class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _auth=FirebaseAuth.instance;
  User? user=FirebaseAuth.instance.currentUser;
  UserModel userModel=UserModel();

  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get().then((value){
        this.userModel=UserModel.fromMap(value.data());
        setState(() {});
        });

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Good morning"),
              SizedBox(height: 10,),
              Text("${userModel.firstname} ${userModel.lastname}",style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
              SizedBox(height: 10,),
              Text("${userModel.email}",style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),),
              SizedBox(height: 10,),
              ActionChip(label: Text("Logout"), onPressed:(){
                logout(context);
              }),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> logout(BuildContext context)async{
    await _auth.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>Login()));
  }
}
