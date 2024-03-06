import 'package:appsol_final/models/producto_model.dart';
import 'package:appsol_final/models/promocion_model.dart';

class PedidoModel {
  final List<Producto> seleccionados;
  final List<Promo> seleccionadosPromo;
  final int cantidadProd;
  final double total;
  PedidoModel({
    required this.seleccionados,
    required this.seleccionadosPromo,
    required this.cantidadProd,
    required this.total,
  });

  /*factory PedidoModel() {
    return PedidoModel(
      seleccionados:[],
      seleccionadosPromo: [],
      total:0.0,
    );
  }*/
}
