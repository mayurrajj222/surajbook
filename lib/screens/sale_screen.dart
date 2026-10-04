import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../theme/app_theme.dart';

class SaleScreen extends StatefulWidget {
  const SaleScreen({super.key});

  @override
  State<SaleScreen> createState() => _SaleScreenState();
}

class _SaleScreenState extends State<SaleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Payment type toggle
  String _paymentType = "Credit"; // "Credit" or "Cash"

  // Dropdown selectors values
  String _invoiceNo = "INV-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
  DateTime _invoiceDate = DateTime.now();
  TimeOfDay _invoiceTime = TimeOfDay.now();

  // Customer inputs
  String? _selectedPartyId;
  final _billingNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();

  // Billed items list
  final List<_BilledItem> _billedItems = [];

  // General discounts
  double _billDiscountPct = 0.0;
  double _additionalCharges = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _billingNameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // Calculated totals
  double get _subtotal {
    return _billedItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
  }

  double get _itemDiscountsTotal {
    return _billedItems.fold(0.0, (sum, item) => sum + ((item.price * item.quantity) * (item.discountPct / 100)));
  }

  double get _netTotal {
    final rawTotal = _subtotal - _itemDiscountsTotal;
    final afterBillDiscount = rawTotal * (1 - (_billDiscountPct / 100));
    return afterBillDiscount + _additionalCharges;
  }

  double get _totalQty {
    return _billedItems.fold(0.0, (sum, item) => sum + item.quantity);
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    // Query active party balance
    double partyBalance = 0.0;
    if (_selectedPartyId != null) {
      final p = appState.parties.firstWhere((p) => p.id == _selectedPartyId);
      partyBalance = p.currentBalance;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sale", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          // Cash/Credit toggles
          Center(
            child: Container(
              height: 34,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  _buildToggleOption("Credit", AppTheme.successGreen),
                  _buildToggleOption("Cash", AppTheme.primary),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.grey),
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
                    // 1. Invoice Info Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildDropdownSelector(
                            label: "Invoice No.",
                            value: _invoiceNo,
                            onTap: () {
                              _showTextInputDialog("Invoice No", _invoiceNo, (val) {
                                setState(() => _invoiceNo = val);
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDropdownSelector(
                            label: "Date",
                            value: DateFormat('dd/MM/yyyy').format(_invoiceDate),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _invoiceDate,
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _invoiceDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildDropdownSelector(
                            label: "Time",
                            value: _invoiceTime.format(context),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _invoiceTime,
                              );
                              if (picked != null) {
                                setState(() => _invoiceTime = picked);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Party Balance label
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Party Balance: ${formatCurrency.format(partyBalance)}",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.red.shade700),
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Customer search dropdown
                    const Text("Customer *", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedPartyId,
                          isExpanded: true,
                          hint: const Text("Select Customer Party", style: TextStyle(fontSize: 13)),
                          items: appState.parties.map((p) {
                            return DropdownMenuItem(
                              value: p.id,
                              child: Text(p.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              final party = appState.parties.firstWhere((p) => p.id == val);
                              setState(() {
                                _selectedPartyId = val;
                                _billingNameCtrl.text = party.name;
                                _phoneCtrl.text = party.phone;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Billing Name
                    TextField(
                      controller: _billingNameCtrl,
                      decoration: const InputDecoration(
                        labelText: "Billing Name (Optional)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Phone Number
                    TextField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: "Phone Number",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Billed Items Header
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

                    // Items list
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _billedItems.length,
                      itemBuilder: (context, index) {
                        final item = _billedItems[index];
                        final sub = item.price * item.quantity;
                        final discVal = sub * (item.discountPct / 100);

                        return Card(
                          elevation: 0.5,
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text("#${index + 1} ${item.name}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text(
                                  "Item Subtotal: ${item.quantity.toInt()} x ${formatCurrency.format(item.price)} = ${formatCurrency.format(sub)}",
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      "Discount (%): ${item.discountPct.toStringAsFixed(0)}",
                                      style: const TextStyle(fontSize: 11, color: Colors.orange, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(width: 24),
                                    Text(
                                      formatCurrency.format(discVal),
                                      style: const TextStyle(fontSize: 11, color: Colors.orange),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Text(formatCurrency.format(sub - discVal), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
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
                    const SizedBox(height: 24),

                    // Total Details Row
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
                            children: [
                              Text("Total Disc: ${formatCurrency.format(_itemDiscountsTotal)}", style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              Text("Total Tax Amt: ₹ 0.00", style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Total Qty: $_totalQty", style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                              Text("Subtotal: ${formatCurrency.format(_subtotal - _itemDiscountsTotal)}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Discount & Charges editing
                    ExpansionTile(
                      title: const Text("Discount & Charges", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(labelText: "Bill Discount (%)", border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      _billDiscountPct = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: TextFormField(
                                  decoration: const InputDecoration(labelText: "Add Charges (₹)", border: OutlineInputBorder()),
                                  keyboardType: TextInputType.number,
                                  onChanged: (val) {
                                    setState(() {
                                      _additionalCharges = double.tryParse(val) ?? 0.0;
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Navigation Actions
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                // round UPI icon
                CircleAvatar(
                  backgroundColor: Colors.blue.shade50,
                  child: Icon(Icons.payments_rounded, color: Colors.blue.shade700),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ThreeDButton(
                    height: 46,
                    color: Colors.white,
                    textColor: AppTheme.primary,
                    borderColor: AppTheme.primary.withOpacity(0.3),
                    onPressed: () => _saveSaleInvoice(appState, clearAfter: true),
                    text: "Save & New",
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ThreeDButton(
                    height: 46,
                    color: Colors.blue.shade600,
                    onPressed: () => _saveSaleInvoice(appState, clearAfter: false),
                    text: "Save",
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(String label, Color activeColor) {
    final isSelected = _paymentType == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _paymentType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? activeColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownSelector({required String label, required String value, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
            const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showTextInputDialog(String title, String currentVal, Function(String) onSave) {
    final ctrl = TextEditingController(text: currentVal);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit $title"),
        content: TextField(controller: ctrl),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (ctrl.text.trim().isNotEmpty) {
                onSave(ctrl.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(_BilledItem item) {
    final qtyCtrl = TextEditingController(text: item.quantity.toStringAsFixed(0));
    final priceCtrl = TextEditingController(text: item.price.toStringAsFixed(0));
    final discCtrl = TextEditingController(text: item.discountPct.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${item.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Quantity")),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Unit Price")),
            TextField(controller: discCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Discount (%)")),
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
                item.discountPct = double.tryParse(discCtrl.text) ?? item.discountPct;
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
                    // Check if already in list
                    final idx = _billedItems.indexWhere((bi) => bi.id == item.id);
                    if (idx != -1) {
                      _billedItems[idx].quantity += 1.0;
                    } else {
                      _billedItems.add(_BilledItem(
                        id: item.id,
                        name: item.name,
                        price: item.salePrice,
                        quantity: 1.0,
                        discountPct: 0.0,
                      ));
                    }
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

  void _saveSaleInvoice(AppState state, {required bool clearAfter}) {
    if (_billedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one item to bill!"), backgroundColor: AppTheme.accentRed),
      );
      return;
    }

    String partyName = "";
    if (_selectedPartyId != null) {
      final p = state.parties.firstWhere((p) => p.id == _selectedPartyId);
      partyName = p.name;
    } else {
      partyName = _billingNameCtrl.text.trim().isNotEmpty
          ? _billingNameCtrl.text.trim()
          : "Walk-in Cash Client";
    }

    // Record transaction
    final tx = Transaction(
      id: "tx_${DateTime.now().millisecondsSinceEpoch}",
      partyId: _selectedPartyId ?? "",
      partyName: partyName,
      type: TransactionType.sale,
      amount: _netTotal,
      date: DateTime.now(),
      description: "POS Sale Invoice. Total Billed Items: ${_billedItems.length}",
      invoiceNo: _invoiceNo,
    );

    state.addTransaction(tx);

    // Apply inventory stock depletion
    for (var bi in _billedItems) {
      state.updateStock(bi.id, -bi.quantity);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Recorded Sale Invoice $_invoiceNo of ₹${_netTotal.toStringAsFixed(2)} successfully!"),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (clearAfter) {
      setState(() {
        _invoiceNo = "JMD-${int.tryParse(_invoiceNo.replaceAll(RegExp(r'[^0-9]'), '')) != null ? (int.parse(_invoiceNo.replaceAll(RegExp(r'[^0-9]'), '')) + 1) : DateTime.now().millisecondsSinceEpoch.toString().substring(8)}";
        _billedItems.clear();
        _selectedPartyId = null;
        _billingNameCtrl.text = "Walk-in";
        _phoneCtrl.text = "";
      });
    } else {
      Navigator.pop(context);
    }
  }
}

class _BilledItem {
  final String id;
  final String name;
  double price;
  double quantity;
  double discountPct;

  _BilledItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.discountPct,
  });
}
