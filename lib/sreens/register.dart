import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../model/user_model.dart';
import 'home.dart';
import 'login.dart';


class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _auth=FirebaseAuth.instance;
  final _formkey=GlobalKey<FormState>();
  final TextEditingController firstname=new TextEditingController();
  final TextEditingController lastname=new TextEditingController();
  final TextEditingController email=new TextEditingController();
  final TextEditingController password=new TextEditingController();
  final TextEditingController passwordConfirme=new TextEditingController();

  @override
  Widget build(BuildContext context) {
    final firstnamefield=TextFormField(
      autofocus: false,
      controller: firstname,
      keyboardType: TextInputType.name,
      validator: (value){
        RegExp regExp=new RegExp(r'^.{3,}$');
        if(value!.isEmpty){
          return ('First Name cannot by empty');
        }
        if(!regExp.hasMatch(value)){
          return ('Enter name valid (Min. 3 Character)');
        }
        return null;
      },
      onSaved: (value){
        firstname.text=value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: "Firstname",
          border:OutlineInputBorder(
              borderRadius: BorderRadius.circular(20)
          )
      ),
    );

    final lastnamefield=TextFormField(
      autofocus: false,
      controller: lastname,
      keyboardType: TextInputType.name,
      validator: (value){
        if(value!.isEmpty){
          return ('Last Name cannot by empty');
        }
        return null;
      },
      onSaved: (value){
        lastname.text=value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: "Lastname",
          border:OutlineInputBorder(
              borderRadius: BorderRadius.circular(20)
          )
      ),
    );

    final emailfield=TextFormField(
      autofocus: false,
      controller: email,
      keyboardType: TextInputType.emailAddress,
      validator: (value){
        if(value!.isEmpty){
          return ("Please enter your email");
        }
        if(!RegExp("^[a-zA-Z0-9+_,-]+@[a-zA-Z0-9.-]+.[a-z]").hasMatch(value)){
          return ("Please enter a valid");
        }
        return null;
      },
      onSaved: (value){
        email.text=value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: "Email",
          border:OutlineInputBorder(
              borderRadius: BorderRadius.circular(20)
          )
      ),
    );

    final passwordfield=TextFormField(
      autofocus: false,
      controller: password,
      obscureText: true,
      validator: (value){
        RegExp regExp=new RegExp(r'^.{8,}$');
        if(value!.isEmpty){
          return ('Please enter your password');
        }
        if(!regExp.hasMatch(value)){
          return (' Enter password valid');
        }
      },
      onSaved: (value){
        password.text=value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          hintText: "Password",
          border:OutlineInputBorder(
              borderRadius: BorderRadius.circular(20)
          )
      ),
    );

    final confirpassworfield=TextFormField(
      autofocus: false,
      controller: passwordConfirme,
      obscureText: true,
      validator: (value){
        if(passwordConfirme.text!=password.text){
          return ('Password don\'t match');
        }
        return null;
      },
      onSaved: (value){
        passwordConfirme.text=value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
          hintText: "Confirme Password",
          border:OutlineInputBorder(
              borderRadius: BorderRadius.circular(20)
          )
      ),
    );

    final RegisterButton=Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.redAccent,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(28, 15, 28, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: (){
          SignUp(email.text, password.text);
        },
        child: Text("Register",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,

          ),
        ),
      ),
    );
    return Scaffold(
      // backgroundColor: Colors.red,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.red,),
          onPressed: (){
            Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context)=>Login()), (route) => false);
          },
        ),
      ),
      body: Center(
        child:SingleChildScrollView(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formkey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                        height: 200,
                        child:Image.asset(
                          "assets/now.jpg",
                          fit: BoxFit.contain,
                        )
                    ),
                    SizedBox(height: 10,),
                    firstnamefield,
                    SizedBox(height: 10,),
                    lastnamefield,
                    SizedBox(height: 10,),
                    emailfield,
                    SizedBox(height: 10,),
                    passwordfield,
                    SizedBox(height: 10,),
                    confirpassworfield,
                    SizedBox(height: 10,),
                    RegisterButton,
                    SizedBox(height: 10,),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void SignUp(String email, String password) async{
    if(_formkey.currentState!.validate()){
        await _auth.createUserWithEmailAndPassword(email: email, password: password)
            .then((value) => {
              postDetailsToFirestore()
            }).catchError((e){
              Fluttertoast.showToast(msg: e!.message);
        });
    }
  }

  void postDetailsToFirestore() async{
    //callling our firestore
    //calling our user modelmap
    //sedning these values
    FirebaseFirestore firestore=FirebaseFirestore.instance;
    User? user=_auth.currentUser;
    UserModel model=UserModel();

    //writing all the values
    model.email=user!.email;
    model.uid=user.uid;
    model.firstname=firstname.text;
    model.lastname=lastname.text;

    await firestore.collection("users").doc(user.uid).set(model.toMap());
    Fluttertoast.showToast(msg: "Account created successfully ");
    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => Home()), (route) => false);
  }
}
