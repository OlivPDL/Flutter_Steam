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
      constraints: const BoxConstraints.expand(),
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("assets/ImageBackground.png"),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Padding(
          padding: EdgeInsets.all(30.10),
          child: Form(
            key: _formKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 107),
                    child: Text('Bienvenue !',
                        style:TextStyle(
                          fontFamily: 'GoogleSans',
                          fontSize: 30.58,
                          color: Colors.white,
                          fontWeight: FontWeight.w700
                        ),
                          ),//GoogleFonts.getFont('Google Sans', fontSize: 30,)
                  ),
                ),
                Center(
                  
                  child: TextFormField(

                    style: TextStyle(
                      color: Colors.white,
                      backgroundColor: Color(0XFF1E262C),
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
                      labelText: 'E-mail',
                      labelStyle: TextStyle(
                        color: Colors.white, // changez la couleur ici
                      ),
                    ),
                  ),
                ),
                TextFormField(
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
                    labelText: 'Mot de passe',
                    labelStyle: TextStyle(
                      color: Colors.white, // changez la couleur ici
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            UserCredential userCredential = await FirebaseAuth
                                .instance
                                .signInWithEmailAndPassword(
                              email: _emailController.text,
                              password: _passwordController.text,
                            );
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TopGamesScreen()),
                            );
                          } on FirebaseAuthException catch (e) {
                            if (e.code == 'user-not-found') {
                              print('No user found for that email.');
                            } else if (e.code == 'wrong-password') {
                              print('Wrong password provided for that user.');
                            }
                          }
                        }
                      },
                      child: Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    TextButton(
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
                  ],
                ),
                SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
