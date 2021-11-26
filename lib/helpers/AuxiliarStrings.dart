import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Future<void>
class Auxstrings {
  //!----------------------------------------------------------------------------- Vars
  // #ICONS
  Future<BitmapDescriptor> customIcon = BitmapDescriptor.fromAssetImage(
      ImageConfiguration(devicePixelRatio: 2.5),
      'assets/maps/custom_marker01.png');
  //---------------------------------------------------------------------------------------- Colors
  static const String colorBlack = "\x1B[30m";
  static const String colorRed = "\x1B[31m";
  static const String colorGreen = "\x1B[32m";
  static const String colorYellow = "\x1B[33m";
  static const String colorBlue = "\x1B[34m";
  static const String colorMagenta = "\x1B[35m";
  static const String colorCyan = "\x1B[36m";
  static const String colorWhite = "\x1B[37m";
  static const String colorReset = "\x1B[0m";

  //---------------------------------------------------------------------------------------- EmptyFields
  static const String emptyFieldEmail = "emptyemail@email.com";

  //---------------------------------------------------------------------------------------- AppConstants

  static const String iconMacDonalds001 = "assets/images/001.png";
  static const String iconMacDonalds002 = "assets/images/002.png";
  static const String iconMacDonalds003 = "assets/images/003.png";

//*--------------------------------------------------------------------------------------------- background Stride Button
  // static const String PrimaryPage3_pickStrideBackground = "assets/primary/page3/pickStrideBackground.png";
  static const String PrimaryPage3_pickStrideBackground =
      "assets/primary/page3/pickStrideBackground.svg";

//!----------------------------------------------------------------------------- Functions

  void printColor(String color, String text) {
    print('$color$text\x1B[0m');
  }

  Future<void> closeTextInputSafely(BuildContext context) async {
    FocusScopeNode currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus) {
      currentFocus.unfocus();
    }

    await Future.delayed(Duration(milliseconds: 500));
    printColor(Auxstrings.colorGreen, "\n ## closed keyboard input safely##");
  }

//!----------------------------------------------------------------------------- Themes
  static const TextStyle textStyle_title = TextStyle(
    height: 1.17,
    fontSize: 24.0,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w700,
    color: Color.fromARGB(255, 0, 0, 0),
  );

  static const TextStyle textStyle_body = TextStyle(
    height: 1.17,
    fontSize: 18.0,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    color: Color.fromARGB(255, 0, 0, 0),
  );

  static const TextStyle textStyle_01 = TextStyle(
    height: 1.17,
    fontSize: 11.0,
    fontFamily: 'Poppins',
    fontWeight: FontWeight.w400,
    color: Colors.black,
    // color: Color.fromARGB(255, 234, 35, 44),
  );

  static ButtonStyle elevatedButtonStyle_01 = ElevatedButton.styleFrom(
    primary: Colors.red, // background
    onPrimary: Colors.white, // foreground
    minimumSize: Size(120, 36),
    padding: EdgeInsets.symmetric(horizontal: 16),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  );
}

void printColor(String color, String text) {
  print('$color$text\x1B[0m');
}
