import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    // Filter purchase transactions
    final purchases = appState.transactions.where((tx) {
      final isPurchase = tx.type == TransactionType.purchase;
      final matchesSearch = tx.partyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          tx.invoiceNo.toLowerCase().contains(_searchQuery.toLowerCase());
      return isPurchase && matchesSearch;
    }).toList();

    final totalPurchaseAmount = appState.transactions
        .where((tx) => tx.type == TransactionType.purchase)
        .fold<double>(0.0, (sum, tx) => sum + tx.amount);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Purchase List",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, color: Colors.grey),
            onPressed: () {
              // Show a simple search dialog or expand a search field
              _showSearchDialog();
            },
          ),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.shade600,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                "Pdf",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Generating Purchase List PDF...")),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Total Purchase Summary Card (Sitting on a light blue gradient)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue.shade50],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Total Purchase",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatCurrency.format(totalPurchaseAmount),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 2. Main content: Purchases list or empty state
          Expanded(
            child: Container(
              color: const Color(0xFFEFF6FF), // Soft light blue background
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (purchases.isEmpty)
                    // Empty state matching Screenshot 1
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildReceiptIllustration(),
                          const SizedBox(height: 24),
                          const Text(
                            "No Data Available",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "No purchase details are available.\nPlease try again after making a purchase.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 80), // offset for button
                        ],
                      ),
                    )
                  else
                    // List of purchases
                    ListView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 85),
                      itemCount: purchases.length,
                      itemBuilder: (context, index) {
                        final tx = purchases[index];
                        return Card(
                          elevation: 0.5,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              tx.partyName.isEmpty ? "Direct Purchase" : tx.partyName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              "Inv: ${tx.invoiceNo} • ${DateFormat('dd MMM yyyy').format(tx.date)}",
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            trailing: Text(
                              formatCurrency.format(tx.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.red, // Purchase is red/negative outflow
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // 3. Bottom Pill Button "+ Add Purchase"
                  Positioned(
                    bottom: 32,
                    child: SizedBox(
                      width: 200,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        label: const Text(
                          "Add Purchase",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AddTransactionScreen(initialType: TransactionType.purchase),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFDC2626), // Vibrant red matching screenshot
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptIllustration() {
    return Container(
      width: 140,
      height: 140,
      decoration: const BoxDecoration(
        color: Color(0xFFFEF3C7), // Soft yellow circle
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Sparkle elements around
          Positioned(
            top: 20,
            left: 20,
            child: Icon(Icons.star_rounded, color: Colors.amber.shade200, size: 16),
          ),
          Positioned(
            bottom: 30,
            left: 15,
            child: Icon(Icons.star_rounded, color: Colors.amber.shade200, size: 14),
          ),
          Positioned(
            top: 40,
            right: 15,
            child: Icon(Icons.star_rounded, color: Colors.amber.shade200, size: 18),
          ),
          // The receipt sheet
          Container(
            width: 66,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 46, height: 3, color: Colors.grey.shade200),
                const SizedBox(height: 6),
                Container(width: 40, height: 3, color: Colors.grey.shade200),
                const SizedBox(height: 6),
                Container(width: 35, height: 3, color: Colors.grey.shade200),
                const SizedBox(height: 6),
                Container(width: 42, height: 3, color: Colors.grey.shade200),
                const SizedBox(height: 8),
                Container(width: 46, height: 1, color: Colors.grey.shade300),
                const SizedBox(height: 4),
                Container(width: 25, height: 4, color: Colors.amber.shade600),
              ],
            ),
          ),
          // Brown bottom roll edge
          Positioned(
            bottom: 36,
            child: Container(
              width: 72,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFFD97706), // Orange-brown bottom roll
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) {
        final ctrl = TextEditingController(text: _searchQuery);
        return AlertDialog(
          title: const Text("Search Purchase"),
          content: TextField(
            controller: ctrl,
            decoration: const InputDecoration(
              hintText: "Enter supplier name or invoice no...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _searchQuery = ctrl.text.trim();
                });
                Navigator.pop(context);
              },
              child: const Text("Search"),
            ),
          ],
        );
      },
    );
  }
}
