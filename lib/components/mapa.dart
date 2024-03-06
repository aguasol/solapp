/*
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:app_final/components/test/camara.dart';

class Mapaprueba extends StatefulWidget {
  const Mapaprueba({super.key});

  @override
  State<Mapaprueba> createState() => _MapapruebaState();
}

class _MapapruebaState extends State<Mapaprueba> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              Container(
                child: ElevatedButton(onPressed: (){
                   Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Camara(
                        pedidoID: 1,
                        problemasOpago: 'problemas',
                      )),
            );
                },
                 child: Text("sigue")),
              ),
              Container(
                height: 100,
                width: 39,
                child: Text("MAPA"),
              ),
              Container(
                height: 300,
                width: 300,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(51.509364, -0.128928),
                    initialZoom: 9.2,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/