import 'dart:math';
import 'package:appsol_final/components/navegador.dart';
import 'package:appsol_final/components/pedido.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:location/location.dart' as location_package;
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:appsol_final/provider/pedido_provider.dart';
import 'package:appsol_final/provider/ubicacion_provider.dart';
import 'package:appsol_final/models/pedido_model.dart';
import 'package:appsol_final/models/ubicacion_model.dart';
import 'package:lottie/lottie.dart';
import 'package:appsol_final/models/zona_model.dart';

class Producto {
  final String nombre;
  final double precio;
  final String descripcion;

  final String foto;

  Producto(
      {required this.nombre,
      required this.precio,
      required this.descripcion,
      required this.foto});
}

class Hola2 extends StatefulWidget {
  final String? url;
  final String? loggedInWith;
  final int? clienteId;
  //final double? latitud;
  // final double? longitud;

  const Hola2({
    this.url,
    this.loggedInWith,
    this.clienteId,
    // this.latitud, // Nuevo campo
    // this.longitud, // Nuevo campo
    Key? key,
  }) : super(key: key);

  @override
  State<Hola2> createState() => _HolaState();
}

class _HolaState extends State<Hola2> with TickerProviderStateMixin {
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiZona = '/api/zona';
  List<Producto> listProducto = [];
  double? latitudUser = 0.0;
  double? longitudUser = 0.0;
  int? zonaIDUbicacion = 0;
  bool _isloading = false;
  int? clienteID = 0;
  List<UbicacionModel> listUbicacionesObjetos = [];
  List<String> ubicacionesString = [];
  String? _ubicacionSelected;
  late String? dropdownValue;
  late String? distrito;
  int cantCarrito = 0;
  double ganacia = 3.00;
  Color colorCantidadCarrito = Colors.black;
  Color colorLetra = const Color.fromARGB(255, 1, 42, 76);
  Color colorTextos = const Color.fromARGB(255, 1, 42, 76);
  late String direccion;
  late UbicacionModel miUbicacion;
  List<Zona> listZonas = [];
  List<String> tempString = [];
  Map<int, dynamic> mapaLineasZonas = {};
  //ACA SE DEBE ACTUALIZAR LA IMAGEN PARA COMPARTIR EN LOS ESTADOS
  String direccionImagenParaEstados = 'lib/imagenes/promocion.jpg';
  //ACA SE DEBE ACTUALIZAR EL LINK PARA DESCARGAR LA APPPPPP
  String urlPreview = 'https://youtu.be/bNKXxwOQYB8?si=d_Un1vXsQiPzMt3s';
  String tituloUbicacion = 'Gracias por compartir tu ubicación!';
  String contenidoUbicacion = '¡Disfruta de Agua Sol!';
  String mensajeCodigoParaAmigos =
      'Hola!,\nUsa mi código en la *app de 💧 Agua Sol 💧* para comprar un *BIDON DE AGUA NUEVO DE 20L a solo S/.10.00* usando mi código, además puedes _*GANAR S/. 4.00 💸*_ por cada persona que compre con tu código de referencia. \n✅ USA MI CODIGO DE REFERENCIA: \n⏬ Descarga la APP AQUÍ: ';

  //bool _disposed = false;
  //bool _autoScrollInProgress = false;

  ScrollController scrollController1 = ScrollController();
  ScrollController scrollController2 = ScrollController();
  DateTime fechaLimite = DateTime.now();

  DateTime mesyAnio(String? fecha) {
    if (fecha is String) {
      print('es string');
      return DateTime.parse(fecha);
    } else {
      print('no es string');
      return DateTime.now();
    }
  }

  @override
  void initState() {
    super.initState();
    ordenarFuncionesInit();
  }

  Future<void> ordenarFuncionesInit() async {
    await getUbicaciones(widget.clienteId);
    await getProducts();
    await getZonas();
  }

