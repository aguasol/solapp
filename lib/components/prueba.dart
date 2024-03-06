


import 'package:flutter/material.dart';
//import 'package:appsol_final/main.dart';

import 'package:provider/provider.dart';
import 'package:appsol_final/provider/user_provider.dart';
class Prueba extends StatelessWidget {
  const Prueba({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    //final userProvider = Provider.of<UserProvider>(context);
    
    return Scaffold(
      appBar: AppBar(title: const Text('Primera página'),),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text("INFOMRACIÓN DEL USUARIO LOGEADO"
            ),
            Text("Id : ${userProvider.user?.id}"
            ),
            Text("Nombres: ${userProvider.user?.nombre}"
            ),
            Text("Apellidos: ${userProvider.user?.apellidos}"),
            Text("CodigoCliente : ${userProvider.user?.codigocliente}"
            ),
            Text("Suscripcion : ${userProvider.user?.suscripcion}"
            ),
        ],
      ),
    );
  }
}