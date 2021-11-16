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
      home: PostosPage(),
    );
  }
}
