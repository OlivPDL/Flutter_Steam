import 'main.dart';
import 'login.dart';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'research.dart';
import 'details.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints.expand(),
      height: MediaQuery.of(context).size.height,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/ImageBackground.png"),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          /*
          title: Text('Sign Up', style: TextStyle(
            color: Colors.white,
          ),
          )*/
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: EdgeInsets.all(30.10),
              child: Form(
                key: _formKey,
                child: SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 30),
                          child: Text(
                            'Inscription',
                            style: TextStyle(
                                fontFamily: 'GoogleSans',
                                fontSize: 30.58,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ), //GoogleFonts.getFont('Google Sans', fontSize: 30,)
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            "Veuillez saisir ces différentes informations \n afin que vos listes soient sauvegardées.",
                            style: TextStyle(
                                fontFamily: 'GoogleSans',
                                fontSize: 15.27,
                                color: Colors.white,
                                fontWeight: FontWeight.w700),
                          ), //GoogleFonts.getFont('Google Sans', fontSize: 30,)
                        ),
                      ),
                      SizedBox(height: 45.0),
                      Center(
                        child: Container(
                          width: 328.22,
                          height: 46.89,
                          decoration: BoxDecoration(
                            color: Color(0xFF1E262C),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextFormField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            controller: _usernameController,
                            keyboardType: TextInputType.text,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your username';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: "Nom d'utilisateur",
                              border: OutlineInputBorder(),
                              hintStyle: TextStyle(
                                color: Colors.white, // changez la couleur ici
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Center(
                        child: Container(
                          width: 328.22,
                          height: 46.89,
                          decoration: BoxDecoration(
                            color: Color(0xFF1E262C),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextFormField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'E-mail',
                              border: OutlineInputBorder(),
                              hintStyle: TextStyle(
                                color: Colors.white, // changez la couleur ici
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 15.0),
                      Center(
                        child: Container(
                          width: 328.22,
                          height: 46.89,
                          decoration: BoxDecoration(
                            color: Color(0xFF1E262C),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: TextFormField(
                            style: TextStyle(
                              color: Colors.white,
                            ),
                            controller: _passwordController,
                            obscureText: false,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Mot de passe',
                              border: OutlineInputBorder(),
                              hintStyle: TextStyle(
                                color: Colors.white, // changez la couleur ici
                              ),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 100),
                      Center(
                        child: Container(
                          width: 328.22,
                          height: 46.89,
                          decoration: BoxDecoration(
                            //color: Color(0xFF636AF6),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                try {
                                  UserCredential userCredential =
                                      await FirebaseAuth.instance
                                          .createUserWithEmailAndPassword(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  );
                                  await FirebaseFirestore.instance
                                      .collection('users')
                                      .doc(userCredential.user!.uid)
                                      .set({
                                    'username': _usernameController.text,
                                    'email': _emailController.text,
                                    'Likelist': [],
                                    'Whishlist': [],
                                  });
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TopGamesScreen()),
                                  );
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'weak-password') {
                                    print(
                                      'The password provided is too weak.',
                                    );
                                  } else if (e.code == 'email-already-in-use') {
                                    print(
                                        'The account already exists for that email.');
                                  }
                                } catch (e) {
                                  print(e);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Color(0xFF636AF6),
                            ),
                            child: Text(
                              "S'inscrire",
                              style: TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
