import 'package:flutter/material.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_glow/flutter_glow.dart';
import 'package:location/location.dart';
import 'package:mlocator/helpers/AuxiliarStrings.dart';
import 'package:mlocator/repositories/postos_repository.dart';
import 'package:mlocator/pages/postos_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
      title: 'McFinder',
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'McFinder',
          style: TextStyle(color: Colors.white),
        ),
        // actions: [
        //   IconButton(
        //     icon: Icon(
        //       Icons.info_outline,
        //       color: Colors.white,
        //     ),
        //     onPressed: () async {},
        //   ),
        // ],
        // backgroundColor: Colors.purple,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Colors.purple, Colors.black])),
        ),
      ),
      body: Container(
        // decoration: new BoxDecoration(color: Colors.deepPurpleAccent[100]),
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new AssetImage(Auxstrings.background001),
            fit: BoxFit.cover,
            colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.7), BlendMode.darken),
          ),
        ),

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
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white,
                  // fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(25)),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple,
              Colors.black,
            ],
          ),
        ),
        child: FloatingActionButton.extended(
            // backgroundColor: Colors.purple,
            backgroundColor: Colors.transparent,
            tooltip: 'Go to map!',
            icon: Icon(Icons.map, color: Colors.white),
            label: Text(
              "Find available McDonalds right now!",
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () async {
              //! CHECK THE LOCATION PERSMISSON AND GIVE DIALOG MESSAGE
              bool result = await checkLocationPermission();
              if (result) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PostosPage()),
                );
              }
            }),
      ),
    );
  }
}

checkLocationPermission() async {
  Location location = new Location();

  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;

  _serviceEnabled = await location.serviceEnabled();
  if (!_serviceEnabled) {
    _serviceEnabled = await location.requestService();
    if (!_serviceEnabled) {
      return;
    }
  }

  _permissionGranted = await location.hasPermission();
  if (_permissionGranted == PermissionStatus.denied) {
    _permissionGranted = await location.requestPermission();
    if (_permissionGranted != PermissionStatus.granted) {
      return;
    }
  }

  _locationData = await location.getLocation();
  return true;
}
