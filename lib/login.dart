import 'main.dart';
import 'forgotpassword.dart';
import 'signup.dart';
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
import 'package:google_fonts/google_fonts.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/ImageBackground.png"),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: EdgeInsets.all(30.10),
            child: Form(
              key: _formKey,
              child: SizedBox(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 50),
                        child: Text(
                          'Bienvenue !',
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
                          'Veuillez vous connecter ou \n créer un nouveau compte \n pour utiliser l\’application.',
                          style: TextStyle(
                              fontFamily: 'GoogleSans',
                              fontSize: 15.27,
                              color: Colors.white,
                              fontWeight: FontWeight.w700),
                        ), //GoogleFonts.getFont('Google Sans', fontSize: 30,)
                      ),
                    ),
                    SizedBox(height: 30.0),
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
                    Container(
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
                        obscureText: true,
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
                    SizedBox(height: 80.0),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 328.22,
                            height: 46.89,
                            decoration: BoxDecoration(
                              //color: Color(0xFFFFFFFF),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  try {
                                    UserCredential userCredential =
                                        await FirebaseAuth.instance
                                            .signInWithEmailAndPassword(
                                      email: _emailController.text,
                                      password: _passwordController.text,
                                    );
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              TopGamesScreen()),
                                    );
                                  } on FirebaseAuthException catch (e) {
                                    if (e.code == 'user-not-found') {
                                      print('No user found for that email.');
                                    } else if (e.code == 'wrong-password') {
                                      print(
                                          'Wrong password provided for that user.');
                                    }
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                primary: Color(0xFF636AF6),
                              ),
                              child: Text(
                                'Se connecter',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    Container(
                      width: 328.22,
                      height: 46.89,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                            width: 1.0, color: const Color(0xFF636AF6)),
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      child: Center(
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SignUpPage()),
                            );
                          },
                          child: Text(
                            'Créer un nouveau compte',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 196.876),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ForgotPasswordPage()),
                          );
                        },
                        child: Text(
                          'Mot de passe oublié',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
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
    );
  }
}
