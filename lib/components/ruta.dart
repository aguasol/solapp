import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Ruta extends StatefulWidget {
  const Ruta({super.key});

  @override
  State<Ruta> createState() => _RutaState();
}

class _RutaState extends State<Ruta> {
  List listOfPoints = [];
  List<LatLng> points = [];

  @override
  void initState() {
    super.initState();
    getRoutes();
  }

  Future<dynamic> getRoutes() async {
    print("dentro---");
    String inicio = '-71.5816251,-16.4058187';
    String fin = '-71.5831701,-16.4033486';
    var res = await http.get(Uri.parse(
        'https://api.openrouteservice.org/v2/directions/driving-car?api_key=5b3ce3597851110001cf62489d018d87b8e24ddcb626d4ef311d7a33&start=-71.5816251,-16.4058187&end=-71.5831701,-16.4033486'));

    print("res");
    print(res);
    try {
      if (res.statusCode == 200) {
        var data = jsonDecode(res.body);
        print("respuesta óptima");
        listOfPoints = data['features'][0]['geometry']['coordinates'];
        points = listOfPoints
            .map((p) => LatLng(p[1].toDouble(), p[0].toDouble()))
            .toList();
      } else {
        print("Error en la solicitud HTTP: ${res.statusCode}");
        print("Cuerpo de la respuesta: ${res.body}");
      }
    } catch (e) {
      print('Error al decodificar la respuesta: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(8),
            child: FlutterMap(
                options: MapOptions(
                  initialCenter: LatLng(-16.4058187, -71.5816251),
                  initialZoom: 15.2,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                          point: LatLng(-16.4058187, -71.5816251),
                          child: FlutterLogo()),
                      Marker(
                          point: LatLng(-16.4033486, -71.5831701),
                          child: FlutterLogo()),
                    ],
                  ),
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: points,
                        color: Colors.blue,
                        strokeWidth: 5
                      ),
                    ],
                  ),
                ])),
      ),
    );
  }
}
