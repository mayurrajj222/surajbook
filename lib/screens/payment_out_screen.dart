import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';

class PaymentOutScreen extends StatefulWidget {
  const PaymentOutScreen({super.key});

  @override
  State<PaymentOutScreen> createState() => _PaymentOutScreenState();
}

class _PaymentOutScreenState extends State<PaymentOutScreen> {
  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    // Filter payment out transactions
    final paymentOuts = appState.transactions.where((tx) => tx.type == TransactionType.paymentOut).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "All Transactions",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        backgroundColor: const Color(0xFF0E7490), // Cyan/Teal background matching Screenshot 2
        elevation: 0,
      ),
      body: Container(
        // The background has subtle watermark tile icons
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (paymentOuts.isEmpty)
              // Empty State matching Screenshot 2
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildHandsIllustration(),
                    const SizedBox(height: 32),
                    const Text(
                      "Add your 1st Payment Out",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Record payment given to your parties & easily link them to purchase bills.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 80), // offset for bottom button
                  ],
                ),
              )
            else
              // Payment Out List
              ListView.builder(
                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 85),
                itemCount: paymentOuts.length,
                itemBuilder: (context, index) {
                  final tx = paymentOuts[index];
                  return Card(
                    elevation: 0.5,
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        tx.partyName.isEmpty ? "Payment Out" : tx.partyName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      subtitle: Text(
                        "Ref: ${tx.invoiceNo} • ${DateFormat('dd MMM yyyy').format(tx.date)}",
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      trailing: Text(
                        formatCurrency.format(tx.amount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.red, // Outflow
                        ),
                      ),
                    ),
                  );
                },
              ),

            // Bottom Red CTA Pill Button "+ Give Payment"
            Positioned(
              bottom: 32,
              child: SizedBox(
                width: 220,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add, color: Colors.white, size: 20),
                  label: const Text(
                    "Give Payment",
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
                        builder: (context) => const AddTransactionScreen(initialType: TransactionType.paymentOut),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFFDC2626), // Vibrant red matching Screenshot 2
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
    );
  }

  Widget _buildHandsIllustration() {
    return SizedBox(
      width: 280,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Left hand & arm giving money (red sleeve)
          Positioned(
            left: 10,
            top: 50,
            child: Row(
              children: [
                // Red sleeve/sleeve cuff
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF991B1B), // Red sleeve color
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(4),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                ),
                // Skin arm
                Container(
                  width: 50,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFED7AA), // Peach skin tone
                  ),
                ),
                // Hand wrist details
                Container(
                  width: 15,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFDBA74),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Stack of Green Money bills & Yellow coins on left hand
          Positioned(
            left: 95,
            top: 25,
            child: Column(
              children: [
                // Gold coins
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: 8,
                      height: 15,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFBBF24),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                // Green bills
                Container(
                  width: 50,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4ADE80), // Bright green bill
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: const Color(0xFF16A34A), width: 1.5),
                  ),
                  alignment: Alignment.center,
                  child: Container(
                    width: 32,
                    height: 12,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white.withOpacity(0.8), width: 1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right hand receiving money (blue sleeve)
          Positioned(
            right: 10,
            top: 75,
            child: Row(
              children: [
                // Skin receiving hand
                Container(
                  width: 55,
                  height: 22,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFED7AA), // Peach skin tone
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                    ),
                  ),
                ),
                // Blue sleeve
                Container(
                  width: 40,
                  height: 32,
                  decoration: const BoxDecoration(
                    color: Color(0xFF1E3A8A), // Dark blue sleeve
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
