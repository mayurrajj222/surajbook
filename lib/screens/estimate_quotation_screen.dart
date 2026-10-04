import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../theme/app_theme.dart';

class EstimateQuotationScreen extends StatefulWidget {
  const EstimateQuotationScreen({super.key});

  @override
  State<EstimateQuotationScreen> createState() => _EstimateQuotationScreenState();
}

class _EstimateQuotationScreenState extends State<EstimateQuotationScreen> {
  final _formKey = GlobalKey<FormState>();

  // Customer inputs
  final _billingNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Invoice identifiers
  String _estimateNo = "EST-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
  DateTime _estimateDate = DateTime.now();

  // Default seeded items
  final List<_BilledItem> _billedItems = [];

  // Discounts
  double _discountPct = 0.0;
  double _additionalCharges = 0.0;

  final _discountPctCtrl = TextEditingController();
  final _discountValCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _discountPctCtrl.text = "0.0";
    _discountValCtrl.text = "0.00";
  }

  @override
  void dispose() {
    _billingNameCtrl.dispose();
    _phoneCtrl.dispose();
    _discountPctCtrl.dispose();
    _discountValCtrl.dispose();
    super.dispose();
  }

  double get _subtotal {
    return _billedItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get _discountAmount {
    return _subtotal * (_discountPct / 100);
  }

  double get _netTotal {
    return _subtotal - _discountAmount + _additionalCharges;
  }

  double get _totalQty {
    return _billedItems.fold(0.0, (sum, item) => sum + item.quantity);
  }

  void _updateDiscountValuesFromPct() {
    final amt = _discountAmount;
    _discountValCtrl.text = amt.toStringAsFixed(2);
  }

  void _updateDiscountValuesFromAmount(double val) {
    if (_subtotal > 0) {
      _discountPct = (val / _subtotal) * 100;
      _discountPctCtrl.text = _discountPct.toStringAsFixed(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Estimate/Quotation", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.blue),
            onPressed: () => _generateInvoicePdf(appState),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Billing details fields
                    TextField(
                      controller: _billingNameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Billing Name (Optional)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Billed Items header
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check_circle_rounded, color: Colors.blue, size: 16),
                          SizedBox(width: 8),
                          Text("Billed Items", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 13)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Card items matching GM Set list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _billedItems.length,
                      itemBuilder: (context, idx) {
                        final item = _billedItems[idx];
                        final sub = item.price * item.quantity;
                        return Card(
                          elevation: 0.5,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text("#${idx + 1} ${item.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  "Item Subtotal: ${item.quantity.toInt()} x ${formatCurrency.format(item.price)} = ${formatCurrency.format(sub)}",
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                const Text("Discount (%): 0", style: TextStyle(fontSize: 11, color: Colors.orange)),
                              ],
                            ),
                            trailing: Text(formatCurrency.format(sub), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            onTap: () => _showEditItemDialog(item),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 8),

                    // Add items button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_circle_outline_rounded),
                      label: const Text("Add Items", style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => _showAddItemsDialog(appState),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: Colors.blue),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Total details card
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Total Disc: ₹ 0.00", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              Text("Total Tax Amt: ₹ 0.00", style: TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Qty: $_totalQty", style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              Text("Subtotal: ${formatCurrency.format(_subtotal)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Discount and charges inputs matching exact layout
                    const Text("Discount & Charges", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155))),
                    const SizedBox(height: 8),
                    ThreeDContainer(
                      depth: 2,
                      borderRadius: 16,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Discount",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 90,
                            child: TextFormField(
                              controller: _discountPctCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                suffixText: "%",
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (val) {
                                final pct = double.tryParse(val) ?? 0.0;
                                setState(() {
                                  _discountPct = pct;
                                  _updateDiscountValuesFromPct();
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              controller: _discountValCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              decoration: const InputDecoration(
                                prefixText: "₹ ",
                                border: OutlineInputBorder(),
                                isDense: true,
                              ),
                              onChanged: (val) {
                                final amt = double.tryParse(val) ?? 0.0;
                                setState(() {
                                  _updateDiscountValuesFromAmount(amt);
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ThreeDButton(
                    height: 48,
                    color: Colors.white,
                    textColor: Colors.red.shade700,
                    borderColor: Colors.red.shade300,
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Estimate cancelled and deleted.")),
                      );
                    },
                    text: "Delete",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ThreeDButton(
                    height: 48,
                    color: Colors.blue.shade600,
                    onPressed: () {
                      _showSaveSuccess(appState);
                    },
                    text: "Save",
                  ),
                ),
                const SizedBox(width: 12),
                // PDF Printer shortcut
                ThreeDButton(
                  width: 90,
                  height: 48,
                  color: AppTheme.primary,
                  onPressed: () => _generateInvoicePdf(appState),
                  text: "PDF",
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(_BilledItem item) {
    final qtyCtrl = TextEditingController(text: item.quantity.toStringAsFixed(0));
    final priceCtrl = TextEditingController(text: item.price.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${item.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Quantity")),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Price")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _billedItems.remove(item);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete Item", style: TextStyle(color: Colors.red)),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item.quantity = double.tryParse(qtyCtrl.text) ?? item.quantity;
                item.price = double.tryParse(priceCtrl.text) ?? item.price;
              });
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  void _showAddItemsDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Catalog Item"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: appState.items.length,
            itemBuilder: (context, index) {
              final item = appState.items[index];
              return ListTile(
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Price: ₹ ${item.salePrice} • SKU: ${item.code}", style: const TextStyle(fontSize: 10)),
                onTap: () {
                  setState(() {
                    final idx = _billedItems.indexWhere((bi) => bi.id == item.id);
                    if (idx != -1) {
                      _billedItems[idx].quantity += 1.0;
                    } else {
                      _billedItems.add(_BilledItem(
                        item.id,
                        item.name,
                        item.salePrice,
                        1.0,
                        0.0,
                      ));
                    }
                    _updateDiscountValuesFromPct();
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  void _showSaveSuccess(AppState state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Estimate $_estimateNo of ₹${_netTotal.toStringAsFixed(2)} saved successfully!"),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.pop(context);
  }

  // PDF Document Viewer Generator Simulator
  void _generateInvoicePdf(AppState appState) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            // Preview header
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Generated Invoice PDF Preview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primary)),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Paper Sheet view
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300),
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Shop details
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(appState.businessName.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppTheme.primary)),
                              const Text("Authorized Book Dealer", style: TextStyle(fontSize: 10, color: Colors.grey)),
                              const Text("Ph: 9876543210 • Email: jmd@gmail.com", style: TextStyle(fontSize: 9, color: Colors.grey)),
                              if (appState.invoiceShowGST)
                                const Text("GSTIN: 07AAAAA1111A1Z1", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400)),
                            child: const Text("ESTIMATE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.blue)),
                          ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Customer/Invoice Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("BILLED TO:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Colors.grey)),
                              Text(_billingNameCtrl.text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                              Text("Phone: ${_phoneCtrl.text}", style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Estimate No: $_estimateNo", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                              Text("Date: ${DateFormat('dd MMM yyyy').format(_estimateDate)}", style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Items Table
                      Table(
                        border: TableBorder.all(color: Colors.grey.shade300, width: 0.8),
                        columnWidths: const {
                          0: FlexColumnWidth(0.8),
                          1: FlexColumnWidth(4.0),
                          2: FlexColumnWidth(1.2),
                          3: FlexColumnWidth(1.2),
                          4: FlexColumnWidth(1.5),
                        },
                        children: [
                          // Table Header
                          const TableRow(
                            decoration: BoxDecoration(color: Color(0xFFF1F5F9)),
                            children: [
                              Padding(padding: EdgeInsets.all(6.0), child: Text("S.N.", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9), textAlign: TextAlign.center)),
                              Padding(padding: EdgeInsets.all(6.0), child: Text("Item Description", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9))),
                              Padding(padding: EdgeInsets.all(6.0), child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9), textAlign: TextAlign.center)),
                              Padding(padding: EdgeInsets.all(6.0), child: Text("Rate", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9), textAlign: TextAlign.right)),
                              Padding(padding: EdgeInsets.all(6.0), child: Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9), textAlign: TextAlign.right)),
                            ],
                          ),
                          // Table Items
                          ..._billedItems.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final item = entry.value;
                            return TableRow(
                              children: [
                                Padding(padding: const EdgeInsets.all(6.0), child: Text("${idx + 1}", style: const TextStyle(fontSize: 9), textAlign: TextAlign.center)),
                                Padding(padding: const EdgeInsets.all(6.0), child: Text(item.name, style: const TextStyle(fontSize: 9))),
                                Padding(padding: const EdgeInsets.all(6.0), child: Text("${item.quantity.toInt()}", style: const TextStyle(fontSize: 9), textAlign: TextAlign.center)),
                                Padding(padding: const EdgeInsets.all(6.0), child: Text(formatCurrency.format(item.price), style: const TextStyle(fontSize: 9), textAlign: TextAlign.right)),
                                Padding(padding: const EdgeInsets.all(6.0), child: Text(formatCurrency.format(item.price * item.quantity), style: const TextStyle(fontSize: 9), textAlign: TextAlign.right)),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Totals breakdown
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 200,
                          child: Column(
                            children: [
                              _buildPdfTotalRow("Subtotal", formatCurrency.format(_subtotal), false),
                              _buildPdfTotalRow("Discount ($_discountPct%)", "- ${formatCurrency.format(_discountAmount)}", false),
                              _buildPdfTotalRow("Tax Amount", "₹ 0.00", false),
                              const Divider(height: 12),
                              _buildPdfTotalRow("NET PAYABLE", formatCurrency.format(_netTotal), true),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Terms & Stamp
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("TERMS & CONDITIONS:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 8, color: Colors.grey)),
                                Text(appState.invoiceTermsAndConditions, style: const TextStyle(fontSize: 7, color: Colors.grey)),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            children: [
                              if (appState.invoiceShowSignature) ...[
                                Container(
                                  width: 60,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.blue.shade300, width: 1.5),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text("APPROVED\nJMD BOOKS", style: TextStyle(fontSize: 6, fontWeight: FontWeight.bold, color: Colors.blue), textAlign: TextAlign.center),
                                ),
                                const SizedBox(height: 4),
                              ],
                              const Text("Authorized Signatory", style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Divider(height: 1),

            // Print share controls
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.print_rounded),
                      label: const Text("Print PDF"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connecting to Bluetooth print client...")));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share_rounded),
                      label: const Text("Share Invoice"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Link copied! Sending via WhatsApp...")));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen, foregroundColor: Colors.white),
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

  Widget _buildPdfTotalRow(String label, String value, bool isBold) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 9, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontSize: 9, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}

class _BilledItem {
  final String id;
  final String name;
  double price;
  double quantity;
  double discountPct;

  _BilledItem(this.id, this.name, this.price, this.quantity, this.discountPct);
}
