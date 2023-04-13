import 'main.dart';
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

class ForgotPasswordPage extends StatefulWidget {
  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

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
          title: Text('Forgot Password',
            style: TextStyle(
              color: Colors.white,
            ),
          ),*/
        ),
        body: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: Padding(
              padding: EdgeInsets.all(30.0),
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
                            'Mot de passe oublié',
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
                            "Veuillez saisir votre email \n afin de réinitialisé votre mot de passe.",
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
                      SizedBox(height: 150),
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
                                  await FirebaseAuth.instance
                                      .sendPasswordResetEmail(
                                    email: _emailController.text,
                                  );
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(
                                          'Password Reset',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        content: Text(
                                          'An email with instructions to reset your password has been sent to your email address.',
                                          style: TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } on FirebaseAuthException catch (e) {
                                  if (e.code == 'user-not-found') {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Error',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          content: Text(
                                            'No user found for that email.',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                'OK',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
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
                              'Renvoyer mon mot de passe',
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
