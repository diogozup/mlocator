import 'package:dio/dio.dart';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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
        snippet: "Click here to check details",

        onTap: () async {
          // _deleteThisMarker(markerId);
          // widget.cleanMarkers();
          print("\n ## DELETE MARKERS ##");
          print("\n\n ## DETAILS ##");
          Dio dio = new Dio();

          Response response = await dio.get(
              "https://maps.googleapis.com/maps/api/distancematrix/json?units=imperial&origins=40.6655101,-73.89188969999998&destinations=40.6905615%2C,-73.9976592&key=AIzaSyAQ7cjyXO5qkbUA_QBIVvYtaNEse8i_IJA");
          print(response.data);

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
                  ListTile(
                    leading: Icon(Icons.social_distance),
                    title: Text('Share'),
                  ),
                ],
              );
            },
          );
        },
      ),
      onTap: () {
        // _onMarkerTapped(markerId, latLng);
        print("\n ## INFO WINDOW!!! ##");
      },
    );

    setState(() {
      markers[markerId] = marker;
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
