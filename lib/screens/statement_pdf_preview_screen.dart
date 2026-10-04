import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../services/statement_pdf_service.dart';
import '../theme/app_theme.dart';
import '../widgets/share_transaction_modal.dart';
import '../widgets/three_d_button.dart';

class StatementPdfPreviewScreen extends StatefulWidget {
  final Party party;
  final List<Transaction> transactions;

  const StatementPdfPreviewScreen({
    super.key,
    required this.party,
    required this.transactions,
  });

  @override
  State<StatementPdfPreviewScreen> createState() => _StatementPdfPreviewScreenState();
}

class _StatementPdfPreviewScreenState extends State<StatementPdfPreviewScreen> {
  bool _isGeneratingPdf = false;

  Future<void> _printOrOpenPdf(BuildContext context) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfBytes = await StatementPdfService.generatePartyStatementPdf(
        party: widget.party,
        transactions: widget.transactions,
        companyName: "J.M.D BOOK STORE",
        companyAddress: "Usha complex, Sahlaur bazar ,Surwala road, Siwan",
        companyPhone: "9431680249",
        companyEmail: "jmdbookstoresiwan@gmail.com",
      );
      await Printing.layoutPdf(
        onLayout: (format) async => pdfBytes,
        name: "Statement_${widget.party.name.replaceAll(' ', '_')}.pdf",
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error opening PDF: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    setState(() => _isGeneratingPdf = true);
    try {
      final pdfBytes = await StatementPdfService.generatePartyStatementPdf(
        party: widget.party,
        transactions: widget.transactions,
        companyName: "J.M.D BOOK STORE",
        companyAddress: "Usha complex, Sahlaur bazar ,Surwala road, Siwan",
        companyPhone: "9431680249",
        companyEmail: "jmdbookstoresiwan@gmail.com",
      );
      await Printing.sharePdf(
        bytes: pdfBytes,
        filename: "Statement_${widget.party.name.replaceAll(' ', '_')}.pdf",
      );
    } catch (_) {
      ShareTransactionModal.show(context, party: widget.party);
    } finally {
      if (mounted) setState(() => _isGeneratingPdf = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
    final formatDate = DateFormat('dd/MM/yyyy');

    final startDate = widget.transactions.isNotEmpty ? widget.transactions.last.date : DateTime.now();
    final endDate = DateTime.now();

    // Calculate running balance and totals for visual preview
    double runningBalance = widget.party.openingBalance;
    double totalDebit = widget.party.type == PartyType.youWillGet ? widget.party.openingBalance : 0.0;
    double totalCredit = widget.party.type == PartyType.youWillGive ? widget.party.openingBalance : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text("Party Statement - ${widget.party.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.print_outlined, color: AppTheme.accentBlue),
            tooltip: "Print / Save PDF",
            onPressed: () => _printOrOpenPdf(context),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: AppTheme.successGreen),
            tooltip: "Share Statement",
            onPressed: () => _sharePdf(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Top Action Toolbar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: ThreeDButton(
                      height: 42,
                      color: AppTheme.accentBlue,
                      textColor: Colors.white,
                      icon: Icons.picture_as_pdf_rounded,
                      text: _isGeneratingPdf ? "Opening..." : "Print / PDF",
                      onPressed: () => _printOrOpenPdf(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ThreeDButton(
                      height: 42,
                      color: AppTheme.successGreen,
                      textColor: Colors.white,
                      icon: Icons.share_rounded,
                      text: "Share",
                      onPressed: () => _sharePdf(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // In-App Interactive Statement Preview Sheet (Matches Screenshot 2)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 6)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Row (Logo Placeholder & Store Info)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Store Logo Placeholder Box
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
                          borderRadius: BorderRadius.circular(10),
                          color: const Color(0xFFF8FAFC),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.menu_book_rounded, color: Color(0xFFD97706), size: 24),
                            SizedBox(height: 2),
                            Text("STORE LOGO", style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                          ],
                        ),
                      ),
                      // Store Header Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: const [
                            Text(
                              "J.M.D BOOK STORE",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Usha complex, Sahlaur bazar ,Surwala road, Siwan",
                              style: TextStyle(fontSize: 10, color: Color(0xFF475569)),
                              textAlign: TextAlign.right,
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Phone no.: 9431680249  Email: jmdbookstoresiwan@gmail.com",
                              style: TextStyle(fontSize: 9, color: Color(0xFF64748B)),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(color: Color(0xFFCBD5E1), thickness: 1),
                  const SizedBox(height: 12),

                  // 2. Title: Party Statement
                  const Center(
                    child: Text(
                      "Party Statement",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 3. Party Info Block
                  Text(
                    "Party name: ${widget.party.name}",
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "Contact no.: ${widget.party.phone.isEmpty ? 'N/A' : widget.party.phone}",
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                  Text(
                    "Address: ${widget.party.address.isEmpty ? 's r public school sarari' : widget.party.address}",
                    style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Duration: From ${formatDate.format(startDate)} to ${formatDate.format(endDate)}",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  ),
                  const SizedBox(height: 16),

                  // 4. Statement Table (Matches Screenshot 2)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(color: const Color(0xFFCBD5E1), width: 1),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: [
                        // Table Header Row
                        TableRow(
                          decoration: const BoxDecoration(color: Color(0xFFE2E8F0)),
                          children: const [
                            Padding(padding: EdgeInsets.all(8), child: Text("Date", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Padding(padding: EdgeInsets.all(8), child: Text("Txn Type", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Padding(padding: EdgeInsets.all(8), child: Text("Invoice/ Bill No.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Padding(padding: EdgeInsets.all(8), child: Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            Padding(padding: EdgeInsets.all(8), child: Text("Debit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.right)),
                            Padding(padding: EdgeInsets.all(8), child: Text("Credit", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.right)),
                            Padding(padding: EdgeInsets.all(8), child: Text("Running Balance", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.right)),
                          ],
                        ),

                        // Beginning Balance Row
                        TableRow(
                          children: [
                            Padding(padding: const EdgeInsets.all(8), child: Text(formatDate.format(startDate), style: const TextStyle(fontSize: 10))),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                widget.party.type == PartyType.youWillGet ? "Receivable Beginning Balance" : "Payable Beginning Balance",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Padding(padding: EdgeInsets.all(8), child: Text("-", style: TextStyle(fontSize: 10))),
                            const Padding(padding: EdgeInsets.all(8), child: Text("-", style: TextStyle(fontSize: 10))),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(widget.party.type == PartyType.youWillGet ? formatCurrency.format(widget.party.openingBalance) : "-", style: const TextStyle(fontSize: 10), textAlign: TextAlign.right),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(widget.party.type == PartyType.youWillGive ? formatCurrency.format(widget.party.openingBalance) : "-", style: const TextStyle(fontSize: 10), textAlign: TextAlign.right),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                "${formatCurrency.format(widget.party.openingBalance)} (${widget.party.type == PartyType.youWillGet ? 'Dr' : 'Cr'})",
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),

                        // Transaction Rows
                        ...widget.transactions.map((tx) {
                          final isDebit = (tx.type == TransactionType.sale || tx.type == TransactionType.paymentOut);
                          if (isDebit) {
                            runningBalance += tx.amount;
                            totalDebit += tx.amount;
                          } else {
                            runningBalance -= tx.amount;
                            totalCredit += tx.amount;
                          }

                          final typeLabel = tx.type == TransactionType.sale
                              ? "Sale Bill"
                              : tx.type == TransactionType.paymentIn
                                  ? "Payment-in"
                                  : tx.type == TransactionType.paymentOut
                                      ? "Payment-out"
                                      : tx.type.name;

                          return TableRow(
                            children: [
                              Padding(padding: const EdgeInsets.all(8), child: Text(formatDate.format(tx.date), style: const TextStyle(fontSize: 10))),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(typeLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                    if (tx.paymentType.isNotEmpty && tx.paymentType != 'Credit')
                                      Text("Payment Type: ${tx.paymentType}", style: const TextStyle(fontSize: 9, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                              Padding(padding: const EdgeInsets.all(8), child: Text(tx.invoiceNo.isEmpty ? '-' : tx.invoiceNo, style: const TextStyle(fontSize: 10))),
                              const Padding(padding: EdgeInsets.all(8), child: Text("Unused", style: TextStyle(fontSize: 10))),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(isDebit ? formatCurrency.format(tx.amount) : "-", style: const TextStyle(fontSize: 10), textAlign: TextAlign.right),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(!isDebit ? formatCurrency.format(tx.amount) : "-", style: const TextStyle(fontSize: 10), textAlign: TextAlign.right),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  "${formatCurrency.format(runningBalance.abs())} (${runningBalance >= 0 ? 'Dr' : 'Cr'})",
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.right,
                                ),
                              ),
                            ],
                          );
                        }),

                        // Total Summary Row
                        TableRow(
                          decoration: const BoxDecoration(color: Color(0xFFCBD5E1)),
                          children: [
                            const Padding(padding: EdgeInsets.all(8), child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
                            const Padding(padding: EdgeInsets.all(8), child: Text("")),
                            const Padding(padding: EdgeInsets.all(8), child: Text("")),
                            const Padding(padding: EdgeInsets.all(8), child: Text("")),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(formatCurrency.format(totalDebit), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.right),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(formatCurrency.format(totalCredit), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), textAlign: TextAlign.right),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                "${formatCurrency.format(widget.party.currentBalance)} (${widget.party.type == PartyType.youWillGet ? 'Dr' : 'Cr'})",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
