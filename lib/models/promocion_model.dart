class Promo {
  final int id;
  final String nombre;
  final double precio;
  final String descripcion;
  final String fechaLimite;
  final String foto;
  int cantidad;

  Promo(
      {required this.id,
      required this.nombre,
      required this.precio,
      required this.descripcion,
      required this.fechaLimite,
      required this.foto,
      this.cantidad = 0});
}
