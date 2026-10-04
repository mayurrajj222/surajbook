import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';

class PurchaseOrderScreen extends StatefulWidget {
  const PurchaseOrderScreen({super.key});

  @override
  State<PurchaseOrderScreen> createState() => _PurchaseOrderScreenState();
}

class _PurchaseOrderScreenState extends State<PurchaseOrderScreen> {
  int _activeFilter = 0; // 0 = All, 1 = Open, 2 = Closed, 3 = Partially Open
  final List<String> _filters = ["All", "Open", "Closed", "Partially Open"];

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    // Filter purchase orders
    final purchaseOrders = appState.transactions.where((tx) => tx.type == TransactionType.purchaseOrder).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Purchase Orders",
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Horizontal Status Chips
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _filters.length,
              itemBuilder: (context, index) {
                final label = _filters[index];
                final isActive = _activeFilter == index;
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _activeFilter = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFFFF1F2) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActive ? const Color(0xFFBE123C) : const Color(0xFFE2E8F0),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isActive ? const Color(0xFFBE123C) : const Color(0xFF64748B),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 2. Main Content
          Expanded(
            child: Container(
              color: const Color(0xFFEFF6FF), // Soft blue background
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (purchaseOrders.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildOrderIllustration(),
                          const SizedBox(height: 24),
                          const Text(
                            "No Purchase Orders",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "Please add your purchase order here.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 85),
                      itemCount: purchaseOrders.length,
                      itemBuilder: (context, index) {
                        final tx = purchaseOrders[index];
                        return Card(
                          elevation: 0.5,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              tx.partyName.isEmpty ? "Purchase Order" : tx.partyName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              "ORD-Ref: ${tx.invoiceNo} • ${DateFormat('dd MMM yyyy').format(tx.date)}",
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            trailing: Text(
                              formatCurrency.format(tx.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // 3. Bottom Pill button "+ Add Order"
                  Positioned(
                    bottom: 32,
                    child: SizedBox(
                      width: 240,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        label: const Text(
                          "Add Purchase Order",
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
                              builder: (context) => const AddTransactionScreen(initialType: TransactionType.purchaseOrder),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFDC2626),
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

  Widget _buildOrderIllustration() {
    return SizedBox(
      width: 180,
      height: 150,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Blue back curl representation
          Positioned(
            right: 25,
            bottom: 30,
            child: Container(
              width: 32,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF1E5CC0),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          Positioned(
            right: 15,
            bottom: 35,
            child: Container(
              width: 25,
              height: 25,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // White document sheet
          Container(
            width: 100,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF2563EB), width: 2),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 50,
                  height: 10,
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 12),
                Container(width: 70, height: 2, color: Colors.grey.shade200),
                const SizedBox(height: 8),
                Container(width: 65, height: 2, color: Colors.grey.shade200),
                const SizedBox(height: 8),
                Container(width: 50, height: 2, color: Colors.grey.shade200),
              ],
            ),
          ),
          // Rupee coin on bottom-right of sheet
          Positioned(
            bottom: 22,
            right: 32,
            child: Container(
              width: 26,
              height: 26,
              decoration: const BoxDecoration(
                color: Color(0xFFFBBF24),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                "₹",
                style: TextStyle(
                  color: Color(0xFFD97706),
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
