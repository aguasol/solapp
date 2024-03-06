import 'dart:typed_data';

class Ruta {
  final int id;
  final int conductorID;
  final int vehiculoID;

  List<Point> puntos;
  String? departamento;
  String? provincia;

  Ruta({
    required this.id,
    required this.nombre,
    required this.poligono,
    this.departamento = '',
    this.provincia = '',
    List<Point>? puntos,
  }) : puntos = puntos ?? [];
}
