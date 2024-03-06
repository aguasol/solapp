import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:appsol_final/components/pdf.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:appsol_final/models/producto_model.dart';

extension StringExtension on String {
  String capitalize() {
    if (this == '') {
      return '';
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class Pedido {
  final int id;
  final double montoTotal;
  final String tipo;
  final String fecha;
  String estado;
  String? tipoPago;

  ///REVISAR EN QUÈ FORMATO SE RECIVE LA FECHA
  final String nombre;
  final String apellidos;
  final String telefono;
  //final String ubicacion;
  final double latitud;
  final double longitud;
  final String direccion;
  String comentario;

  Pedido({
    Key? key,
    required this.id,
    required this.montoTotal,
    required this.tipo,
    required this.fecha,
    required this.nombre,
    required this.apellidos,
    required this.telefono,
    //required this.ubicacion,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.estado = 'en proceso',
    this.comentario = '',
    this.tipoPago,
  });
}

class DetallePedido {
  final int pedidoID;
  final int productoID;
  final String productoNombre;
  final int cantidadProd;
  final int? promocionID;

  const DetallePedido({
    Key? key,
    required this.pedidoID,
    required this.productoID,
    required this.productoNombre,
    required this.cantidadProd,
    required this.promocionID,
  });
}

class HolaConductor2 extends StatefulWidget {
  const HolaConductor2({
    Key? key,
  }) : super(key: key);

  @override
  State<HolaConductor2> createState() => _HolaConductor2State();
}

class _HolaConductor2State extends State<HolaConductor2> {
  late io.Socket socket;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String googleApiKey = 'AIzaSyCyDQIhOQ_fxWclmJnJTq0yHT1JFhzMTPM';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiDetallePedido = '/api/detallepedido/';
  bool puedoLlamar = false;
  List<Pedido> listPedidosbyRuta = [];
  List<Producto> listProducto = [];
  String productosYCantidades = '';
  int numerodePedidosExpress = 0;
  int numPedidoActual = 1;
  int pedidoIDActual = 0;
  String nombreCliente = '';
  double? latitudPreference = 0.0;
  double? longitudPreference = 0.0;
  LatLng ubicacionPref = LatLng(0.0, 0.0);
  double latitudPedido = 0.0;
  double longitudPedido = 0.0;
  String apellidoCliente = '';
  String observacionCliente = '';
  Color colorProgreso = Colors.transparent;
  Color colorBotonesAzul = const Color.fromRGBO(0, 106, 252, 1.000);
  Color colorTexto = const Color.fromARGB(255, 75, 75, 75);
  Pedido pedidoTrabajo = Pedido(
      id: 0,
      montoTotal: 0,
      tipo: '',
      fecha: '',
      nombre: '',
      apellidos: '',
      telefono: '',
      latitud: 0.0,
      longitud: 0.0,
      direccion: '',
      tipoPago: '',
      comentario: '');
  int rutaID = 0;
  int? rutaIDpref = 0;
  int? conductorIDpref = 0;
  double totalMonto = 0;
  int cantidad = 0;
  double totalYape = 0;
  double totalPlin = 0;
  double totalEfectivo = 0;
  int totalPendiente = 0;
  int totalProceso = 0;
  int totalEntregado = 0;
  int totalTruncado = 0;
  double decimalProgreso = 0;
  int porcentajeProgreso = 0;
  List<int> idpedidos = [];
  final Completer<GoogleMapController> _controller = Completer();
  late Location location;
  LatLng _currentLocation = LatLng(-16.403174, -71.582565);

  List<LatLng> polylineCoordinates = [];
  LocationData? currentLocation;
  void getPolyPoints() async {
    polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        'AIzaSyCX0DB2ilFam7EoOcvoto1vpvinszdSMIw',
        PointLatLng(_currentLocation.latitude, _currentLocation.longitude),
        PointLatLng(latitudPedido, longitudPedido));
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) =>
            polylineCoordinates.add(LatLng(point.latitude, point.longitude)),
      );
      setState(() {});
    }
  }

  _cargarPreferencias() async {
    print('3) CARGAR PREFERENCIAS-------');
    SharedPreferences rutaPreference = await SharedPreferences.getInstance();
    SharedPreferences userPreference = await SharedPreferences.getInstance();
    if (rutaPreference.getInt("Ruta") != null) {
      print('3.a)  EMTRO A los IFS------- ');
      setState(() {
        rutaIDpref = rutaPreference.getInt("Ruta");
      });
    } else {
      setState(() {
        rutaIDpref = 1;
      });
    }
    if (userPreference.getInt("userID") != null) {
      setState(() {
        conductorIDpref = userPreference.getInt("userID");
      });
    } else {
      setState(() {
        conductorIDpref = 3;
      });
    }

    print('4) esta es mi ruta Preferencia ------- $rutaIDpref');
    print('4) esta es mi COND Preferencia ------- $conductorIDpref');
  }

  Future<dynamic> getProducts() async {
    var res = await http.get(
      Uri.parse("$apiUrl/api/products"),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Producto> tempProducto = data.map<Producto>((mapa) {
          return Producto(
            id: mapa['id'],
            nombre: mapa['nombre'],
            precio: mapa['precio'].toDouble(), //?,
            descripcion: mapa['descripcion'],
            promoID: null,
            foto: '$apiUrl/images/${mapa['foto']}',
          );
        }).toList();

        setState(() {
          listProducto = tempProducto;
          //conductores = tempConductor;
        });
        print("....lista productos");
        print(listProducto);
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  Future<void> _initialize() async {
    print('1) INITIALIZE-------------');
    print('2) esta es mi ruta Preferencia ------- $rutaIDpref');
    await getProducts();
    await _cargarPreferencias();
    print('5) esta es mi ruta Preferencia ACT---- $rutaIDpref');
    await getPedidosConductor(rutaIDpref, conductorIDpref);
    await getDetalleXUnPedido(pedidoIDActual);
  }

  Future<dynamic> getPedidosConductor(rutaIDpref, conductorID) async {
    print("6) entro al get PEDIDOS con RUTA $rutaIDpref y COND $conductorID");
    var res = await http.get(
      Uri.parse(
          "$apiUrl$apiPedidosConductor${rutaIDpref.toString()}/${conductorID.toString()}"),
      headers: {"Content-type": "application/json"},
    );
    print(
        "que fue chamooo: $apiPedidosConductor${rutaIDpref.toString()}/${conductorID.toString()}");
    try {
      print("flag");
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        List<Pedido> listTemporal = data.map<Pedido>((mapa) {
          return Pedido(
              id: mapa['id'],
              montoTotal: mapa['total']?.toDouble(),
              latitud: mapa['latitud']?.toDouble(),
              longitud: mapa['longitud']?.toDouble(),
              fecha: mapa['fecha'],
              estado: mapa['estado'],
              tipo: mapa['tipo'],
              nombre: mapa['nombre'],
              apellidos: mapa['apellidos'],
              telefono: mapa['telefono'],
              direccion: mapa['direccion'],
              tipoPago: mapa['tipo_pago'],
              comentario: mapa['observacion'] ?? 'sin comentarios');
        }).toList();
        print('7) Esta es la lista temporal ${listTemporal.length}');
        //SE SETEA EL VALOR DE PEDIDOS BY RUTA
        setState(() {
          listPedidosbyRuta = listTemporal;
        });
        //SE CALCULA LA LONGITUD DE PEDIDOS BY RUTA PARA SABER CUANTOS SON
        //EXPRESS Y CUANTOS SON NORMALES
        print('7.5) Monto total de lista temporal');
        for (var i = 0; i < listPedidosbyRuta.length; i++) {
          setState(() {
            totalMonto += listPedidosbyRuta[i].montoTotal;
            print('tipo: ${listPedidosbyRuta[i].tipoPago}');
            idpedidos.add(listPedidosbyRuta[i].id);
          });

          switch (listPedidosbyRuta[i].tipoPago) {
            case 'yape':
              setState(() {
                totalYape += listPedidosbyRuta[i].montoTotal;
              });
              break;
            case 'plin':
              setState(() {
                totalPlin += listPedidosbyRuta[i].montoTotal;
              });
              break;
            case 'efectivo':
              setState(() {
                totalEfectivo += listPedidosbyRuta[i].montoTotal;
              });
              break;
            default:
          }
          switch (listPedidosbyRuta[i].estado) {
            case 'pendiente':
              setState(() {
                totalPendiente++;
              });

              break;
            case 'en proceso':
              setState(() {
                totalProceso++;
              });

              break;
            case 'truncado':
              setState(() {
                totalTruncado++;
              });

              break;
            case 'entregado':
              setState(() {
                totalEntregado++;
              });

              break;
            default:
          }
        }
        print(
            '---precio total de los pedidos: $totalMonto \n yape: $totalYape \n plin:$totalPlin \n efectivo:$totalEfectivo \n #pendientes: $totalPendiente \n #procesos: $totalProceso');
        setState(() {
          cantidad = listPedidosbyRuta.length;
          numerodePedidosExpress = 0;
          numPedidoActual = 0;
        });
        print('8) Longitud de pedidos recibidos: $cantidad');
        print('9) Calculando pedidos express');

        for (var i = 0; i < listPedidosbyRuta.length; i++) {
          if (listPedidosbyRuta[i].tipo == 'express') {
            setState(() {
              numerodePedidosExpress++;
            });
          }
          if (listPedidosbyRuta[i].estado == 'entregado' ||
              listPedidosbyRuta[i].estado == 'truncado') {
            setState(() {
              numPedidoActual++;
            });
          }
        }

        print("---- numerp de Pedido Actual $numPedidoActual");
        if (numPedidoActual > 0 && cantidad > 0) {
          setState(() {
            decimalProgreso = ((numPedidoActual) / cantidad);
            print("-------$numPedidoActual/$cantidad = $decimalProgreso");
            porcentajeProgreso = (decimalProgreso * 100).round();
          });
        }
        if (porcentajeProgreso < 33.4) {
          setState(() {
            colorProgreso = Color.fromRGBO(255, 0, 93, 1.000);
          });
        } else if (porcentajeProgreso < 66.6) {
          setState(() {
            colorProgreso = Color.fromRGBO(244, 183, 87, 1.000);
          });
        } else {
          setState(() {
            colorProgreso = Color.fromRGBO(120, 251, 99, 1.000);
          });
        }
        print('10) Cantidad de Pedidos express: $numerodePedidosExpress');

        //CALCULA EL PEDIDO SIGUIENTE QUE SE ENCUENTRA "EN PROCESO"
        for (var i = 0; i < listPedidosbyRuta.length; i++) {
          if (listPedidosbyRuta[i].estado == 'en proceso') {
            print('----------------------------------');
            print('11) Este es i $i');
            setState(() {
              pedidoIDActual = listPedidosbyRuta[i].id;
              pedidoTrabajo = listPedidosbyRuta[i];
              latitudPedido = listPedidosbyRuta[i].latitud;
              longitudPedido = listPedidosbyRuta[i].longitud;
              getPolyPoints();
              nombreCliente = listPedidosbyRuta[i].nombre.capitalize();
              apellidoCliente = listPedidosbyRuta[i].apellidos.capitalize();
              observacionCliente = listPedidosbyRuta[i].comentario.capitalize();
              print('12) Este es el pedidoIDactual $pedidoIDActual');
            });
            break;
          }
        }
        setState(() {});
      }
    } catch (e) {
      print('Error en la solicitud: $e');
      throw Exception('Error en la solicitud: $e');
    }
  }

  void connectToServer() async {
    print("3.1) Dentro de connectToServer");
    // Reemplaza la URL con la URL de tu servidor Socket.io
    socket = io.io(apiUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
      'reconnect': true,
      'reconnectionAttempts': 5,
      'reconnectionDelay': 1000,
    });
    socket.connect();
    socket.onConnect((_) {
      print('Conexión establecida: CONDUCTOR');
      // Inicia la transmisión de ubicación cuando se conecta
      //iniciarTransmisionUbicacion();
    });
    socket.onDisconnect((_) {
      print('Conexión desconectada: CONDUCTOR');
    });
    socket.onConnectError((error) {
      print("Error de conexión $error");
    });
    socket.onError((error) {
      print("Error de socket, $error");
    });
    SharedPreferences rutaPreference = await SharedPreferences.getInstance();
    socket.on(
      'creadoRuta',
      (data) {
        print("------esta es lA RUTA");
        print(data['id']);

        setState(() {
          rutaID = data['id'];
          rutaPreference.setInt("Ruta", rutaID);
        });
      },
    );
    socket.on(
      'ruteando',
      (data) {
        print("------este es el pedido nuevo");
        if (data == true) {
          _initialize();
        }
      },
    );
    socket.on('Llama tus Pedidos :)', (data) {
      print('Puedo llamar a mis pedidos $data');
      setState(() {
        puedoLlamar = true;
      });
      if (puedoLlamar == true) {
        _initialize();
      }
    });
    //  }
  }

  Future<dynamic> updateEstadoPedido(
      estadoNuevo, foto, observacion, tipoPago, pedidoID) async {
    if (pedidoID != 0) {
      await http.put(Uri.parse("$apiUrl$apiPedidosConductor$pedidoID"),
          headers: {"Content-type": "application/json"},
          body: jsonEncode({
            "estado": estadoNuevo,
            "foto": foto,
            "observacion": observacion,
            "tipo_pago": tipoPago
          }));
    } else {
      print('papas fritas');
    }
  }

  Future<dynamic> getDetalleXUnPedido(pedidoID) async {
    print('----------------------------------');
    print('14) Dentro de Detalles');
    print('pedido ID: $pedidoID');
    if (pedidoID != 0) {
      var res = await http.get(
        Uri.parse(apiUrl + apiDetallePedido + pedidoID.toString()),
        headers: {"Content-type": "application/json"},
      );
      try {
        if (res.statusCode == 200) {
          var data = json.decode(res.body);
          List<DetallePedido> listTemporal = data.map<DetallePedido>((mapa) {
            return DetallePedido(
              pedidoID: mapa['pedido_id'],
              productoID: mapa['producto_id'],
              productoNombre: mapa['nombre'],
              cantidadProd: mapa['cantidad'],
              promocionID: mapa['promocion_id'],
            );
          }).toList();

          setState(() {
            for (var j = 0; j < listProducto.length; j++) {
              for (var i = 0; i < listTemporal.length; i++) {
                if (listProducto[j].nombre == listTemporal[i].productoNombre) {
                  setState(() {
                    listProducto[j].cantidad += 1;
                  });
                }
              }
            }
            for (var i = 0; i < listProducto.length; i++) {
              if (listProducto[i].cantidad != 0) {
                var salto = '\n';
                if (productosYCantidades == '') {
                  setState(() {
                    productosYCantidades =
                        "${listProducto[i].nombre} x ${listProducto[i].cantidad.toString()} uds."
                            .capitalize();
                  });
                } else {
                  setState(() {
                    productosYCantidades =
                        "$productosYCantidades $salto${listProducto[i].nombre.capitalize()} x ${listProducto[i].cantidad.toString()} uds.";
                  });
                }
                print('15) Estas son los prods. $productosYCantidades');
              }
            }
          });
        }
      } catch (e) {
        print('Error en la solicitud: $e');
        throw Exception('Error en la solicitud: $e');
      }
    } else {
      print('papas');
    }
  }

  void esDouble(num1, num2) async {
    if (num1 is double && num2 is double) {
      setState(() {
        ubicacionPref = LatLng(num1, num2);
      });
    } else {
      setState(() {
        num1 = 0.0;
        num2 = 0.0;
        ubicacionPref = LatLng(num1, num2);
      });
    }
  }

  TextEditingController comentarioConductor = TextEditingController();
  String comentario = '';
  String observacionPedido = '';
  String estadoNuevo = '';
  String tipoPago = '';
  File? _imageFile;
  bool flag = false;
  Future<void> _takePicture(String dato) async {
    final pass = await getApplicationDocumentsDirectory();
    final otro = path.join(pass.path, 'pictures');
    final picturesDirectory = Directory(otro);
    if (!await picturesDirectory.exists()) {
      await picturesDirectory.create(recursive: true);
      print('Directorio creado: $otro');
    } else {
      print('El directorio ya existe: $otro');
    }
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
    if (_imageFile != null) {
      final pass = await getApplicationDocumentsDirectory();
      final otro = path.join(pass.path, 'pictures');
      final String fileName = '${pedidoTrabajo.id}.jpg';
      String filePath = '$otro/$fileName';
      final nuevaFoto = XFile(_imageFile!.path);
      nuevaFoto.saveTo(filePath);
      deletePhoto(_imageFile!.path);
      setState(() {
        _imageFile = null;
      });

      esProblemaOesPago(dato);
      setState(() {
        flag = true;
      });
    } else {
      setState(() {
        flag = false;
      });

      print("Todavia no se ha tomado una foto");
    }
  }

  void esProblemaOesPago(String problemasOpago) {
    if (problemasOpago == 'pago') {
      setState(() {
        comentario = 'Comentarios (opcional)';
        estadoNuevo = 'entregado';
        tipoPago = 'yape';
      });
    } else {
      setState(() {
        comentario = 'Detalla los inconvenientes (obligatiorio)';
        estadoNuevo = 'truncado';
        tipoPago = '';
      });
    }
  }

  void deletePhoto(String? fileName) async {
    try {
      // Crear un objeto File para el archivo que deseas eliminar
      File file = File(fileName!);

      // Verificar si el archivo existe antes de intentar eliminarlo
      if (await file.exists()) {
        // Eliminar el archivo
        await file.delete();
        print('Foto eliminada con éxito: $fileName');
      } else {
        print('El archivo no existe: $fileName');
      }
    } catch (e) {
      print('Error al eliminar la foto: $e');
    }
  }

  void TomarFoto(double anchoActual, double largoActual, String dato) {
    _takePicture(dato);
    print("Como esta el flag :=> $flag");
  }

  ubicacionExacta() async {
    location = Location();
    GoogleMapController googleMapController = await _controller.future;
    location.onLocationChanged.listen((LocationData currentLocation) {
      setState(() {
        _currentLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
      });
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 14.7365,
            target:
                LatLng(_currentLocation.latitude, _currentLocation.longitude),
          ),
        ),
      );
    });
  }

  @override
  void initState() {
    super.initState();
    ubicacionExacta();
    _initialize();
    connectToServer();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    int numeroTotalPedidos = listPedidosbyRuta.length;
    print('16) Esta es la longitud de Pedidos $numeroTotalPedidos');
    print('17) Este es el pedido actual $numPedidoActual');
    print('18) Este es el pedido id actual $pedidoIDActual');
    print('18) LATII $latitudPedido');
    print('18) LONGIII $longitudPedido');
    final userProvider = context.watch<UserProvider>();
    conductorIDpref = userProvider.user?.id;
    esDouble(latitudPedido, longitudPedido);
    //final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
        //key: _scaffoldKey,
        body: PopScope(
      canPop: false,
      onPopInvoked: (bool didPop) {
        if (didPop) {
          return;
        }
      },
      child: SafeArea(
          top: false,
          child: Padding(
              padding: const EdgeInsets.all(0.0),
              child: Container(
                  height: largoActual,
                  width: anchoActual,
                  child: Stack(children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _currentLocation,
                        zoom: 20,
                      ),
                      onMapCreated: (mapController) {
                        _controller.complete(mapController);
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId('currentLocation'),
                          position: _currentLocation,
                        ),
                        Marker(
                          markerId: const MarkerId('pedido'),
                          position: LatLng(latitudPedido, longitudPedido),
                          icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueRose),
                        ),
                      },
                      polylines: {
                        Polyline(
                            polylineId: const PolylineId("route"),
                            points: polylineCoordinates,
                            color: Colors.blue,
                            width: 6),
                      },
                      myLocationEnabled: true,
                      myLocationButtonEnabled: true,
                    ),

                    //BOTON DE MENU
                    //FALTA HABILITAR
                    Positioned(
                      top: anchoActual *
                          0.09, // Ajusta la posición vertical según tus necesidades
                      left: anchoActual *
                          0.05, // Ajusta la posición horizontal según tus necesidades
                      child: SizedBox(
                        height: anchoActual * 0.12,
                        width: anchoActual * 0.12,
                        child: FloatingActionButton(
                          elevation: 20,
                          onPressed: () async {
                            //Habiuliteishon
                          },
                          backgroundColor:
                              const Color.fromRGBO(230, 230, 230, 1),
                          child: const Icon(Icons.menu,
                              color: Color.fromARGB(255, 119, 119, 119)),
                        ),
                      ),
                    ),

                    //BARRA DE PROGRESO
                    Positioned(
                      top: anchoActual *
                          0.08, // Ajusta la posición vertical según tus necesidades
                      right: anchoActual *
                          0.05, // Ajusta la posición horizontal según tus necesidades
                      child: Card(
                        surfaceTintColor:
                            const Color.fromARGB(108, 255, 255, 255),
                        color: const Color.fromARGB(0, 255, 255, 255),
                        elevation: 20,
                        child: Container(
                            alignment: Alignment.center,
                            height: anchoActual * 0.12,
                            width: anchoActual * 0.65,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                LinearPercentIndicator(
                                  lineHeight: anchoActual * 0.07,
                                  width: anchoActual * 0.50,
                                  percent: decimalProgreso,
                                  center: Text(
                                    "$porcentajeProgreso %",
                                    style: TextStyle(
                                        color: colorTexto,
                                        fontWeight: FontWeight.w800),
                                  ),
                                  leading: Text(
                                    "$numPedidoActual",
                                    style: TextStyle(
                                        color: colorTexto,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  trailing: Text(
                                    "$numeroTotalPedidos",
                                    style: TextStyle(
                                        color: colorTexto,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  progressColor: colorProgreso,
                                  backgroundColor: Colors.transparent,
                                  animateFromLastPercent: true,
                                  animationDuration: 50000,
                                  barRadius: Radius.circular(20),
                                ),
                              ],
                            )),
                      ),
                    ),
                    //BOTON DE LLAMADASSS
                    Positioned(
                      bottom: anchoActual *
                          0.05, // Ajusta la posición vertical según tus necesidades
                      right: anchoActual *
                          0.05, // Ajusta la posición horizontal según tus necesidades
                      child: SizedBox(
                        height: anchoActual * 0.14,
                        width: anchoActual * 0.2,
                        child: ElevatedButton(
                          onPressed: () async {
                            final Uri url = Uri(
                              scheme: 'tel',
                              path: pedidoTrabajo.telefono,
                            ); // Acciones al hacer clic en el FloatingActionButton
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            } else {
                              print('no se puede llamar:(');
                            }
                          },
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(8),
                            fixedSize: MaterialStatePropertyAll(
                                Size(anchoActual * 0.14, largoActual * 0.14)),
                            backgroundColor:
                                MaterialStateProperty.all(colorBotonesAzul),
                          ),
                          child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [Icon(Icons.call, color: Colors.white)],
                          ),
                        ),
                      ),
                    ),
                    //BOTON DE INFO DEL PEDIDO
                    Positioned(
                      bottom: anchoActual *
                          0.05, // Ajusta la posición vertical según tus necesidades
                      left: anchoActual *
                          0.05, // Ajusta la posición horizontal según tus necesidades
                      child: SizedBox(
                        height: anchoActual * 0.14,
                        width: anchoActual * 0.2,
                        child: ElevatedButton(
                          onPressed: () {
                            if (numPedidoActual == numeroTotalPedidos) {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return Container(
                                      margin: EdgeInsets.only(
                                          left: anchoActual * 0.08,
                                          right: anchoActual * 0.08,
                                          top: largoActual * 0.05,
                                          bottom: largoActual * 0.05),
                                      child: Column(children: [
                                        Container(
                                            margin:
                                                const EdgeInsets.only(left: 15),
                                            child: Text(
                                              "¡Terminaste de entregar los pedidos de tu ruta!",
                                              style: TextStyle(
                                                  color: colorTexto,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500),
                                            )),
                                        Container(
                                            margin:
                                                const EdgeInsets.only(left: 15),
                                            child: Text(
                                              "Aquí puedes generar el pdf con el reporte de tu ruta ;) ",
                                              style: TextStyle(
                                                  color: colorTexto,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.w500),
                                            )),
                                        SizedBox(
                                          width: anchoActual,
                                          height: 19,
                                          child: ElevatedButton(
                                            onPressed: () async {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) => Pdf(
                                                          rutaID: rutaIDpref,
                                                          pedidos:
                                                              totalPendiente,
                                                          totalMonto:
                                                              totalMonto,
                                                          totalYape: totalYape,
                                                          totalPlin: totalPlin,
                                                          totalEfectivo:
                                                              totalEfectivo,
                                                          pedidosEntregados:
                                                              totalEntregado,
                                                          idpedidos: idpedidos,
                                                          pedidosTruncados:
                                                              totalTruncado,
                                                        )),
                                              );
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      colorBotonesAzul),
                                            ),
                                            child: const Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons
                                                      .picture_as_pdf_outlined, // Reemplaza con el icono que desees
                                                  size: 10,
                                                  color: Colors.white,
                                                ),
                                                SizedBox(
                                                    width:
                                                        3), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                                Text(
                                                  "Crear informe",
                                                  style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      color: Colors.white),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                    );
                                  });
                            } else {
                              showModalBottomSheet(
                                  context: context,
                                  isScrollControlled: true,
                                  builder: (context) {
                                    return Padding(
                                      padding: EdgeInsets.only(
                                          bottom: MediaQuery.of(context)
                                              .viewInsets
                                              .bottom),
                                      child: Container(
                                        height: largoActual * 0.45,
                                        width: anchoActual,
                                        margin: EdgeInsets.only(
                                            left: anchoActual * 0.08,
                                            right: anchoActual * 0.08,
                                            top: largoActual * 0.05,
                                            bottom: largoActual * 0.05),
                                        child: Column(children: [
                                          Text(
                                            "Pedido ${numPedidoActual + 1}/$numeroTotalPedidos",
                                            style: TextStyle(
                                                color: colorTexto,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500),
                                          ),
                                          SizedBox(
                                            height: largoActual * 0.02,
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 85,
                                                child: Text(
                                                  "Productos",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: colorTexto),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                ":   ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: colorTexto),
                                              ),
                                              Text(
                                                productosYCantidades,
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: colorTexto),
                                              )
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 85,
                                                child: Text(
                                                  "Cliente",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: colorTexto),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                ":   ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: colorTexto),
                                              ),
                                              Text(
                                                "$nombreCliente $apellidoCliente",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: colorTexto),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 85,
                                                child: Text(
                                                  "Monto",
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: colorTexto),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                ":   ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: colorTexto),
                                              ),
                                              Text(
                                                "S/. ${pedidoTrabajo.montoTotal}",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: colorTexto),
                                              ),
                                            ],
                                          ),

                                          Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                width: 85,
                                                child: Text(
                                                  "Comentarios",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: colorTexto,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(
                                                width: 5,
                                              ),
                                              Text(
                                                ":   ",
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    color: colorTexto),
                                              ),
                                              SizedBox(
                                                width: anchoActual * 0.55,
                                                child: Text(
                                                  observacionCliente,
                                                  textAlign: TextAlign.justify,
                                                  style: TextStyle(
                                                      fontSize: 14,
                                                      color: colorTexto),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Expanded(child: SizedBox()),
                                          Container(
                                              margin: const EdgeInsets.only(
                                                  left: 15),
                                              child: Text(
                                                "Tipo de pago",
                                                style: TextStyle(
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w500,
                                                    color: colorTexto),
                                              )),
                                          SizedBox(
                                            height: largoActual * 0.02,
                                          ),
                                          //BOTONES YAPE Y EFECTIVO
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              //BOTON YAPE PLIN
                                              Container(
                                                width:
                                                    anchoActual * (164.5 / 400),
                                                height: largoActual * 0.05,
                                                child: ElevatedButton(
                                                    onPressed: () async {
                                                      await _takePicture(
                                                          'pago');
                                                      if (flag) {
                                                        showModalBottomSheet(
                                                            isDismissible:
                                                                false,
                                                            backgroundColor:
                                                                const Color
                                                                    .fromRGBO(
                                                                    0,
                                                                    106,
                                                                    252,
                                                                    1.000),
                                                            // ignore: use_build_context_synchronously
                                                            context: context,
                                                            isScrollControlled:
                                                                true,
                                                            builder: (context) {
                                                              return Padding(
                                                                padding: EdgeInsets.only(
                                                                    bottom: MediaQuery.of(
                                                                            context)
                                                                        .viewInsets
                                                                        .bottom),
                                                                child:
                                                                    Container(
                                                                  height:
                                                                      largoActual *
                                                                          0.15,
                                                                  margin: EdgeInsets.only(
                                                                      left: anchoActual *
                                                                          0.08,
                                                                      right: anchoActual *
                                                                          0.08,
                                                                      top: largoActual *
                                                                          0.05,
                                                                      bottom: largoActual *
                                                                          0.05),
                                                                  child: Column(
                                                                    children: [
                                                                      Column(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
                                                                          children: [
                                                                            Container(
                                                                              decoration: BoxDecoration(
                                                                                color: Colors.white,
                                                                                borderRadius: BorderRadius.circular(8.0),
                                                                                border: Border.all(
                                                                                  color: Colors.grey,
                                                                                  width: 0.5,
                                                                                ),
                                                                              ),
                                                                              child: TextField(
                                                                                decoration: InputDecoration(hintText: comentario),
                                                                                controller: comentarioConductor,
                                                                              ),
                                                                            )
                                                                          ]),
                                                                      const SizedBox(
                                                                        height:
                                                                            20,
                                                                      ),
                                                                      Row(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.spaceBetween,
                                                                        children: [
                                                                          SizedBox(
                                                                            height:
                                                                                40,
                                                                            width:
                                                                                anchoActual * 0.83,
                                                                            child: ElevatedButton(
                                                                                onPressed: () {
                                                                                  updateEstadoPedido(estadoNuevo, null, comentarioConductor.text, tipoPago, pedidoTrabajo.id);
                                                                                  Navigator.push(
                                                                                    context,
                                                                                    //REGRESA A LA VISTA DE HOME PERO ACTUALIZA EL PEDIDO
                                                                                    MaterialPageRoute(builder: (context) => const HolaConductor2()),
                                                                                  );
                                                                                },
                                                                                style: ButtonStyle(elevation: MaterialStateProperty.all(8), surfaceTintColor: MaterialStateProperty.all(Colors.white), backgroundColor: MaterialStateProperty.all(Colors.white)),
                                                                                child: const Row(
                                                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                                                  children: [
                                                                                    Text(
                                                                                      "Listo",
                                                                                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Color.fromRGBO(0, 106, 252, 1.000)),
                                                                                    ),
                                                                                    SizedBox(width: 8),
                                                                                    Icon(
                                                                                      Icons.arrow_forward, // Reemplaza con el icono que desees
                                                                                      size: 24,
                                                                                      color: Color.fromRGBO(0, 106, 252, 1.000),
                                                                                    ),
                                                                                  ],
                                                                                )),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              );
                                                            });
                                                      } else {
                                                        print(
                                                            "Todavia no se ha tomado una foto");
                                                      }
                                                      setState(() {
                                                        flag = false;
                                                      });
                                                    },
                                                    style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(
                                                                    colorBotonesAzul)),
                                                    child: const Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Icon(
                                                          Icons
                                                              .camera_alt, // Reemplaza con el icono que desees
                                                          size: 18,
                                                          color: Colors.white,
                                                        ),
                                                        SizedBox(width: 3),
                                                        Text(
                                                          "Yape/Plin",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.white),
                                                        )
                                                      ],
                                                    )),
                                              ),
                                              //BOTON EFECTIVO
                                              Container(
                                                width:
                                                    anchoActual * (164.5 / 400),
                                                height: largoActual * 0.05,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext
                                                          context) {
                                                        return AlertDialog(
                                                          surfaceTintColor:
                                                              Color.fromRGBO(
                                                                  0,
                                                                  106,
                                                                  252,
                                                                  1.000),
                                                          elevation: 20,
                                                          title: const Text(
                                                            'TERMINE MI PEDIDO',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Color
                                                                    .fromRGBO(
                                                                        0,
                                                                        106,
                                                                        252,
                                                                        1.000)),
                                                          ),
                                                          content: const Text(
                                                            '¿Entregaste el pedido?',
                                                            style: TextStyle(
                                                                fontSize: 15,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400),
                                                          ),
                                                          actions: <Widget>[
                                                            Row(
                                                              children: [
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () async {
                                                                      print(
                                                                          "print CHIIIII");
                                                                      print(pedidoTrabajo
                                                                          .id);
                                                                      await updateEstadoPedido(
                                                                          'entregado',
                                                                          null,
                                                                          "",
                                                                          'efectivo',
                                                                          pedidoTrabajo
                                                                              .id);
                                                                      setState(
                                                                          () {
                                                                        listProducto =
                                                                            [];
                                                                        productosYCantidades =
                                                                            '';
                                                                      });
                                                                      await _initialize();
                                                                      // ignore: use_build_context_synchronously
                                                                      Navigator.pop(
                                                                          context);
                                                                      // ignore: use_build_context_synchronously
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop();
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      '     Si     ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              16,
                                                                          color: Color.fromRGBO(
                                                                              0,
                                                                              106,
                                                                              252,
                                                                              1.000)),
                                                                    )),
                                                                const Expanded(
                                                                    child:
                                                                        SizedBox()),
                                                                ElevatedButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.of(
                                                                              context)
                                                                          .pop(); // Cierra el AlertDialog
                                                                    },
                                                                    child:
                                                                        const Text(
                                                                      '     No     ',
                                                                      style: TextStyle(
                                                                          fontWeight: FontWeight
                                                                              .bold,
                                                                          fontSize:
                                                                              16,
                                                                          color: Color.fromRGBO(
                                                                              0,
                                                                              106,
                                                                              252,
                                                                              1.000)),
                                                                    )),
                                                              ],
                                                            ),
                                                          ],
                                                        );
                                                      },
                                                    );
                                                  },
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(const Color
                                                                .fromRGBO(
                                                                0,
                                                                106,
                                                                252,
                                                                1.000)),
                                                  ),
                                                  child: const Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      Icon(
                                                        Icons
                                                            .money, // Reemplaza con el icono que desees
                                                        size: 18,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(
                                                          width:
                                                              8), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                                      Text(
                                                        "Efectivo",
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          //BOTON DE PROBLEMASS
                                          Container(
                                            width: anchoActual,
                                            height: largoActual * 0.05,
                                            child: ElevatedButton(
                                                onPressed: () async {
                                                  await _takePicture(
                                                      'problemas');
                                                  if (flag) {
                                                    showModalBottomSheet(
                                                        isDismissible: false,
                                                        backgroundColor:
                                                            const Color
                                                                .fromRGBO(
                                                                0,
                                                                106,
                                                                252,
                                                                1.000),
                                                        // ignore: use_build_context_synchronously
                                                        context: context,
                                                        isScrollControlled:
                                                            true,
                                                        builder: (context) {
                                                          return Padding(
                                                            padding: EdgeInsets.only(
                                                                bottom: MediaQuery.of(
                                                                        context)
                                                                    .viewInsets
                                                                    .bottom),
                                                            child: Container(
                                                              height:
                                                                  largoActual *
                                                                      0.15,
                                                              margin: EdgeInsets.only(
                                                                  left:
                                                                      anchoActual *
                                                                          0.08,
                                                                  right:
                                                                      anchoActual *
                                                                          0.08,
                                                                  top:
                                                                      largoActual *
                                                                          0.05,
                                                                  bottom:
                                                                      largoActual *
                                                                          0.05),
                                                              child: Column(
                                                                children: [
                                                                  Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        Container(
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            color:
                                                                                Colors.white,
                                                                            borderRadius:
                                                                                BorderRadius.circular(8.0),
                                                                            border:
                                                                                Border.all(
                                                                              color: Colors.grey,
                                                                              width: 0.5,
                                                                            ),
                                                                          ),
                                                                          child:
                                                                              TextField(
                                                                            decoration:
                                                                                InputDecoration(hintText: comentario),
                                                                            controller:
                                                                                comentarioConductor,
                                                                          ),
                                                                        )
                                                                      ]),
                                                                  const SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                  Row(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceBetween,
                                                                    children: [
                                                                      SizedBox(
                                                                        height:
                                                                            40,
                                                                        width: anchoActual *
                                                                            0.83,
                                                                        child: ElevatedButton(
                                                                            onPressed: () {
                                                                              updateEstadoPedido(estadoNuevo, null, comentarioConductor.text, tipoPago, pedidoTrabajo.id);
                                                                              Navigator.push(
                                                                                context,
                                                                                //REGRESA A LA VISTA DE HOME PERO ACTUALIZA EL PEDIDO
                                                                                MaterialPageRoute(builder: (context) => const HolaConductor2()),
                                                                              );
                                                                            },
                                                                            style: ButtonStyle(elevation: MaterialStateProperty.all(8), surfaceTintColor: MaterialStateProperty.all(Colors.white), backgroundColor: MaterialStateProperty.all(Colors.white)),
                                                                            child: const Row(
                                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                                              children: [
                                                                                Text(
                                                                                  "Listo",
                                                                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400, color: Color.fromRGBO(0, 106, 252, 1.000)),
                                                                                ),
                                                                                SizedBox(width: 8),
                                                                                Icon(
                                                                                  Icons.arrow_forward, // Reemplaza con el icono que desees
                                                                                  size: 24,
                                                                                  color: Color.fromRGBO(0, 106, 252, 1.000),
                                                                                ),
                                                                              ],
                                                                            )),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        });
                                                  } else {
                                                    print(
                                                        "Todavia no se ha tomado una foto");
                                                  }

                                                  setState(() {
                                                    flag = false;
                                                  });
                                                },
                                                style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all(const Color
                                                                .fromRGBO(230,
                                                                230, 230, 1))),
                                                child: const Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Icon(
                                                      Icons
                                                          .camera_alt, // Reemplaza con el icono que desees
                                                      size: 18,
                                                      color: Color.fromARGB(
                                                          255, 119, 119, 119),
                                                    ),
                                                    SizedBox(width: 3),
                                                    Text(
                                                      "¿Problemas?",
                                                      style: TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: Color.fromARGB(
                                                              255,
                                                              119,
                                                              119,
                                                              119)),
                                                    )
                                                  ],
                                                )),
                                          ),

                                          /*SizedBox(
                                                                width: anchoActual,
                                                                height: 19,
                                                                child: ElevatedButton(
                                                                  onPressed: () async {
                                                                    Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => Pdf(
                                          rutaID: rutaIDpref,
                                          pedidos: totalPendiente,
                                          totalMonto: totalMonto,
                                          totalYape: totalYape,
                                          totalPlin: totalPlin,
                                          totalEfectivo: totalEfectivo,
                                          pedidosEntregados: totalProceso,
                                                                              )),
                                                                    );
                                                                  },
                                                                  style: ButtonStyle(
                                                                    backgroundColor: MaterialStateProperty.all(
                                                                        const Color.fromARGB(255, 2, 86, 155)),
                                                                  ),
                                                                  child: const Row(
                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                    children: [
                                                                      Icon(
                                                                        Icons
                                                                            .picture_as_pdf_outlined, // Reemplaza con el icono que desees
                                                                        size: 10,
                                                                        color: Colors.white,
                                                                      ),
                                                                      SizedBox(
                                                                          width:
                                                                              3), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                                                      Text(
                                                                        "Crear informe",
                                                                        style: TextStyle(
                                                                            fontSize: 10,
                                                                            fontWeight: FontWeight.w400,
                                                                            color: Colors.white),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                         */
                                        ]),
                                      ),
                                    );
                                  });
                            }
                          },
                          child: const Icon(Icons.info_rounded,
                              color: Colors.white),
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(8),
                            minimumSize: MaterialStatePropertyAll(
                                Size(anchoActual * 0.28, largoActual * 0.054)),
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromRGBO(0, 106, 252, 1.000)),
                          ),
                        ),
                      ),
                    ),
                  ])))),
    ));
  }
}
