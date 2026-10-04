import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';

class PurchaseReturnScreen extends StatefulWidget {
  const PurchaseReturnScreen({super.key});

  @override
  State<PurchaseReturnScreen> createState() => _PurchaseReturnScreenState();
}

class _PurchaseReturnScreenState extends State<PurchaseReturnScreen> {
  int _activeDateFilter = 0; // 0 = All, 1 = Today, 2 = This Week, 3 = This Month, 4 = Custom
  final List<String> _dateFilters = ["All", "Today", "This Week", "This Month", "Custom Range"];

  DateTime? _customStartDate;
  DateTime? _customEndDate;

  bool _isWithinRange(DateTime date) {
    final now = DateTime.now();
    switch (_activeDateFilter) {
      case 0:
        return true;
      case 1:
        // Today
        return date.year == now.year && date.month == now.month && date.day == now.day;
      case 2:
        // This Week
        final diff = now.difference(date).inDays;
        return diff >= 0 && diff < 7;
      case 3:
        // This Month
        return date.year == now.year && date.month == now.month;
      case 4:
        // Custom Range
        if (_customStartDate != null && _customEndDate != null) {
          return date.isAfter(_customStartDate!.subtract(const Duration(seconds: 1))) &&
              date.isBefore(_customEndDate!.add(const Duration(seconds: 1)));
        }
        return true;
      default:
        return true;
    }
  }

  Future<void> _selectCustomRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _customStartDate != null && _customEndDate != null
          ? DateTimeRange(start: _customStartDate!, end: _customEndDate!)
          : null,
    );
    if (picked != null) {
      setState(() {
        _customStartDate = picked.start;
        _customEndDate = picked.end;
        _activeDateFilter = 4; // Select Custom Range
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    // Filter purchase returns (Debit Notes) by Date Range
    final debitNotes = appState.transactions.where((tx) {
      final isDebitNote = tx.type == TransactionType.purchaseReturn;
      return isDebitNote && _isWithinRange(tx.date);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Purchase Return (Debit Note)",
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
          // 1. Horizontal Date Filter Chips
          Container(
            height: 54,
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _dateFilters.length,
              itemBuilder: (context, index) {
                final label = _dateFilters[index];
                final isActive = _activeDateFilter == index;
                return Container(
                  margin: const EdgeInsets.only(right: 10),
                  child: InkWell(
                    onTap: () {
                      if (index == 4) {
                        _selectCustomRange();
                      } else {
                        setState(() {
                          _activeDateFilter = index;
                        });
                      }
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            label,
                            style: TextStyle(
                              color: isActive ? const Color(0xFFBE123C) : const Color(0xFF64748B),
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          if (index == 4 && _customStartDate != null && _customEndDate != null) ...[
                            const SizedBox(width: 4),
                            const Icon(Icons.check_circle, size: 12, color: Color(0xFFBE123C)),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Custom range preview
          if (_activeDateFilter == 4 && _customStartDate != null && _customEndDate != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8, left: 16, right: 16),
              child: Text(
                "Filter: ${DateFormat('dd MMM yy').format(_customStartDate!)} to ${DateFormat('dd MMM yy').format(_customEndDate!)}",
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),

          // 2. Main Content
          Expanded(
            child: Container(
              color: const Color(0xFFEFF6FF), // Soft blue background
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (debitNotes.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildReturnIllustration(),
                          const SizedBox(height: 24),
                          const Text(
                            "No Returns Found",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "No purchase return / debit note details match your selection.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 80),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      padding: const EdgeInsets.only(left: 16, right: 16, top: 12, bottom: 85),
                      itemCount: debitNotes.length,
                      itemBuilder: (context, index) {
                        final tx = debitNotes[index];
                        return Card(
                          elevation: 0.5,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(
                              tx.partyName.isEmpty ? "Purchase Return" : tx.partyName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            subtitle: Text(
                              "RET-Ref: ${tx.invoiceNo} • ${DateFormat('dd MMM yyyy').format(tx.date)}",
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                            trailing: Text(
                              formatCurrency.format(tx.amount),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.green, // Purchase Return reduces liability, technically positive inflow/credit
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  // 3. Bottom Pill button "+ Add Return"
                  Positioned(
                    bottom: 32,
                    child: SizedBox(
                      width: 240,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white, size: 20),
                        label: const Text(
                          "Add Purchase Return",
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
                              builder: (context) => const AddTransactionScreen(initialType: TransactionType.purchaseReturn),
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

  Widget _buildReturnIllustration() {
    return Container(
      width: 130,
      height: 130,
      decoration: BoxDecoration(
        color: Colors.blue.shade100,
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.assignment_return_outlined,
        size: 64,
        color: Color(0xFF1E3A8A),
      ),
    );
  }
}
