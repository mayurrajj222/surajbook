import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../theme/app_theme.dart';

class MobilePosScreen extends StatefulWidget {
  const MobilePosScreen({super.key});

  @override
  State<MobilePosScreen> createState() => _MobilePosScreenState();
}

class _MobilePosScreenState extends State<MobilePosScreen> {
  String _searchQuery = "";
  String _selectedCategory = "All";

  // Cart representation: Map of Item ID -> Quantity
  final Map<String, double> _cart = {};

  // Selected customer details
  String? _selectedPartyId;
  String _paymentMode = "Cash";

  // Discount options
  double _billDiscount = 0.0;
  double _additionalCharges = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    // Categories list matching screenshot tags
    final categories = ["All", "Aspire publication", "Avni prakashan", "Bookstore Specials"];

    // Filtered items list
    final filteredItems = appState.items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.code.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesSearch;
    }).toList();

    int totalCartCount = _cart.values.fold(0, (sum, qty) => sum + qty.toInt());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Mobile POS", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.primary,
        elevation: 0,
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_rounded, color: AppTheme.primary),
                onPressed: () => _openCartScreen(appState),
              ),
              if (totalCartCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: CircleAvatar(
                    radius: 8,
                    backgroundColor: AppTheme.accentRed,
                    child: Text(
                      "$totalCartCount",
                      style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar and add button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ThreeDContainer(
                    depth: 2,
                    borderRadius: 14,
                    borderWidth: 1,
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: Color(0xFF94A3B8)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: const InputDecoration(
                              hintText: "Search any Item or code",
                              border: InputBorder.none,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.qr_code_scanner_rounded, color: Colors.blue),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Mocking POS Barcode Scanner..."), behavior: SnackBarBehavior.floating),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ThreeDButton(
                  width: 70,
                  height: 48,
                  borderRadius: 12,
                  depth: 2,
                  color: Colors.white,
                  borderColor: Colors.blue.shade300,
                  onPressed: () {
                    _showAddNewItemDialog(appState);
                  },
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, size: 16, color: Colors.blue),
                      Text("Add", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.blue)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. Category tags
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: categories.length,
              itemBuilder: (context, idx) {
                final cat = categories[idx];
                final isSelected = _selectedCategory == cat;
                return Container(
                  margin: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(cat, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    selected: isSelected,
                    selectedColor: Colors.blue.shade100,
                    labelStyle: TextStyle(color: isSelected ? Colors.blue.shade800 : Colors.grey.shade700),
                    onSelected: (val) {
                      if (val) {
                        setState(() => _selectedCategory = cat);
                      }
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),

          // 3. Grid of Catalog items matching Mobile POS layout
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text("No items found matching filter", style: TextStyle(color: Colors.grey)))
                : GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filteredItems.length,
                    itemBuilder: (context, idx) {
                      final item = filteredItems[idx];
                      final countInCart = _cart[item.id] ?? 0;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Image container with + button overlay
                          Expanded(
                            child: Stack(
                              children: [
                                ThreeDContainer(
                                  depth: 2,
                                  borderRadius: 16,
                                  padding: EdgeInsets.zero,
                                  color: Colors.grey.shade100,
                                  borderColor: countInCart > 0 ? Colors.blue.withOpacity(0.5) : Colors.grey.shade300,
                                  child: Center(
                                    child: Icon(
                                      Icons.image_outlined,
                                      size: 36,
                                      color: countInCart > 0 ? Colors.blue.shade300 : Colors.grey.shade400,
                                    ),
                                  ),
                                ),
                                // + Button
                                Positioned(
                                  right: 4,
                                  bottom: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _cart[item.id] = (_cart[item.id] ?? 0) + 1;
                                      });
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text("Added ${item.name} to POS cart!"),
                                          duration: const Duration(milliseconds: 600),
                                          behavior: SnackBarBehavior.floating,
                                        ),
                                      );
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: Colors.blue.shade300),
                                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
                                      ),
                                      child: const Icon(Icons.add, size: 14, color: Colors.blue),
                                    ),
                                  ),
                                ),
                                // Badge indicator for count
                                if (countInCart > 0)
                                  Positioned(
                                    left: 6,
                                    top: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(8)),
                                      child: Text(
                                        "${countInCart.toInt()}",
                                        style: const TextStyle(fontSize: 8, color: Colors.white, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Title & Price
                          Text(
                            item.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black87),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            formatCurrency.format(item.salePrice),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF1E293B)),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: totalCartCount > 0
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, -2))],
              ),
              child: ThreeDButton(
                height: 48,
                color: AppTheme.accentRed,
                onPressed: () => _openCartScreen(appState),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("Cart: $totalCartCount Items", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    Row(
                      children: const [
                        Text("Checkout", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  // --- Dynamic Cart Screen ---
  void _openCartScreen(AppState appState) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.6,
        maxChildSize: 0.95,
        builder: (context, sc) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: StatefulBuilder(
            builder: (context, setCartState) {
              final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

              // Calculate Cart subtotal
              double subtotal = 0.0;
              List<_CartItem> cartItems = [];
              _cart.forEach((itemId, qty) {
                final idx = appState.items.indexWhere((i) => i.id == itemId);
                if (idx != -1) {
                  final item = appState.items[idx];
                  final itemSub = item.salePrice * qty;
                  subtotal += itemSub;
                  cartItems.add(_CartItem(item, qty));
                }
              });

              final discountAmount = subtotal * (_billDiscount / 100);
              final total = subtotal - discountAmount + _additionalCharges;

              // Bind selected customer details
              String customerName = "Add Customer Details";
              if (_selectedPartyId != null) {
                final partyIndex = appState.parties.indexWhere((p) => p.id == _selectedPartyId);
                if (partyIndex != -1) {
                  customerName = appState.parties[partyIndex].name;
                }
              }

              return Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded),
                              onPressed: () => Navigator.pop(context),
                            ),
                            const Text("Cart", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        if (_cart.isNotEmpty)
                          TextButton(
                            child: const Text("Clear Cart", style: TextStyle(color: Colors.red)),
                            onPressed: () {
                              setCartState(() {
                                _cart.clear();
                              });
                              setState(() {});
                              Navigator.pop(context);
                            },
                          ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Cart Contents
                  Expanded(
                    child: ListView(
                      controller: sc,
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        // Customer card matching Screenshot 2
                        Card(
                          elevation: 0.5,
                          child: ListTile(
                            title: const Text("Customer Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                            subtitle: Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                            trailing: IconButton(
                              icon: const Icon(Icons.add, color: Colors.blue),
                              onPressed: () {
                                _showCustomerSelectDialog(appState, setCartState);
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Review Order section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Review Order", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF475569))),
                            Text("${cartItems.length} Items", style: const TextStyle(fontSize: 11, color: Colors.grey, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),

                        ...cartItems.map((ci) {
                          return Card(
                            elevation: 0.5,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade50,
                                    child: const Icon(Icons.menu_book_rounded, color: Colors.blue, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(ci.item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                                        Text("Price: ${formatCurrency.format(ci.item.salePrice)}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      // Quantity Selector
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 4),
                                        decoration: BoxDecoration(border: Border.all(color: Colors.blue.shade200), borderRadius: BorderRadius.circular(8)),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, size: 14, color: Colors.blue),
                                              onPressed: () {
                                                setCartState(() {
                                                  if (_cart[ci.item.id]! > 1) {
                                                    _cart[ci.item.id] = _cart[ci.item.id]! - 1;
                                                  } else {
                                                    _cart.remove(ci.item.id);
                                                  }
                                                });
                                                setState(() {});
                                              },
                                            ),
                                            Text("${ci.quantity.toInt()}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue)),
                                            IconButton(
                                              icon: const Icon(Icons.add, size: 14, color: Colors.blue),
                                              onPressed: () {
                                                setCartState(() {
                                                  _cart[ci.item.id] = _cart[ci.item.id]! + 1;
                                                });
                                                setState(() {});
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(formatCurrency.format(ci.item.salePrice * ci.quantity), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        const SizedBox(height: 18),

                        // Bill Details card matching screenshot
                        Card(
                          elevation: 0.5,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Bill Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                                const Divider(),
                                _buildBillDetailsRow("Sub Total", formatCurrency.format(subtotal)),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Bill Discount", style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit, size: 12),
                                      label: Text(_billDiscount > 0 ? "${_billDiscount.toStringAsFixed(0)}% Off" : "Add Discount"),
                                      onPressed: () {
                                        _showDiscountInputDialog(setCartState);
                                      },
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Additional Charge", style: TextStyle(fontSize: 12, color: Color(0xFF334155))),
                                    TextButton.icon(
                                      icon: const Icon(Icons.edit, size: 12),
                                      label: Text(_additionalCharges > 0 ? formatCurrency.format(_additionalCharges) : "Add Charges"),
                                      onPressed: () {
                                        _showChargesInputDialog(setCartState);
                                      },
                                    ),
                                  ],
                                ),
                                _buildBillDetailsRow("Round off", "₹ 0"),
                                const Divider(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text(formatCurrency.format(total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: Color(0xFF1E293B))),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Payment mode selection
                        Card(
                          elevation: 0.5,
                          child: ListTile(
                            title: const Text("Payment Mode", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                            subtitle: Text(_paymentMode, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B))),
                            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                            onTap: () {
                              setCartState(() {
                                _paymentMode = _paymentMode == "Cash" ? "Bank / UPI" : "Cash";
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom Button Create Invoice matching screenshot
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                    decoration: BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Colors.grey.shade200))),
                    child: ThreeDButton(
                      height: 52,
                      color: AppTheme.accentRed,
                      onPressed: () {
                        if (_cart.isEmpty) return;
                        _saveAndGeneratePOSInvoice(appState, total, cartItems);
                      },
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Total: ${formatCurrency.format(total)}", style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                          Row(
                            children: const [
                              Text("Create Invoice", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBillDetailsRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF334155))),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
        ],
      ),
    );
  }

  void _showCustomerSelectDialog(AppState appState, StateSetter setCartState) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Customer"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: appState.parties.length,
            itemBuilder: (context, idx) {
              final party = appState.parties[idx];
              return ListTile(
                title: Text(party.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                subtitle: Text("Ph: ${party.phone}", style: const TextStyle(fontSize: 10)),
                onTap: () {
                  setCartState(() {
                    _selectedPartyId = party.id;
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

  void _showDiscountInputDialog(StateSetter setCartState) {
    final ctrl = TextEditingController(text: _billDiscount.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Bill Discount (%)"),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setCartState(() {
                _billDiscount = double.tryParse(ctrl.text) ?? _billDiscount;
              });
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  void _showChargesInputDialog(StateSetter setCartState) {
    final ctrl = TextEditingController(text: _additionalCharges.toStringAsFixed(0));
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Enter Additional Charges (₹)"),
        content: TextField(controller: ctrl, keyboardType: TextInputType.number),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              setCartState(() {
                _additionalCharges = double.tryParse(ctrl.text) ?? _additionalCharges;
              });
              Navigator.pop(context);
            },
            child: const Text("Apply"),
          ),
        ],
      ),
    );
  }

  void _showAddNewItemDialog(AppState appState) {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add New Product"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: "Product Title")),
            TextField(controller: priceCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Sale Price")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty && priceCtrl.text.trim().isNotEmpty) {
                final price = double.parse(priceCtrl.text.trim());
                final newItem = InventoryItem(
                  id: "pos_${DateTime.now().millisecondsSinceEpoch}",
                  name: nameCtrl.text.trim(),
                  type: ItemType.product,
                  stock: 50.0,
                  salePrice: price,
                  purchasePrice: price * 0.65,
                  unit: "PCS",
                  code: "SKU-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}",
                );
                appState.addInventoryItem(newItem);
                setState(() {});
                Navigator.pop(context);
              }
            },
            child: const Text("Add Product"),
          ),
        ],
      ),
    );
  }

  // Save transaction and launch Invoice view PDF
  void _saveAndGeneratePOSInvoice(AppState state, double total, List<_CartItem> cartItems) {
    String partyName = "";
    if (_selectedPartyId != null) {
      final idx = state.parties.indexWhere((p) => p.id == _selectedPartyId);
      partyName = idx != -1 ? state.parties[idx].name : "Walk-in Cash Client";
    } else {
      partyName = "Walk-in Cash Client";
    }

    final invoiceNo = "POS-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}";

    // Create transaction record
    final tx = Transaction(
      id: "tx_${DateTime.now().millisecondsSinceEpoch}",
      partyId: _selectedPartyId ?? "",
      partyName: partyName,
      type: TransactionType.sale,
      amount: total,
      date: DateTime.now(),
      description: "Mobile POS Sale. Items: ${cartItems.length}",
      invoiceNo: invoiceNo,
    );

    state.addTransaction(tx);

    // Deplete stock
    for (var ci in cartItems) {
      state.updateStock(ci.item.id, -ci.quantity);
    }

    // Reset local cart
    setState(() {
      _cart.clear();
      _selectedPartyId = null;
      _billDiscount = 0.0;
      _additionalCharges = 0.0;
    });

    Navigator.pop(context); // Close cart drawer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Invoice $invoiceNo of ₹${total.toStringAsFixed(2)} created successfully!"),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Now open the PDF simulation
    _launchInvoicePdfViewer(state, invoiceNo, partyName, total, cartItems);
  }

  void _launchInvoicePdfViewer(AppState appState, String invoiceNo, String customerName, double netAmount, List<_CartItem> items) {
    final formatCurrency = NumberFormat.currency(locale: 'en_IN', symbol: '₹ ');

    showDialog(
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
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
                            child: const Text("TAX INVOICE", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.successGreen)),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text("BILLED TO:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 9, color: Colors.grey)),
                              Text(customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text("Invoice No: $invoiceNo", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10)),
                              Text("Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}", style: const TextStyle(fontSize: 10)),
                              Text("Mode: $_paymentMode", style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
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
                          ...items.asMap().entries.map((entry) {
                            final idx = entry.key;
                            final ci = entry.value;
                            return TableRow(
                              children: [
                                Padding(padding: const EdgeInsets.all(6.0), child: Text("${idx + 1}", style: const TextStyle(fontSize: 9), textAlign: TextAlign.center)),
                                Padding(padding: const EdgeInsets.all(6.0), child: Text(ci.item.name, style: const TextStyle(fontSize: 9))),
                                Padding(padding: const EdgeInsets.all(6.0), child: Text("${ci.quantity.toInt()}", style: const TextStyle(fontSize: 9), textAlign: TextAlign.center)),
                                Padding(padding: const EdgeInsets.all(6.0), child: Text(formatCurrency.format(ci.item.salePrice), style: const TextStyle(fontSize: 9), textAlign: TextAlign.right)),
                                Padding(padding: const EdgeInsets.all(6.0), child: Text(formatCurrency.format(ci.item.salePrice * ci.quantity), style: const TextStyle(fontSize: 9), textAlign: TextAlign.right)),
                              ],
                            );
                          }).toList(),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: SizedBox(
                          width: 200,
                          child: Column(
                            children: [
                              _buildPdfTotalRow("Subtotal", formatCurrency.format(items.fold(0.0, (s, c) => s + (c.item.salePrice * c.quantity)))),
                              if (_billDiscount > 0)
                                _buildPdfTotalRow("Bill Discount ($_billDiscount%)", "- ${formatCurrency.format(items.fold(0.0, (s, c) => s + (c.item.salePrice * c.quantity)) * (_billDiscount / 100))}"),
                              _buildPdfTotalRow("Tax Amount", "₹ 0.00"),
                              const Divider(height: 12),
                              _buildPdfTotalRow("NET PAYABLE", formatCurrency.format(netAmount)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.print_rounded),
                      label: const Text("Print Invoice"),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connecting to Bluetooth print client...")));
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.share_rounded),
                      label: const Text("Share via WhatsApp"),
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

  Widget _buildPdfTotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 9)),
          Text(value, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _CartItem {
  final InventoryItem item;
  final double quantity;

  _CartItem(this.item, this.quantity);
}
