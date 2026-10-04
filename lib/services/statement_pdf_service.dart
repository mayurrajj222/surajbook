import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class StatementPdfService {
  static Future<Uint8List> generatePartyStatementPdf({
    required Party party,
    required List<Transaction> transactions,
    required String companyName,
    required String companyAddress,
    required String companyPhone,
    required String companyEmail,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Load Unicode Google Fonts to prevent any font encoding exceptions (supports ₹ symbol & all unicode)
    pw.Font fontRegular;
    pw.Font fontBold;
    try {
      fontRegular = await PdfGoogleFonts.robotoRegular();
      fontBold = await PdfGoogleFonts.robotoBold();
    } catch (_) {
      fontRegular = pw.Font.helvetica();
      fontBold = pw.Font.helveticaBold();
    }

    final pdf = pw.Document(
      theme: pw.ThemeData.withFont(
        base: fontRegular,
        bold: fontBold,
      ),
    );

    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
    final formatDate = DateFormat('dd/MM/yyyy');

    final sDate = startDate ?? (transactions.isNotEmpty ? transactions.last.date : DateTime.now());
    final eDate = endDate ?? DateTime.now();

    // Calculate beginning balance and running totals
    double runningBalance = party.openingBalance;
    double totalDebit = 0.0;
    double totalCredit = 0.0;

    if (party.type == PartyType.youWillGet) {
      totalDebit += party.openingBalance;
    } else {
      totalCredit += party.openingBalance;
    }

    final tableRows = <pw.TableRow>[];

    // Header Row of Table
    tableRows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('Date', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('Txn Type', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('Invoice/ Bill No.', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('Status', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9)),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('Debit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.right),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('Credit', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.right),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text('Running Balance', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.right),
          ),
        ],
      ),
    );

    // Beginning Balance Row
    final String begTypeStr = party.type == PartyType.youWillGet ? "Receivable Beginning Balance" : "Payable Beginning Balance";
    tableRows.add(
      pw.TableRow(
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(formatDate.format(sDate), style: const pw.TextStyle(fontSize: 8))),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(begTypeStr, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold))),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('-', style: const pw.TextStyle(fontSize: 8))),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('-', style: const pw.TextStyle(fontSize: 8))),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(party.type == PartyType.youWillGet ? formatCurrency.format(party.openingBalance) : '-', style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(party.type == PartyType.youWillGive ? formatCurrency.format(party.openingBalance) : '-', style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text("${formatCurrency.format(party.openingBalance)} (${party.type == PartyType.youWillGet ? 'Dr' : 'Cr'})", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
          ),
        ],
      ),
    );

    // Populate transaction rows
    for (final tx in transactions) {
      final isDebit = (tx.type == TransactionType.sale || tx.type == TransactionType.paymentOut);
      if (isDebit) {
        runningBalance += tx.amount;
        totalDebit += tx.amount;
      } else {
        runningBalance -= tx.amount;
        totalCredit += tx.amount;
      }

      final String typeLabel;
      switch (tx.type) {
        case TransactionType.sale:
          typeLabel = "Sale Bill";
          break;
        case TransactionType.paymentIn:
          typeLabel = "Payment-in";
          break;
        case TransactionType.paymentOut:
          typeLabel = "Payment-out";
          break;
        case TransactionType.purchase:
          typeLabel = "Purchase Bill";
          break;
        case TransactionType.saleReturn:
          typeLabel = "Sale Return";
          break;
        default:
          typeLabel = tx.type.name;
      }

      tableRows.add(
        pw.TableRow(
          children: [
            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(formatDate.format(tx.date), style: const pw.TextStyle(fontSize: 8))),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(typeLabel, style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold)),
                  if (tx.paymentType.isNotEmpty && tx.paymentType != 'Credit')
                    pw.Text("Payment Type: ${tx.paymentType}", style: const pw.TextStyle(fontSize: 7, color: PdfColors.grey700)),
                ],
              ),
            ),
            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(tx.invoiceNo.isEmpty ? '-' : tx.invoiceNo, style: const pw.TextStyle(fontSize: 8))),
            pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Unused', style: const pw.TextStyle(fontSize: 8))),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(isDebit ? formatCurrency.format(tx.amount) : '-', style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text(!isDebit ? formatCurrency.format(tx.amount) : '-', style: const pw.TextStyle(fontSize: 8), textAlign: pw.TextAlign.right),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(6),
              child: pw.Text("${formatCurrency.format(runningBalance.abs())} (${runningBalance >= 0 ? 'Dr' : 'Cr'})", style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold), textAlign: pw.TextAlign.right),
            ),
          ],
        ),
      );
    }

    // Total Row
    tableRows.add(
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColors.grey300),
        children: [
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('Total', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9))),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('')),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('')),
          pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text('')),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(formatCurrency.format(totalDebit), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.right),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text(formatCurrency.format(totalCredit), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.right),
          ),
          pw.Padding(
            padding: const pw.EdgeInsets.all(6),
            child: pw.Text("${formatCurrency.format(party.currentBalance)} (${party.type == PartyType.youWillGet ? 'Dr' : 'Cr'})", style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 9), textAlign: pw.TextAlign.right),
          ),
        ],
      ),
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) => [
          // Header Section (Logo Placeholder on left, Store details on right)
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Logo Placeholder Box
              pw.Container(
                width: 70,
                height: 70,
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400, width: 1),
                  borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
                ),
                child: pw.Center(
                  child: pw.Column(
                    mainAxisAlignment: pw.MainAxisAlignment.center,
                    children: [
                      pw.Text('STORE LOGO', style: pw.TextStyle(fontSize: 7, fontWeight: pw.FontWeight.bold, color: PdfColors.grey700)),
                      pw.Text('Placeholder', style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey600)),
                    ],
                  ),
                ),
              ),
              // Store Header Details
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(companyName, style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 2),
                  pw.Text(companyAddress, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                  pw.SizedBox(height: 2),
                  pw.Text("Phone no.: $companyPhone  Email: $companyEmail", style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey800)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Divider(color: PdfColors.grey400, thickness: 1),
          pw.SizedBox(height: 12),

          // Title: Party Statement
          pw.Center(
            child: pw.Text(
              'Party Statement',
              style: pw.TextStyle(
                fontSize: 18,
                fontWeight: pw.FontWeight.bold,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ),
          pw.SizedBox(height: 14),

          // Party Info Block
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Party name: ${party.name}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 2),
              pw.Text('Contact no.: ${party.phone.isEmpty ? "N/A" : party.phone}', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 2),
              pw.Text('Address: ${party.address.isEmpty ? "N/A" : party.address}', style: const pw.TextStyle(fontSize: 10)),
              pw.SizedBox(height: 8),
              pw.Text('Duration: From ${formatDate.format(sDate)} to ${formatDate.format(eDate)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.SizedBox(height: 14),

          // Statement Table
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(1.8),
              2: const pw.FlexColumnWidth(1.4),
              3: const pw.FlexColumnWidth(1.0),
              4: const pw.FlexColumnWidth(1.4),
              5: const pw.FlexColumnWidth(1.4),
              6: const pw.FlexColumnWidth(1.6),
            },
            children: tableRows,
          ),
        ],
      ),
    );

    return pdf.save();
  }
}
