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
import 'package:flutter_svg/flutter_svg.dart';
//import 'package:cached_network_image/cached_network_image.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class EmptyLike extends StatelessWidget {
  const EmptyLike({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mes likes'),
        backgroundColor: Color(0xFF1A2025),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/coeur.svg',
              width: 100,
              height: 100,
              color: Colors.white,
            ),
            SizedBox(height: 35),
            Text(
              "Vous n’avez encore pas liké de contenu. \n \n Cliquez sur le coeur pour en rajouter.",
              style: TextStyle(
                fontFamily: 'ProximaNova',
                fontSize: 15.27,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyWhish extends StatelessWidget {
  const EmptyWhish({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ma liste de souhaits'),
        backgroundColor: Color(0xFF1A2025),
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/etoile.svg',
              width: 100,
              height: 100,
              color: Colors.white,
            ),
            SizedBox(height: 35),
            Text(
              "Vous n’avez encore pas ajouté de jeu souhaité. \n \n Cliquez sur l'étoile pour en rajouter.",
              style: TextStyle(
                fontFamily: 'ProximaNova',
                fontSize: 15.27,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
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
      home: MyWidget(),
    );
  }
}

class GameRank {
  final int rank;
  final int appId;
  final String name;
  final String description;
  final String publisher;
  final List<GameReview> reviews;

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
      reviews: [],
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
    if (json['data'] != null) {
      final data = json['data'];

      final List<dynamic> publisherList = data['publishers'];

      final List<String> publishers =
          publisherList.map((publisher) => publisher as String).toList();
      return GameDetails(
        name: data['name'],
        description: data['about_the_game'],
        publishers: publishers,
      );
    } else {
      return GameDetails(
        name: 'sorry no information on this game',
        description: 'sorry no information on this game',
        publishers: ['sorry no information on this game'],
      );
    }
  }
}

class GameReview {
  final String review;

  GameReview({required this.review});

  factory GameReview.fromJson(Map<String, dynamic> json) {
    if (json['review'] != null) {
      return GameReview(
        review: json['review'] as String,
      );
    } else {
      return GameReview(
        review: "No review for this game",
      );
    }
  }
}

Future<List<GameRank>> fetchMostPlayedGames() async {
  final response = await http.get(Uri.parse(
      'https://api.steampowered.com/ISteamChartsService/GetMostPlayedGames/v1/?key=C0713D972156C4B7933C72F0A8100655&format=json&limit=5'));

  if (response.statusCode == 200) {
    final Map<String, dynamic> res = jsonDecode(response.body);
    List<dynamic> ranks = (res['response'] as Map)['ranks'];

    List<GameRank> games = [];

    for (int i = 0; i < ranks.length; i++) {
      final gameRank = GameRank.fromJson(ranks[i]);
      final detailsResponse = await http.get(Uri.parse(
          'https://store.steampowered.com/api/appdetails?appids=${gameRank.appId}&cc=fr&l=fr'));
      if (detailsResponse.statusCode == 200) {
        final detailsRes = jsonDecode(detailsResponse.body);
        final details =
            GameDetails.fromJson(detailsRes[gameRank.appId.toString()]);
        List<String> publishers = [];
        if (detailsRes[gameRank.appId.toString()]['data'] != null) {
          final List<dynamic> publishersJson =
              detailsRes[gameRank.appId.toString()]['data']['publishers'];
          publishers = publishersJson.map((json) => json as String).toList();
        } else {
          publishers = ["no informations", "on this game"];
        }

        final reviewsResponse = await http.get(Uri.parse(
            'https://store.steampowered.com/appreviews/${gameRank.appId}?json=1'));
        if (reviewsResponse.statusCode == 200) {
          final Map<String, dynamic> resRev = jsonDecode(reviewsResponse.body);
          // List<dynamic> reviews = (resRev['query_summary'] as Map)['reviews'];
          List<dynamic> reviews = resRev['reviews'];
          List<GameReview> avis = [];
          for (int j = 0; j < reviews.length; j++) {
            final rev = GameReview.fromJson(reviews[j]);

            avis.add(GameReview(review: rev.review));
          }
          if (reviews.length == 0) {
            avis.add(GameReview(review: 'No review for this game'));
          }

          games.add(GameRank(
            rank: gameRank.rank,
            appId: gameRank.appId,
            name: details.name,
            description: details.description,
            publisher: publishers.join(', '),
            reviews: avis,
          ));
        }
      } else {
        throw Exception('Failed to load reviews for game ${gameRank.appId}');
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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmptyLike()),
              );
            },
            icon: SvgPicture.asset(
              'assets/like_vide.svg',
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EmptyWhish()),
              );
            },
            icon: SvgPicture.asset(
              'assets/etoile_vide.svg',
              color: Colors.white,
            ),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Color(0xFF636AF6),
                backgroundColor: Color(0xFF1E262C),
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
                    icon: Icon(
                      Icons.search,
                      color: Color(0xFF636AF6),
                    ),
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
          Container(
            width: 700,
            height: 170,
            child: Expanded(
              child: Container(
                width: 700,
                height: 50,
                child: AspectRatio(
                  aspectRatio: 4 / 2,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        'https://cdn.akamai.steamstatic.com/steam/apps/730/header.jpg',
                        fit: BoxFit.cover,
                      ),
                      Container(
                        color: Colors.black.withOpacity(0.4),
                      ),
                      Positioned(
                        bottom: 80.0,
                        left: 16.0,
                        child: Text('CS: GO',
                            style: TextStyle(
                              fontSize: 28.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )),
                      ),
                      Positioned(
                        bottom: 0.0,
                        left: 16.0,
                        child: Text(
                          "Counter-Strike: Global Offensive (CS:GO) étend \n le genre du jeu d'action en équipe \n dont Counter-Strike fut le pionnier \n lors de sa sortie, en 1999.",
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.0, top: 10),
            child: Text(
              'Les meilleures ventes',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              textAlign: TextAlign.left,
            ),
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
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all(
                                    Color(0xFF636AF6))),
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
