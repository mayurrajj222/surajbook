import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ShareTransactionModal extends StatelessWidget {
  final Transaction? transaction;
  final Party party;

  const ShareTransactionModal({
    super.key,
    this.transaction,
    required this.party,
  });

  static void show(BuildContext context, {Transaction? transaction, required Party party}) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => ShareTransactionModal(
        transaction: transaction,
        party: party,
      ),
    );
  }

  Future<void> _shareWhatsApp(BuildContext context) async {
    final cleanPhone = party.phone.replaceAll(RegExp(r'[^\d+]'), '');
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
    final formatDate = DateFormat('dd MMM, yyyy');

    final String message;
    if (transaction != null) {
      final tx = transaction!;
      final typeLabel = tx.type == TransactionType.sale
          ? "Sale Invoice"
          : tx.type == TransactionType.paymentIn
              ? "Payment In"
              : tx.type == TransactionType.paymentOut
                  ? "Payment Out"
                  : tx.type.name;
      message = "Transaction Details from J.M.D BOOK STORE:\n\n"
          "Party: ${party.name}\n"
          "Type: $typeLabel\n"
          "Invoice No: ${tx.invoiceNo}\n"
          "Date: ${formatDate.format(tx.date)}\n"
          "Amount: ${formatCurrency.format(tx.amount)}\n"
          "Payment Type: ${tx.paymentType}\n\n"
          "Thank you for your business!";
    } else {
      message = "Account Statement Summary from J.M.D BOOK STORE:\n\n"
          "Party Name: ${party.name}\n"
          "Contact No: ${party.phone}\n"
          "Current Balance: ${formatCurrency.format(party.currentBalance)} (${party.type == PartyType.youWillGet ? 'YOU WILL GET' : 'YOU WILL GIVE'})\n\n"
          "Thank you for doing business with us!";
    }

    String formattedPhone = cleanPhone;
    if (formattedPhone.length == 10) {
      formattedPhone = "91$formattedPhone";
    }

    final Uri waUrl = Uri.parse("https://wa.me/$formattedPhone?text=${Uri.encodeComponent(message)}");
    try {
      final launched = await launchUrl(waUrl, mode: LaunchMode.externalApplication);
      if (!launched) {
        final Uri waAppUri = Uri.parse("whatsapp://send?phone=$formattedPhone&text=${Uri.encodeComponent(message)}");
        await launchUrl(waAppUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Redirecting to WhatsApp for ${party.name}...")),
      );
    }
  }

  Future<void> _shareSms(BuildContext context) async {
    final cleanPhone = party.phone.replaceAll(RegExp(r'[^\d+]'), '');
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    final String text;
    if (transaction != null) {
      final tx = transaction!;
      text = "J.M.D BOOK STORE: ${party.name}, Txn #${tx.invoiceNo} of ${formatCurrency.format(tx.amount)} recorded. Thank you!";
    } else {
      text = "J.M.D BOOK STORE: ${party.name}, your total account balance is ${formatCurrency.format(party.currentBalance)}. Thank you!";
    }

    final Uri smsUri = Uri.parse("sms:$cleanPhone?body=${Uri.encodeComponent(text)}");
    try {
      await launchUrl(smsUri);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Opening SMS app for ${party.name}...")),
      );
    }
  }

  void _shareCopyText(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');
    final String text;
    if (transaction != null) {
      final tx = transaction!;
      text = "J.M.D BOOK STORE - Txn #${tx.invoiceNo} | Party: ${party.name} | Amount: ${formatCurrency.format(tx.amount)}";
    } else {
      text = "J.M.D BOOK STORE - Statement Total | Party: ${party.name} | Balance: ${formatCurrency.format(party.currentBalance)}";
    }
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Transaction details copied to clipboard!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                transaction != null ? "Share Transaction" : "Share Statement Total",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // WhatsApp
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _shareWhatsApp(context);
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFDCFCE7),
                      child: const Icon(Icons.chat_bubble_rounded, color: Color(0xFF16A34A), size: 26),
                    ),
                    const SizedBox(height: 8),
                    const Text("Whatsapp", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  ],
                ),
              ),
              // SMS
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _shareSms(context);
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFFFE4E6),
                      child: const Icon(Icons.sms_rounded, color: Color(0xFFE11D48), size: 26),
                    ),
                    const SizedBox(height: 8),
                    const Text("SMS", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  ],
                ),
              ),
              // Share / Copy
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  _shareCopyText(context);
                },
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: const Color(0xFFEEF2FF),
                      child: const Icon(Icons.share_rounded, color: Color(0xFF4F46E5), size: 26),
                    ),
                    const SizedBox(height: 8),
                    const Text("Share", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569))),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
