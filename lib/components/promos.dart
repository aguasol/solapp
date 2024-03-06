import 'package:appsol_final/models/producto_model.dart';
import 'package:appsol_final/components/pedido.dart';
import 'package:appsol_final/models/promocion_model.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/models/pedido_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProductoPromocion {
  final int promocionId;
  final int productoId;
  final int cantidadProd;
  final int? cantidadPromo;

  ProductoPromocion({
    required this.promocionId,
    required this.productoId,
    required this.cantidadProd,
    required this.cantidadPromo,
  });
}

class Promos extends StatefulWidget {
  const Promos({super.key});
  @override
  State<Promos> createState() => _PromosState();
}

class _PromosState extends State<Promos> {
  late PedidoModel pedidoMio;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  DateTime fechaLim = DateTime.now();
  List<Producto> productosContabilizados = [];
  List<Producto> productosProvider = [];
  List<Promo> promocionesContabilizadas = [];
  List<Promo> promosProvider = [];
  List<Promo> listPromociones = [];
  double totalProvider = 0.0;
  List<ProductoPromocion> prodPromContabilizadas = [];
  List<ProductoPromocion> listProdProm = [];
  int cantidadP = 0;
  bool almenosUno = false;
  int cantCarrito = 0;
  Color colorCantidadCarrito = Colors.black;

  @override
  void initState() {
    super.initState();
    getPromociones();
  }

  DateTime mesyAnio(String fecha) {
    fechaLim = DateTime.parse(fecha);
    return fechaLim;
  }

