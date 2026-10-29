import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../models/posicion.dart';

class PdfPosiciones {
  static Future<void> generarYCompartir({
    required List<Posicion> posiciones,
  }) async {
    final documento = pw.Document();

    final fecha = DateTime.now();

    final fechaTexto =
        '${fecha.day.toString().padLeft(2, '0')}/'
        '${fecha.month.toString().padLeft(2, '0')}/'
        '${fecha.year}';

    documento.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(28),
        build: (context) => [
          pw.Container(
            width: double.infinity,
            padding: const pw.EdgeInsets.all(16),
            decoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF146B3A),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Text(
                  'FUTBOLMANAGER',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 6),
                pw.Text(
                  'CLASIFICACIÓN GENERAL',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                pw.Text(
                  'Tabla oficial de posiciones',
                  style: const pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 12),

          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Fecha de generación: $fechaTexto',
              style: const pw.TextStyle(fontSize: 9),
            ),
          ),

          pw.SizedBox(height: 12),

          pw.TableHelper.fromTextArray(
            headers: [
              'Pos.',
              'Equipo',
              'PJ',
              'PG',
              'PE',
              'PP',
              'GF',
              'GC',
              'DG',
              'Pts.',
            ],
            data: List.generate(posiciones.length, (index) {
              final posicion = posiciones[index];

              final diferencia = posicion.diferenciaGoles > 0
                  ? '+${posicion.diferenciaGoles}'
                  : '${posicion.diferenciaGoles}';

              return [
                '${index + 1}',
                posicion.nombreEquipo,
                '${posicion.partidosJugados}',
                '${posicion.partidosGanados}',
                '${posicion.partidosEmpatados}',
                '${posicion.partidosPerdidos}',
                '${posicion.golesFavor}',
                '${posicion.golesContra}',
                diferencia,
                '${posicion.puntos}',
              ];
            }),
            headerDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF146B3A),
            ),
            headerStyle: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
            ),
            cellStyle: const pw.TextStyle(fontSize: 9),
            cellAlignment: pw.Alignment.center,
            headerAlignment: pw.Alignment.center,
            cellPadding: const pw.EdgeInsets.all(7),
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            oddRowDecoration: const pw.BoxDecoration(
              color: PdfColor.fromInt(0xFFE3F1E8),
            ),
            columnWidths: {
              0: const pw.FixedColumnWidth(35),
              1: const pw.FlexColumnWidth(3),
              2: const pw.FixedColumnWidth(35),
              3: const pw.FixedColumnWidth(35),
              4: const pw.FixedColumnWidth(35),
              5: const pw.FixedColumnWidth(35),
              6: const pw.FixedColumnWidth(35),
              7: const pw.FixedColumnWidth(35),
              8: const pw.FixedColumnWidth(40),
              9: const pw.FixedColumnWidth(40),
            },
          ),

          pw.SizedBox(height: 14),

          pw.Text(
            'PJ: partidos jugados | PG: ganados | PE: empatados | '
            'PP: perdidos | GF: goles a favor | GC: goles en contra | '
            'DG: diferencia de goles | Pts.: puntos',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),

          pw.SizedBox(height: 6),

          pw.Text(
            'Documento generado con FutbolManager.',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
          ),
        ],
      ),
    );

    final bytes = await documento.save();

    await Printing.sharePdf(
      bytes: bytes,
      filename: 'tabla_general_futbolmanager.pdf',
    );
  }
}
