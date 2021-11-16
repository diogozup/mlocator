import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mlocator/ui/constants/map_key.dart';

class NearcyLocationApi {
  // static NearcyLocationApi _instance;

  // NearcyLocationApi._();

  // static NearcyLocationApi get instance {
  //   if (_instance == null) {
  //     _instance = NearcyLocationApi._();
  //   }
  //   return _instance;
  // }

  // Future<List<Nearby>> getNearby({
  Future<List<dynamic>> getNearby({
    required Position userLocation,
    required double radius,
    required String type,
    required String keyword,
  }) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${userLocation.latitude},${userLocation.longitude}&radius=$radius&type=$type&keyword=$keyword&key=${MapKey.apiKey}';
    // http.Response response = await http.get(url);
    http.Response response = await http.get(Uri.parse(url));
    final values = jsonDecode(response.body);
    final List result = values['results'];
    print(result);
    // return result.map((e) => Nearby.fromJson(e)).toList();
    return result;
  }
}
