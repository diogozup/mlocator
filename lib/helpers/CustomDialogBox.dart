import 'package:dio/dio.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mlocator/controllers/postos_controller.dart';
import 'package:mlocator/helpers/AuxiliarStrings.dart';
import 'package:mlocator/helpers/MapUtils.dart';
import 'package:mlocator/pages/postos_page.dart';
import 'package:mlocator/ui/constants/map_key.dart';
import 'package:uuid/uuid.dart';

class CustomDialogBox extends StatefulWidget {
  final String title, descriptions, text;
  // final Image img;
  final String img;
  final String rating;
  final LatLng latLng;
  final Function() notifyParent;
  final Function() cleanMarkers;
  final Function() cameraUpdate_01;
  final Function() cameraUpdate_02;
  final Function() cameraUpdate_03;

  const CustomDialogBox({
    Key? key,
    required this.title,
    required this.descriptions,
    required this.text,
    required this.img,
    required this.rating,
    required this.latLng,
    required this.notifyParent,
    required this.cleanMarkers,
    required this.cameraUpdate_01,
    required this.cameraUpdate_02,
    required this.cameraUpdate_03,
  }) : super(key: key);

  @override
  _CustomDialogBoxState createState() => _CustomDialogBoxState();
}

class _CustomDialogBoxState extends State<CustomDialogBox> {
  _cleanMarkers() {
    setState(() {
      print("\n ## Clean Markers! ##");
      markers = <MarkerId, Marker>{};
      widget.notifyParent();
    });
  }

