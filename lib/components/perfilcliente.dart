import 'package:appsol_final/components/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:lottie/lottie.dart';

class PerfilCliente extends StatefulWidget {
  const PerfilCliente({Key? key}) : super(key: key);
  @override
  State<PerfilCliente> createState() => _PerfilCliente();
}

class _PerfilCliente extends State<PerfilCliente> {
  Color colorTitulos = const Color.fromARGB(255, 3, 34, 60);
  Color colorLetra = const Color.fromARGB(255, 1, 42, 76);
  Color colorInhabilitado = const Color.fromARGB(255, 130, 130, 130);
  bool estaHabilitado = false;
  String mensajeBanco = 'Numero de celular, cuenta o CCI';
  List<String> mediosString = ['Yape', 'Plin', 'Transferencia'];
  List<String> bancosString = ['BCP', 'BBVA', 'Caja Arequipa', 'Otros'];
  bool esYape = false;
  final TextEditingController _telefono = TextEditingController();
  final TextEditingController _cuenta = TextEditingController();
  String telefono_ = '';
  String cuenta_ = '';
  String apiUrl = dotenv.env['API_URL'] ?? '';
  DateTime fechaLimite = DateTime.now();
  TextEditingController numeroDeCuenta = TextEditingController();
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
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final userProvider = context.watch<UserProvider>();
    fechaLimite = mesyAnio(userProvider.user?.fechaCreacionCuenta)
        .add(const Duration(days: (30 * 3)));
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(anchoActual * 0.04),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            height: largoActual * 0.037,
          ),
          Row(
            children: [
              //FOTO DEL CLIENTE
              Container(
                margin: EdgeInsets.only(left: anchoActual * 0.035),
                decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 218, 218, 218),
                    borderRadius: BorderRadius.circular(50)),
                height: largoActual * 0.085,
                width: anchoActual * 0.18,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  //poner un if por aqui por si es hombre o mujer
                  child: userProvider.user?.sexo == 'femenino'
                      ? Icon(
                          Icons.face_3_rounded,
                          color: colorTitulos,
                          size: anchoActual * 0.14,
                        )
                      : Icon(
                          Icons.face_6_rounded,
                          color: colorTitulos,
                          size: anchoActual * 0.14,
                        ),
                ),
              ),
              SizedBox(
                width: anchoActual * 0.05,
              ),

              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //Nombre
                  Text(
                    '${userProvider.user?.nombre} ${userProvider.user?.apellidos}',
                    style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: largoActual * 0.025,
                        color: colorTitulos),
                  ),
                  //Correo
                  Text(
                    'Codigo: ${userProvider.user?.codigocliente}',
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: largoActual * 0.018,
                        color: colorTitulos),
                  ),
                  //Numero
                  Text(
                    '${userProvider.user?.suscripcion}',
                    style: TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: largoActual * 0.018,
                        color: colorTitulos),
                  ),
                ],
              )
            ],
          ),
          SizedBox(
            height: largoActual * 0.02,
          ),
          //CARDS DE INFOPERSONAL MEMBRE SOL CUPONES
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //CARD DE INFO PERSONAL
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  elevation: 8,
                  child: Container(
                    margin: EdgeInsets.all(anchoActual * 0.02),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            //ACA ACCIONES
                          },
                          icon: Icon(
                            Icons.person_2_outlined,
                            color: colorLetra,
                            size: anchoActual * 0.11,
                          ),
                        ),
                        Text(
                          'Info. Pesonal',
                          style: TextStyle(
                              color: colorLetra,
                              fontWeight: FontWeight.w400,
                              fontSize: largoActual * 0.015),
                        ),
                      ],
                    ),
                  )),
              //CARD DE MEMBRESOL
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  elevation: 8,
                  child: Container(
                    margin: EdgeInsets.all(anchoActual * 0.02),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.beach_access_outlined,
                            size: anchoActual * 0.11,
                            color: colorLetra,
                          ),
                        ),
                        Text(
                          ' Membre Sol ',
                          style: TextStyle(
                              color: colorLetra,
                              fontWeight: FontWeight.w400,
                              fontSize: largoActual * 0.015),
                        ),
                      ],
                    ),
                  )),
              //CARD DE CUPONES
              Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  surfaceTintColor: Colors.white,
                  color: Colors.white,
                  elevation: 8,
                  child: Container(
                    margin: EdgeInsets.all(anchoActual * 0.02),
                    child: Column(
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.discount_outlined,
                            color: colorLetra,
                            size: anchoActual * 0.11,
                          ),
                        ),
                        Text(
                          '    Cupones    ',
                          style: TextStyle(
                              color: colorLetra,
                              fontWeight: FontWeight.w400,
                              fontSize: largoActual * 0.015),
                        ),
                      ],
                    ),
                  )),
            ],
          ),
          SizedBox(
            height: largoActual * 0.01,
          ),
          //BILLETERA SOL
          Container(
            margin: EdgeInsets.only(left: anchoActual * 0.045),
            child: Text(
              "Billetera Sol",
              style: TextStyle(
                  color: colorTitulos,
                  fontWeight: FontWeight.w600,
                  fontSize: largoActual * (16 / 760)),
            ),
          ),
          SizedBox(
            height: largoActual * 0.21,
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                surfaceTintColor: Color.fromRGBO(246, 224, 128, 1.000),
                color: Colors.white,
                elevation: 8,
                child: Container(
                  margin: EdgeInsets.only(
                    left: anchoActual * 0.1,
                    right: anchoActual * 0.1,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'S/. ${userProvider.user?.saldoBeneficio}0',
                            style: TextStyle(
                                color: colorLetra,
                                fontWeight: FontWeight.w700,
                                fontSize: largoActual * 0.045),
                          ),
                          Text(
                            'Retiralo hasta el: ${fechaLimite.day}/${fechaLimite.month}/${fechaLimite.year}',
                            style: TextStyle(
                                color: colorLetra,
                                fontWeight: FontWeight.w400,
                                fontSize: largoActual * 0.016),
                          ),
                          SizedBox(
                            height: largoActual * 0.01,
                          ),
                          SizedBox(
                            width: anchoActual * (168 / 375),
                            height: largoActual * 0.03,
                            child: ElevatedButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    String _selectedItem =
                                        'Seleccione su metodo';
                                    String _otroItem = 'Ingrese su banco';
                                    return AlertDialog(
                                      title: Text(
                                          'Selecciona un metodo de retiro'),
                                      content: StatefulBuilder(
                                        builder: (BuildContext context,
                                            StateSetter setState) {
                                          return Column(
                                            children: [
                                              DropdownButtonFormField<String>(
                                                onChanged: (String? newValue) {
                                                  setState(() {
                                                    _selectedItem = newValue!;
                                                    print(
                                                        'valor: $_selectedItem');
                                                  });
                                                },
                                                value: _selectedItem,
                                                items: <String>[
                                                  'Seleccione su metodo',
                                                  'transferencia',
                                                  'yape o plin'
                                                ].map<DropdownMenuItem<String>>(
                                                    (String value) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: value,
                                                    child: Text(value),
                                                  );
                                                }).toList(),
                                              ),
                                              const SizedBox(height: 20),
                                              Visibility(
                                                visible: _selectedItem ==
                                                    'transferencia',
                                                child: Column(
                                                  children: [
                                                    DropdownButtonFormField<
                                                        String>(
                                                      onChanged:
                                                          (String? newValue) {
                                                        setState(() {
                                                          _otroItem = newValue!;
                                                        });
                                                      },
                                                      value: _otroItem,
                                                      items: <String>[
                                                        'Ingrese su banco',
                                                        'BBVA',
                                                        'BCP',
                                                        'Caja Arequipa',
                                                        'Otros'
                                                      ].map<
                                                              DropdownMenuItem<
                                                                  String>>(
                                                          (String value) {
                                                        return DropdownMenuItem<
                                                            String>(
                                                          value: value,
                                                          child: Text(value),
                                                        );
                                                      }).toList(),
                                                    ),
                                                    TextFormField(
                                                      controller: _cuenta,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText:
                                                            'ingrese su numero de cuenta',
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Por favor, ingrese su numero de cuenta';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        cuenta_ = _cuenta.text;
                                                        _cuenta.text = '';
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      style: ButtonStyle(
                                                        elevation:
                                                            MaterialStateProperty
                                                                .all(8),
                                                        surfaceTintColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .white),
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .white),
                                                      ),
                                                      child: const Text(
                                                        "Aceptar",
                                                        style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              0,
                                                              106,
                                                              252,
                                                              1.000),
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Visibility(
                                                visible: _selectedItem ==
                                                    'yape o plin',
                                                child: Column(
                                                  children: [
                                                    TextFormField(
                                                      controller: _telefono,
                                                      decoration:
                                                          const InputDecoration(
                                                        hintText:
                                                            'ingrese su numero de telefono',
                                                        border:
                                                            InputBorder.none,
                                                      ),
                                                      validator: (value) {
                                                        if (value == null ||
                                                            value.isEmpty) {
                                                          return 'Por favor, ingrese su numero';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        print(_telefono.text);
                                                        telefono_ =
                                                            _telefono.text;
                                                        _telefono.text = '';
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                      style: ButtonStyle(
                                                        elevation:
                                                            MaterialStateProperty
                                                                .all(8),
                                                        surfaceTintColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .white),
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all(Colors
                                                                    .white),
                                                      ),
                                                      child: const Text(
                                                        "Aceptar",
                                                        style: TextStyle(
                                                          color: Color.fromRGBO(
                                                              0,
                                                              106,
                                                              252,
                                                              1.000),
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(1),
                                minimumSize: MaterialStatePropertyAll(Size(
                                    anchoActual * 0.28, largoActual * 0.01)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromRGBO(0, 106, 252, 1.000)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons
                                        .monetization_on_rounded, // Reemplaza con el icono que desees
                                    size: largoActual * 0.02,
                                    color: Colors.white,
                                  ),

                                  SizedBox(
                                      width: anchoActual *
                                          0.020), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                  Text(
                                    "Retirar dinero",
                                    style: TextStyle(
                                        fontSize: largoActual * 0.02,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        height: largoActual * (80 / 760),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          //color: Colors.amberAccent,
                          borderRadius: BorderRadius.circular(0),
                        ),
                        child: Lottie.asset('lib/imagenes/billetera1.json'),
                      ),
                    ],
                  ),
                )),
          ),
          //CONFIGURACION
          SizedBox(
            height: largoActual * 0.01,
          ),
          Container(
            margin: EdgeInsets.only(left: anchoActual * 0.045),
            child: Text(
              "Configuración",
              style: TextStyle(
                  color: colorTitulos,
                  fontWeight: FontWeight.w600,
                  fontSize: largoActual * (16 / 760)),
            ),
          ),
          ElevatedButton(
            onPressed: estaHabilitado
                ? () {
                    //aca se debe ver la info de notificaciones del cliente
                  }
                : null,
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(8),
              surfaceTintColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 255, 255, 255)),
              minimumSize: const MaterialStatePropertyAll(Size(350, 38)),
              backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 221, 221, 221)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.notifications_outlined,
                      color: colorInhabilitado,
                      size: anchoActual * 0.065,
                    ),
                    SizedBox(
                      width: anchoActual * 0.025,
                    ),
                    Text(
                      'Muy pronto',
                      //'Notificaciones',
                      style: TextStyle(
                          color: colorInhabilitado,
                          fontWeight: FontWeight.w400,
                          fontSize: largoActual * 0.018),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_right_rounded,
                  color: colorInhabilitado,
                )
              ],
            ),
          ),

          ElevatedButton(
            onPressed: estaHabilitado
                ? () {
                    //aca se puede va a implementar el libro de reclamaciones
                  }
                : null,
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(8),
              surfaceTintColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 255, 255, 255)),
              minimumSize: const MaterialStatePropertyAll(Size(350, 38)),
              backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 221, 221, 221)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: anchoActual * 0.065,
                      color: colorInhabilitado,
                    ),
                    SizedBox(
                      width: anchoActual * 0.025,
                    ),
                    Text(
                      'Muy pronto',
                      //'Libro de reclamaciones',
                      style: TextStyle(
                          color: colorInhabilitado,
                          fontWeight: FontWeight.w400,
                          fontSize: largoActual * 0.018),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_right_rounded,
                  color: colorInhabilitado,
                )
              ],
            ),
          ),
          ElevatedButton(
            onPressed: estaHabilitado
                ? () {
                    //aca se puede agregar la informacion de la tienda
                  }
                : null,
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(8),
              surfaceTintColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 255, 255, 255)),
              minimumSize: const MaterialStatePropertyAll(Size(350, 38)),
              backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 221, 221, 221)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.storefront_rounded,
                      size: anchoActual * 0.065,
                      color: colorInhabilitado,
                    ),
                    SizedBox(
                      width: anchoActual * 0.025,
                    ),
                    Text(
                      'Muy pronto',
                      //'Registra tu tienda',
                      style: TextStyle(
                          color: colorInhabilitado,
                          fontWeight: FontWeight.w400,
                          fontSize: largoActual * 0.018),
                    ),
                  ],
                ),
                Icon(
                  Icons.arrow_right_rounded,
                  color: colorInhabilitado,
                )
              ],
            ),
          ),
          //CERRAR SESION
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const Login()),
              );
            },
            style: ButtonStyle(
              elevation: MaterialStateProperty.all(8),
              surfaceTintColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 255, 255, 255)),
              minimumSize: const MaterialStatePropertyAll(Size(350, 38)),
              backgroundColor: MaterialStateProperty.all(
                  const Color.fromARGB(255, 255, 255, 255)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.person_outlined,
                      size: anchoActual * 0.065,
                      color: colorLetra,
                    ),
                    SizedBox(
                      width: anchoActual * 0.025,
                    ),
                    Text(
                      'Cerrar sesion',
                      style: TextStyle(
                          color: colorLetra,
                          fontWeight: FontWeight.w400,
                          fontSize: largoActual * 0.018),
                    ),
                  ],
                ),
                Icon(
                  Icons.exit_to_app_rounded,
                  color: colorLetra,
                )
              ],
            ),
          ),
        ]),
      )),
    );
  }
}
