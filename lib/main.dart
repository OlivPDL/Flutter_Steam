import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'login.dart';
import 'research.dart';
import 'details.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:cached_network_image/cached_network_image.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFF1A2025),
      ),
      home: LoginPage(),
    );
  }
}

class GameRank {
  final int rank;
  final int appId;
  final String name;
  final String description;
  final String publisher;
  final String reviews;

  GameRank({
    required this.rank,
    required this.appId,
    required this.name,
    required this.description,
    required this.publisher,
    required this.reviews,
  });

  factory GameRank.fromJson(Map<String, dynamic> json) {
    return GameRank(
      rank: json['rank'],
      appId: json['appid'],
      name: '',
      description: '',
      publisher: '',
      reviews: '',
    );
  }
}

class GameDetails {
  final String name;
  final String description;
  final List<String> publishers;

  GameDetails({
    required this.name,
    required this.description,
    required this.publishers,
  });

  factory GameDetails.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final List<dynamic> publisherList = data['publishers'];
    final List<String> publishers =
        publisherList.map((publisher) => publisher as String).toList();
    return GameDetails(
      name: data['name'],
      description: data['about_the_game'],
      publishers: publishers,
    );
  }
}

Future<List<GameRank>> fetchMostPlayedGames() async {
  final response = await http.get(Uri.parse(
      'https://api.steampowered.com/ISteamChartsService/GetMostPlayedGames/v1/?key=C0713D972156C4B7933C72F0A8100655&format=json&limit=5'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> res = jsonDecode(response.body);
    List<dynamic> ranks = (res['response'] as Map)['ranks'];
    List<GameRank> games = [];

    for (int i = 0; i < 20; i++) {
      final gameRank = GameRank.fromJson(ranks[i]);
      final detailsResponse = await http.get(Uri.parse(
          'https://store.steampowered.com/api/appdetails?appids=${gameRank.appId}&cc=fr&l=fr'));
      if (detailsResponse.statusCode == 200) {
        final detailsRes = jsonDecode(detailsResponse.body);
        final details =
            GameDetails.fromJson(detailsRes[gameRank.appId.toString()]);
        final List<dynamic> publishersJson =
            detailsRes[gameRank.appId.toString()]['data']['publishers'];
        final List<String> publishers =
            publishersJson.map((json) => json as String).toList();

        final reviewsResponse = await http.get(Uri.parse(
            'https://store.steampowered.com/appreviews/${gameRank.appId}?json=1&language=fr'));
        if (reviewsResponse.statusCode == 200) {
          final reviewsRes = jsonDecode(reviewsResponse.body);
          final List<dynamic> reviewsJson = reviewsRes['reviews'];
          final List<String> reviews =
              reviewsJson.map((json) => json['review'] as String).toList();

          games.add(GameRank(
            rank: gameRank.rank,
            appId: gameRank.appId,
            name: details.name,
            description: details.description,
            publisher: publishers.join(', '),
            reviews: reviews.join('\n'),
          ));
        } else {
          throw Exception('Failed to load reviews for game ${gameRank.appId}');
        }
      } else {
        throw Exception('Failed to load game details for ${gameRank.appId}');
      }
    }

    return games;
  } else {
    throw Exception('Failed to load top games');
  }
}

class TopGamesScreen extends StatefulWidget {
  @override
  _TopGamesScreenState createState() => _TopGamesScreenState();
}

class _TopGamesScreenState extends State<TopGamesScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Acceuil'),
        backgroundColor: Color(0xFF1A2025),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.settings),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF636AF6),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Rechercher un jeu...', textAlign: TextAlign.left),
                  Spacer(),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => MyWidget()),
                      );
                    },
                    icon: Icon(Icons.search),
                  ),
                ],
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyWidget()),
                );
              },
            ),
          ),
          Text(
            'Les meilleures ventes',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            textAlign: TextAlign.left,
          ),
          Expanded(
            child: FutureBuilder<List<GameRank>>(
              future: fetchMostPlayedGames(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<GameRank> games = snapshot.data!;
                  return ListView.builder(
                    itemCount: games.length,
                    itemBuilder: (context, index) {
                      GameRank game = games[index];
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
                                  builder: (context) => GameDetail(
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
