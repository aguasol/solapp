import 'package:flutter/material.dart';
import 'package:appsol_final/components/navegador.dart';
import 'package:lottie/lottie.dart';

class Fin extends StatefulWidget {
  const Fin({super.key});

  @override
  State<Fin> createState() => _FinState();
}

class _FinState extends State<Fin> {
  double tamanoTexto = 0.0;
  @override
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    tamanoTexto = largoActual * 0.037;

    return Scaffold(
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
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
            ], begin: Alignment.topLeft, end: Alignment.bottomCenter)),
            child: SafeArea(
                child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: largoActual * 0.7,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child:
                                Stack(alignment: Alignment.center, children: [
                              Lottie.asset(
                                'lib/imagenes/check10.json',
                                height: anchoActual * 1,
                              ),
                              Positioned(
                                right: largoActual * 0.07,
                                bottom: largoActual * 0.18,
                                child: Lottie.asset(
                                  'lib/imagenes/check3.json',
                                  height: anchoActual * 0.35,
                                ),
                              ),
                              Positioned(
                                top: 0.02,
                                child: SizedBox(
                                  width: anchoActual * 0.8,
                                  child: Text(
                                    "Gracias por confiar en Agua Sol para llevar VIDA A TU HOGAR",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w300,
                                        fontSize: tamanoTexto),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: largoActual * 0.04,
                                child: Container(
                                  height: largoActual * 0.081,
                                  //color:Colors.grey,
                                  width: anchoActual * 0.39,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const BarraNavegacion(
                                                  indice: 0,
                                                  subIndice: 0,
                                                )),
                                      );
                                    },
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                const Color.fromRGBO(
                                                    0, 106, 252, 1.000))),
                                    child: Text(
                                      "Menú",
                                      style: TextStyle(
                                          fontSize: largoActual * 0.027,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              )
                            ]),
                          ),
                        ]))),
          ),
        ));
  }
}
