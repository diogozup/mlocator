import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mlocator/controllers/postos_controller.dart';
import 'package:mlocator/helpers/AuxiliarStrings.dart';
import 'package:mlocator/helpers/CustomDialogBox.dart';
import 'package:mlocator/services/nearby_location_api.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

final appKey = GlobalKey();
bool isAppWorking = false;
double rangeRadius = 3500;
late BitmapDescriptor customIcon;
double currentZoom = 10.0;

Map<MarkerId, Marker> markers = <MarkerId, Marker>{};
LatLng latLng01 = LatLng(41.4472213, -8.2825556); // DUMMY_DATA

class PostosPage extends StatefulWidget {
  @override
  State<PostosPage> createState() => _PostosPageState();
}

class _PostosPageState extends State<PostosPage> {
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
        zoom: 10.0)));
  }

  changeZoomTo_11() {
    print("\n ## Change Zoom Value to 11! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 11.0)));
  }

  changeZoomTo_12() {
    print("\n ## Change Zoom Value to 12! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 12.0)));
  }

  changeZoomTo_13() {
    print("\n ## Change Zoom Value to 13! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 13.0)));
  }

  changeZoomTo_14() {
    print("\n ## Change Zoom Value to 14! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 14.0)));
  }

  changeZoomTo_15() {
    print("\n ## Change Zoom Value to 15! ##");
    mapsController.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target:
            LatLng(CurrentUserPosition.latitude, CurrentUserPosition.longitude),
        zoom: 15.0)));
  }

  refresh() {
    setState(() {});
  }

  _cleanMarkers() {
    setState(() {
      print("\n ## Clean Markers! ##");
      markers = <MarkerId, Marker>{};
    });
  }

  setCustomMarker() async {
    customIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(devicePixelRatio: 1.0), 'assets/maps/marker02.png');
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
        // _updateMarkerPositon(markerId, newPosition);
        // markers[markerId] = marker.copyWith(positionParam: LatLng(newPosition.latitude, newPosition.longitude));
      }),
      infoWindow: InfoWindow(
        title: markers.length == 0
            ? 'This is open now!'
            : 'CheckPoint - ' + markers.length.toString(),
        // snippet: markerIdVal,
        snippet: "Click here to delete this marker",

        onTap: () {
          // _deleteThisMarker(markerId);
          _cleanMarkers();
          print("\n ## DELETE THIS MARKER ##");
        },
      ),
      onTap: () {
        // _onMarkerTapped(markerId, latLng);
        print("\n ## INFO WINDOW ##");
      },
    );

    setState(() {
      markers[markerId] = marker;
    });
  }

  Set<Circle> circles = Set.from([
    Circle(
      circleId: CircleId('001'),
      center: LatLng(latLng01.latitude, latLng01.longitude),
      radius: 1000,
      fillColor: Colors.blue,
    ),
    Circle(
      circleId: CircleId('002'),
      center: LatLng(latLng01.latitude, latLng01.longitude),
      radius: 5000,
      fillColor: Colors.yellow.withOpacity(0.5),
    ),
    Circle(
      circleId: CircleId('003'),
      center: LatLng(latLng01.latitude, latLng01.longitude),
      radius: 10000,
      fillColor: Colors.red.withOpacity(0.5),
    )
  ]);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setCustomMarker();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: appKey,
      appBar: AppBar(
        title: Text('Currently Opened McDonalds'),
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
                circles: circles,
              ),
              Positioned(
                bottom: 30,
                left: 10,
                child: GestureDetector(
                  onTap: () async {
                    if (!isAppWorking) {
                      isAppWorking = true;
                      print("\n ## TAPPED - Red Container ##");
                      print(CurrentUserPosition.latitude.toString());
                      print(CurrentUserPosition.longitude.toString());
                      var result = await NearcyLocationApi().getNearby(
                          userLocation: CurrentUserPosition,
                          radius: rangeRadius,
                          type: 'restaurants',
                          keyword: "McDonalds");
                      print("\n #### RESULT LENGHT ####");
                      print(result.length.toString());
                      print(result[0]['place_id']);
                      print(result[0]['name']);
                      print(result[0]['vicinity']);
                      print(result[0]['user_ratings_total'].toString());
                      print(result[0]['opening_hours']);
                      print(result[0]['opening_hours']['open_now']);

                      _displayAlertDialog(
                          context, result, refresh, _cleanMarkers);
                      isAppWorking = false;
                    } else {
                      print("\n App is working !!");
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.red,
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                left: 10,
                child: GestureDetector(
                  onTap: () async {
                    print("\n ## TAPPED - Green Container ##");
                    _addMarker(latLng01);
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.green,
                  ),
                ),
              ),
              Positioned(
                bottom: 180,
                left: 10,
                child: GestureDetector(
                  onTap: () async {
                    print("\n ## TAPPED - Yellow Container ##");
                    _cleanMarkers();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.yellow,
                  ),
                ),
              ),
              Positioned(
                bottom: 250,
                left: 10,
                child: GestureDetector(
                  onTap: () async {
                    print("\n ## TAPPED - Orange Container ##");
                    currentZoom -= 1;
                    changeZoom(currentZoom);
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.orange,
                  ),
                ),
              ),
              Positioned(
                bottom: 330,
                left: 10,
                child: GestureDetector(
                  onTap: () async {
                    print("\n ## TAPPED - Purple Container ##");
                    currentZoom += 1;
                    changeZoom(currentZoom);
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.purple,
                  ),
                ),
              ),
              Positioned(
                bottom: 400,
                left: 10,
                child: GestureDetector(
                  onTap: () async {
                    print("\n ## TAPPED - Pink Container ##");

                    // changeZoom(9);
                    changeZoomTo_12();
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.pink,
                  ),
                ),
              ),
              Positioned(
                bottom: 480,
                left: 10,
                child: GestureDetector(
                  onTap: () async {
                    print("\n ## TAPPED - black Container ##");

                    print("\n ## The rangeRadius is:" + rangeRadius.toString());
                    print("\n ## The currentZoom is:" + currentZoom.toString());
                  },
                  child: Container(
                    height: 50,
                    width: 50,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

Widget setupAlertDialoadContainer(
    List results, dynamic refresh, dynamic cleanMarkers) {
  return Container(
    height: 300.0,
    width: 300.0,
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        return results[index]['name'] == "McDonald's" &&
                results[index]['opening_hours']['open_now'] == true
            ? ListTile(
                leading: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: AssetImage(Auxstrings.iconMacDonalds003),
                ),
                title: Text(results[index]['name']),
                subtitle: Text(results[index]['vicinity']),
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
                        );
                      });
                },
              )
            : Container();
      },
    ),
  );
}

void _displayAlertDialog(
    BuildContext context, List results, dynamic refresh, dynamic cleanMarkers) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Opened Now!'),
          content: setupAlertDialoadContainer(results, refresh, cleanMarkers),
        );
      });
}
