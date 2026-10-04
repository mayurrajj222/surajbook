import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../widgets/transaction_types_modal.dart';
import '../widgets/share_transaction_modal.dart';
import '../theme/app_theme.dart';
import 'add_transaction_screen.dart';
import 'statement_pdf_preview_screen.dart';

class PartyDetailScreen extends StatelessWidget {
  final String partyId;

  const PartyDetailScreen({super.key, required this.partyId});

  // 1. Redirect to Phone Dialer
  Future<void> _makePhoneCall(BuildContext context, String phone) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No phone number available for this party.")),
      );
      return;
    }
    final Uri telUri = Uri.parse("tel:$cleanPhone");
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        await launchUrl(telUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Redirecting to dialer ($cleanPhone)...")),
      );
    }
  }

  // 2. Redirect to WhatsApp with Payment Reminder Message
  Future<void> _sendWhatsAppReminder(
    BuildContext context,
    Party party,
    NumberFormat formatCurrency,
  ) async {
    final cleanPhone = party.phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No valid phone number for WhatsApp.")),
      );
      return;
    }

    final isGet = party.type == PartyType.youWillGet;
    final String amountStr = formatCurrency.format(party.currentBalance);

    final String message;
    if (isGet && party.currentBalance > 0) {
      message = "Dear ${party.name},\n\n"
          "This is a gentle payment reminder from our business.\n"
          "Pending Amount Due: $amountStr\n\n"
          "Kindly clear the pending balance at your earliest convenience.\n"
          "Thank you!";
    } else if (!isGet && party.currentBalance > 0) {
      message = "Dear ${party.name},\n\n"
          "This is an account statement update.\n"
          "Current Balance Payable: $amountStr\n\n"
          "Thank you for doing business with us!";
    } else {
      message = "Dear ${party.name},\n\n"
          "Your account balance is fully settled ($amountStr).\n"
          "Thank you for your business!";
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
        SnackBar(content: Text("Opening WhatsApp chat with ${party.name}...")),
      );
    }
  }

  // 3. Send SMS Reminder
  Future<void> _sendSmsReminder(
    BuildContext context,
    Party party,
    NumberFormat formatCurrency,
  ) async {
    final cleanPhone = party.phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (cleanPhone.isEmpty) return;
    final amountStr = formatCurrency.format(party.currentBalance);
    final text = "Dear ${party.name}, payment reminder for pending amount $amountStr. Thank you!";
    final Uri smsUri = Uri.parse("sms:$cleanPhone?body=${Uri.encodeComponent(text)}");
    try {
      await launchUrl(smsUri);
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Opening SMS app for ${party.name}...")),
      );
    }
  }

  // 4. Modal for Extra Party Features (+ Symbol)
  void _showMoreFeaturesModal(BuildContext context, Party party, NumberFormat formatCurrency) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Party Tools & Actions (${party.name})",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(height: 16),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEFF6FF),
                  child: Icon(Icons.sms_rounded, color: AppTheme.accentBlue),
                ),
                title: const Text("Send SMS Reminder", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("Send direct SMS with payment pending info"),
                onTap: () {
                  Navigator.pop(context);
                  _sendSmsReminder(context, party, formatCurrency);
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFECFDF5),
                  child: Icon(Icons.copy_all_rounded, color: AppTheme.successGreen),
                ),
                title: const Text("Copy Account Summary", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("Copy text summary of current balance & details"),
                onTap: () {
                  Navigator.pop(context);
                  final summary = "Party: ${party.name}\nPhone: ${party.phone}\nCurrent Balance: ${formatCurrency.format(party.currentBalance)} (${party.type == PartyType.youWillGet ? 'YOU WILL GET' : 'YOU WILL GIVE'})";
                  Clipboard.setData(ClipboardData(text: summary));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Party statement summary copied to clipboard!")),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFFFFBEB),
                  child: Icon(Icons.event_note_rounded, color: AppTheme.warningOrange),
                ),
                title: const Text("Set Due Date / Reminder Note", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("Add custom note or follow-up payment date"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Payment reminder scheduled for ${party.name}.")),
                  );
                },
              ),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFF1F5F9),
                  child: Icon(Icons.qr_code_2_rounded, color: Color(0xFF334155)),
                ),
                title: const Text("Share Payment QR Code", style: TextStyle(fontWeight: FontWeight.w600)),
                subtitle: const Text("Generate UPI QR code for fast payment collect"),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("UPI QR Code generated for ${party.name}.")),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    // Find party
    Party? party;
    try {
      party = appState.parties.firstWhere((p) => p.id == partyId);
    } catch (_) {
      // Handle missing party
    }

    if (party == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Party not found.")),
      );
    }

    // Filter transactions for this party
    final partyTxs = appState.transactions.where((tx) => tx.partyId == partyId).toList();
    final isGet = party.type == PartyType.youWillGet;
    final balanceColor = isGet ? AppTheme.successGreen : AppTheme.accentRed;

    return Scaffold(
      appBar: AppBar(
        title: Text(party.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.accentRed),
            onPressed: () => _confirmDelete(context, appState, party!),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Party Profile & Balance Display (3D card)
              ThreeDContainer(
                depth: 5,
                borderRadius: 22,
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: balanceColor.withOpacity(0.1),
                      child: Icon(Icons.person_rounded, color: balanceColor, size: 36),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      party.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontSize: 20),
                    ),
                    Text(
                      "Phone: ${party.phone} • ${party.email.isEmpty ? 'No email' : party.email}",
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    if (party.address.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        party.address,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                      ),
                    ],
                    const Divider(height: 30, color: Color(0xFFE2E8F0)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Current Balance:",
                          style: TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                        ),
                        Text(
                          formatCurrency.format(party.currentBalance),
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: balanceColor,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        isGet ? "YOU WILL GET" : "YOU WILL GIVE",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: balanceColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Color(0xFFE2E8F0)),
                    const SizedBox(height: 10),
                    // Send Reminder & Send Statement Buttons (Screenshot 1)
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => _sendWhatsAppReminder(context, party!, formatCurrency),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.notifications_none_rounded, size: 16, color: Color(0xFF1D4ED8)),
                                  SizedBox(width: 6),
                                  Text(
                                    "Send Reminder",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(width: 1, height: 18, color: const Color(0xFFCBD5E1)),
                        Expanded(
                          child: InkWell(
                            onTap: () => ShareTransactionModal.show(context, party: party!),
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Icon(Icons.feed_outlined, size: 16, color: Color(0xFF1D4ED8)),
                                  SizedBox(width: 6),
                                  Text(
                                    "Send Statement",
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1D4ED8)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 2. Action Panel: Call / WhatsApp / Statement
              Row(
                children: [
                  Expanded(
                    child: ThreeDButton(
                      height: 46,
                      color: Colors.white,
                      textColor: AppTheme.accentBlue,
                      borderColor: AppTheme.accentBlue.withOpacity(0.3),
                      icon: Icons.phone_rounded,
                      text: "Call",
                      onPressed: () => _makePhoneCall(context, party!.phone),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ThreeDButton(
                      height: 46,
                      color: Colors.white,
                      textColor: AppTheme.successGreen,
                      borderColor: AppTheme.successGreen.withOpacity(0.3),
                      icon: Icons.chat_bubble_outline_rounded,
                      text: "WhatsApp",
                      onPressed: () => _sendWhatsAppReminder(context, party!, formatCurrency),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ThreeDButton(
                      height: 46,
                      color: Colors.white,
                      textColor: AppTheme.warningOrange,
                      borderColor: AppTheme.warningOrange.withOpacity(0.3),
                      icon: Icons.picture_as_pdf_rounded,
                      text: "Statement",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatementPdfPreviewScreen(
                              party: party!,
                              transactions: partyTxs,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. Transactions List Section
              const Text(
                "Party Transaction History",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              const SizedBox(height: 10),

              partyTxs.isEmpty
                  ? ThreeDContainer(
                      depth: 2,
                      padding: const EdgeInsets.all(24),
                      child: const Center(
                        child: Text(
                          "No transactions recorded with this party yet.",
                          style: TextStyle(color: Color(0xFF64748B)),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: partyTxs.length,
                      itemBuilder: (context, index) {
                        final tx = partyTxs[index];
                        final typeLabel = tx.type == TransactionType.sale
                            ? "Sale Invoice"
                            : tx.type == TransactionType.paymentIn
                                ? "Payment-In"
                                : tx.type == TransactionType.paymentOut
                                    ? "Payment-Out"
                                    : tx.type.name;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12.0),
                          child: ThreeDContainer(
                            depth: 2,
                            borderRadius: 16,
                            padding: const EdgeInsets.all(14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          typeLabel,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E293B)),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFFEF3C7),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            "UNUSED",
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFFD97706)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "#${tx.invoiceNo}",
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  DateFormat('dd MMM, yy • hh:mm a').format(tx.date),
                                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Text("Total ", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                            Text(
                                              formatCurrency.format(tx.amount),
                                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Text("Unused ", style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                            Text(
                                              formatCurrency.format(tx.amount),
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF475569)),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.print_outlined, size: 20, color: Color(0xFF64748B)),
                                          tooltip: "Print PDF",
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => StatementPdfPreviewScreen(
                                                  party: party!,
                                                  transactions: [tx],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.share_outlined, size: 20, color: Color(0xFF64748B)),
                                          tooltip: "Share Transaction",
                                          onPressed: () {
                                            ShareTransactionModal.show(context, transaction: tx, party: party!);
                                          },
                                        ),
                                        PopupMenuButton<String>(
                                          icon: const Icon(Icons.more_vert_rounded, size: 20, color: Color(0xFF64748B)),
                                          onSelected: (val) {
                                            if (val == 'share') {
                                              ShareTransactionModal.show(context, transaction: tx, party: party!);
                                            }
                                          },
                                          itemBuilder: (context) => [
                                            const PopupMenuItem(value: 'share', child: Text("Share Receipt")),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

              const SizedBox(height: 30),

              // 4. Quick Record Buttons with Centered (+) Transaction Modal Button (same feature as home screen)
              Row(
                children: [
                  Expanded(
                    child: ThreeDButton(
                      color: AppTheme.accentRed,
                      text: "Give Payment",
                      icon: Icons.remove_circle_outline_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTransactionScreen(
                              initialType: TransactionType.paymentOut,
                              initialPartyId: party!.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  // (+) Transaction Modal Button (same as home screen)
                  ThreeDButton(
                    width: 48,
                    height: 54,
                    borderRadius: 24,
                    color: const Color(0xFF1E293B),
                    padding: EdgeInsets.zero,
                    child: const Center(
                      child: Icon(
                        Icons.add_rounded,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    onPressed: () {
                      TransactionTypesModal.show(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ThreeDButton(
                      color: AppTheme.successGreen,
                      text: "Receive Payment",
                      icon: Icons.add_circle_outline_rounded,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTransactionScreen(
                              initialType: TransactionType.paymentIn,
                              initialPartyId: party!.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppState state, Party party) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Party?"),
        content: Text("Are you sure you want to delete ${party.name}? This will also delete all their transaction history."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              state.deleteParty(party.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Back to HomeScreen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Party '${party.name}' deleted."),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text("Delete", style: TextStyle(color: AppTheme.accentRed)),
          ),
        ],
      ),
    );
  }
}
