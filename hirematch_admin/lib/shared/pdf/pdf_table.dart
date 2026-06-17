import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

pw.Widget buildPdfTable(List<String> headers, List<List<String>> rows) {
  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.teal800),
        children: headers
            .map(
              (h) => pw.Padding(
                padding: const pw.EdgeInsets.all(6),
                child: pw.Text(
                  h,
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            )
            .toList(),
      ),
      ...rows.map(
        (row) => pw.TableRow(
          children: row
              .map(
                (cell) => pw.Padding(
                  padding: const pw.EdgeInsets.all(6),
                  child: pw.Text(cell, style: const pw.TextStyle(fontSize: 9)),
                ),
              )
              .toList(),
        ),
      ),
    ],
  );
}
