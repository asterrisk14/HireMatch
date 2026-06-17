import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../shared/pdf/pdf_table.dart';
import 'analytics_service.dart';

Future<List<int>> buildAnalyticsReportPdf(AnalyticsStats stats) async {
  final doc = pw.Document();
  final now = DateFormat('dd.MM.yyyy').format(DateTime.now());

  doc.addPage(
    pw.Page(
      build: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'HireMatch Analytics Report',
            style: pw.TextStyle(
              fontSize: 20,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal800,
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            'Generated: $now',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 16),
          buildPdfTable(
            ['Metric', 'Value'],
            [
              ['Jobs posted', stats.jobsPosted.toString()],
              ['Candidates', stats.candidates.toString()],
              ['Applications', stats.applications.toString()],
              ['Total users', stats.totalUsers.toString()],
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Applications by month',
            style: pw.TextStyle(
              fontSize: 13,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.teal800,
            ),
          ),
          pw.SizedBox(height: 8),
          buildPdfTable(
            ['Month', 'Applications'],
            List.generate(
              stats.monthLabels.length,
              (i) => [
                stats.monthLabels[i],
                stats.monthlyApplications[i].toString(),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  return doc.save();
}
