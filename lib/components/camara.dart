import 'dart:io';
import 'package:appsol_final/components/holaconductor2.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:image_picker/image_picker.dart';

class Camara extends StatefulWidget {
  final int? pedidoID;
  final String? problemasOpago;
  const Camara({
    Key? key,
    this.pedidoID,
    this.problemasOpago,
  }) : super(key: key);

  @override
  State<Camara> createState() => _CamaraState();
}

class _CamaraState extends State<Camara> {
  //late List<CameraDescription> camera;
  late List<CameraDescription> cameras;
  late CameraController cameraController;
  TextEditingController comentarioConductor = TextEditingController();
  String apiUrl = dotenv.env['API_URL'] ?? '';
  String apiPedidosConductor = '/api/pedido_conductor/';
  String comentario = '';
  String observacionPedido = '';
  String estadoNuevo = '';
  String tipoPago = '';
  File? _imageFile;

  Future<void> _takePicture() async {
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

  void esProblemaOesPago() {
    if (widget.problemasOpago == 'pago') {
      setState(() {
        comentario = 'Comentarios';
        estadoNuevo = 'entregado';
        tipoPago = 'yape';
      });
    } else {
      setState(() {
        comentario = 'Detalla los inconvenientes';
        estadoNuevo = 'truncado';
        tipoPago = '';
      });
    }
  }

  Future<List<CameraDescription>> funcion() async {
    List<CameraDescription> cameras = await availableCameras();
    return cameras;
  }

  @override
  void initState() {
    startCamera();
    super.initState();
    esProblemaOesPago();
  }

  bool _cameraInitialized = false;

  void startCamera() async {
    print("somaaa");
    cameras = await availableCameras();

    cameraController = CameraController(cameras[0], ResolutionPreset.high);

    print(" Camera controller : $cameraController");

    cameraController.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {
        _cameraInitialized =
            true; // updating the flag after camera is initialized
      }); //To refresh widget
    }).catchError((e) {
      print(e);
    });
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

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    if (_cameraInitialized && cameraController.value.isInitialized) {
      return Scaffold(
          body: SafeArea(
              top: false,
              child: Padding(
                  padding: const EdgeInsets.all(0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            //CAAMARA
                            Container(
                              height: largoActual,
                              width: MediaQuery.of(context).size.width <= 480
                                  ? 430
                                  : 300,
                              padding: const EdgeInsets.all(10),
                              child: CameraPreview(cameraController),
                            ),
                            //BOTON DE REGRESO
                            Positioned(
                              top: anchoActual *
                                  0.09, // Ajusta la posición vertical según tus necesidades
                              left: anchoActual *
                                  0.05, // Ajusta la posición horizontal según tus necesidades
                              child: SizedBox(
                                height: anchoActual * 0.12,
                                width: anchoActual * 0.12,
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              const HolaConductor2()),
                                    );
                                  },
                                  child: const Icon(Icons.arrow_back,
                                      color:
                                          Color.fromARGB(255, 119, 119, 119)),
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(8),
                                    fixedSize: MaterialStatePropertyAll(Size(
                                        anchoActual * 0.14,
                                        largoActual * 0.14)),
                                    backgroundColor: MaterialStateProperty.all(
                                        const Color.fromRGBO(230, 230, 230, 1)),
                                    surfaceTintColor: MaterialStateProperty.all(
                                        const Color.fromRGBO(230, 230, 230, 1)),
                                  ),
                                ),
                              ),
                            ),

                            //BOTONES DE TOMAR FOTO ACEPTAR Y DESCARTAR
                            Positioned(
                              bottom: largoActual * 0.01,
                              child: SizedBox(
                                width: anchoActual,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    //BOTON DE TOMAR FOTO
                                    FloatingActionButton(
                                      onPressed: _takePicture,
                                      backgroundColor: Colors.black,
                                      child: const Icon(
                                        Icons.camera_alt,
                                        color: Colors.white,
                                      ),
                                    ),
                                    //BOTON DE ACEPTAR FOTO
                                    ElevatedButton(
                                      onPressed: () async {
                                        try {
                                          if (_imageFile != null) {
                                            final pass =
                                                await getApplicationDocumentsDirectory();
                                            final otro = path.join(
                                                pass.path, 'pictures');
                                            final String fileName =
                                                '${widget.pedidoID}.jpg';
                                            String filePath = '$otro/$fileName';
                                            final nuevaFoto =
                                                XFile(_imageFile!.path);
                                            nuevaFoto.saveTo(filePath);
                                            deletePhoto(_imageFile!.path);
                                            setState(() {
                                              _imageFile = null;
                                            });
                                            showModalBottomSheet(
                                                backgroundColor: Color.fromRGBO(
                                                    0, 106, 252, 1.000),
                                                context: context,
                                                isScrollControlled: true,
                                                builder: (context) {
                                                  return Padding(
                                                    padding: EdgeInsets.only(
                                                        bottom: MediaQuery.of(
                                                                context)
                                                            .viewInsets
                                                            .bottom),
                                                    child: Container(
                                                      height:
                                                          largoActual * 0.15,
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
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Container(
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                        .white,
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .grey,
                                                                      width:
                                                                          0.5,
                                                                    ),
                                                                  ),
                                                                  child:
                                                                      TextField(
                                                                    decoration: InputDecoration(
                                                                        hintText:
                                                                            comentario),
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
                                                                height: 40,
                                                                width:
                                                                    anchoActual *
                                                                        0.83,
                                                                child:
                                                                    ElevatedButton(
                                                                        onPressed:
                                                                            () {
                                                                          updateEstadoPedido(
                                                                              estadoNuevo,
                                                                              null,
                                                                              comentarioConductor.text,
                                                                              tipoPago,
                                                                              widget.pedidoID);
                                                                          Navigator
                                                                              .push(
                                                                            context,
                                                                            //REGRESA A LA VISTA DE HOME PERO ACTUALIZA EL PEDIDO
                                                                            MaterialPageRoute(builder: (context) => const HolaConductor2()),
                                                                          );
                                                                        },
                                                                        style: ButtonStyle(
                                                                            elevation: MaterialStateProperty.all(
                                                                                8),
                                                                            surfaceTintColor: MaterialStateProperty.all(Colors
                                                                                .white),
                                                                            backgroundColor: MaterialStateProperty.all(Colors
                                                                                .white)),
                                                                        child:
                                                                            const Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.center,
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
                                        } catch (e) {
                                          print('Algun error: $e');
                                        }
                                      },
                                      child: Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      ),
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.black)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ]))));
    } else {
      return Scaffold(
        body: Container(
          child: Center(
            child: Text(
              "... Detectando Cámara",
              style: TextStyle(fontSize: 30),
            ),
          ),
        ),
      );
    }
  }
}