  Future<dynamic> getZonas() async {
    print('1) obteniendo las zonas de trabajo');
    var res = await http.get(
      Uri.parse(apiUrl + apiZona),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Zona> tempZona = data.map<Zona>((mapa) {
          return Zona(
            id: mapa['id'],
            nombre: mapa['nombre'],
            poligono: mapa['poligono'],
            departamento: mapa['departamento'],
          );
        }).toList();

        if (mounted) {
          setState(() {
            listZonas = tempZona;
            print('2) esta es la lista de zonas de trabajo');
            print(listZonas);
          });
          print('-----------------------------------');
          print('3) Revisando zona por zona');
          for (var i = 0; i < listZonas.length; i++) {
            print('zona Nª $i');
            setState(() {
              tempString = listZonas[i].poligono.split(',');
            });

            print(tempString);
            //el string 'poligono', se separa en strings por las comas en la lista
            //temString
            for (var j = 0; j < tempString.length; j++) {
              //luego se recorre la lista y se hacen puntos con cada dos numeros
              if (j % 2 == 0) {
                print('es par');
                //es multiplo de dos
                //SI ES PAR
                double x = double.parse(tempString[j]);
                double y = double.parse(tempString[j + 1]);
                print('$x y $y');
                setState(() {
                  print('entro al set Statw');
                  listZonas[i].puntos.add(Point(x, y));
                });
              }
            }
            print('se llenaron los puntos de esta zona');
            print(listZonas[i].puntos);
          }

          //AHORA DE ACUERDO A LA CANTIDAD DE PUTNOS QUE HAY EN LA LISTA DE PUNTOS SE CALCULA LA CANTIDAD
          //DE LINEAS CON LAS QUE S ETRABAJA
          for (var i = 0; i < listZonas.length; i++) {
            print('entro al for que revisa zona por zona');
            var zonaID = listZonas[i].id;
            print('esta en la ubicación = $i, con zona ID = $zonaID');
            setState(() {
              print(
                  'se crea la key zon ID, con un valor igual a un mapa vacio');
              mapaLineasZonas[zonaID] = {};
            });

            for (var j = 0; j < listZonas[i].puntos.length; j++) {
              print(
                  'revisa punto por punto en la lista de puntos de cada zona');
              print('zonaID = $zonaID y punto Nº = $j');
              //ingresa a un for en el que se obtienen los datos de todas la lineas que forman los puntos del polígono
              if (j == listZonas[i].puntos.length - 1) {
                print('-- esta en el ultimo punto');
                print('se hallan las propiedades de la linea');
                Point punto1 = listZonas[i].puntos[j];
                Point punto2 = listZonas[i].puntos[0];
                var maxX = max(punto1.x, punto2.x);
                var maxY = max(punto1.y, punto2.y);
                var minY = min(punto1.y, punto2.y);
                var pendiente = (punto2.y - punto1.y) / (punto2.x - punto1.x);
                var constante = punto1.y - (pendiente * punto1.x);
                Map lineaTemporal = {
                  "punto1": punto1,
                  "punto2": punto2,
                  "maxX": maxX,
                  "maxY": maxY,
                  "minY": minY,
                  "pendiente": pendiente,
                  "constante": constante
                };
                print('$lineaTemporal');

                setState(() {
                  mapaLineasZonas[zonaID][j] = lineaTemporal;
                });
              } else {
                print('se hallan las propiedades de la linea');
                Point punto1 = listZonas[i].puntos[j];
                Point punto2 = listZonas[i].puntos[j + 1];
                var maxX = max(punto1.x, punto2.x);
                var maxY = max(punto1.y, punto2.y);
                var minY = min(punto1.y, punto2.y);
                var pendiente = (punto2.y - punto1.y) / (punto2.x - punto1.x);
                var constante = punto1.y - (pendiente * punto1.x);
                Map lineaTemporal = {
                  "punto1": punto1,
                  "punto2": punto2,
                  "maxX": maxX,
                  "maxY": maxY,
                  "minY": minY,
                  "pendiente": pendiente,
                  "constante": constante
                };
                print('$lineaTemporal');
                setState(() {
                  mapaLineasZonas[zonaID][j] = lineaTemporal;
                });
              }
            }
          }
        }
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> getUbicaciones(clienteID) async {
    print("1) get ubicaciones---------");
    print("$apiUrl/api/ubicacion/$clienteID");
    var res = await http.get(
      Uri.parse("$apiUrl/api/ubicacion/$clienteID"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        print("2) entro al try de get ubicaciones---------");
        var data = json.decode(res.body);
        List<UbicacionModel> tempUbicacion = data.map<UbicacionModel>((mapa) {
          return UbicacionModel(
              id: mapa['id'],
              latitud: mapa['latitud'].toDouble(),
              longitud: mapa['longitud'].toDouble(),
              direccion: mapa['direccion'],
              clienteID: mapa['cliente_id'],
              clienteNrID: null,
              distrito: mapa['distrito'],
              zonaID: mapa['zona_trabajo_id'] ?? 0);
        }).toList();
        if (mounted) {
          setState(() {
            listUbicacionesObjetos = tempUbicacion;
            print(listUbicacionesObjetos);
          });
          for (var i = 0; i < listUbicacionesObjetos.length; i++) {
            setState(() {
              ubicacionesString.add(listUbicacionesObjetos[i].direccion);
            });
          }
        }
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<dynamic> creadoUbicacion(clienteId, distrito) async {
    await http.post(Uri.parse("$apiUrl/api/ubicacion"),
        headers: {"Content-type": "application/json"},
        body: jsonEncode({
          "latitud": latitudUser,
          "longitud": longitudUser,
          "direccion": direccion,
          "cliente_id": clienteId,
          "cliente_nr_id": null,
          "distrito": distrito,
          "zona_trabajo_id": zonaIDUbicacion
        }));
  }

  Future<void> obtenerDireccion(x, y) async {
    print("¡¡Entro a obtenerDireccion!!");
    List<Placemark> placemark = await placemarkFromCoordinates(x, y);
    try {
      if (placemark.isNotEmpty) {
        Placemark lugar = placemark.first;
        setState(() {
          direccion =
              "${lugar.locality}, ${lugar.subAdministrativeArea}, ${lugar.street}";
          setState(() {
            distrito = lugar.locality;
          });
        });
      } else {
        direccion = "Default";
      }
      print("x-----y");
      print("${x},${y}");
      await puntoEnPoligono(x, y);
    } catch (e) {
      //throw Exception("Error ${e}");
      // Manejo de errores, puedes mostrar un mensaje al usuario indicando que hubo un problema al obtener la ubicación.
      print("Error al obtener la ubicación: $e");
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text(
              'Error de Ubicación',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            content: Text(
              'Hubo un problema al obtener la ubicación. Por favor, inténtelo de nuevo.',
              style: TextStyle(fontSize: 16),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Cierra el AlertDialog
                  setState(() {
                    _isloading = false;
                  });
                },
                child: const Text(
                  'OK',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                ),
              ),
            ],
          );
        },
      );
    } finally {
      setState(() {
        latitudUser = x;
        longitudUser = y;
        _isloading = false;
        print('esta es la zonaID $zonaIDUbicacion');
        creadoUbicacion(widget.clienteId, distrito);
      });
    }
  }

  Future<void> currentLocation() async {
    print("¡¡Entro al CurrectLocation!!");
    var location = location_package.Location();
    location_package.PermissionStatus permissionGranted;
    location_package.LocationData locationData;

    setState(() {
      _isloading = true;
      print("_isloadin = $_isloading");
    });

    // Verificar si el servicio de ubicación está habilitado
    var serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      // Solicitar habilitación del servicio de ubicación
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        // Mostrar mensaje al usuario indicando que el servicio de ubicación es necesario
        setState(() {
          _isloading = true;
        });
        return;
      }
    }

