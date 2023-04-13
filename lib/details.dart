import 'main.dart';
import 'avis.dart';
import 'research.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameDetail extends StatefulWidget {
  final GameRank game;

  GameDetail({required this.game});

  @override
  _GameDetailState createState() => _GameDetailState();
}

class _GameDetailState extends State<GameDetail> {
  bool _isLiked = false;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    checkIfLiked();
    //checkIfWhish();
  }

  Future<void> checkIfLiked() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('Likelist')) {
          setState(() {
            _isLiked = data['Likelist'].contains(widget.game.appId);
          });
        }
      }
    }
  }
/*
  Future<void> checkIfWhish() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('Whishlist')) {
          setState(() {
            _isWhished = data['Whishlist'].contains(widget.game.appId);
          });
        }
      }
    }
  }*/

  Future<void> toggleLiked() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      List<dynamic> likelist = documentSnapshot.get('Likelist');
      if (_isLiked) {
        likelist.remove(widget.game.appId);
      } else {
        likelist.add(widget.game.appId);
      }
      await documentReference.set({'Likelist': likelist});
      setState(() {
        _isLiked = !_isLiked;
      });
    }
  }
/*
  Future<void> toggleWhish() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      List<dynamic> whishlist = documentSnapshot.get('Whishlist');
      if (whishlist == null) {
        whishlist = []; // initialise la liste vide si elle n'existe pas
      }
      if (_isWhished) {
        whishlist.remove(widget.game.appId);
      } else {
        whishlist.add(widget.game.appId);
      }
      await documentReference.set({'Whishlist': whishlist});
      setState(() {
        _isWhished = !_isWhished;
      });
    }
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A2025),
        title: Text('Détail du jeu'),
        actions: [
          IconButton(
            onPressed: toggleLiked,
            icon: _isLiked
                ? SvgPicture.asset(
                    'assets/coeur_rempli.svg',
                    color: Colors.white,
                  )
                : SvgPicture.asset(
                    'assets/like_vide.svg',
                    color: Colors.white,
                  ),
          ),
          IconButton(
            icon: isPressed
                ? SvgPicture.asset('assets/etoile_rempli.svg')
                : SvgPicture.asset('assets/etoile_vide.svg'),
            onPressed: () {
              setState(() {
                isPressed =
                    !isPressed; // inverser l'état du bouton lorsqu'il est pressé
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } catch (e) {
                print('Error logging out: $e');
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://cdn.akamai.steamstatic.com/steam/apps/${widget.game.appId}/header.jpg',
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.4),
                ),
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  child: Text(
                    widget.game.name,
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 16.0,
                  child: Text(
                    widget.game.publisher,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
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
              border: Border.all(width: 1.0, color: const Color(0xFF636AF6)),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Avis(game: widget.game)),
                  );
                },
                child: Text(
                  'Voir les derniers avis du Jeu',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0;
                        i <= 2 && i < widget.game.reviews.length;
                        i++)
                      ListTile(
                        title: Text(
                          widget.game.description,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SteamGameDetail extends StatefulWidget {
  final SteamGame game;

  SteamGameDetail({required this.game});

  @override
  _SteamGameDetailState createState() => _SteamGameDetailState();
}

class _SteamGameDetailState extends State<SteamGameDetail> {
  bool _isLiked = false;
  bool isPressed = false;

  @override
  void initState() {
    super.initState();
    checkIfLiked();
    //checkIfWhish();
  }

  Future<void> checkIfLiked() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (documentSnapshot.exists) {
        Map<String, dynamic> data =
            documentSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('Likelist')) {
          setState(() {
            _isLiked = data['Likelist'].contains(widget.game.appId);
          });
        }
      }
    }
  }

  Future<void> toggleLiked() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference documentReference =
          FirebaseFirestore.instance.collection('users').doc(user.uid);
      DocumentSnapshot documentSnapshot = await documentReference.get();
      List<dynamic> likelist = documentSnapshot.get('Likelist');
      if (_isLiked) {
        likelist.remove(widget.game.appId);
      } else {
        likelist.add(widget.game.appId);
      }
      await documentReference.set({'Likelist': likelist});
      setState(() {
        _isLiked = !_isLiked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A2025),
        title: Text('Détail du jeu'),
        actions: [
          IconButton(
            onPressed: toggleLiked,
            icon: _isLiked
                ? SvgPicture.asset(
                    'assets/coeur_rempli.svg',
                    color: Colors.white,
                  )
                : SvgPicture.asset(
                    'assets/like_vide.svg',
                    color: Colors.white,
                  ),
          ),
          IconButton(
            icon: isPressed
                ? SvgPicture.asset('assets/etoile_rempli.svg')
                : SvgPicture.asset('assets/etoile_vide.svg'),
            onPressed: () {
              setState(() {
                isPressed =
                    !isPressed; // inverser l'état du bouton lorsqu'il est pressé
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              try {
                await FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              } catch (e) {
                print('Error logging out: $e');
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(
                  'https://cdn.akamai.steamstatic.com/steam/apps/${widget.game.appId}/header.jpg',
                  fit: BoxFit.cover,
                ),
                Container(
                  color: Colors.black.withOpacity(0.4),
                ),
                Positioned(
                  bottom: 16.0,
                  left: 16.0,
                  child: Text(
                    widget.game.name,
                    style: TextStyle(
                      fontSize: 28.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0.0,
                  left: 16.0,
                  child: Text(
                    widget.game.publisher,
                    style: TextStyle(
                      fontSize: 18.0,
                      color: Colors.white,
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
              border: Border.all(width: 1.0, color: const Color(0xFF636AF6)),
              borderRadius: BorderRadius.circular(5.0),
            ),
            child: Center(
              child: TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AvisSteam(game: widget.game)),
                  );
                },
                child: Text(
                  'Voir les derniers avis du Jeu',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        widget.game.description,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
