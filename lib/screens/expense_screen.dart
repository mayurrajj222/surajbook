import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';

class ExpenseScreen extends StatefulWidget {
  const ExpenseScreen({super.key});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  // GST Toggle
  bool _gstEnabled = false;

  // Header Metadata
  String _expenseNo = "EXP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  // Category
  String _selectedCategory = "";
  final TextEditingController _categoryCtrl = TextEditingController();

  // Billed Items
  final List<_ExpenseBilledItem> _billedItems = [];

  // Shipping & Extra Charges
  final TextEditingController _shippingCtrl = TextEditingController();
  final TextEditingController _extraChargeCtrl = TextEditingController();
  bool _roundOff = true;

  final List<String> _categories = [
    "Manufacturing Expense",
    "Petrol",
    "Rent",
    "Salary",
    "Tea & Snacks",
    "Transport",
    "Office Supplies",
    "Utilities",
    "Maintenance",
  ];

  @override
  void dispose() {
    _categoryCtrl.dispose();
    _shippingCtrl.dispose();
    _extraChargeCtrl.dispose();
    super.dispose();
  }

  double get _itemsSubtotal {
    return _billedItems.fold(0.0, (sum, item) => sum + (item.qty * item.rate));
  }

  double get _totalQty {
    return _billedItems.fold(0.0, (sum, item) => sum + item.qty);
  }

  double get _shippingCharge {
    return double.tryParse(_shippingCtrl.text) ?? 0.0;
  }

  double get _extraCharge {
    return double.tryParse(_extraChargeCtrl.text) ?? 0.0;
  }

  double get _rawTotal {
    return _itemsSubtotal + _shippingCharge + _extraCharge;
  }

  double get _finalTotal {
    if (_roundOff) {
      return _rawTotal.roundToDouble();
    }
    return _rawTotal;
  }

