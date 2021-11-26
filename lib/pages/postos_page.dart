import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mlocator/controllers/postos_controller.dart';
import 'package:mlocator/helpers/AuxiliarStrings.dart';
import 'package:mlocator/services/nearby_location_api.dart';
import 'package:provider/provider.dart';

final appKey = GlobalKey();
bool isAppWorking = false;
double rangeRadius = 13500;

class PostosPage extends StatelessWidget {
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
                initialCameraPosition: CameraPosition(
                  target: LatLng(local.lat, local.long),
                  zoom: 18,
                ),
                zoomControlsEnabled: true,
                mapType: MapType.normal,
                myLocationEnabled: true,
                onMapCreated: local.onMapCreated,
                markers: local.markers,
              ),
              Positioned(
                  bottom: 30,
                  left: 10,
                  child: GestureDetector(
                    onTap: () async {
                      if (!isAppWorking) {
                        isAppWorking = true;
                        print("\n ## TAPPED - Red Container ##");
                        print(CurrentUserPosition.latitude);
                        print(CurrentUserPosition.longitude);
                        var result = await NearcyLocationApi().getNearby(
                            userLocation: CurrentUserPosition,
                            radius: rangeRadius,
                            type: 'restaurants',
                            keyword: "McDonalds");
                        print("\n #### RESULT LENGHT ####");
                        print(result.length);
                        print(result[0]['place_id']);
                        print(result[0]['name']);
                        print(result[0]['vicinity']);
                        print(result[0]['user_ratings_total']);
                        print(result[0]['opening_hours']);
                        print(result[0]['opening_hours']['open_now']);

                        _displayAlertDialog(context, result);
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
                  )),
            ],
          );
        }),
      ),
    );
  }
}

Widget setupAlertDialoadContainer(List results) {
  return Container(
    height: 300.0,
    width: 300.0,
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: results.length,
      itemBuilder: (BuildContext context, int index) {
        return results[index]['name'] == "McDonald's"
            ? ListTile(
                leading: CircleAvatar(
                  radius: 30.0,
                  backgroundImage: AssetImage(Auxstrings.iconMacDonalds003),
                ),
                title: Text(results[index]['name']),
                subtitle: Text(results[index]['vicinity']),
                onTap: () {
                  print(results[index]['place_id']);
                },
              )
            : Container();
      },
    ),
  );
}

void _displayAlertDialog(BuildContext context, List results) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Opened Now!'),
          content: setupAlertDialoadContainer(results),
        );
      });
}
