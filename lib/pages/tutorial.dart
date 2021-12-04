import 'package:flutter/material.dart';
import 'package:flutter_overboard/flutter_overboard.dart';
import 'package:mlocator/helpers/AuxiliarStrings.dart';

class Tutorial extends StatefulWidget {
  static const routeName = '/IntroOverboardPage';

  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _globalKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var _pages = [
      PageModel(
        color: const Color(0xFF9600AA),
        imageAssetPath: Auxstrings.tutorialImage000,
        title: "Welcome to McFinder!",
        body: "A brief tutorial for using our App will be presented",
        doAnimateImage: true,
      ),
      PageModel(
        color: const Color(0xFF01565F),
        imageAssetPath: Auxstrings.tutorialImage001,
        title: "Pick a range",
        body:
            "User the slider to set the range that you desire to find an open restaurant",
        doAnimateImage: true,
      ),
      PageModel(
        color: const Color.fromRGBO(202, 88, 66, 1),
        imageAssetPath: Auxstrings.tutorialImage002,
        title: "Start the search!",
        body:
            "Click the displayed icon to start searching for open restaurants in the range you picked",
        doAnimateImage: true,
      ),
      PageModel(
        color: const Color(0xFF00613C),
        imageAssetPath: Auxstrings.tutorialImage003,
        title: "Thank you for your attention",
        body:
            "Now you can start finding open restaurants in nearby your location!",
        doAnimateImage: true,
      ),
    ];

    return Scaffold(
      key: _globalKey,
      body: OverBoard(
        pages: _pages,
        showBullets: true,
        skipCallback: () {
          Navigator.pop(context);
        },
        finishCallback: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