  double get _roundOffDiff {
    return _finalTotal - _rawTotal;
  }

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Expense",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 19,
          ),
        ),
        actions: [
          Row(
            children: [
              const Text(
                "GST",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(width: 4),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: _gstEnabled,
                  activeColor: const Color(0xFF007BFF),
                  onChanged: (val) {
                    setState(() {
                      _gstEnabled = val;
                    });
                  },
                ),
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Color(0xFF475569)),
            onPressed: () => _showSettingsDialog(),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Top Metadata Bar (Expense No. | Date | Time)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        // Expense No.
                        Expanded(
                          child: InkWell(
                            onTap: () => _showEditExpenseNoDialog(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Expense No.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF94A3B8),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Text(
                                      _expenseNo.isEmpty ? "—" : _expenseNo,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      size: 18,
                                      color: Color(0xFF94A3B8),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: 28,
                          width: 1,
                          color: const Color(0xFFE2E8F0),
                        ),

                        // Date
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickDate(),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Date",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        DateFormat('dd/MM/yyyy').format(_selectedDate),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF334155),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: 28,
                          width: 1,
                          color: const Color(0xFFE2E8F0),
                        ),

                        // Time
                        Expanded(
                          child: InkWell(
                            onTap: () => _pickTime(),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Time",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF94A3B8),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Row(
                                    children: [
                                      Text(
                                        _selectedTime.format(context),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF334155),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      const Icon(
                                        Icons.keyboard_arrow_down_rounded,
                                        size: 18,
                                        color: Color(0xFF94A3B8),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 2. Expense Category Field (Custom Blue Outlined TextField matching mockup)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: InkWell(
                      onTap: () => _showCategoryPickerBottomSheet(),
                      borderRadius: BorderRadius.circular(6),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: "Expense Category",
                          labelStyle: const TextStyle(
                            color: Color(0xFF007BFF),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFF007BFF), width: 1.8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFF007BFF), width: 1.8),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: Color(0xFF007BFF), width: 2.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedCategory.isEmpty ? "" : _selectedCategory,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF1E293B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 3. Billed Items Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Billed Items",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        InkWell(
                          onTap: () => _showAddItemDialog(),
                          child: const Row(
                            children: [
                              Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF007BFF)),
                              SizedBox(width: 4),
                              Text(
                                "Add Item",
                                style: TextStyle(
                                  color: Color(0xFF007BFF),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Items Table Grid matching screenshot
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        children: [
                          // Table Header
                          Container(
                            color: const Color(0xFFF8FAFC),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            child: const Row(
                              children: [
                                Expanded(
                                  flex: 4,
                                  child: Text(
                                    "Item Name",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Qty",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Rate",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    "Amount",
                                    textAlign: TextAlign.right,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 1, color: Color(0xFFE2E8F0)),

                          // Item rows or Dotted placeholder matching screenshot
                          if (_billedItems.isEmpty)
                            InkWell(
                              onTap: () => _showAddItemDialog(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                                child: const Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        "....................",
                                        style: TextStyle(
                                          color: Color(0xFFCBD5E1),
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "........",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFFCBD5E1),
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: Text(
                                        "........",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: Color(0xFFCBD5E1),
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: SizedBox.shrink(),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _billedItems.length,
                              separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              itemBuilder: (context, index) {
                                final item = _billedItems[index];
                                final sub = item.qty * item.rate;
                                return InkWell(
                                  onTap: () => _showEditItemDialog(index),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 4,
                                          child: Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item.qty.toStringAsFixed(item.qty.truncateToDouble() == item.qty ? 0 : 1),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            item.rate.toStringAsFixed(0),
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(fontSize: 13, color: Color(0xFF334155)),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(
                                            formatCurrency.format(sub).replaceAll("₹ ", "₹"),
                                            textAlign: TextAlign.right,
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),

                          const Divider(height: 1, color: Color(0xFFE2E8F0)),

                          // Total row
                          Container(
                            color: const Color(0xFFF8FAFC),
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            child: Row(
                              children: [
                                const Expanded(
                                  flex: 4,
                                  child: Text(
                                    "Total",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _billedItems.isEmpty
                                        ? ""
                                        : _totalQty.toStringAsFixed(_totalQty.truncateToDouble() == _totalQty ? 0 : 1),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  flex: 2,
                                  child: SizedBox.shrink(),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _itemsSubtotal > 0 ? formatCurrency.format(_itemsSubtotal).replaceAll("₹ ", "₹") : "",
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider Bar
                  Container(height: 8, color: const Color(0xFFF1F5F9)),

                  const SizedBox(height: 16),

                  // 4. Discount & Charges Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Discount & Charges",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 16),

                        // Shipping Field Row
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                "Shipping",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Color(0xFF1E293B),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 150,
                              height: 40,
                              child: TextField(
                                controller: _shippingCtrl,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                onChanged: (val) => setState(() {}),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  prefixIcon: Container(
                                    width: 32,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(6),
                                        bottomLeft: Radius.circular(6),
                                      ),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      "₹",
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6),
                                    borderSide: const BorderSide(color: Color(0xFF007BFF)),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Secondary Charge / Discount Row
                        Align(
                          alignment: Alignment.centerRight,
                          child: SizedBox(
                            width: 150,
                            height: 40,
                            child: TextField(
                              controller: _extraChargeCtrl,
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              onChanged: (val) => setState(() {}),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                prefixIcon: Container(
                                  width: 32,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(6),
                                      bottomLeft: Radius.circular(6),
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: const Text(
                                    "₹",
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6),
                                  borderSide: const BorderSide(color: Color(0xFF007BFF)),
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Round Off Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: Checkbox(
                                    value: _roundOff,
                                    activeColor: const Color(0xFF007BFF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                    onChanged: (val) {
                                      setState(() {
                                        _roundOff = val ?? true;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  "Round Off",
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                const Text(
                                  "₹  ",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                if (_roundOff && _roundOffDiff != 0)
                                  Text(
                                    _roundOffDiff.toStringAsFixed(2),
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF334155),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                else
                                  const Text(
                                    "....................",
                                    style: TextStyle(
                                      color: Color(0xFFCBD5E1),
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider Bar
                  Container(height: 8, color: const Color(0xFFF1F5F9)),

                  // 5. Total Amount Row
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Amount",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Row(
                          children: [
                            const Text(
                              "₹  ",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            if (_finalTotal > 0)
                              Text(
                                formatCurrency.format(_finalTotal).replaceAll("₹ ", ""),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF007BFF),
                                ),
                              )
                            else
                              const Text(
                                "....................",
                                style: TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  letterSpacing: 1.5,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // 6. Bottom Sticky Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Save & New Button
                  TextButton(
                    onPressed: () => _saveExpense(saveAndNew: true),
                    child: const Text(
                      "Save & New",
                      style: TextStyle(
                        color: Color(0xFF334155),
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Save Prominent Blue Button
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () => _saveExpense(saveAndNew: false),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF007BFF),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          "Save",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),

                  // Three dots menu
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF007BFF)),
                    onPressed: () => _showMoreOptionsMenu(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Actions & Dialogs ---

  void _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _showEditExpenseNoDialog() {
    final ctrl = TextEditingController(text: _expenseNo);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Expense No."),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Expense Number"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _expenseNo = ctrl.text.trim();
              });
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _showCategoryPickerBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Select Expense Category",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: _categories.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final cat = _categories[index];
                    return ListTile(
                      title: Text(cat),
                      trailing: _selectedCategory == cat
                          ? const Icon(Icons.check_circle, color: Color(0xFF007BFF))
                          : null,
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat;
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Custom Category"),
                onPressed: () {
                  Navigator.pop(context);
                  _showAddCustomCategoryDialog();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 44),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAddCustomCategoryDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Category"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Category Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newCat = ctrl.text.trim();
              if (newCat.isNotEmpty) {
                setState(() {
                  _categories.add(newCat);
                  _selectedCategory = newCat;
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showAddItemDialog() {
    final appState = Provider.of<AppState>(context, listen: false);
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: "1");
    final rateCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Billed Item"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text.isEmpty) {
                    return appState.items.map((i) => i.name);
                  }
                  return appState.items
                      .where((i) => i.name.toLowerCase().contains(textEditingValue.text.toLowerCase()))
                      .map((i) => i.name);
                },
                onSelected: (String selection) {
                  nameCtrl.text = selection;
                  final found = appState.items.firstWhere((i) => i.name == selection);
                  rateCtrl.text = found.purchasePrice.toStringAsFixed(0);
                },
                fieldViewBuilder: (context, controller, focusNode, onEditingComplete) {
                  return TextField(
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: (val) => nameCtrl.text = val,
                    decoration: const InputDecoration(
                      labelText: "Item Name",
                      hintText: "Type or pick from catalog",
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              TextField(
                controller: qtyCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Quantity"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: rateCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: "Rate (₹)"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameCtrl.text.trim();
              final qty = double.tryParse(qtyCtrl.text) ?? 1.0;
              final rate = double.tryParse(rateCtrl.text) ?? 0.0;
              if (name.isNotEmpty) {
                setState(() {
                  _billedItems.add(_ExpenseBilledItem(name: name, qty: qty, rate: rate));
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add Item"),
          ),
        ],
      ),
    );
  }

  void _showEditItemDialog(int index) {
    final item = _billedItems[index];
    final qtyCtrl = TextEditingController(text: item.qty.toStringAsFixed(0));
    final rateCtrl = TextEditingController(text: item.rate.toStringAsFixed(0));

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit ${item.name}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: qtyCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Quantity")),
            TextField(controller: rateCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Rate (₹)")),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _billedItems.removeAt(index);
              });
              Navigator.pop(context);
            },
            child: const Text("Delete Item", style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                item.qty = double.tryParse(qtyCtrl.text) ?? item.qty;
                item.rate = double.tryParse(rateCtrl.text) ?? item.rate;
              });
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _saveExpense({required bool saveAndNew}) {
    final appState = Provider.of<AppState>(context, listen: false);

    final amount = _finalTotal > 0 ? _finalTotal : 0.0;
    final category = _selectedCategory.isNotEmpty ? _selectedCategory : "General Expense";

    final tx = Transaction(
      id: "tx_${DateTime.now().millisecondsSinceEpoch}",
      partyId: "",
      partyName: category,
      type: TransactionType.expense,
      amount: amount,
      date: DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, _selectedTime.hour, _selectedTime.minute),
      description: "Category: $category • Items: ${_billedItems.length}",
      invoiceNo: _expenseNo,
    );

    appState.addTransaction(tx);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Recorded Expense of ₹ ${amount.toStringAsFixed(2)}!"),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    if (saveAndNew) {
      setState(() {
        final currentNum = int.tryParse(_expenseNo.replaceAll(RegExp(r'[^0-9]'), '')) ?? 1;
        _expenseNo = "EXP-${(currentNum + 1).toString().padLeft(2, '0')}";
        _selectedCategory = "";
        _billedItems.clear();
        _shippingCtrl.clear();
        _extraChargeCtrl.clear();
      });
    } else {
      Navigator.pop(context);
    }
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Expense Settings"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: const Text("Enable GST on Expenses"),
              value: _gstEnabled,
              onChanged: (val) {
                setState(() {
                  _gstEnabled = val;
                });
                Navigator.pop(context);
              },
            ),
            SwitchListTile(
              title: const Text("Auto Round Off Amounts"),
              value: _roundOff,
              onChanged: (val) {
                setState(() {
                  _roundOff = val;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  void _showMoreOptionsMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.refresh_rounded, color: Colors.blue),
            title: const Text("Reset Form"),
            onTap: () {
              Navigator.pop(context);
              setState(() {
                _billedItems.clear();
                _shippingCtrl.clear();
                _extraChargeCtrl.clear();
                _selectedCategory = "";
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text("Discard Expense"),
            onTap: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}

class _ExpenseBilledItem {
  String name;
  double qty;
  double rate;

  _ExpenseBilledItem({
    required this.name,
    required this.qty,
    required this.rate,
  });
}
