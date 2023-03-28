import 'details.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class SteamGame {
  final int appId;
  final String name;
  final String publisher;
  String description;

  SteamGame({
    required this.appId,
    required this.name,
    required this.publisher,
    required this.description,
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
    );
  }
}

class SteamGameDetails {
  final String description;

  SteamGameDetails({
    required this.description,
  });

  factory SteamGameDetails.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return SteamGameDetails(
      description: data['about_the_game'],
    );
  }
} /*
Future<void> _fetchGameDescription(int appId) async {
  final response = await http.get(Uri.parse('https://store.steampowered.com/api/appdetails?appids=$appId&cc=fr&l=fr'));
  if (response.statusCode == 200) {
    final Map<String, dynamic> gameDetailsJson = json.decode(response.body)['$appId'];
    final String description = gameDetailsJson['data']['detailed_description'];
    return description;
  } else {
    throw Exception('Failed to load game details');
  }
}*/

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
      for (int i = 0; i < 50; i++) {
        final steamGame = SteamGame.fromJson(gamesList[i]);
        final appDetailsResponse = await http.get(Uri.parse(
            'https://store.steampowered.com/api/appdetails?appids=${steamGame.appId}&cc=fr&l=fr'));
        if (appDetailsResponse.statusCode == 200) {
          final detailRes = jsonDecode(appDetailsResponse.body);
          final details =
              SteamGameDetails.fromJson(detailRes[steamGame.appId.toString()]);
          jeux.add(SteamGame(
            appId: steamGame.appId,
            name: steamGame.name,
            publisher: steamGame.publisher,
            description: details.description,
          ));
        } else {
          throw Exception('Failed to load game details for ${steamGame.appId}');
        }
      }
      /*

      //final List<dynamic> gamesList = gamesJson.values.toList();
      //final List<SteamGame> steamGames =
          gamesList.map((json) => SteamGame.fromJson(json)).toList();

      //await _fetchGameDescriptions();
      for (var game in steamGames) {
        final appDetailsResponse = await http.get(Uri.parse(
            'https://store.steampowered.com/api/appdetails?appids=${game.appId}&cc=fr&l=fr'));
        if (appDetailsResponse.statusCode == 200) {
          final detailRes = jsonDecode(appDetailsResponse.body);
          final details =
              SteamGameDetails.fromJson(detailRes[game.appId.toString()]);
          game.description = details.description;
        }
      } 
      for (int i = 0; i < steamGames.length; i++) {
        final String description = await _fetchGameDescription(steamGames[i].appId);
        steamGames[i].description = description;
      }*/
      return jeux;
    } else {
      throw Exception('Failed to load games');
    }
  }

/*
  Future<void> _fetchGameDescriptions() async {
    final List<int> appIds = _games.map((game) => game.appId).toList();
    final String baseUrl = 'https://store.steampowered.com/api/appdetails';
    final String queryParams =
        '?cc=fr&l=fr&appids=${appIds.join(',')}';

    final response = await http.get(Uri.parse('$baseUrl$queryParams'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> gamesJson = json.decode(response.body);
      setState(() {
        _games = _games.map((game) {
          final int appId = game.appId;
          final String description = gamesJson[appId.toString()]['data']?['detailed_description'] ?? '';
          return game.copyWith(description: description);
        }).toList();
      });
    } else {
      throw Exception('Failed to load game descriptions');
    }
  }*/

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
        title: Text('Jeux Steam'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Column(
        children: <Widget>[
          // Champ de recherche
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              style: TextStyle(color: Colors.white),
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
