import 'package:appsol_final/components/actualizado_stock.dart';
import 'package:appsol_final/models/ruta_model.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'dart:convert';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:lottie/lottie.dart';

extension StringExtension on String {
  String capitalize() {
    if (this == '') {
      return '';
    }
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class HolaConductor extends StatefulWidget {
  const HolaConductor({
    Key? key,
  }) : super(key: key);

  @override
  State<HolaConductor> createState() => _HolaConductorState();
}

class _HolaConductorState extends State<HolaConductor> {
  late io.Socket socket;
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String apiLastRutaCond = '/api/rutakastcond/';
  String apiDetallePedido = '/api/detallepedido/';
  String mensaje =
      'El día de hoy todavía no te han asignado una ruta, espera un momento ;)';
  bool puedoLlamar = false;
  int numerodePedidosExpress = 0;
  int numPedidoActual = 1;
  int pedidoIDActual = 0;
  bool tengoruta = false;
  Color colorProgreso = Colors.transparent;
  Color colorBotonesAzul = const Color.fromRGBO(0, 106, 252, 1.000);
  Color colorTexto = const Color.fromARGB(255, 75, 75, 75);
  int rutaID = 0;
  int? rutaIDpref = 0;
  int? conductorIDpref = 0;
  int cantidad = 0;
  List<int> idpedidos = [];
  DateTime fechaHoy = DateTime.now();
  String nombreCamion = '';
  String placa = '';

  //CREAR UN FUNCION QUE LLAME EL ENDPOINT EN EL QUE SE VERIFICA QUE EL CONDUCTOR
  //TIENE UNA RUTA ASIGNADA PARA ESE DÍA

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

  Future<void> _initialize() async {
    print('1) INITIALIZE-------------');
    print('2) esta es mi ruta Preferencia ------- $rutaIDpref');
    await _cargarPreferencias();
    await getRutas();
    print('5) esta es mi ruta Preferencia ACT---- $rutaIDpref');
  }

  Future<dynamic> getRutas() async {
    var res = await http.get(
      Uri.parse(apiUrl + apiLastRutaCond + conductorIDpref.toString()),
      headers: {"Content-type": "application/json"},
    );
    try {
      if (res.statusCode == 200) {
        var data = json.decode(res.body);
        print("ESTA ES LA DATA !!!! $data");
        RutaModel tempRutaModel = RutaModel(
            id: data['id'],
            conductorID: data['conductor_id'],
            vehiculoID: data['vehiculo_id'],
            fechaCreacion: data['fecha_creacion'],
            nombreVehiculo: data['nombre_modelo'],
            placaVehiculo: data['placa']);
        print("ESTA ES LA FECHA DE CREACION ${tempRutaModel.fechaCreacion}");
        DateTime fechaCreacion = DateTime.parse(tempRutaModel.fechaCreacion);
        if (fechaCreacion.day == fechaHoy.day &&
            fechaCreacion.month == fechaHoy.month &&
            fechaCreacion.year == fechaHoy.year) {
          //si la fecha de creacion es de hoy entonces esta es la ruta del dia!!
          SharedPreferences rutaPreference =
              await SharedPreferences.getInstance();
          SharedPreferences vehiculoPreference =
              await SharedPreferences.getInstance();
          setState(() {
            rutaID = tempRutaModel.id;
            nombreCamion = tempRutaModel.nombreVehiculo;
            placa = tempRutaModel.placaVehiculo;
          });
          rutaPreference.setInt("Ruta", rutaID);
          vehiculoPreference.setInt("carID", tempRutaModel.vehiculoID);
          mensaje =
              'Tu ruta hoy es la Nº $rutaID, en el vehículo $nombreCamion con placa $placa\n ¡EXITOS!';
          tengoruta = true;
        }
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
        //ca

        setState(() {
          rutaID = data['id'];
          rutaPreference.setInt("Ruta", rutaID);
          rutaPreference.setInt("Ruta", data['vehiculo_id']);
          mensaje = 'Tu ruta hoy es la ruta Nº $rutaID :D';
          tengoruta = true;
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

  @override
  void initState() {
    super.initState();
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
    final userProvider = context.watch<UserProvider>();
    conductorIDpref = userProvider.user?.id;
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
      child: DecoratedBox(
        decoration: const BoxDecoration(
            gradient: LinearGradient(colors: [
          Color.fromRGBO(0, 106, 252, 1.000),
          Color.fromRGBO(0, 106, 252, 1.000),
          Colors.white,
          Colors.white,
        ], begin: Alignment.topLeft, end: Alignment.bottomCenter)),
        child: SafeArea(
            top: true,
            child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: largoActual * 0.2,
                    ),
                    //MENSAJE DE SALUDO AL CONDUCTOR
                    Text(
                      '¡Hola, ${userProvider.user?.nombre}!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontSize: largoActual * 0.04),
                    ),
                    //MENSAJE DE ESTADO DE SU RUTA POR EL DÍA
                    Container(
                      margin: EdgeInsets.only(
                          left: anchoActual * 0.1, right: anchoActual * 0.1),
                      child: Text(
                        mensaje,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            fontSize: largoActual * 0.025),
                      ),
                    ),
                    SizedBox(
                      height: largoActual * 0.08,
                    ),
                    //BOTON DE COMENZAR RUTA QUE APARECE SOLO SI EL CONDUCTOR TIENE UNA RUTA DE ESE DÍA
                    SizedBox(
                      child: tengoruta
                          ? ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ActualizadoStock()),
                                );
                                //QUE LO LLEVE A LA VISTA DE FORMULARIO DE LLENADO DE STOCK
                              },
                              style: ButtonStyle(
                                surfaceTintColor: MaterialStateProperty.all(
                                    Color.fromRGBO(83, 176, 68, 1.000)),
                                elevation: MaterialStateProperty.all(10),
                                minimumSize: MaterialStatePropertyAll(Size(
                                    anchoActual * 0.28, largoActual * 0.054)),
                                backgroundColor: MaterialStateProperty.all(
                                    Color.fromRGBO(83, 176, 68, 1.000)),
                              ),
                              child: Text(
                                '¡Comenzar!',
                                style: TextStyle(
                                    fontSize: largoActual * 0.021,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ))
                          : Expanded(child: Container()),
                    ),
                    Expanded(child: Container()),
                    Lottie.asset('lib/imagenes/camion6.json'),
                  ],
                ))),
      ),
    ));
  }
}
