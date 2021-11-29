import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mlocator/pages/postos_page.dart';
import 'package:mlocator/repositories/postos_repository.dart';
import 'package:mlocator/widgets/posto_detalhes.dart';

late Position CurrentUserPosition;
late GoogleMapController mapsController;

class PostosController extends ChangeNotifier {
  double lat = 0.0;
  double long = 0.0;
  String erro = '';
  Set<Marker> markers = Set<Marker>();

  // PostosController() {
  //   getPosicao();
  // }

  onMapCreated(GoogleMapController gmc) async {
    mapsController = gmc;
    getPosicao();
    loadPostos();
  }

  loadPostos() {
    final postos = PostosRepository().postos;
    postos.forEach((posto) async {
      markers.add(
        Marker(
          markerId: MarkerId(posto.nome),
          position: LatLng(posto.latitude, posto.longitude),
          icon: await BitmapDescriptor.fromAssetImage(
            ImageConfiguration(),
            'images/posto.png',
          ),
          onTap: () => {
            showModalBottomSheet(
              context: appKey.currentState!.context,
              builder: (context) => PostoDetalhes(posto: posto),
            )
          },
        ),
      );
    });
    notifyListeners();
  }

  getPosicao() async {
    try {
      Position posicao = await _posicaoAtual();
      lat = posicao.latitude;
      long = posicao.longitude;
      mapsController.animateCamera(CameraUpdate.newLatLng(LatLng(lat, long)));
      CurrentUserPosition = posicao;
    } catch (e) {
      erro = e.toString();
    }
    notifyListeners();
  }

  Future<Position> _posicaoAtual() async {
    LocationPermission permissao;

    bool ativado = await Geolocator.isLocationServiceEnabled();
    if (!ativado) {
      return Future.error('Por favor, habilite a localização no smartphone');
    }

    permissao = await Geolocator.checkPermission();
    if (permissao == LocationPermission.denied) {
      permissao = await Geolocator.requestPermission();
      if (permissao == LocationPermission.denied) {
        return Future.error('Você precisa autorizar o acesso à localização');
      }
    }

    if (permissao == LocationPermission.deniedForever) {
      return Future.error('Você precisa autorizar o acesso à localização');
    }

    return await Geolocator.getCurrentPosition();
  }
}