  void _addMarker(LatLng latLng) async {
    var uuid = Uuid();
    // Generate a v1 (time-based) id - SO SINCE THEY ALL CREATED ON BUILD, I CHANGED TO v4!
    var v4 = uuid.v4();

    var markerIdVal = v4.toString();
    MarkerId markerId = MarkerId(markerIdVal);

    // creating a new MARKER
    final Marker marker = Marker(
      draggable: true,
      markerId: markerId,
      icon: customIcon,
      position: LatLng(latLng.latitude, latLng.longitude),
      onDragEnd: ((newPosition) {
        print(newPosition.latitude);
        print(newPosition.longitude);
      }),
      infoWindow: InfoWindow(
        title: markers.length == 0
            ? 'This is open now!'
            : 'CheckPoint - ' + markers.length.toString(),
        // snippet: markerIdVal,
        snippet: "Check the restaurant details.",

        onTap: () async {
          // // _deleteThisMarker(markerId);
          // // widget.cleanMarkers();
          // print("\n ## DELETE MARKERS ##");
          // print("\n\n ## DETAILS ##");
          // Dio dio = new Dio();
          // Response response = await dio.get(
          //     "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${CurrentUserPosition.latitude},${CurrentUserPosition.longitude}&destinations=${widget.latLng.latitude},${widget.latLng.longitude}&key=${MapKey.apiKeyDistanceMatrix}");
          // // "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=41.4472213,-8.2825556&destinations=41.4472213,-8.2825556&key=AIzaSyAgDB2tilx_lL-juFtIoa2B2CVA9e76UKI");
          // print(response.data);
          // print("\n ##");
          // print(response.data["rows"][0]["elements"][0]["distance"]["text"]);
          // print(response.data["rows"][0]["elements"][0]["duration"]["text"]);
          // //?- distance
          // String distanceInMiles =
          //     response.data["rows"][0]["elements"][0]["distance"]["text"];
          // distanceInMiles =
          //     distanceInMiles.substring(0, distanceInMiles.length - 3);
          // // print("DISTANCE IN MILES: " + distanceInMiles);
          // double distanceInKM = double.parse(distanceInMiles) * 1.60934;
          // // print("DISTANCE IN KM: " + distanceInKM.toStringAsFixed(2));
          // //?- travelTime
          // String travelTime =
          //     response.data["rows"][0]["elements"][0]["duration"]["text"];
          // double travelTimeInMinutes =
          //     double.parse(travelTime.substring(0, travelTime.length - 4));

          // showModalBottomSheet(
          //   context: appKey.currentState!.context,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.only(
          //       topLeft: Radius.circular(20),
          //       topRight: Radius.circular(20),
          //     ),
          //   ),
          //   builder: (context) {
          //     return Wrap(
          //       children: [
          //         Padding(
          //           padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
          //           child: Container(
          //             height: 50,
          //             child: Center(
          //               child: SvgPicture.asset(
          //                 Auxstrings.iconMacDonalds005,
          //                 color: Colors.black,
          //                 matchTextDirection: true,
          //                 fit: BoxFit.contain,
          //                 semanticsLabel: "aaaa",
          //                 height: 50,
          //                 width: 50,
          //               ),
          //             ),
          //           ),
          //         ),
          //         ListTile(
          //           leading: Icon(Icons.directions_car_filled),
          //           title: Text('Exact distance by car: ' +
          //               distanceInKM.toStringAsFixed(2) +
          //               ' km'),
          //         ),
          //         ListTile(
          //           leading: Icon(Icons.access_time_filled),
          //           title: Text('Travel time: ' +
          //               travelTimeInMinutes.toStringAsFixed(0) +
          //               ' minutes'),
          //         ),
          //         GestureDetector(
          //           onTap: () {
          //             print("\n ## TAPPED ##");
          //             MapUtils.openMap(
          //                 widget.latLng.latitude, widget.latLng.longitude);
          //           },
          //           child: ListTile(
          //             tileColor: Colors.purple,
          //             leading: Icon(
          //               Icons.arrow_forward_rounded,
          //               color: Colors.white,
          //             ),
          //             title: Text(
          //               'GO THERE !',
          //               style: TextStyle(color: Colors.white),
          //             ),
          //           ),
          //         ),
          //       ],
          //     );
          //   },
          // );
        },
      ),
      onTap: () async {
        print("\n ## INFO WINDOW!!! ##");
        Dio dio = new Dio();
        Response response = await dio.get(
            "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=${CurrentUserPosition.latitude},${CurrentUserPosition.longitude}&destinations=${widget.latLng.latitude},${widget.latLng.longitude}&key=${MapKey.apiKeyDistanceMatrix}");
        //?- distance
        String distanceInMiles =
            response.data["rows"][0]["elements"][0]["distance"]["text"];
        distanceInMiles =
            distanceInMiles.substring(0, distanceInMiles.length - 3);
        // print("DISTANCE IN MILES: " + distanceInMiles);
        double distanceInKM = double.parse(distanceInMiles) * 1.60934;
        // print("DISTANCE IN KM: " + distanceInKM.toStringAsFixed(2));
        //?- travelTime
        String travelTime =
            response.data["rows"][0]["elements"][0]["duration"]["text"];
        double travelTimeInMinutes =
            double.parse(travelTime.substring(0, travelTime.length - 4));

        showModalBottomSheet(
          context: appKey.currentState!.context,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          builder: (context) {
            return Wrap(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
                  child: Container(
                    height: 50,
                    child: Center(
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
                ),
                ListTile(
                  leading: Icon(Icons.directions_car_filled),
                  title: Text('Exact distance by car: ' +
                      distanceInKM.toStringAsFixed(2) +
                      ' km'),
                ),
                ListTile(
                  leading: Icon(Icons.access_time_filled),
                  title: Text('Travel time: ' +
                      travelTimeInMinutes.toStringAsFixed(0) +
                      ' minutes'),
                ),
                GestureDetector(
                  onTap: () {
                    print("\n ## TAPPED ##");
                    MapUtils.openMap(
                        widget.latLng.latitude, widget.latLng.longitude);
                  },
                  child: ListTile(
                    tileColor: Colors.purple,
                    leading: Icon(
                      Icons.arrow_forward_rounded,
                      color: Colors.white,
                    ),
                    title: Text(
                      'GO THERE !',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    setState(() {
      markers[markerId] = marker;
      isAnimatedTextDisplayed = true;
    });
    print("\n ## Notify Parent! ##");

    widget.notifyParent();
    //!-- CHANGE THE ZOOM LEVEL ACCOUTING THE RADIUS OF THE QUERY HERE!
    if (rangeRadius == 1500) {
      widget.cameraUpdate_01();
    } else if (rangeRadius <= 5000) {
      widget.cameraUpdate_02();
    } else {
      widget.cameraUpdate_03();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(Constants.padding),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: contentBox(context),
    );
  }

  contentBox(context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(
              left: Constants.padding,
              top: Constants.avatarRadius + Constants.padding,
              right: Constants.padding,
              bottom: Constants.padding),
          margin: EdgeInsets.only(top: Constants.avatarRadius),
          decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: Colors.white,
              borderRadius: BorderRadius.circular(Constants.padding),
              boxShadow: [
                BoxShadow(
                    color: Colors.black, offset: Offset(0, 10), blurRadius: 10),
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.title,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              ),
              SizedBox(
                height: 15,
              ),
              Text(
                widget.descriptions,
                style: TextStyle(fontSize: 14, color: Colors.purple),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 22,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    // flex: 50,
                    child: Text(
                      "Rating:",
                      style: TextStyle(fontSize: 14),
                      textAlign: TextAlign.left,
                    ),
                  ),
                  Expanded(
                    // flex: 50,
                    child: Text(
                      widget.rating,
                      style: TextStyle(fontSize: 14, color: Colors.green),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).pop();
                      markers = <MarkerId, Marker>{};

                      _addMarker(widget.latLng);
                    },
                    child: Text(
                      widget.text,
                      style: TextStyle(fontSize: 18, color: Colors.purple),
                    )),
              ),
            ],
          ),
        ),
        Positioned(
          left: Constants.padding,
          right: Constants.padding,
          child: CircleAvatar(
            backgroundColor: Colors.transparent,
            radius: Constants.avatarRadius,
            child: ClipRRect(
                borderRadius:
                    BorderRadius.all(Radius.circular(Constants.avatarRadius)),
                child: Image.network(widget.img)),
          ),
        ),
      ],
    );
  }
}

class Constants {
  Constants._();
  static const double padding = 20;
  static const double avatarRadius = 45;
}