    // Verificar si se otorgaron los permisos de ubicación
    permissionGranted = await location.hasPermission();
    if (permissionGranted == location_package.PermissionStatus.denied) {
      // Solicitar permisos de ubicación
      permissionGranted = await location.requestPermission();
      if (permissionGranted != location_package.PermissionStatus.granted) {
        // Mostrar mensaje al usuario indicando que los permisos de ubicación son necesarios
        return;
      }
    }

    // Obtener la ubicación
    try {
      locationData = await location.getLocation();

      //updateLocation(locationData);
      await obtenerDireccion(locationData.latitude, locationData.longitude);

      print("ubicación - $locationData");
      print("latitud - $latitudUser");
      print("longitud - $longitudUser");

      // Aquí puedes utilizar la ubicación obtenida (locationData)
    } catch (e) {
      // Manejo de errores, puedes mostrar un mensaje al usuario indicando que hubo un problema al obtener la ubicación.
      print("Error al obtener la ubicación: $e");
    }
  }

  Future puntoEnPoligono(double? xA, double? yA) async {
    print('----------------------------------------');
    print('----------------------------------------');
    print('¡¡ENTRO A PUNTO EN POLIGONO!!');
    if (xA is double && yA is double) {
      print('1) son double, se recorre las zonas');
      for (var i = 0; i < listZonas.length; i++) {
        var zonaID = listZonas[i].id;
        print('zonaID = $zonaID');
        mapaLineasZonas[zonaID].forEach((value, mapaLinea) {
          print('Ingreso a recorrer las lineas de la zona $zonaID');
          if (xA <= mapaLinea["maxX"] &&
              mapaLinea['minY'] <= yA &&
              yA <= mapaLinea['maxY']) {
            print('- Cumple todas estas');
            print('- $xA <= ${mapaLinea["maxX"]}');
            print('- ${mapaLinea['minY']} <= $yA');
            print('- $yA<= ${mapaLinea['maxY']}');
            print('');
            var xInterseccion =
                (yA - mapaLinea['constante']) / mapaLinea['pendiente'];
            print('Se calcula la xInterseccion');
            print(
                'xI = ($yA - ${mapaLinea['constante']})/${mapaLinea['pendiente']} = $xInterseccion');
            if (xA <= xInterseccion) {
              //EL PUNTO INTERSECTA A LA LINEA
              print('- el punto intersecta la linea hacia la deresha');
              print('- $xA <= $xInterseccion');
              print('');
              setState(() {
                mapaLinea['intersecciones'] = 1;
              });
            }
          }
        });
      }
      //SE CUENTA LA CANTIDAD DE INTERSECCIONES EN CADA ZONA
      for (var i = 0; i < listZonas.length; i++) {
        //se revisa para cada zona
        print('');
        print('');
        print('Ahora se cuenta la cantidad de intersecciones');
        var zonaID = listZonas[i].id;
        print('Primero en la zona $zonaID');
        int intersecciones = 0;
        mapaLineasZonas[zonaID].forEach((key, mapaLinea) {
          if (mapaLinea['intersecciones'] == 1) {
            intersecciones += 1;
          }
        });
        if (intersecciones > 0) {
          print('Nª intersecciones = $intersecciones en la Zona $zonaID');
          if (intersecciones % 2 == 0) {
            print('- Es una cantidad PAR, ESTA AFUERA');
            setState(() {
              zonaIDUbicacion = null;
            });
          } else {
            setState(() {
              print('- Es una cantidad IMPAR, ESTA DENTRO');
              zonaIDUbicacion = zonaID;
            });
            //es impar ESTA AFUERA
          }
          print('');
        } else {
          print('No tiene intersecciones');
          setState(() {
            zonaIDUbicacion = null;
          });
          print('');
        }
      }
    }
  }

  Future<dynamic> getProducts() async {
    print("3) get products---------");
    var res = await http.get(
      Uri.parse("$apiUrl/api/products"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Producto> tempProducto = data.map<Producto>((mapa) {
          return Producto(
            nombre: mapa['nombre'],
            precio: mapa['precio'].toDouble(),
            descripcion: mapa['descripcion'],
            foto: '$apiUrl/images/${mapa['foto']}',
          );
        }).toList();

        // VERIFICAR SI EL WIDGET EXISTE Y LUEGO SETEAMOS EL VALOR
        if (mounted) {
          setState(() {
            listProducto = tempProducto;
            //conductores = tempConductor;
          });
        }

        print("4) ....lista productos");
        //print(listProducto[0].foto);
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  void esVacio(PedidoModel? pedido) {
    if (pedido is PedidoModel) {
      print('ES PEDIDOOO');
      cantCarrito = pedido.cantidadProd;
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
        colorCantidadCarrito = Colors.grey;
      });
    }
  }

  void direccionesVacias() {
    if (listUbicacionesObjetos.isEmpty) {
      setState(() {
        dropdownValue = "";
      });
    } else {
      setState(() {
        dropdownValue = listUbicacionesObjetos.first.direccion;
        miUbicacion = listUbicacionesObjetos.first;
      });
    }
  }

  UbicacionModel direccionSeleccionada(String direccion) {
    UbicacionModel ubicacionObjeto = UbicacionModel(
        id: 0,
        latitud: 0,
        longitud: 0,
        direccion: 'direccion',
        clienteID: 0,
        clienteNrID: 0,
        distrito: 'distrito',
        zonaID: 0);
    for (var i = 0; i < listUbicacionesObjetos.length; i++) {
      if (listUbicacionesObjetos[i].direccion == direccion) {
        setState(() {
          ubicacionObjeto = listUbicacionesObjetos[i];
        });
      }
    }
    return ubicacionObjeto;
  }
  // TEST UBICACIONES PARA DROPDOWN

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final TabController _tabController = TabController(length: 2, vsync: this);
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    final pedidoProvider = context.watch<PedidoProvider>();
    final userProvider = context.watch<UserProvider>();
    fechaLimite = mesyAnio(userProvider.user?.fechaCreacionCuenta)
        .add(const Duration(days: (30 * 3)));
    direccionesVacias();
    esVacio(pedidoProvider.pedido);
    print("ya esta corriendo el widget");
    print(listUbicacionesObjetos);
    return Scaffold(
        backgroundColor: Colors.white,
        body: PopScope(
          canPop: false,
          onPopInvoked: (bool didPop) {
            if (didPop) {
              return;
            }
          },
          child: SafeArea(
              key: _scaffoldKey,
              child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        //CONTAINER DE UBICACION Y CARRITO
                        Container(
                          width: anchoActual,
                          margin: EdgeInsets.only(
                              left: anchoActual * 0.028,
                              right: anchoActual * 0.028),
                          //color: Colors.red,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              //LOCATION
                              Container(
                                width: MediaQuery.of(context).size.width / 1.4,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  children: [
                                    Container(
                                      width: anchoActual * 0.7,
                                      decoration: BoxDecoration(
                                        color: const Color.fromRGBO(
                                            83, 176, 68, 1.000),
                                        borderRadius: BorderRadius.circular(15),
                                      ),
                                      child: Container(
                                        //color: Colors.amberAccent,
                                        margin: const EdgeInsets.only(
                                            left: 12, right: 5),
                                        child: DropdownButton<String>(
                                          hint: Text(
                                            '¿A dónde llevamos tu pedido?',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: largoActual * 0.018,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          icon: IconButton(
                                            onPressed: () {
                                              showModalBottomSheet(
                                                backgroundColor:
                                                    const Color.fromRGBO(
                                                        0, 106, 252, 1.000),
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  return Container(
                                                    margin: EdgeInsets.only(
                                                        top:
                                                            largoActual * 0.041,
                                                        left:
                                                            anchoActual * 0.055,
                                                        right: anchoActual *
                                                            0.055),
                                                    height: largoActual * 0.17,
                                                    width: anchoActual,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                          margin:
                                                              const EdgeInsets
                                                                  .only(
                                                                  left: 10),
                                                          child: Text(
                                                            'Agregar Ubicación',
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  largoActual *
                                                                      0.023,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                largoActual *
                                                                    0.013),
                                                        ElevatedButton(
                                                          onPressed: () async {
                                                            setState(() {
                                                              _isloading = true;
                                                            });
                                                            await currentLocation();

                                                            // ignore: use_build_context_synchronously
                                                            Navigator.pop(
                                                                // ignore: use_build_context_synchronously
                                                                context);
                                                          },
                                                          style: ButtonStyle(
                                                            surfaceTintColor:
                                                                MaterialStateProperty
                                                                    .all(Colors
                                                                        .white),
                                                            elevation:
                                                                MaterialStateProperty
                                                                    .all(8),
                                                            minimumSize:
                                                                MaterialStatePropertyAll(Size(
                                                                    anchoActual *
                                                                        0.28,
                                                                    largoActual *
                                                                        0.054)),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(Colors
                                                                        .white),
                                                          ),
                                                          child: Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children:
                                                                  _isloading
                                                                      ? [
                                                                          const CircularProgressIndicator(
                                                                            color: Color.fromRGBO(
                                                                                0,
                                                                                106,
                                                                                252,
                                                                                1.000),
                                                                            strokeWidth:
                                                                                3,
                                                                          ),
                                                                        ]
                                                                      : [
                                                                          Icon(
                                                                            Icons.add_location_alt_rounded,
                                                                            color: const Color.fromRGBO(
                                                                                0,
                                                                                106,
                                                                                252,
                                                                                1.000),
                                                                            size:
                                                                                largoActual * 0.034,
                                                                          ),
                                                                          Text(
                                                                            ' Agregar ubicación actual',
                                                                            style: TextStyle(
                                                                                fontSize: largoActual * 0.021,
                                                                                fontWeight: FontWeight.w500,
                                                                                color: const Color.fromRGBO(0, 106, 252, 1.000)),
                                                                          ),
                                                                        ]),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                            icon: Icon(
                                                Icons.add_location_alt_rounded,
                                                size: largoActual * 0.031,
                                                color: Colors.white),
                                          ),
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: largoActual * 0.018,
                                              fontWeight: FontWeight.w500),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          elevation: 20,
                                          dropdownColor: const Color.fromRGBO(
                                              83, 176, 68, 1.000),
                                          isExpanded: true,
                                          value: _ubicacionSelected,
                                          items: ubicacionesString
                                              .map((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                          onChanged: (String? newValue) {
                                            if (newValue is String) {
                                              if (direccionSeleccionada(
                                                          newValue)
                                                      .zonaID ==
                                                  0) {
                                                setState(() {
                                                  tituloUbicacion =
                                                      'Lo sentimos :(';
                                                  contenidoUbicacion =
                                                      'Todavía no llegamos a tu zona, pero puedes revisar nuestros productos en la aplicación o elegir otra ubicación :D';
                                                });
                                                showDialog(
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      backgroundColor:
                                                          Colors.white,
                                                      surfaceTintColor:
                                                          Colors.white,
                                                      title: Text(
                                                        tituloUbicacion,
                                                        style: TextStyle(
                                                            fontSize:
                                                                largoActual *
                                                                    0.026,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.black),
                                                      ),
                                                      content: Text(
                                                        contenidoUbicacion,
                                                        style: TextStyle(
                                                            fontSize:
                                                                largoActual *
                                                                    0.018,
                                                            fontWeight:
                                                                FontWeight
                                                                    .w400),
                                                      ),
                                                      actions: <Widget>[
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(); // Cierra el AlertDialog
                                                          },
                                                          child: Text(
                                                            'OK',
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                fontSize:
                                                                    largoActual *
                                                                        0.02,
                                                                color: Colors
                                                                    .black),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                );
                                              } else {
                                                Provider.of<UbicacionProvider>(
                                                        context,
                                                        listen: false)
                                                    .updateUbicacion(
                                                        miUbicacion);
                                                setState(() {
                                                  _ubicacionSelected = newValue;
                                                  miUbicacion =
                                                      direccionSeleccionada(
                                                          newValue);
                                                });
                                              }
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().shakeX(
                                    duration: Duration(milliseconds: 300),
                                  ),

                              //CARRITO
                              Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: const Color.fromRGBO(
                                        0, 106, 252, 1.000),
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
                                        MaterialPageRoute(
                                            builder: (context) => const Pedido()
                                            //const Promos()
                                            ),
                                      );
                                    },
                                    icon:
                                        const Icon(Icons.shopping_cart_rounded),
                                    color: Colors.white,
                                    iconSize: largoActual * 0.030,
                                  ).animate().shakeY(
                                        duration: Duration(milliseconds: 300),
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        //BIENVENIDA DEL CLIENTE
                        Container(
                          width: anchoActual,
                          margin: EdgeInsets.only(
                              left: anchoActual * 0.055,
                              top: largoActual * 0.016),
                          child: Text(
                            "Bienvenid@, ${userProvider.user?.nombre.capitalize()}",
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: largoActual * 0.019,
                                color: colorLetra),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(left: anchoActual * 0.055),
                          child: Text(
                            "Disfruta de Agua Sol!",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: largoActual * 0.019,
                                color: colorTextos),
                          ),
                        ),
                        SizedBox(
                          height: largoActual * 0.016,
                        ),
                        //TAB BAR PRODUCTOS/PROMOCIONES
                        SizedBox(
                          height: largoActual * 0.046,
                          width: anchoActual,
                          child: TabBar(
                              indicatorSize: TabBarIndicatorSize.label,
                              controller: _tabController,
                              indicatorWeight: 10,
                              /*indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Color.fromRGBO(120, 251, 99, 0.5),
                              ),*/
                              labelStyle: TextStyle(
                                  fontSize: largoActual * 0.019,
                                  fontWeight: FontWeight
                                      .w500), // Ajusta el tamaño del texto de la pestaña seleccionada
                              unselectedLabelStyle: TextStyle(
                                  fontSize: largoActual * 0.019,
                                  fontWeight: FontWeight.w300),
                              labelColor: colorTextos,
                              unselectedLabelColor: colorTextos,
                              indicatorColor:
                                  const Color.fromRGBO(83, 176, 68, 1.000),
                              tabs: const [
                                Tab(
                                  text: "Promociones",
                                ),
                                Tab(
                                  text: "Productos",
                                ),
                              ]),
                        ),
                        //IMAGENES DE PRODUCTOS Y PROMOCIONES TAB BAR
                        Container(
                          margin: EdgeInsets.only(
                            top: largoActual * 0.013,
                          ),
                          height: largoActual / 2.5,
                          width: double.maxFinite,
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              ListView.builder(
                                  controller: scrollController1,
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 5,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BarraNavegacion(
                                                    indice: 0,
                                                    subIndice: 1,
                                                  )
                                              //const Promos()
                                              ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: anchoActual * 0.028),
                                        height: anchoActual * 0.83,
                                        width: anchoActual * 0.83,
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 130, 219, 133),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: const DecorationImage(
                                              image: AssetImage(
                                                  'lib/imagenes/bodegon.png'),
                                              fit: BoxFit.cover,
                                            )),
                                      ),
                                    );
                                  }),
                              ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  controller: scrollController2,
                                  itemCount: listProducto.length,
                                  itemBuilder: (context, index) {
                                    Producto producto = listProducto[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const BarraNavegacion(
                                                    indice: 0,
                                                    subIndice: 2,
                                                  )
                                              //const Productos()
                                              ),
                                        );
                                      },
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            right: anchoActual * 0.028),
                                        height: anchoActual * 0.83,
                                        width: anchoActual * 0.83,
                                        decoration: BoxDecoration(
                                            color: const Color.fromARGB(
                                                255, 130, 219, 133),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            image: DecorationImage(
                                              image:
                                                  NetworkImage(producto.foto),
                                              fit: BoxFit.fitHeight,
                                            )),
                                      ),
                                    );
                                  }),
                            ],
                          ),
                        ),
                        //Expanded(child: Container()),
                        SizedBox(
                          height: largoActual * 0.03,
                        ),
                        //BILLETERA SOL
                        Container(
                          margin: EdgeInsets.only(left: anchoActual * 0.055),
                          child: Text(
                            "Billetera Sol",
                            style: TextStyle(
                                color: colorTextos,
                                fontWeight: FontWeight.w500,
                                fontSize: largoActual * 0.019),
                          ),
                        ),
                        SizedBox(
                          height: largoActual * 0.009,
                        ),
                        SizedBox(
                          height: largoActual * 0.16,
                          child: Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              surfaceTintColor: Colors.white,
                              color: Colors.white,
                              elevation: 10,
                              child: OutlinedButton(
                                style: const ButtonStyle(
                                    shape: MaterialStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                    ),
                                    side: MaterialStatePropertyAll(
                                        BorderSide.none)),
                                onPressed: () {
                                  showDialog(
                                      context: context,
                                      barrierColor:
                                          Colors.black.withOpacity(0.8),
                                      builder: (BuildContext context) {
                                        return Dialog(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                          insetPadding: EdgeInsets.all(
                                            0,
                                          ),
                                          backgroundColor: Colors.transparent,
                                          surfaceTintColor: Colors.transparent,
                                          child: Stack(
                                              clipBehavior: Clip.none,
                                              alignment: Alignment.center,
                                              children: [
                                                //CONTAINER CON INFO DE LA PROMOOO
                                                Container(
                                                  height: largoActual * 0.64,
                                                  width: anchoActual * 0.8,
                                                  decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              15),
                                                      gradient:
                                                          const LinearGradient(
                                                              colors: [
                                                            Color.fromRGBO(
                                                                0,
                                                                106,
                                                                252,
                                                                1.000),
                                                            Color.fromRGBO(
                                                                0,
                                                                106,
                                                                252,
                                                                1.000),
                                                            Color.fromRGBO(
                                                                0,
                                                                106,
                                                                252,
                                                                1.000),
                                                            Color.fromRGBO(150,
                                                                198, 230, 1),
                                                            Colors.white,
                                                            Colors.white,
                                                          ],
                                                              begin: Alignment
                                                                  .topLeft,
                                                              end: Alignment
                                                                  .bottomCenter)),
                                                  child: Container(
                                                    margin: EdgeInsets.all(
                                                        anchoActual * 0.06),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        //ESPACIO PARA QUE EL TEXTO NO SE TAPE CON LAS IMAGENES
                                                        SizedBox(
                                                          height: largoActual *
                                                              0.15,
                                                        ),
                                                        //TEXTO QUIERES GANAR MONI
                                                        Text(
                                                          '¿Quieres ganar dinero sin salir de tu hogar?',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  largoActual *
                                                                      0.03,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        //TEXTO CON AGUA SOL PUEDES LOGRARLO
                                                        Text(
                                                          '¡Con Agua Sol puedes lograrlo!',
                                                          style: TextStyle(
                                                              fontStyle:
                                                                  FontStyle
                                                                      .italic,
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  largoActual *
                                                                      0.025,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400),
                                                        ),
                                                        //ESPACIOOO
                                                        SizedBox(
                                                            height:
                                                                largoActual *
                                                                    0.06),
                                                        //TEXTO EXPLICATIVO
                                                        RichText(
                                                            text: TextSpan(
                                                                style: TextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .normal,
                                                                    color:
                                                                        colorLetra,
                                                                    fontSize:
                                                                        largoActual *
                                                                            0.021,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                                children: [
                                                              const TextSpan(
                                                                  text:
                                                                      'Puedes '),
                                                              TextSpan(
                                                                  text:
                                                                      'GANAR S/. ${ganacia}0 ',
                                                                  style: const TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800)),
                                                              const TextSpan(
                                                                  text:
                                                                      'por cada '),
                                                              const TextSpan(
                                                                  text:
                                                                      'Bidon Nuevo ',
                                                                  style: TextStyle(
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800)),
                                                              const TextSpan(
                                                                  text: 'que '),
                                                              const TextSpan(
                                                                  text:
                                                                      'compren ',
                                                                  style: TextStyle(
                                                                      fontStyle:
                                                                          FontStyle
                                                                              .italic,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w800)),
                                                              const TextSpan(
                                                                  text:
                                                                      'tus contactos con tu código.'),
                                                            ])),
//ESPACIOOO
                                                        SizedBox(
                                                            height:
                                                                largoActual *
                                                                    0.07),
//BOTON COMPARTE
                                                        SizedBox(
                                                          height: largoActual *
                                                              0.04,
                                                          child: OutlinedButton(
                                                              style:
                                                                  const ButtonStyle(
                                                                      shape:
                                                                          MaterialStatePropertyAll(
                                                                        RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(10))),
                                                                      ),
                                                                      side: MaterialStatePropertyAll(
                                                                          BorderSide
                                                                              .none)),
                                                              onPressed:
                                                                  () async {
                                                                await Share.share(
                                                                    mensajeCodigoParaAmigos +
                                                                        urlPreview);
                                                              },
                                                              child: Text(
                                                                'COMPARTE TU CÓDIGO',
                                                                style: TextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .normal,
                                                                    color:
                                                                        colorTextos,
                                                                    fontSize:
                                                                        largoActual *
                                                                            0.015,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              )),
                                                        ),

                                                        //BOTON PARA PUBLICARLO EN TU ESTADO
                                                        SizedBox(
                                                          height: largoActual *
                                                              0.04,
                                                          child: OutlinedButton(
                                                              style:
                                                                  const ButtonStyle(
                                                                      shape:
                                                                          MaterialStatePropertyAll(
                                                                        RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.all(Radius.circular(10))),
                                                                      ),
                                                                      side: MaterialStatePropertyAll(
                                                                          BorderSide
                                                                              .none)),
                                                              onPressed:
                                                                  () async {
                                                                final image =
                                                                    await rootBundle
                                                                        .load(
                                                                            direccionImagenParaEstados);
                                                                final buffer =
                                                                    image
                                                                        .buffer;
                                                                final temp =
                                                                    await getTemporaryDirectory();
                                                                final path =
                                                                    '${temp.path}/image.jpg';

                                                                await Share
                                                                    .shareXFiles(
                                                                  [
                                                                    XFile
                                                                        .fromData(
                                                                      buffer
                                                                          .asUint8List(
                                                                        image
                                                                            .offsetInBytes,
                                                                        image
                                                                            .lengthInBytes,
                                                                      ),
                                                                      mimeType:
                                                                          'image/jpg',
                                                                      name:
                                                                          'usaMiCodigo',
                                                                    )
                                                                  ],
                                                                  subject:
                                                                      'mi codigo',
                                                                );
                                                              },
                                                              child: Text(
                                                                'PUBLÍCALO EN TU ESTADO',
                                                                style: TextStyle(
                                                                    fontStyle:
                                                                        FontStyle
                                                                            .normal,
                                                                    color:
                                                                        colorTextos,
                                                                    fontSize:
                                                                        largoActual *
                                                                            0.015,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w400),
                                                              )),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                                //ANIMACION PALMERAS
                                                Positioned(
                                                  top: -largoActual * 0.08,
                                                  left: anchoActual * 0.035,
                                                  height: largoActual * 0.23,
                                                  child: Lottie.asset(
                                                      'lib/imagenes/palmeras1.json'),
                                                ),

                                                //ANIMACION PLAYERA
                                                Positioned(
                                                  top: -largoActual * 0.08,
                                                  left: anchoActual * 0.035,
                                                  height: largoActual * 0.23,
                                                  child: Lottie.asset(
                                                      'lib/imagenes/playa1.json'),
                                                ),
                                                //ANIMACION PALMERAS
                                                Positioned(
                                                  top: -largoActual * 0.08,
                                                  left: anchoActual * 0.18,
                                                  height: largoActual * 0.23,
                                                  child: Lottie.asset(
                                                      'lib/imagenes/palmeras1.json'),
                                                ),

                                                //IMAGEN DE BIDONCITO BONITO
                                                Positioned(
                                                  top: -largoActual * 0.15,
                                                  right: -anchoActual * 0.08,
                                                  child: Container(
                                                    height: largoActual * 0.30,
                                                    width: anchoActual * 0.5,
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    decoration: const BoxDecoration(
                                                        color:
                                                            Colors.transparent,
                                                        image: DecorationImage(
                                                            image: AssetImage(
                                                                'lib/imagenes/BIDON20.png'),
                                                            fit: BoxFit
                                                                .scaleDown)),
                                                  ),
                                                ),
                                                //BOTON DE CERRADO
                                                Positioned(
                                                  top: -largoActual * 0.13,
                                                  right: -anchoActual * 0.018,
                                                  child: Container(
                                                      alignment:
                                                          Alignment.center,
                                                      decoration: BoxDecoration(
                                                          color: const Color
                                                              .fromARGB(11, 191,
                                                              191, 191),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      50)),
                                                      height:
                                                          largoActual * 0.05,
                                                      width: largoActual * 0.05,
                                                      child: IconButton(
                                                        onPressed: () {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        const Pedido()
                                                                //const Promos()
                                                                ),
                                                          );
                                                        },
                                                        icon: const Icon(Icons
                                                            .close_rounded),
                                                        color: Colors.white,
                                                        iconSize:
                                                            largoActual * 0.030,
                                                      )),
                                                ),
                                              ]),
                                        );
                                      });
                                },
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'S/. ${userProvider.user?.saldoBeneficio}0',
                                          style: TextStyle(
                                              color: colorLetra,
                                              fontWeight: FontWeight.w700,
                                              fontSize: 35),
                                        ),
                                        Text(
                                          'Retiralo hasta el: ${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}',
                                          style: TextStyle(
                                              color: colorLetra,
                                              fontWeight: FontWeight.w400,
                                              fontSize: largoActual * 0.016),
                                        ),
                                      ],
                                    ),
                                    Lottie.asset(
                                        'lib/imagenes/billetera3.json'),
                                  ],
                                ),
                              )),
                        ),
                      ]))),
        ));
  }
}
