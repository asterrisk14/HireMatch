import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../shared/pdf/pdf_table.dart';
import 'applications_service.dart';

Future<List<int>> buildApplicationsReportPdf(
  List<Application> applications,
) async {
  final doc = pw.Document();
  final now = DateFormat('dd.MM.yyyy').format(DateTime.now());

  doc.addPage(
    pw.MultiPage(
      build: (context) => [
        pw.Text(
          'Job Applications Report',
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
        pw.Text(
          'Total applications: ${applications.length}',
          style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
        ),
        pw.SizedBox(height: 16),
        buildPdfTable(
          ['Candidate', 'Email', 'Position', 'Status', 'Applied'],
          applications
              .map(
                (a) => [
                  a.candidateFullName,
                  a.candidateEmail,
                  a.jobPostTitle,
                  a.applicationStatusName,
                  DateFormat('dd.MM.yyyy').format(a.appliedAt),
                ],
              )
              .toList(),
        ),
      ],
    ),
  );

  return doc.save();
}
