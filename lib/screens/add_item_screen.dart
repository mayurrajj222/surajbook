import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../models/models.dart';
import '../widgets/three_d_container.dart';
import '../widgets/three_d_button.dart';
import '../theme/app_theme.dart';

class AddItemScreen extends StatefulWidget {
  const AddItemScreen({super.key});

  @override
  State<AddItemScreen> createState() => _AddItemScreenState();
}

class _AddItemScreenState extends State<AddItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _jsrController = TextEditingController();
  final _brandController = TextEditingController();
  final _salePriceController = TextEditingController();
  final _openingStockController = TextEditingController(text: "0");
  
  String? _selectedCategory;
  bool _customFieldsExpanded = true;
  String _activeTab = "Pricing"; // "Pricing" | "Stock" | "Online Store"
  bool _publishToOnlineStore = false;

  final List<String> _categories = [
    "Fiction",
    "Non-Fiction",
    "Biography",
    "Children & Kids",
    "Academic & Education",
    "Stationery",
    "Others"
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _jsrController.dispose();
    _brandController.dispose();
    _salePriceController.dispose();
    _openingStockController.dispose();
    super.dispose();
  }

  // Generates a mock barcode/ISBN code
  void _assignCode() {
    setState(() {
      _codeController.text = "ISBN-${DateTime.now().millisecondsSinceEpoch.toString().substring(5)}";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Barcode generated and assigned!"),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Opens a dialog to input and append a new category
  void _showAddCategoryDialog() {
    final categoryController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Add New Category", style: TextStyle(fontWeight: FontWeight.bold)),
        content: TextField(
          controller: categoryController,
          decoration: InputDecoration(
            labelText: "Category Name",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newCat = categoryController.text.trim();
              if (newCat.isNotEmpty) {
                setState(() {
                  if (!_categories.contains(newCat)) {
                    _categories.add(newCat);
                    _selectedCategory = newCat;
                  }
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Category '$newCat' added successfully!"),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Add Item",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppTheme.primary),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo_outlined, color: Colors.blueAccent),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Photo attachment feature enabled."), behavior: SnackBarBehavior.floating),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.grey),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Opening item settings..."), behavior: SnackBarBehavior.floating),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Scrollable Form body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 1. Item Name Required field
                    _buildTextField(
                      controller: _nameController,
                      label: "Item Name *",
                      hintText: "Enter book title or product name",
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) return "Item Name is required";
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // 2. Item Code / Barcode field with "Assign Code" button
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _codeController,
                            label: "Item Code / Barcode",
                            hintText: "Barcode value",
                          ),
                        ),
                        const SizedBox(width: 10),
                        // Assign Code blue-tint button
                        TextButton(
                          onPressed: _assignCode,
                          style: TextButton.styleFrom(
                            backgroundColor: const Color(0xFFEFF6FF),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Color(0xFFBFDBFE), width: 1),
                            ),
                          ),
                          child: const Text(
                            "Assign Code",
                            style: TextStyle(
                              color: Color(0xFF2563EB),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 3. Item Category Dropdown Selection with Add Category Option
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: _buildDropdownField(
                            value: _selectedCategory,
                            label: "Item Category",
                            hintText: "Select Category",
                            items: _categories,
                            onChanged: (val) {
                              setState(() => _selectedCategory = val);
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                          onSelected: (val) {
                            if (val == "add") {
                              _showAddCategoryDialog();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: "add",
                              child: Row(
                                children: [
                                  Icon(Icons.add_rounded, size: 18, color: AppTheme.primary),
                                  SizedBox(width: 8),
                                  Text("Add Category"),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // 4. 🙏JSR🙏 Notes Custom field
                    _buildTextField(
                      controller: _jsrController,
                      label: "🙏JSR🙏",
                      hintText: "Enter notes / remarks",
                      maxLines: 2,
                    ),
                    const SizedBox(height: 16),

                    // 5. Expander header & Body for "Custom Fields"
                    _buildCustomFieldsExpander(),
                    const SizedBox(height: 16),

                    // 6. Sub-tabs Segment (Pricing, Stock, Online Store)
                    _buildSubTabsSegment(),
                    const SizedBox(height: 16),

                    // 7. Active Sub-tab Forms area
                    _buildActiveTabContent(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Bar containing Cancel & Save
          _buildBottomActionBar(appState),
        ],
      ),
    );
  }

  // Visual helper textfield with bordered container
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hintText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
          hintText: hintText,
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  // Visual helper dropdown with border matching screenshots
  Widget _buildDropdownField({
    required String? value,
    required String label,
    required String hintText,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: DropdownButtonFormField<String>(
        value: value,
        hint: Text(hintText, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF64748B)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13, fontWeight: FontWeight.w600),
          border: InputBorder.none,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 4),
        ),
        items: items.map((cat) {
          return DropdownMenuItem<String>(
            value: cat,
            child: Text(cat, style: const TextStyle(fontSize: 13)),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  // Custom Fields Expandable accordion widget
  Widget _buildCustomFieldsExpander() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Accordion Header
        InkWell(
          onTap: () {
            setState(() {
              _customFieldsExpanded = !_customFieldsExpanded;
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Custom Fields",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF334155)),
                ),
                Icon(
                  _customFieldsExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: const Color(0xFF64748B),
                ),
              ],
            ),
          ),
        ),
        // Accordion Body
        if (_customFieldsExpanded) ...[
          const SizedBox(height: 12),
          _buildTextField(
            controller: _brandController,
            label: "Brand",
            hintText: "Enter book publisher or brand",
          ),
        ],
      ],
    );
  }

  // Horizontal sub-tabs System
  Widget _buildSubTabsSegment() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildSubTabButton("Pricing"),
          _buildSubTabButton("Stock"),
          _buildSubTabButton("Online Store"),
        ],
      ),
    );
  }

  Widget _buildSubTabButton(String tabName) {
    final isActive = _activeTab == tabName;

    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = tabName),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: isActive
                ? const Border(
                    bottom: BorderSide(color: AppTheme.accentRed, width: 2),
                  )
                : null,
          ),
          child: Text(
            tabName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: isActive ? AppTheme.accentRed : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }

  // Conditional widget selector displaying active sub-tab content
  Widget _buildActiveTabContent() {
    if (_activeTab == "Pricing") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                "Sale Price",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
              const SizedBox(width: 8),
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF94A3B8), width: 1),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _salePriceController,
            label: "Sale Price",
            hintText: "0.0",
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      );
    } else if (_activeTab == "Stock") {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                "Opening Stock",
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF334155)),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.info_outline_rounded, size: 14, color: Color(0xFF94A3B8)),
            ],
          ),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _openingStockController,
            label: "Opening Stock",
            hintText: "Ex: 300",
            keyboardType: TextInputType.number,
          ),
        ],
      );
    } else {
      // Online Store
      return ThreeDContainer(
        depth: 2,
        borderRadius: 12,
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Publish to Online Catalog",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF1E293B)),
                ),
                Text(
                  "Display book listing to store customers",
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
              ],
            ),
            Switch(
              value: _publishToOnlineStore,
              activeColor: AppTheme.successGreen,
              onChanged: (val) {
                setState(() => _publishToOnlineStore = val);
              },
            ),
          ],
        ),
      );
    }
  }

  // Cancel & Save actions bar at bottom matching screenshots
  Widget _buildBottomActionBar(AppState state) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFE2E8F0), width: 1),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Cancel Flat Button
            Expanded(
              child: InkWell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
            // Save Solid Red Button
            Expanded(
              child: InkWell(
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text.trim();
                    final code = _codeController.text.trim().isNotEmpty
                        ? _codeController.text.trim()
                        : "ISBN-${DateTime.now().millisecondsSinceEpoch.toString().substring(6)}";
                    final salePrice = double.tryParse(_salePriceController.text.trim()) ?? 0.0;
                    final openingStock = double.tryParse(_openingStockController.text.trim()) ?? 0.0;

                    // Build and save inventory item
                    final newItem = InventoryItem(
                      id: "i_${DateTime.now().millisecondsSinceEpoch}",
                      name: name,
                      type: ItemType.product,
                      stock: openingStock,
                      salePrice: salePrice,
                      purchasePrice: salePrice * 0.7, // Simulated cost price
                      unit: "PCS",
                      code: code,
                      category: _selectedCategory ?? "Others",
                    );

                    state.addInventoryItem(newItem);
                    Navigator.pop(context);
                    
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Book '$name' added to catalog successfully!"),
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: AppTheme.successGreen,
                      ),
                    );
                  }
                },
                child: Container(
                  height: 52,
                  color: const Color(0xFFE11D48), // Solid crimson red
                  alignment: Alignment.center,
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: Colors.white,
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
}
