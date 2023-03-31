/*


import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:firebase/firebase.dart' as fb;

class Game {
  final int id;
  final String name;
  final String description;
  final String publisher;
  final List<String> reviews;

  Game({this.id, this.name, this.description, this.publisher, this.reviews});

  factory Game.fromJson(Map<String, dynamic> json) {
    List<dynamic> reviewsJson = json['reviews'] as List<dynamic>;
    List<String> reviews = reviewsJson.map((r) => r['review'] as String).toList();
    return Game(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      publisher: json['publisher'] as String,
      reviews: reviews,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    data['description'] = this.description;
    data['publisher'] = this.publisher;
    data['reviews'] = this.reviews.map((r) => {'review': r}).toList();
    return data;
  }
}

Future<List<Game>> fetchAndCacheGames() async {
  final apiKey = 'YOUR_STEAM_API_KEY';
  final cacheTime = Duration(minutes: 10);

  // Initialize Firebase App
  final firebaseApp = fb.initializeApp(
    apiKey: 'YOUR_FIREBASE_API_KEY',
    authDomain: 'YOUR_FIREBASE_AUTH_DOMAIN',
    databaseURL: 'YOUR_FIREBASE_DATABASE_URL',
    projectId: 'YOUR_FIREBASE_PROJECT_ID',
    storageBucket: 'YOUR_FIREBASE_STORAGE_BUCKET',
  );

  // Initialize Firebase Database
  final database = fb.database();

  // Initialize Firebase Cache
  final cache = database.ref('gameCache');

  // Get cached games
  final cachedGames = (await cache.once('value')).snapshot.val() as Map<dynamic, dynamic>;

  // Initialize Firebase HTTP Client
  final httpClient = fb.functions().httpsCallable('http');

  // Fetch most played games from Steam API
  final steamResponse = await httpClient({
    'url': 'https://api.steampowered.com/ISteamChartsService/GetMostPlayedGames/v1/',
    'params': {
      'key': apiKey,
      'format': 'json',
      'limit': 5,
    }
  });

  if (steamResponse.data['success'] != true) {
    throw Exception('Failed to load most played games from Steam API');
  }

  final steamGamesJson = steamResponse.data['response']['ranks'] as List<dynamic>;

  final games = <Game>[];

  for (final steamGameJson in steamGamesJson) {
    final gameId = steamGameJson['appid'] as int;

    // Check if game is already cached
    if (cachedGames.containsKey(gameId)) {
      final cachedGameJson = cachedGames[gameId];
      final game = Game.fromJson(cachedGameJson);
      games.add(game);
      continue;
    }

    // Fetch game details from Steam API
    final detailsResponse = await httpClient({
      'url': 'https://store.steampowered.com/api/appdetails/',
      'params': {
        'appids': gameId,
        'cc': 'fr',
        'l': 'fr',
      },
    });



    */