  Future<dynamic> getPromociones() async {
    var res = await http.get(
      Uri.parse('$apiUrl/api/promocion'),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Promo> tempPromocion = data.map<Promo>((mapa) {
          return Promo(
              id: mapa['id'],
              nombre: mapa['nombre'],
              precio: mapa['precio'].toDouble(),
              descripcion: mapa['descripcion'],
              fechaLimite: mapa['fecha_limite'],
              foto: '$apiUrl/images/${mapa['foto'].replaceAll(r'\\', '/')}');
        }).toList();
        
        if(mounted){
          setState(() {
          listPromociones = tempPromocion;
        });
        }
        
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

//MOVER A LA OTRA VISTA
  Future<dynamic> getProductoPromocion(promocionID, cantidadPromo) async {
    print("cantidad promo----${cantidadPromo}");
    var res = await http.get(
      Uri.parse('$apiUrl/api/prod_prom/' + promocionID.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<ProductoPromocion> tempProductoPromocion =
            data.map<ProductoPromocion>((mapa) {
          return ProductoPromocion(
            promocionId: mapa['promocion_id'],
            productoId: mapa['producto_id'],
            cantidadProd: mapa['cantidad'],
            cantidadPromo: cantidadPromo,
          );
        }).toList();

        setState(() {
          listProdProm = tempProductoPromocion;
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> getProducto(
      productoID, cantidadProdXProm, cantidadProm, promoID) async {
    ;

    var res = await http.get(
      Uri.parse('$apiUrl/api/products' + "/" + productoID.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Producto> tempProducto = data.map<Producto>((mapa) {
          return Producto(
              id: mapa['id'],
              precio: 0.0,
              nombre: mapa['nombre'],
              descripcion: mapa['descripcion'],
              foto: "",
              cantidad: cantidadProdXProm * cantidadProm,
              promoID: promoID);
        }).toList();

        setState(() {
          productosContabilizados.addAll(tempProducto);
          print("Prodctos contabilizados");
          print(productosContabilizados);
          //listProductos = tempProducto;
        });
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

//FUNCIONES DE SUMATORIA
  void incrementar(int index) {
    setState(() {
      almenosUno = true;
      listPromociones[index].cantidad++;
    });
  }

  void disminuir(int index) {
    setState(() {
      promocionesContabilizadas = [];

      if (listPromociones[index].cantidad > 0) {
        listPromociones[index].cantidad--;
      }
      promocionesContabilizadas =
          listPromociones.where((promocion) => promocion.cantidad > 0).toList();
      print("${promocionesContabilizadas.isEmpty} <--isEmpty?");
      almenosUno = promocionesContabilizadas.isNotEmpty;

      print("PContabilizados: ${promocionesContabilizadas}");
    });
  }

  double obtenerTotal() {
    double stotal = 0;
    promocionesContabilizadas =
        listPromociones.where((promo) => promo.cantidad > 0).toList();
    for (var promo in promocionesContabilizadas) {
      stotal += promo.cantidad * promo.precio;
    }
    return stotal;
  }

  Future<void> obtenerProducto() async {
    setState(() {
      prodPromContabilizadas = [];
    });

    for (var promo in promocionesContabilizadas) {
      await getProductoPromocion(promo.id, promo.cantidad);
      prodPromContabilizadas.addAll(listProdProm);
    }

    print(prodPromContabilizadas);
    setState(() {
      productosContabilizados = [];
    });

    for (var i = 0; i < prodPromContabilizadas.length; i++) {
      await getProducto(
          prodPromContabilizadas[i].productoId,
          prodPromContabilizadas[i].cantidadProd,
          prodPromContabilizadas[i].cantidadPromo,
          prodPromContabilizadas[i].promocionId);
    }
  }

  void esVacio(PedidoModel? pedido) {
    if (pedido is PedidoModel) {
      print('ES PEDIDOOO');
      cantCarrito = pedido.cantidadProd;
      productosProvider = pedido.seleccionados;
      promosProvider = pedido.seleccionadosPromo;
      totalProvider = pedido.total;
      if (pedido.cantidadProd > 0) {
        setState(() {
          colorCantidadCarrito = const Color.fromRGBO(255, 0, 93, 1.000);
        });
      } else {
        setState(() {
          colorCantidadCarrito = Colors.grey;
        });
      }
    } else {
      print('no es pedido');
      setState(() {
        cantCarrito = 0;
        productosProvider = [];
        promosProvider = [];
        colorCantidadCarrito = Colors.grey;
        totalProvider = 0.0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double total = obtenerTotal();
    //final TabController _tabController = TabController(length: 2, vsync: this);
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final pedidoProvider = context.watch<PedidoProvider>();
    esVacio(pedidoProvider.pedido);
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          toolbarHeight: largoActual * 0.08,
          actions: [
            Container(
              margin: EdgeInsets.only(
                  top: largoActual * 0.018, right: anchoActual * 0.045),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(0, 106, 252, 1.000),
                  borderRadius: BorderRadius.circular(50)),
              height: largoActual * 0.059,
              width: largoActual * 0.059,
              child: Badge(
                largeSize: 18,
                backgroundColor: colorCantidadCarrito,
                label: Text(cantCarrito.toString(),
                    style: const TextStyle(fontSize: 12)),
                child: IconButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Pedido()
                          //const Promos()
                          ),
                    );
                  },
                  icon: const Icon(Icons.shopping_cart_rounded),
                  color: Colors.white,
                  iconSize: largoActual * 0.030,
                ).animate().shakeY(
                      duration: Duration(milliseconds: 300),
                    ),
              ),
            ),
          ],
        ),
        body: SafeArea(
            child: Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, right: 10, bottom: 10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin:
                            EdgeInsets.only(top: 0, left: anchoActual * 0.055),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Llévate las mejores promos!",
                                    style: TextStyle(
                                        color: const Color.fromARGB(
                                            255, 1, 42, 76),
                                        fontWeight: FontWeight.w200,
                                        fontSize: largoActual * 0.027),
                                  ),
                                  Container(
                                    child: Text(
                                      "Solo para tí",
                                      style: TextStyle(
                                          color: const Color.fromARGB(
                                              255, 1, 46, 84),
                                          fontSize: largoActual * 0.026,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ]),
                      ),

                      //CONTAINER CON LIST BUILDER
                      SizedBox(
                          height: largoActual * 0.60,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: listPromociones.length,
                            itemBuilder: (context, index) {
                              Promo promocion = listPromociones[index];
                              return Card(
                                surfaceTintColor: Colors.white,
                                color: Colors.white,
                                elevation: 8,
                                margin: EdgeInsets.only(
                                    top: largoActual * 0.027,
                                    left: anchoActual * 0.028,
                                    right: anchoActual * 0.028,
                                    bottom: largoActual * 0.041),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: largoActual * 0.31,
                                      width: anchoActual * 0.55,
                                      margin: EdgeInsets.only(
                                          top: largoActual * 0.013),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          image: DecorationImage(
                                              image:
                                                  NetworkImage(promocion.foto),
                                              fit: BoxFit.scaleDown)),
                                    ),
                                    Container(
                                      width: anchoActual * 0.64,
                                      margin: EdgeInsets.only(
                                          top: largoActual * 0.013,
                                          right: anchoActual * 0.042,
                                          left: anchoActual * 0.042),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            promocion.nombre,
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: largoActual * 0.02,
                                                color: const Color.fromARGB(
                                                    255, 4, 62, 107)),
                                          ),
                                          Flex(
                                            direction: Axis.vertical,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Text(
                                                promocion.descripcion
                                                    .capitalize(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w300,
                                                    fontSize:
                                                        largoActual * 0.018,
                                                    color: const Color.fromARGB(
                                                        255, 4, 62, 107)),
                                              ),
                                            ],
                                          ),
                                          Text(
                                            "Val. Hasta: ${mesyAnio(promocion.fechaLimite).day.toString()}/${mesyAnio(promocion.fechaLimite).month.toString()}/${mesyAnio(promocion.fechaLimite).year.toString()}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: largoActual * 0.012,
                                                color: const Color.fromARGB(
                                                    255, 4, 62, 107)),
                                          ),
                                          Text(
                                            "S/.${promocion.precio} ",
                                            style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: largoActual * 0.022,
                                                color: const Color.fromARGB(
                                                    255, 4, 62, 107)),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            // mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    // cantidadP = producto.cantidad++;
                                                    disminuir(index);
                                                    print(
                                                        "disminuir ${promocion.cantidad}");
                                                  });
                                                },
                                                iconSize: largoActual * 0.041,
                                                color: const Color.fromARGB(
                                                    255, 0, 57, 103),
                                                icon: const Icon(
                                                  Icons.remove_circle,
                                                  color: Color.fromRGBO(
                                                      0, 170, 219, 1.000),
                                                ),
                                              ),
                                              Text(
                                                "${promocion.cantidad}",
                                                style: TextStyle(
                                                    color: const Color.fromARGB(
                                                        255, 4, 62, 107),
                                                    fontSize:
                                                        largoActual * 0.034,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    // cantidadP = producto.cantidad++;
                                                    incrementar(index);
                                                    print(
                                                        "incrementar ${promocion.cantidad}");
                                                  });
                                                },
                                                iconSize: largoActual * 0.041,
                                                color: const Color.fromARGB(
                                                    255, 0, 49, 89),
                                                icon: const Icon(
                                                  Icons.add_circle,
                                                  color: Color.fromRGBO(
                                                      0, 170, 219, 1.000),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          )),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            children: [
                              Container(
                                margin:
                                    EdgeInsets.only(left: anchoActual * 0.055),
                                child: Text(
                                  "Subtotal:",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: largoActual * 0.022,
                                      color:
                                          const Color.fromARGB(255, 1, 25, 44)),
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(left: anchoActual * 0.055),
                                child: Text(
                                  "S/.${total}",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w400,
                                      fontSize: largoActual * 0.027,
                                      color: const Color.fromARGB(
                                          255, 4, 62, 107)),
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Container(
                                margin:
                                    EdgeInsets.only(right: anchoActual * 0.055),
                                child: Text(
                                  "Agregar al carrito",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      fontSize: largoActual * 0.022,
                                      color:
                                          const Color.fromARGB(255, 1, 32, 56)),
                                ),
                              ),
                              Container(
                                margin:
                                    EdgeInsets.only(right: anchoActual * 0.055),
                                child: ElevatedButton(
                                    onPressed: almenosUno
                                        ? () async {
                                            await obtenerProducto();
                                            setState(() {
                                              if (productosProvider
                                                  .isNotEmpty) {
                                                if (productosContabilizados
                                                    .isNotEmpty) {
                                                  productosContabilizados
                                                      .addAll(
                                                          productosProvider);
                                                } else {
                                                  productosContabilizados =
                                                      productosProvider;
                                                }
                                              }
                                              promocionesContabilizadas
                                                  .addAll(promosProvider);
                                            });
                                            pedidoMio = PedidoModel(
                                                seleccionados:
                                                    productosContabilizados,
                                                seleccionadosPromo:
                                                    promocionesContabilizadas,
                                                cantidadProd:
                                                    productosContabilizados
                                                        .length,
                                                total: totalProvider + total);
                                            Provider.of<PedidoProvider>(context,
                                                    listen: false)
                                                .updatePedido(pedidoMio);
                                          }
                                        : null,
                                    style: ButtonStyle(
                                        elevation: MaterialStateProperty.all(8),
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color.fromRGBO(
                                                    120, 251, 99, 1.000))),
                                    child: const Icon(
                                      Icons.add_shopping_cart_rounded,
                                      color: Colors.white,
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ]))));
  }
}
