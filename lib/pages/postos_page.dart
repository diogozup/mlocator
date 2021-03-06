import 'dart:io';
import 'package:mlocator/ui/constants/map_key.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mlocator/controllers/postos_controller.dart';
import 'package:mlocator/helpers/AuxiliarStrings.dart';
import 'package:mlocator/helpers/CustomDialogBox.dart';
import 'package:mlocator/helpers/MapUtils.dart';
import 'package:mlocator/pages/tutorial.dart';
import 'package:mlocator/services/nearby_location_api.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:uuid/uuid.dart';

final appKey = GlobalKey();
bool isAppWorking = false;
double rangeRadius = 3500;
late BitmapDescriptor customIcon;
double currentZoom = 12.0;
int getUserLocationStatus = -1;
bool isAnimatedTextDisplayed = false;

Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
LatLng latLng01 = LatLng(41.4472213, -8.2825556); // DUMMY_DATA

class PostosPage extends StatefulWidget {
  @override
  State<PostosPage> createState() => _PostosPageState();
}

class _PostosPageState extends State<PostosPage> {
  double sliderVal = 1500.0;
  bool hasNetwork = false;

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late int _counter;

  Future<int> _incrementCounter() async {
    final SharedPreferences prefs = await _prefs;
    final int counter = (prefs.getInt('counter') ?? 0) + 1;

    prefs.setInt('counter', counter).then((bool success) {
      return counter;
    });
    return counter;
  }

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];
  GlobalKey keyBottomNavigation1 = GlobalKey();
  GlobalKey keyBottomNavigation2 = GlobalKey();
  GlobalKey keyBottomNavigation3 = GlobalKey();

  void showTutorial() {
    initTargets();
    tutorialCoachMark = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.purple,
      textSkip: "",
      paddingFocus: 5,
      opacityShadow: 0.8,
      onFinish: () {
        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        print("skip");
      },
    )..show();
  }

  void initTargets() {
    targets.clear();
    targets.add(
      TargetFocus(
          identify: "Target 1",
          keyTarget: keyBottomNavigation1,
          contents: [
            TargetContent(
                align: ContentAlign.bottom,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        "You can always check this tutorial",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "This simple tutorial will help you to know how to use the app!",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ))
          ]),
    );
    targets.add(
      TargetFocus(
          identify: "Target 2",
          keyTarget: keyBottomNavigation2,
          contents: [
            TargetContent(
                align: ContentAlign.top,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 100.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        "Step - 1",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Choose a radius that you want to search for nearby McDonald's Restaurants",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.0,
                          ),
                        ),
                      )
                    ],
                  ),
                ))
          ]),
    );

    targets.add(
      TargetFocus(
          identify: "Target 3",
          keyTarget: keyBottomNavigation3,
          contents: [
            TargetContent(
                align: ContentAlign.top,
                child: Container(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: const <Widget>[
                      Text(
                        "Step - 2",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 20.0),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Text(
                          "Click here to get all the nearby McDonald's Restaurants that are currently open and ready to serve you!",
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      )
                    ],
                  ),
                ))
          ]),
    );
  }

  Future<bool> hasNetworkCheck() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  showAlertDialog_Error0(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Oops!"),
      content: new Row(
        children: [
          Container(
              margin: EdgeInsets.only(left: 5), child: Text("Not updated!")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog_Error1(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Oops!"),
      content: new Row(
        children: [
          Container(
              margin: EdgeInsets.only(left: 5),
              child: Text("Por favor, habilite a localiza????o no smartphone")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  changeZoom(double newZoomValue) {
    print("\n ## Change Zoom Value! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: newZoomValue)));
  }

  changeZoomTo_08() {
    print("\n ## Change Zoom Value to 08! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(
              CurrentUserPosition.latitude, CurrentUserPosition.longitude),
          zoom: 8.0),
    ));
  }

  changeZoomTo_09() {
    print("\n ## Change Zoom Value to 09! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 09.0)));
  }

  changeZoomTo_10() {
    print("\n ## Change Zoom Value to 10! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 09.0)));
  }

  changeZoomTo_11() {
    print("\n ## Change Zoom Value to 11! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 10.0)));
  }

  changeZoomTo_12() {
    print("\n ## Change Zoom Value to 12! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 10.0)));
  }

  changeZoomTo_13() {
    print("\n ## Change Zoom Value to 13! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 11.0)));
  }

  changeZoomTo_14() {
    print("\n ## Change Zoom Value to 14! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 12.0)));
  }

  changeZoomTo_15() {
    print("\n ## Change Zoom Value to 15! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 15.0)));
  }

  changeZoomTo_16() {
    print("\n ## Change Zoom Value to 16! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 16.0)));
  }

  refresh() {
    setState(() {});
  }

  _cleanMarkers() {
    setState(() {
      print("\n ## Clean Markers! ##");
      markers = <MarkerId, Marker>{};
      isAppWorking = false;
      isAnimatedTextDisplayed = false;
    });
  }

  setCustomMarker() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1.0), 'assets/maps/marker02.png');
  }

  // void _addMarker(LatLng latLng) async {
  //   var uuid = Uuid();
  //   // Generate a v1 (time-based) id - SO SINCE THEY ALL CREATED ON BUILD, I CHANGED TO v4!
  //   var v4 = uuid.v4();

  //   var markerIdVal = v4.toString();
  //   MarkerId markerId = MarkerId(markerIdVal);

  //   // creating a new MARKER
  //   final Marker marker = Marker(
  //     draggable: true,
  //     markerId: markerId,
  //     icon: customIcon,
  //     position: LatLng(latLng.latitude, latLng.longitude),
  //     onDragEnd: ((newPosition) {
  //       print(newPosition.latitude);
  //       print(newPosition.longitude);
  //       // _updateMarkerPositon(markerId, newPosition);
  //       // markers[markerId] = marker.copyWith(positionParam: LatLng(newPosition.latitude, newPosition.longitude));
  //     }),
  //     infoWindow: InfoWindow(
  //       title: markers.length == 0
  //           ? 'This is open now!'
  //           : 'CheckPoint - ' + markers.length.toString(),
  //       // snippet: markerIdVal,
  //       snippet: "Click here to delete this marker",

  //       onTap: () {
  //         // _deleteThisMarker(markerId);
  //         _cleanMarkers();
  //         print("\n ## DELETE THIS MARKER ##");
  //       },
  //     ),
  //     onTap: () {
  //       // _onMarkerTapped(markerId, latLng);
  //       print("\n ## INFO WINDOW! ##");
  //     },
  //   );

  //   setState(() {
  //     markers[markerId] = marker;
  //   });
  // }

  Set<Circle> circles = Set.from([
    Circle(
      circleId: CircleId('rangeRadius'),
      center: LatLng(latLng01.latitude, latLng01.longitude),
      radius: rangeRadius,
      fillColor: Colors.purple.withOpacity(0.3),
    ),
  ]);

  Set<Circle> getFirstCircle(lat, lng) {
    Set<Circle> circles = Set.from([
      Circle(
        circleId: CircleId('rangeRadius'),
        center: LatLng(lat, lng),
        radius: rangeRadius + 2500,
        fillColor: Colors.purple.withOpacity(0.3),
        strokeWidth: 1,
      ),
    ]);
    return circles;
  }

  _displayLoadingWidget() {
    // showDialog(
    //   context: context,
    //   barrierDismissible: false,
    //   builder: (BuildContext context) {
    //     return Dialog(
    //       child: new Row(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           new CircularProgressIndicator(),
    //           new Text("Loading"),
    //         ],
    //       ),
    //     );
    //   },
    // );
  }

  showAlertDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: new Row(
        children: [
          CircularProgressIndicator(
            color: Colors.purple,
          ),
          Container(
              margin: EdgeInsets.only(left: 5), child: Text(" Searching...")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  showAlertDialog_NoHitsFound(BuildContext context) {
    AlertDialog alert = AlertDialog(
      title: Text("Oops!"),
      content: new Row(
        children: [
          Container(
              margin: EdgeInsets.only(left: 5), child: Text("Nothing Found!")),
        ],
      ),
    );
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  void printWrapped(String text) {
    final pattern = RegExp('.{1,800}'); // 800 is the size of each chunk
    pattern.allMatches(text).forEach((match) => print(match.group(0)));
  }

  _displayTutorialIfFirstTimeAppIsOpened() async {
    printColor(Auxstrings.colorRed, "INIT STAT GOOGLE MAPS SHOW TUTORIAL");
    int count = await _incrementCounter();
    print("#### NUM TIMES IS APP OPENED THIS MAP SCREEN ### - " +
        count.toString());
    if (count == 1) {
      Future.delayed(Duration.zero, showTutorial);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setCustomMarker();
    rangeRadius = 1500;
    _displayTutorialIfFirstTimeAppIsOpened();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: appKey,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text(
            'Currently available McDonalds',
            style: TextStyle(color: Colors.white),
          ),
          // backgroundColor: Colors.purple,
          flexibleSpace: Container(
            decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: const <Color>[Colors.purple, Colors.black])),
          ),
          actions: [
            // IconButton(
            //   icon: Icon(
            //     Icons.info_outline,
            //     color: Colors.white,
            //   ),
            //   onPressed: () {
            //     Future.delayed(Duration.zero, showTutorial);
            //   },
            // ),
            IconButton(
              key: keyBottomNavigation1,
              icon: Icon(
                Icons.info_outline,
                color: Colors.white,
              ),
              onPressed: () {
                print("\n ## INFO ICON APPBAR ##");
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Tutorial()),
                );
              },
            ),
          ],
        ),
        body: ChangeNotifierProvider<PostosController>(
          create: (context) => PostosController(),
          child: Builder(builder: (context) {
            final local = context.watch<PostosController>();

            return Stack(
              children: [
                GoogleMap(
                  zoomGesturesEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(local.lat, local.long),
                    // zoom: 18,
                    zoom: currentZoom,
                  ),
                  zoomControlsEnabled: true,
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  onMapCreated: local.onMapCreated,
                  // markers: local.markers,
                  markers: Set<Marker>.of(markers.values),
                  // circles: circles,
                  circles: getFirstCircle(local.lat, local.long),
                ),
                Positioned(
                  top: 120,
                  width: MediaQuery.of(context).size.width * 1,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        // Container(
                        //   width: 100,
                        //   height: 100,
                        //   color: Colors.red,
                        // ),
                        // SizedBox(
                        isAnimatedTextDisplayed
                            ? Container(
                                // color: Colors.purple,
                                width: 250,
                                child: DefaultTextStyle(
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    fontFamily: 'Canterbury',
                                    color: Colors.black,
                                  ),
                                  child: AnimatedTextKit(
                                    totalRepeatCount: 4,
                                    animatedTexts: [
                                      ScaleAnimatedText(
                                          'Click the marker for Details'),
                                      // ScaleAnimatedText('for Details'),
                                    ],
                                    onTap: () {
                                      print("Tap Event");
                                      setState(() {
                                        isAnimatedTextDisplayed = false;
                                      });
                                    },
                                  ),
                                ),
                              )
                            : Container(),
                      ]),
                ),

                Positioned(
                  key: keyBottomNavigation3,
                  bottom: 30,
                  left: 10,
                  child: GestureDetector(
                    onTap: () async {
                      hasNetwork = await hasNetworkCheck();
                      if (hasNetwork) {
                        hasNetwork = false;
                        if (!isAppWorking) {
                          isAppWorking = true;
                          print("\n ## TAPPED - Red Container ##");
                          print(CurrentUserPosition.latitude.toString());
                          print(CurrentUserPosition.longitude.toString());

                          // showDialog(
                          //     context: context,
                          //     builder: (_) => AlertDialog(
                          //           title: Text('Dialog Title'),
                          //           content: Text('This is my content'),
                          //         ));

                          // _displayLoadingWidget();

                          showAlertDialog(context);

                          var result = await NearcyLocationApi().getNearby(
                              userLocation: CurrentUserPosition,
                              radius: rangeRadius,
                              type: 'restaurants',
                              keyword: "McDonalds");
                          print("\n #### RESULT LENGHT ####");
                          // print(result[0].keys);
                          // printWrapped(result[0].toString());
                          // printWrapped(result[1].toString());
                          // print("\n\n\n ### ### ### ### ");
                          // print(result.length.toString());
                          // print(result[0]['place_id']);
                          // print(result[0]['name']);
                          // print(result[0]['vicinity']);
                          // print(result[0]['user_ratings_total'].toString());
                          // print(result[0]['opening_hours']);
                          // print(result[0]['opening_hours']['open_now']);
                          print("\n\n ####");
                          print(result.length.toString());
                          if (result.length != 0) {
                            Navigator.pop(context);

                            _displayAlertDialog(
                              context,
                              result,
                              refresh,
                              _cleanMarkers,
                              changeZoomTo_14,
                              changeZoomTo_13,
                              changeZoomTo_12,
                              changeZoomTo_11,
                              changeZoomTo_10,
                            );
                            isAppWorking = false;
                          } else {
                            Navigator.pop(context);
                            isAppWorking = false;
                            print("\n\n ## display NO FOUND ##");
                            showAlertDialog_NoHitsFound(context);
                          }
                        } else {
                          print("\n App is working !!");
                        }
                      } else {
                        hasNetwork = false;
                        showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text("Oops!"),
                                content: Text(
                                    "You appear to be offline, this app requires an internet connection"),
                              );
                            });
                      }
                    },
                    // child: Container(
                    //   height: 70,
                    //   width: 70,
                    //   // color: Colors.red,
                    //   decoration: BoxDecoration(
                    //     image: DecorationImage(
                    //       image: AssetImage(Auxstrings.iconMacDonalds004),
                    //       fit: BoxFit.contain,
                    //     ),
                    //     shape: BoxShape.circle,
                    //   ),
                    // ),
                    child: SvgPicture.asset(
                      Auxstrings.iconMacDonalds005,
                      color: Colors.black,
                      matchTextDirection: true,
                      fit: BoxFit.contain,
                      semanticsLabel: "aaaa",
                      height: 50,
                      width: 50,
                    ),
                  ),
                ),
                markers.length == 0 || markers.isEmpty
                    ? Container()
                    : Positioned(
                        bottom: 100,
                        left: 10,
                        child: GestureDetector(
                          onTap: () async {
                            print("\n ## TAPPED - clean markers ##");
                            _cleanMarkers();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            // color: Colors.green,
                            decoration: BoxDecoration(
                                color: Colors.purple,
                                border: Border.all(
                                  color: Colors.purple,
                                ),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                // Positioned(
                //   bottom: 100,
                //   left: 10,
                //   child: GestureDetector(
                //     onTap: () async {
                //       print("\n ## TAPPED - Green Container ##");
                //       _addMarker(latLng01);
                //     },
                //     child: Container(
                //       height: 50,
                //       width: 50,
                //       color: Colors.green,
                //     ),
                //   ),
                // ),
                // Positioned(
                //   bottom: 180,
                //   left: 10,
                //   child: GestureDetector(
                //     onTap: () async {
                //       print("\n ## TAPPED - Yellow Container ##");
                //       // _cleanMarkers();
                //       MapUtils.openMap(-3.823216, -38.481700);
                //     },
                //     child: Container(
                //       height: 50,
                //       width: 50,
                //       color: Colors.yellow,
                //     ),
                //   ),
                // ),
                // Positioned(
                //   bottom: 250,
                //   left: 10,
                //   child: GestureDetector(
                //     onTap: () async {
                //       print("\n ## TAPPED - Orange Container ##");
                //       currentZoom -= 1;
                //       changeZoom(currentZoom);
                //     },
                //     child: Container(
                //       height: 50,
                //       width: 50,
                //       color: Colors.orange,
                //     ),
                //   ),
                // ),
                // Positioned(
                //   bottom: 330,
                //   left: 10,
                //   child: GestureDetector(
                //     onTap: () async {
                //       print("\n ## TAPPED - Purple Container ##");
                //       currentZoom += 1;
                //       changeZoom(currentZoom);
                //     },
                //     child: Container(
                //       height: 50,
                //       width: 50,
                //       color: Colors.purple,
                //     ),
                //   ),
                // ),
                // Positioned(
                //   bottom: 400,
                //   left: 10,
                //   child: GestureDetector(
                //     onTap: () async {
                //       print("\n ## TAPPED - Pink Container ##");

                //       // changeZoom(9);
                //       changeZoomTo_12();
                //     },
                //     child: Container(
                //       height: 50,
                //       width: 50,
                //       color: Colors.pink,
                //     ),
                //   ),
                // ),
                // Positioned(
                //   bottom: 480,
                //   left: 10,
                //   child: GestureDetector(
                //     onTap: () async {
                //       print("\n ## TAPPED - black Container ##");

                //       print("\n ## The rangeRadius is:" + rangeRadius.toString());
                //       print("\n ## The currentZoom is:" + currentZoom.toString());
                //     },
                //     child: Container(
                //       height: 50,
                //       width: 50,
                //       color: Colors.black,
                //     ),
                //   ),
                // ),
                Positioned(
                    bottom: 30,
                    left: 60,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.fromSwatch().copyWith(
                          onSurface: Colors.purple.withOpacity(0.3),
                          onPrimary: Colors.black,
                          // secondary: Colors.grey,
                          // background: Colors.grey,
                          // onBackground: Colors.orange,
                          // onSecondary: Colors.purple,
                          // primary: Colors.white,
                          // primaryVariant: Colors.yellow,
                          // secondaryVariant: Colors.red,
                        ),
                      ),
                      child: Slider(
                        key: keyBottomNavigation2,
                        value: sliderVal,
                        onChanged: (value) {
                          setState(() {
                            sliderVal = value;
                            rangeRadius = value;

                            circles.clear();
                            circles.add(Circle(
                              circleId: CircleId('rangeRadius'),
                              center: LatLng(local.lat, local.long),
                              radius: rangeRadius,
                              fillColor: Colors.purple.withOpacity(0.3),
                              strokeWidth: 1,
                            ));
                            if (rangeRadius >= 500 && rangeRadius < 1500) {
                              changeZoomTo_14();
                            } else if (rangeRadius >= 1500 &&
                                rangeRadius <= 3000) {
                              changeZoomTo_13();
                            } else if (rangeRadius > 3000 &&
                                rangeRadius <= 5000) {
                              changeZoomTo_12();
                            } else if (rangeRadius > 5000 &&
                                rangeRadius <= 10000) {
                              changeZoomTo_11();
                            } else if (rangeRadius > 10000 &&
                                rangeRadius <= 20000) {
                              changeZoomTo_10();
                            }
                          });
                        },
                        min: 500,
                        max: 20000,
                        activeColor: Colors.purple,
                        inactiveColor: Colors.purple[100],
                        // label: sliderVal.round().toString() + " Meters",
                        label: (sliderVal / 1000.0).toStringAsFixed(1) + " km",

                        divisions: 17,
                      ),
                    )),

                //   Slider(
                //   value: val,
                //   onChanged: (value) {
                //     setState(() {
                //       val = value;
                //     });
                //   },
                //   min: 0,
                //   max: 10,
                //   activeColor: Colors.green,
                //   inactiveColor: Colors.green[100],
                //   label: val.round().toString(),
                //   divisions: 10,
                // )
              ],
            );
          }),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(top: 100.0),
          child: Container(
            height: 100,
            width: 120,
            child: FittedBox(
              child: Opacity(
                opacity: 0.9,
                child: FloatingActionButton.extended(
                  label: Text(
                    (rangeRadius / 1000.0).toStringAsFixed(1) + " km",
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  heroTag: 'displayDistance',
                  elevation: 0.0,

                  // backgroundColor: Auxstrings.mainAppThemeColor02,
                  backgroundColor: Colors.black,

                  onPressed: () {},
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterTop);
  }
}

_getAllDistances(List results) async {
  List<String> travelTimes = [];
  List<String> distances = [];
  // Map<String, String> markerMetaData = {};
  List<Map<String, String>> markerMetaDataList = [];
  Dio dio = new Dio();
  for (int index = 0; index < results.length; index++) {
    Response response = await dio.get(
        "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${CurrentUserPosition.latitude},${CurrentUserPosition.longitude}&destinations=${results[index]['geometry']['location']['lat']},${results[index]['geometry']['location']['lng']}&key=${MapKey.apiKeyDistanceMatrix}");
    //?- distance
    String distanceInMiles =
        response.data["rows"][0]["elements"][0]["distance"]["text"];
    distanceInMiles = distanceInMiles.substring(0, distanceInMiles.length - 3);
    // print("DISTANCE IN MILES: " + distanceInMiles);
    double distanceInKM = (double.parse(distanceInMiles) * 1.60934);
    String distanceInKMString = distanceInKM.toStringAsFixed(1);

    //?- travelTime
    String travelTime =
        response.data["rows"][0]["elements"][0]["duration"]["text"];
    double travelTimeInMinutes =
        double.parse(travelTime.substring(0, travelTime.length - 4));

    distances.add(distanceInKMString);
    travelTimes.add(travelTimeInMinutes.toString());
    Map<String, String> markerMetaData = {
      "distanceInKMString": distanceInKMString,
      "travelTimeInMinutes": travelTimeInMinutes.toString()
    };

    markerMetaDataList.add(markerMetaData);
  }
  // return distances;
  return markerMetaDataList;
}

Widget setupAlertDialoadContainer(
  // List<String> distances,
  List<Map<String, String>> markerMetaDataList,
  List results,
  dynamic refresh,
  dynamic cleanMarkers,
  dynamic changeZoomTo_14,
  dynamic changeZoomTo_13,
  dynamic changeZoomTo_12,
  dynamic changeZoomTo_11,
  dynamic changeZoomTo_10,
) {
  return Container(
    height: 300.0,
    width: 300.0,
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        var var1 = markerMetaDataList[index]["distanceInKMString"];
        Text text1 = Text("Distance: " + var1! + " km");
        var var2 = markerMetaDataList[index]["travelTimeInMinutes"];
        Text text2 = Text("Duration: " + var2! + " min");

        return results[index]['name'] == "McDonald's" &&
                results[index]['opening_hours']['open_now'] == true
            ? ListTile(
                leading: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: AssetImage(Auxstrings.iconMacDonalds004),
                ),
                title: text1,
                subtitle: text2,
                // title: Text(
                //     markerMetaDataList[index]['distanceInKMString'] ?? "0.0"),
                // subtitle: Text(
                //     markerMetaDataList[index]['travelTimeInMinutes'] ?? "0.0"),

                // subtitle: Text(results[index]['vicinity']),
                // trailing: Text(
                //   distances[index].toString() + " km",
                //   style: TextStyle(color: Colors.purple),
                // ),
                onTap: () {
                  print(results[index]['place_id']);
                  print(results[index]['geometry']['location']['lat']);
                  print(results[index]['opening_hours']['open_now']);
                  print(results[index]['photos'][0]['photo_reference']);
                  print(results[index].keys);
                  print(results[index]['business_status']);
                  print(results[index]['opening_hours']);
                  print(
                      "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${results[index]['photos'][0]['photo_reference']}&key=AIzaSyAQ7cjyXO5qkbUA_QBIVvYtaNEse8i_IJA");

                  LatLng latLng = new LatLng(
                      results[index]['geometry']['location']['lat'],
                      results[index]['geometry']['location']
                          ['lng']); // DUMMY_DATa
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return CustomDialogBox(
                          title: results[index]['name'],
                          descriptions: results[index]['vicinity'],
                          text: "Go there!",
                          img:
                              "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photo_reference=${results[index]['photos'][0]['photo_reference']}&key=AIzaSyAQ7cjyXO5qkbUA_QBIVvYtaNEse8i_IJA",
                          rating: results[index]['rating'].toString(),
                          latLng: latLng,
                          notifyParent: refresh,
                          cleanMarkers: cleanMarkers,
                          cameraUpdate_01: changeZoomTo_14,
                          cameraUpdate_02: changeZoomTo_13,
                          cameraUpdate_03: changeZoomTo_12,
                          cameraUpdate_04: changeZoomTo_11,
                          cameraUpdate_05: changeZoomTo_10,
                        );
                      });
                },
              )
            : Container();
      },
    ),
  );
}

Future<void> _displayAlertDialog(
  BuildContext context,
  List results,
  dynamic refresh,
  dynamic cleanMarkers,
  dynamic changeZoomTo_14,
  dynamic changeZoomTo_13,
  dynamic changeZoomTo_12,
  dynamic changeZoomTo_11,
  dynamic changeZoomTo_10,
) async {
  // List<String> distances = await _getAllDistances(results);
  List<Map<String, String>> markerMetaDataList =
      await _getAllDistances(results);
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Opened Now!'),
          content: setupAlertDialoadContainer(
            // distances,
            markerMetaDataList,
            results,
            refresh,
            cleanMarkers,
            changeZoomTo_14,
            changeZoomTo_13,
            changeZoomTo_12,
            changeZoomTo_11,
            changeZoomTo_10,
          ),
        );
      });
}
