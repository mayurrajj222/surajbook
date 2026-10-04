import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_button.dart';
import '../theme/app_theme.dart';

class SaleReturnScreen extends StatefulWidget {
  const SaleReturnScreen({super.key});

  @override
  State<SaleReturnScreen> createState() => _SaleReturnScreenState();
}

class _SaleReturnScreenState extends State<SaleReturnScreen> {
  final _formKey = GlobalKey<FormState>();

  // State variables matching mockup
  String _returnNo = "1";
  DateTime _returnDate = DateTime.now();

  String? _selectedPartyId;
  final _customerNameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  
  DateTime? _invoiceDate;
  final _invoiceDateCtrl = TextEditingController();
  final _invoiceNoCtrl = TextEditingController();

  final List<_ReturnedItem> _billedItems = [];
  final _totalAmountCtrl = TextEditingController();

  @override
  void dispose() {
    _customerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _invoiceDateCtrl.dispose();
    _invoiceNoCtrl.dispose();
    _totalAmountCtrl.dispose();
    super.dispose();
  }

  void _updateTotalAmount() {
    if (_billedItems.isNotEmpty) {
      final total = _billedItems.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity));
      _totalAmountCtrl.text = total.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Credit Note",
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
            icon: const Icon(Icons.settings_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Top Header Row (Return No. & Date)
          Container(
            color: const Color(0xFFF8FAFC),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildHeaderSelector(
                    label: "Return No.",
                    value: _returnNo,
                    onTap: () {
                      _showTextInputDialog("Return No", _returnNo, (val) {
                        setState(() => _returnNo = val);
                      });
                    },
                  ),
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.grey.shade300,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: _buildHeaderSelector(
                    label: "Date",
                    value: DateFormat('dd/MM/yyyy').format(_returnDate),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _returnDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (picked != null) {
                        setState(() => _returnDate = picked);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),

          // 2. Main Form Fields
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    // Customer Name (searchable picker)
                    TextFormField(
                      controller: _customerNameCtrl,
                      readOnly: true,
                      onTap: () => _showSelectCustomerDialog(appState),
                      decoration: InputDecoration(
                        labelText: "Customer Name *",
                        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
                        ),
                        suffixIcon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.grey),
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return "Customer Name is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Phone Number
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: "Phone Number",
                        labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Invoice Date & Inv No Row
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _invoiceDateCtrl,
                            readOnly: true,
                            onTap: () => _selectInvoiceDate(context),
                            decoration: InputDecoration(
                              labelText: "Invoice Date",
                              labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                              suffixIcon: const Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            controller: _invoiceNoCtrl,
                            decoration: InputDecoration(
                              labelText: "Inv No.",
                              labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Add Items Button
                    OutlinedButton.icon(
                      icon: const Icon(Icons.add_circle_rounded, color: Colors.blue, size: 18),
                      label: const Text(
                        "Add Items (Optional)",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      onPressed: () => _showAddItemsDialog(appState),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Returned Items List
                    if (_billedItems.isNotEmpty) ...[
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _billedItems.length,
                        itemBuilder: (context, index) {
                          final item = _billedItems[index];
                          final sub = item.price * item.quantity;
                          return Card(
                            elevation: 0.5,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              subtitle: Text(
                                "${item.quantity.toInt()} x ${formatCurrency.format(item.price)} = ${formatCurrency.format(sub)}",
                                style: const TextStyle(fontSize: 11, color: Colors.grey),
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.red),
                                onPressed: () {
                                  setState(() {
                                    _billedItems.removeAt(index);
                                    _updateTotalAmount();
                                  });
                                },
                              ),
                              onTap: () => _showEditItemDialog(item),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Total Amount Display / Input
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "₹ ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            SizedBox(
                              width: 140,
                              child: TextFormField(
                                controller: _totalAmountCtrl,
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                decoration: const InputDecoration(
                                  hintText: ".........................",
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 3. Bottom Action Buttons
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _saveCreditNote(appState, clearAfter: true),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Save & New",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _saveCreditNote(appState, clearAfter: false),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      "Save",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                IconButton(
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSelector({
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: Colors.grey),
            ],
          ),
        ],
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

  void _showSelectCustomerDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Customer"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: appState.parties.length,
            itemBuilder: (context, index) {
              final party = appState.parties[index];
              return ListTile(
                title: Text(party.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Ph: ${party.phone}"),
                onTap: () {
                  setState(() {
                    _selectedPartyId = party.id;
                    _customerNameCtrl.text = party.name;
                    _phoneCtrl.text = party.phone;
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

  Future<void> _selectInvoiceDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _invoiceDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _invoiceDate = picked;
        _invoiceDateCtrl.text = DateFormat('dd/MM/yyyy').format(picked);
      });
    }
  }

  void _showAddItemsDialog(AppState appState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Item to Return"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: appState.items.length,
            itemBuilder: (context, index) {
              final item = appState.items[index];
              return ListTile(
                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Price: ₹ ${item.salePrice} • SKU: ${item.code}"),
                onTap: () {
                  setState(() {
                    final idx = _billedItems.indexWhere((bi) => bi.id == item.id);
                    if (idx != -1) {
                      _billedItems[idx].quantity += 1.0;
                    } else {
                      _billedItems.add(_ReturnedItem(
                        id: item.id,
                        name: item.name,
                        price: item.salePrice,
                        quantity: 1.0,
                      ));
                    }
                    _updateTotalAmount();
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

  void _showEditItemDialog(_ReturnedItem item) {
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
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Unit Price")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _billedItems.remove(item);
                _updateTotalAmount();
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
                _updateTotalAmount();
              });
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  void _saveCreditNote(AppState state, {required bool clearAfter}) {
    if (!_formKey.currentState!.validate()) return;

    final amountStr = _totalAmountCtrl.text.trim();
    final amount = double.tryParse(amountStr) ?? 
        (_billedItems.isNotEmpty 
            ? _billedItems.fold<double>(0.0, (sum, item) => sum + (item.price * item.quantity))
            : 0.0);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Total amount must be greater than 0!"), backgroundColor: AppTheme.accentRed),
      );
      return;
    }

    // Save transaction
    final tx = Transaction(
      id: "tx_${DateTime.now().millisecondsSinceEpoch}",
      partyId: _selectedPartyId ?? "",
      partyName: _customerNameCtrl.text.trim(),
      type: TransactionType.saleReturn,
      amount: amount,
      date: _returnDate,
      description: "Credit Note / Sale Return. Total Returned Items: ${_billedItems.length}. Inv No Ref: ${_invoiceNoCtrl.text.trim()}",
      invoiceNo: "RET-$_returnNo",
    );

    state.addTransaction(tx);

    // Apply inventory stock return (stock increments)
    for (var bi in _billedItems) {
      state.updateStock(bi.id, bi.quantity);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Recorded Sale Return Credit Note RET-$_returnNo of ₹${amount.toStringAsFixed(2)} successfully!"),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (clearAfter) {
      setState(() {
        _returnNo = "${(int.tryParse(_returnNo) ?? 0) + 1}";
        _billedItems.clear();
        _selectedPartyId = null;
        _customerNameCtrl.clear();
        _phoneCtrl.clear();
        _invoiceDate = null;
        _invoiceDateCtrl.clear();
        _invoiceNoCtrl.clear();
        _totalAmountCtrl.clear();
      });
    } else {
      Navigator.pop(context);
    }
  }
}

class _ReturnedItem {
  final String id;
  final String name;
  double price;
  double quantity;

  _ReturnedItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}
