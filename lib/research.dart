import 'details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class SteamGame {
  final int appId;
  final String name;
  final String publisher;
  String description;
  final List<SteamGameReview> reviews;

  SteamGame({
    required this.appId,
    required this.name,
    required this.publisher,
    required this.description,
    required this.reviews,
  });

  factory SteamGame.fromJson(Map<String, dynamic> json) {
    final appId = json['appid'];
    final name = json['name'];
    final publisher = json['publisher'];
    return SteamGame(
      appId: appId,
      name: name,
      publisher: publisher,
      description: '',
      reviews: [],
    );
  }
}

class SteamGameDetails {
  final String description;

  SteamGameDetails({
    required this.description,
  });

  factory SteamGameDetails.fromJson(Map<String, dynamic> json) {
    if (json['data'] != null) {
      final data = json['data'];
      return SteamGameDetails(
        description: data['detailed_description'],
      );
    } else {
      return SteamGameDetails(
        description: "No description for this game",
      );
    }
  }
}

class SteamGameReview {
  final String review;

  SteamGameReview({required this.review});

  factory SteamGameReview.fromJson(Map<String, dynamic> json) {
    if (json['review'] != null) {
      return SteamGameReview(
        review: json['review'] as String,
      );
    } else {
      return SteamGameReview(
        review: "No review on this game",
      );
    }
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  // Variables
  late TextEditingController _searchController = TextEditingController();

  // late List<SteamGame> _games = [];
  String _searchText = "";

  //late Map<int, String> _gameDescriptions = {};

  // Appel de l'API Steam
  Future<List<SteamGame>> _fetchGames() async {
    final response =
        await http.get(Uri.parse('https://steamspy.com/api.php?request=all'));
    if (response.statusCode == 200) {
      final Map<String, dynamic> gamesJson = json.decode(response.body);
      List<dynamic> gamesList = gamesJson.values.toList();
      List<SteamGame> jeux = [];
      for (int i = 0; i < 150; i++) {
        final steamGame = SteamGame.fromJson(gamesList[i]);
        final appDetailsResponse = await http.get(Uri.parse(
            'https://store.steampowered.com/api/appdetails?appids=${steamGame.appId}&cc=fr&l=fr'));
        if (appDetailsResponse.statusCode == 200) {
          final detailRes = jsonDecode(appDetailsResponse.body);
          final details =
              SteamGameDetails.fromJson(detailRes[steamGame.appId.toString()]);

          final reviewsResponse = await http.get(Uri.parse(
              'https://store.steampowered.com/appreviews/${steamGame.appId}?json=1'));
          if (reviewsResponse.statusCode == 200) {
            final Map<String, dynamic> resRev =
                jsonDecode(reviewsResponse.body);

            // List<dynamic> reviews = (resRev['query_summary'] as Map)['reviews'];
            List<dynamic> reviews = resRev['reviews'];

            List<SteamGameReview> avis = [];
            for (int j = 0; j < reviews.length; j++) {
              final rev = SteamGameReview.fromJson(reviews[j]);

              if (SteamGameReview(review: rev.review) != null) {
                avis.add(SteamGameReview(review: rev.review));
              }
            }
            if (reviews.length == 0) {
              avis.add(SteamGameReview(review: "No review for this game"));
            }
            jeux.add(SteamGame(
              appId: steamGame.appId,
              name: steamGame.name,
              publisher: steamGame.publisher,
              description: details.description,
              reviews: avis,
            ));
          } else {
            throw Exception(
                'Failed to load game details for ${steamGame.appId}');
          }
        }
      }
      return jeux;
    } else {
      throw Exception('Failed to load games');
    }
  }

  @override
  void initState() {
    super.initState();
    // _games = [];
    _searchController = TextEditingController();
    /* _fetchGames().then((games) {
      setState(() {
        _games = games;
      });
    });*/

    // Ajout d'un listener sur le champ de recherche

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    // Suppression du listener
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF1A2025),
        title: Text('Recherche'),
        leading: IconButton(
          icon: Icon(Icons.close_rounded),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
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
        children: <Widget>[
          // Champ de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(
                color: Colors.white,
                backgroundColor: Color(0xFF1E262C),
              ),
              decoration: InputDecoration(
                hintText: "Rechercher...",
                hintStyle: TextStyle(color: Colors.white70),
              ), //onChanged: _onSearchTextChanged,
            ),
          ),
          // Liste avec filtrage
          Expanded(
            child: FutureBuilder<List<SteamGame>>(
              future: _fetchGames(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<SteamGame> games = snapshot.data!;
                  return ListView.builder(
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      if (_searchText.isNotEmpty &&
                          !games[index]
                              .name
                              .toLowerCase()
                              .contains(_searchText.toLowerCase())) {
                        return Container();
                      }
                      SteamGame game = games[index];
                      return Container(
                        color: Color.fromRGBO(30, 38, 44, 0.9),
                        padding: EdgeInsets.all(10),
                        child: ListTile(
                          tileColor: Color.fromRGBO(30, 38, 44, 0.9),
                          leading: Image(
                              width: 60,
                              height: 60,
                              image: NetworkImage(
                                  'https://cdn.akamai.steamstatic.com/steam/apps/${game.appId}/header.jpg')),
                          title: Text(
                            game.name,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            game.publisher,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SteamGameDetail(
                                    game: game,
                                  ),
                                ),
                              );
                            },
                            child: Text('En savoir plus'),
                          ),
                        ),
                      );
                    },
                  );
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Failed to load games: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
