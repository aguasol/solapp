import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path/path.dart' as path;

class Pdf extends StatefulWidget {
  final int? rutaID;
  final int? pedidos;
  final int? pedidosEntregados;
  final int? pedidosTruncados;
  final double? totalMonto;
  final double? totalYape;
  final double? totalPlin;
  final double? totalEfectivo;
  final List<int>? idpedidos;
  const Pdf(
      {Key? key,
      this.rutaID,
      this.pedidos,
      this.pedidosEntregados,
      this.pedidosTruncados,
      this.totalMonto,
      this.totalYape,
      this.totalPlin,
      this.totalEfectivo,
      this.idpedidos})
      : super(key: key);

  @override
  State<Pdf> createState() => _PdfState();
}

class _PdfState extends State<Pdf> {
  String pathh = "";

  Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }

  Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getExternalStorageDirectory();
    final file = File('${dir!.path}/$name');
    print("----${dir.path}");

    await file.writeAsBytes(bytes);

    return file;
  }

  List<pw.TableRow> _generateTableRows(List<Uint8List> fotos) {
    List<pw.TableRow> rows = [
      pw.TableRow(children: [
        pw.Text("Ruta",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text("Pedido ID",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text("Cliente",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text("Descuento",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.Text("Foto",
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      ]),
    ];

    for (int idPedido in widget.idpedidos ?? []) {
      rows.add(pw.TableRow(children: [
        pw.Text("data 1"),
        pw.Text("$idPedido"),
        pw.Text("data 2"),
        pw.Text("data 3"),
        pw.Container(
          height: 100,
          width: 50,
          child: pw.Image(
              pw.MemoryImage(fotos[widget.idpedidos!.indexOf(idPedido)])),
        ),
      ]));
    }

    return rows;
  }

  Future<File> _createPDF(String text) async {
    // imagenes
    final ByteData logoEmpresa =
        await rootBundle.load('lib/imagenes/logo_sol_tiny.png');
    Uint8List logoData = (logoEmpresa).buffer.asUint8List();
    List<Uint8List> fotos = [];
    for (var pedido in widget.idpedidos!) {
      final pass = await getApplicationDocumentsDirectory();
      final otro = path.join(pass.path, 'pictures/$pedido.jpg');
      if (File(otro).existsSync()) {
        List<int> bytes = await File(otro).readAsBytes();
        ByteData byteData = ByteData.sublistView(Uint8List.fromList(bytes));
        Uint8List finalByte = (byteData).buffer.asUint8List();
        fotos.add(finalByte);
      } else {
        print("El archivo no existe.");
        fotos.add(logoData);
      }
    }
    print(".......dentro d create");
    final pdf = pw.Document();

    // SECCION 1
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin:
            const pw.EdgeInsets.only(top: 20, left: 10, right: 10, bottom: 20),
        build: (context) => [
          // Titulos
          pw.Center(
            child: pw.Text("Informe de ventas",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 20,
                )),
          ),

          // FECHA
          pw.Center(
            child: pw.Text(
                "Del: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 20,
                )),
          ),

          // DATOS PERSONALES
          pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Container(
                    //color: PdfColor.fromHex('#4B366A'),
                    padding: const pw.EdgeInsets.all(5),
                    decoration: pw.BoxDecoration(
                        borderRadius: pw.BorderRadius.circular(20)),
                    child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Nombres: ",
                              style: const pw.TextStyle(fontSize: 20)),
                          pw.Text("Apellidos: ",
                              style: const pw.TextStyle(fontSize: 20)),
                          pw.Text("Dni: ",
                              style: const pw.TextStyle(fontSize: 20)),
                          pw.Text("Cargo: Conductor",
                              style: const pw.TextStyle(fontSize: 20))
                        ])),
                pw.Container(
                    height: 100,
                    width: 100,
                    child: pw.Image(pw.MemoryImage(logoData)))
              ]),
          pw.SizedBox(height: 5),
          pw.Container(
              child: pw.Text("RESUMEN".toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 15, fontWeight: pw.FontWeight.bold))),
          pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
            pw.Text("Ruta asignada: ${widget.rutaID}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("# pedidos por entregar: ${widget.pedidos}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("# pedidos entregados: ${widget.pedidosEntregados}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("# pedidos truncados: ${widget.pedidosTruncados}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("# cantidad recaudada: ${widget.totalMonto}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("por yape: ${widget.totalYape}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("por efectivo: ${widget.totalEfectivo}",
                style: const pw.TextStyle(fontSize: 20)),
            pw.Text("por plin: ${widget.totalPlin}",
                style: const pw.TextStyle(fontSize: 20))
          ]),
          // TITULO
          pw.Container(
              child: pw.Text(
                  "1.- Detalle de pedidos entregados y pendientes"
                      .toUpperCase(),
                  style: pw.TextStyle(
                      fontSize: 15, fontWeight: pw.FontWeight.bold))),

          pw.SizedBox(
            height: 10,
          ),

          // INFORME
          pw.Container(
              child: pw.Table(
                  border: pw.TableBorder.all(),
                  children: _generateTableRows(fotos))),
        ],
      ),
    );

    return saveDocument(
        name:
            'informe_${DateTime.now().day}_${DateTime.now().month}_${DateTime.now().year}.pdf',
        pdf: pdf);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(children: [
            Container(
              child: const Text("s"),
            ),
            Container(
              child: Text("path ${pathh}"),
            ),
            Container(
              child: ElevatedButton(
                onPressed: () async {
                  final pdfFile = await _createPDF('Sample Text');

                  openFile(pdfFile);
                },
                child: Text("DESCARGAR"),
              ),
            )
          ]),
        ),
      ),
    );
  }
}
