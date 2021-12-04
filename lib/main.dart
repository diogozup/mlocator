import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:mlocator/repositories/postos_repository.dart';
import 'package:mlocator/pages/postos_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterConfig.loadEnvVariables();

  runApp(
    ChangeNotifierProvider<PostosRepository>(
      create: (_) => PostosRepository(),
      child: App(),
    ),
  );
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Postos Locais',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      // home: PostosPage(),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    // _getLocationPermission();
  }

  // void _getLocationPermission() async {
  //   var location = new Location();
  //   try {
  //     location.requestPermission();
  //   } on Exception catch (_) {
  //     print('There was a problem allowing location access');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'McFinder',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Container(
        decoration: new BoxDecoration(color: Colors.deepPurpleAccent[100]),
        padding: EdgeInsets.all(16),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Welcome to McFinder',
                style: TextStyle(fontSize: 42, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                'This is an app that will help you quickly find the McDonalds restaurants available to welcome you right away.',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
          // backgroundColor: Colors.yellowAccent,
          tooltip: 'Go to map!',
          // child: Icon(Icons.map, color: Colors.white),
          icon: Icon(Icons.map, color: Colors.black),
          label: Text(
            "Find available McDonalds right now!",
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PostosPage()),
            );
          }),
    );
  }
}
