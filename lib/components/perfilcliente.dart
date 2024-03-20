import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
import 'package:lottie/lottie.dart';

class PerfilCliente extends StatefulWidget {
  const PerfilCliente({Key? key}) : super(key: key);
  @override
  _PerfilCliente createState() => _PerfilCliente();
}

class _PerfilCliente extends State<PerfilCliente> {
  //Color colorLetra = Color.fromARGB(255, 1, 75, 135);
  Color colorTitulos = const Color.fromARGB(255, 3, 34, 60);
  //Color colorTitulos = Color.fromARGB(255, 1, 42, 76);
  Color colorLetra = const Color.fromARGB(255, 1, 42, 76);
  String apiUrl = dotenv.env['API_URL'] ?? '';
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
  Widget build(BuildContext context) {
    final anchoActual = MediaQuery.of(context).size.width;
    final largoActual = MediaQuery.of(context).size.height;
    final userProvider = context.watch<UserProvider>();
    fechaLimite = mesyAnio(userProvider.user?.fechaCreacionCuenta)
        .add(const Duration(days: (30 * 3)));
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
          child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(bottom: 20, left: 20, right: 20),
            child: Row(
              children: [
                //FOTO DEL CLIENTE
                Container(
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 218, 218, 218),
                      borderRadius: BorderRadius.circular(40)),
                  height: 60,
                  width: 70,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    //poner un if por aqui por si es hombre o mujer
                    child: Icon(
                      Icons.man_2_rounded,
                      color: colorTitulos,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 30,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //Nombre
                    Text(
                      '${userProvider.user?.nombre} ${userProvider.user?.apellidos}',
                      style: TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 18,
                          color: colorTitulos),
                    ),
                    //Correo
                    Text(
                      'Codigo: ${userProvider.user?.codigocliente}',
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                          color: colorTitulos),
                    ),
                    //Numero
                    Text(
                      '${userProvider.user?.suscripcion}',
                      style: TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 15,
                          color: colorTitulos),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.only(bottom: 10, left: 10, right: 10),
            child: Row(
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
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, top: 3, bottom: 10),
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.person_2_outlined,
                              color: colorLetra,
                              size: 45,
                            ),
                          ),
                          Text(
                            'Info. Pesonal',
                            style: TextStyle(
                                color: colorLetra,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
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
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.beach_access_outlined,
                              size: 45,
                              color: colorLetra,
                            ),
                          ),
                          Text(
                            ' Membre Sol ',
                            style: TextStyle(
                                color: colorLetra,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
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
                      margin: const EdgeInsets.only(
                          left: 10, right: 10, top: 5, bottom: 5),
                      child: Column(
                        children: [
                          IconButton(
                            onPressed: () {},
                            icon: Icon(
                              Icons.discount_outlined,
                              color: colorLetra,
                              size: 45,
                            ),
                          ),
                          Text(
                            '    Cupones    ',
                            style: TextStyle(
                                color: colorLetra,
                                fontWeight: FontWeight.w400,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          //BILLETERA SOL
          Container(
            margin: const EdgeInsets.only(bottom: 10, left: 20),
            child: Text(
              "Billetera Sol",
              style: TextStyle(
                  color: colorTitulos,
                  fontWeight: FontWeight.w600,
                  fontSize: largoActual * (16 / 760)),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
            height: largoActual * 0.23,
            child: Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                surfaceTintColor: Colors.white,
                color: Colors.white,
                elevation: 8,
                child: Container(
                  margin: const EdgeInsets.only(
                      left: 40, right: 40, bottom: 10, top: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          /** SARITA =) YA ESTA EL END POINT DE SALDO SERA QU LO PRUEBS  */
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                                    fontSize: 14),
                              ),
                            ],
                          ),
                          Container(
                            height: largoActual * (80 / 760),
                            width: anchoActual * (61 / 360),
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              //color: Colors.amberAccent,
                              borderRadius: BorderRadius.circular(0),
                            ),
                            child: Lottie.asset('lib/imagenes/billetera3.json'),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: largoActual * 0.02,
                      ),
                      SizedBox(
                        width: anchoActual * (168 / 360),
                        height: largoActual * 0.04,
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                String _selectedItem = 'yape o plin';
                                String _secondSelectedItem = 'yape o plin';
                                return AlertDialog(
                                  title: Text('Selecciona un metodo de retiro'),
                                  content: Column(
                                    children: [
                                      DropdownButtonFormField<String>(
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            _selectedItem = newValue!;
                                          });
                                        },
                                        onSaved: (value) {
                                          setState(() {
                                            _selectedItem = value!;
                                          });
                                        },
                                        value: _selectedItem,
                                        items: <String>[
                                          'transferencia',
                                          'yape o plin'
                                        ].map<DropdownMenuItem<String>>(
                                            (String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                      SizedBox(height: 20),
                                      if (_selectedItem == 'yape o plin')
                                        DropdownButtonFormField<String>(
                                          value: _secondSelectedItem,
                                          onChanged: (String? newValue) {
                                            setState(() {
                                              _secondSelectedItem = newValue!;
                                            });
                                          },
                                          onSaved: (value) {
                                            setState(() {
                                              _secondSelectedItem = value!;
                                            });
                                          },
                                          items: <String>[
                                            'yape o plin',
                                            'Opción B',
                                            'Opción C',
                                            'Opción D'
                                          ].map<DropdownMenuItem<String>>(
                                              (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(1),
                            minimumSize: MaterialStatePropertyAll(
                                Size(anchoActual * 0.28, largoActual * 0.01)),
                            backgroundColor: MaterialStateProperty.all(
                                const Color.fromRGBO(0, 106, 252, 1.000)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons
                                    .support_agent_rounded, // Reemplaza con el icono que desees
                                size: largoActual * 0.025,
                                color: Colors.white,
                              ),

                              SizedBox(
                                  width: anchoActual *
                                      0.020), // Ajusta el espacio entre el icono y el texto según tus preferencias
                              Text(
                                "Retirar dinero",
                                style: TextStyle(
                                    fontSize: largoActual * 0.021,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
          //CONFIGURACION
          Container(
            margin: const EdgeInsets.only(bottom: 10, left: 20),
            child: Text(
              "Configuración",
              style: TextStyle(
                  color: colorTitulos,
                  fontWeight: FontWeight.w600,
                  fontSize: largoActual * (16 / 760)),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            child: ElevatedButton(
              onPressed: () {},
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
                        Icons.notifications_outlined,
                        color: colorLetra,
                        size: 25,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Notificaciones',
                        style: TextStyle(
                            color: colorLetra,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_right_rounded,
                    color: colorLetra,
                  )
                ],
              ),
            ),
          ),

          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            child: ElevatedButton(
              onPressed: () {},
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
                        Icons.auto_stories_outlined,
                        size: 25,
                        color: colorLetra,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Libro de reclamaciones',
                        style: TextStyle(
                            color: colorLetra,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  Icon(
                    Icons.arrow_right_rounded,
                    color: colorLetra,
                  )
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 10, left: 10),
            child: ElevatedButton(
              onPressed: () {},
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
                        Icons.storefront_rounded,
                        size: 25,
                        color: colorLetra,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Text(
                        'Registra tu tienda',
                        style: TextStyle(
                            color: colorLetra,
                            fontWeight: FontWeight.w400,
                            fontSize: 14),
                      ),
                    ],
                  ),
                  /*
                  SizedBox(
                            width: anchoActual * 0.4,
                            height: largoActual * 0.054,
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const Asistencia()),
                                );
                              },
                              style: ButtonStyle(
                                elevation: MaterialStateProperty.all(8),
                                minimumSize: MaterialStatePropertyAll(Size(
                                    anchoActual * 0.28, largoActual * 0.054)),
                                backgroundColor: MaterialStateProperty.all(
                                    const Color.fromRGBO(0, 106, 252, 1.000)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons
                                        .support_agent_rounded, // Reemplaza con el icono que desees
                                    size: largoActual * 0.025,
                                    color: Colors.white,
                                  ),

                                  SizedBox(
                                      width: anchoActual *
                                          0.020), // Ajusta el espacio entre el icono y el texto según tus preferencias
                                  Text(
                                    "Ayuda",
                                    style: TextStyle(
                                        fontSize: largoActual * 0.021,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        
                  */
                  Icon(
                    Icons.arrow_right_rounded,
                    color: colorLetra,
                  )
                ],
              ),
            ),
          ),
        ]),
      )),
    );
  }
}
