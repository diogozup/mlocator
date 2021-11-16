import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mlocator/controllers/postos_controller.dart';
import 'package:mlocator/services/nearby_location_api.dart';
import 'package:provider/provider.dart';

final appKey = GlobalKey();

class PostosPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: appKey,
      appBar: AppBar(
        title: Text('Postos'),
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
                      print("\n ## TAPPED - Red Container ##");
                      print(CurrentUserPosition.latitude);
                      print(CurrentUserPosition.longitude);
                      var result = await NearcyLocationApi().getNearby(
                          userLocation: CurrentUserPosition,
                          radius: 1500,
                          type: 'restaurants',
                          keyword: "McDonalds");
                      print("\n #### RESULT LENGHT ####");
                      print(result.length);
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
