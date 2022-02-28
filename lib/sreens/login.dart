import 'package:auth_myah/sreens/register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:local_auth/local_auth.dart';
import 'home.dart';


class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final _formkey=GlobalKey<FormState>();
  final TextEditingController email=new TextEditingController();
  final TextEditingController password=new TextEditingController();

  final _auth=FirebaseAuth.instance;
  final LocalAuthentication auth=LocalAuthentication();
  bool? _canCheckBiometrics;
  List<BiometricType>? _availableBiometrics;
  String _authorized = 'Not Authorized';


  Future<void> _checkBiometrics() async {
    late bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      canCheckBiometrics = false;
      print(e);
    }
    if (!mounted) {return;}
    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    late List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      availableBiometrics = <BiometricType>[];
      print(e);
    }
    if (!mounted) {return;}
    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }
  Future<void> _authenticate() async {
     bool authenticated = false;
     try{
        authenticated=await auth.authenticate(
          localizedReason: "Scan your finger to authenticate",
          useErrorDialogs: true,
          stickyAuth: true,
        );
     }on PlatformException catch(e){
       print(e);
       Fluttertoast.showToast(msg: '${e.message}');
     }
     if(!mounted){return;}
     setState(() {
       _authorized=authenticated ? "Authorized success" :"Faild to Authenticate";
       if(authenticated){
         Navigator.push(context, MaterialPageRoute(builder: (context)=>Home()));
       }
       Fluttertoast.showToast(msg: _authorized);
       print(_authorized);

     });

  }
  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _getAvailableBiometrics();

  }
  @override
  Widget build(BuildContext context) {

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
          return ('Please enter the valide password');
        }
      },
      onSaved: (value){
        password.text=value!;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        hintText: "Password",
        
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20)
        )
      ),
    );

    final loginButton=Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.redAccent,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(28, 15, 28, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: (){
          signIn(email.text, password.text);
        },
        child: Text("login",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,

          ),
        ),
      ),
    );

    final auth_empreint=Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.redAccent,
      child: MaterialButton(
        padding: EdgeInsets.fromLTRB(28, 15, 28, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: (){
          _authenticate();
        },
        child: Text("Empreint Auth",
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
        title: Text("Login",
          style: TextStyle(
        ),
        ),
        centerTitle: true,
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
                     ),
                   ),
                   Text("Fingerprint",style: TextStyle(
                     fontSize: 20,
                     fontWeight: FontWeight.bold,
                     fontStyle: FontStyle.italic,
                   ),),
                   SizedBox(height: 10,),
                   emailfield,
                   SizedBox(height: 10,),
                   passwordfield,
                   SizedBox(height: 10,),
                   loginButton,
                   SizedBox(height: 10,),
                   Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       Text("Don't have any account? "),
                       GestureDetector(
                         onTap: (){
                           Navigator.push(context, MaterialPageRoute(builder:(context)=>Register()));
                         },
                         child: Text("SignUp",
                         style: TextStyle(
                           color:Colors.redAccent,
                           fontWeight: FontWeight.bold,
                           fontSize: 15,
                         ),),
                       )
                     ],
                   ),
                   SizedBox(height: 10,),
                   auth_empreint,
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

  void signIn(String email, String password) async{
    if(_formkey.currentState!.validate()){
      await _auth
          .signInWithEmailAndPassword(email: email, password: password)
          .then((uid) =>{ Fluttertoast.showToast(msg: "login Successfully"),
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context)=>Home())),

      }).catchError((e){
        Fluttertoast.showToast(msg: e!.message);
      });

    }
  }
}
