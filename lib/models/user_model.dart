class UserModel {
  final int id;
  final String nombre;
  final String apellidos;
  String? sexo;
  double? saldoBeneficio;
  String? codigocliente;
  String? fechaCreacionCuenta;
  String? suscripcion;
  String? frecuencia;
  bool? quiereRetirar;
  bool esNuevo;


  // Agrega más atributos según sea necesario

  UserModel({
    required this.id,
    required this.nombre,
    required this.apellidos,
    this.sexo,
    this.saldoBeneficio,
    this.codigocliente,
    this.fechaCreacionCuenta,
    this.suscripcion,
    this.frecuencia,
    this.quiereRetirar,


    this.esNuevo = false,
    // Agrega más parámetros según sea necesario
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['usuario']['id'] ?? 0,
      nombre: json['usuario']['nombre'] ?? '',
      apellidos: json['usuario']['apellidos'] ?? '',
      saldoBeneficio: json['usuario']['saldo_beneficios'].toDouble(),
      codigocliente: json['usuario']['codigo'],
      fechaCreacionCuenta: json['usuario']['fecha_creacion_cuenta'],
      suscripcion: json['usuario']['suscripcion'],

      // Agrega más inicializaciones según sea necesario
    );
  }
}
