import 'dart:convert';

enum TransactionType {
  sale,
  purchase,
  paymentIn,
  paymentOut,
  expense,
  saleReturn,
  purchaseReturn,
  purchaseOrder,
  estimate,
  deliveryChallan,
}

enum PartyType {
  youWillGet,
  youWillGive,
}

enum ItemType {
  product,
  service,
}

class Party {
  final String id;
  final String name;
  final String phone;
  final String address;
  final String email;
  final double openingBalance;
  double currentBalance;
  final PartyType type;

  Party({
    required this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.email,
    required this.openingBalance,
    required this.currentBalance,
    required this.type,
  });

  Map<String, dynamic> toMap({String? companyId}) {
    return {
      'id': id,
      if (companyId != null) 'company_id': companyId,
      'name': name,
      'phone': phone,
      'address': address,
      'email': email,
      'opening_balance': openingBalance,
      'current_balance': currentBalance,
      'type': type == PartyType.youWillGet ? 'youWillGet' : 'youWillGive',
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory Party.fromMap(Map<String, dynamic> map) {
    return Party(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      phone: map['phone']?.toString() ?? '',
      address: map['address']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      openingBalance: (map['opening_balance'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (map['current_balance'] as num?)?.toDouble() ?? 0.0,
      type: (map['type'] == 'youWillGive')
          ? PartyType.youWillGive
          : PartyType.youWillGet,
    );
  }
}

class Transaction {
  final String id;
  final String partyId;
  final String partyName;
  final TransactionType type;
  final double amount;
  final DateTime date;
  final String description;
  final String invoiceNo;
  final String paymentType;
  final List<dynamic>? items;

  Transaction({
    required this.id,
    required this.partyId,
    required this.partyName,
    required this.type,
    required this.amount,
    required this.date,
    required this.description,
    required this.invoiceNo,
    this.paymentType = 'Credit',
    this.items,
  });

  static TransactionType _parseType(String? val) {
    switch (val) {
      case 'purchase':
        return TransactionType.purchase;
      case 'paymentIn':
        return TransactionType.paymentIn;
      case 'paymentOut':
        return TransactionType.paymentOut;
      case 'expense':
        return TransactionType.expense;
      case 'saleReturn':
        return TransactionType.saleReturn;
      case 'purchaseReturn':
        return TransactionType.purchaseReturn;
      case 'purchaseOrder':
        return TransactionType.purchaseOrder;
      case 'estimate':
        return TransactionType.estimate;
      case 'deliveryChallan':
        return TransactionType.deliveryChallan;
      case 'sale':
      default:
        return TransactionType.sale;
    }
  }

  static String _typeToString(TransactionType type) {
    switch (type) {
      case TransactionType.purchase:
        return 'purchase';
      case TransactionType.paymentIn:
        return 'paymentIn';
      case TransactionType.paymentOut:
        return 'paymentOut';
      case TransactionType.expense:
        return 'expense';
      case TransactionType.saleReturn:
        return 'saleReturn';
      case TransactionType.purchaseReturn:
        return 'purchaseReturn';
      case TransactionType.purchaseOrder:
        return 'purchaseOrder';
      case TransactionType.estimate:
        return 'estimate';
      case TransactionType.deliveryChallan:
        return 'deliveryChallan';
      case TransactionType.sale:
      default:
        return 'sale';
    }
  }

  Map<String, dynamic> toMap({String? companyId}) {
    return {
      'id': id,
      if (companyId != null) 'company_id': companyId,
      'party_id': partyId,
      'party_name': partyName,
      'type': _typeToString(type),
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
      'invoice_no': invoiceNo,
      'payment_type': paymentType,
      'items_json': items != null ? jsonEncode(items) : '[]',
      'created_at': date.toIso8601String(),
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    DateTime parsedDate = DateTime.now();
    if (map['date'] != null) {
      try {
        parsedDate = DateTime.parse(map['date'].toString());
      } catch (_) {}
    }

    List<dynamic>? parsedItems;
    if (map['items_json'] != null) {
      try {
        if (map['items_json'] is List) {
          parsedItems = map['items_json'] as List<dynamic>;
        } else if (map['items_json'] is String) {
          parsedItems = jsonDecode(map['items_json'] as String) as List<dynamic>;
        }
      } catch (_) {}
    }

    return Transaction(
      id: map['id']?.toString() ?? '',
      partyId: map['party_id']?.toString() ?? '',
      partyName: map['party_name']?.toString() ?? '',
      type: _parseType(map['type']?.toString()),
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      date: parsedDate,
      description: map['description']?.toString() ?? '',
      invoiceNo: map['invoice_no']?.toString() ?? '',
      paymentType: map['payment_type']?.toString() ?? 'Credit',
      items: parsedItems,
    );
  }
}

class InventoryItem {
  final String id;
  final String name;
  final ItemType type;
  double stock;
  final double salePrice;
  final double purchasePrice;
  final String unit;
  final String code;
  final String category;

  InventoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.stock,
    required this.salePrice,
    required this.purchasePrice,
    required this.unit,
    required this.code,
    this.category = "Others",
  });

  Map<String, dynamic> toMap({String? companyId}) {
    return {
      'id': id,
      if (companyId != null) 'company_id': companyId,
      'name': name,
      'type': type == ItemType.product ? 'product' : 'service',
      'stock': stock,
      'sale_price': salePrice,
      'purchase_price': purchasePrice,
      'unit': unit,
      'code': code,
      'category': category,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory InventoryItem.fromMap(Map<String, dynamic> map) {
    return InventoryItem(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      type: (map['type'] == 'service') ? ItemType.service : ItemType.product,
      stock: (map['stock'] as num?)?.toDouble() ?? 0.0,
      salePrice: (map['sale_price'] as num?)?.toDouble() ?? 0.0,
      purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0.0,
      unit: map['unit']?.toString() ?? 'PCS',
      code: map['code']?.toString() ?? '',
      category: map['category']?.toString() ?? 'Others',
    );
  }
}

class BankAccount {
  final String id;
  final String name;
  final String accountNumber;
  double balance;
  final bool isCash;
  final bool printOnInvoice;
  final bool printUPIOnInvoice;

  BankAccount({
    required this.id,
    required this.name,
    this.accountNumber = "",
    required this.balance,
    required this.isCash,
    this.printOnInvoice = false,
    this.printUPIOnInvoice = false,
  });

  Map<String, dynamic> toMap({String? companyId}) {
    return {
      'id': id,
      if (companyId != null) 'company_id': companyId,
      'name': name,
      'account_number': accountNumber,
      'balance': balance,
      'is_cash': isCash,
      'print_on_invoice': printOnInvoice,
      'print_upi_on_invoice': printUPIOnInvoice,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory BankAccount.fromMap(Map<String, dynamic> map) {
    return BankAccount(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      accountNumber: map['account_number']?.toString() ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      isCash: (map['is_cash'] as bool?) ?? false,
      printOnInvoice: (map['print_on_invoice'] as bool?) ?? false,
      printUPIOnInvoice: (map['print_upi_on_invoice'] as bool?) ?? false,
    );
  }
}

class Company {
  final String id;
  String name;
  final List<Party> parties;
  final List<Transaction> transactions;
  final List<InventoryItem> items;
  final List<BankAccount> bankAccounts;

  Company({
    required this.id,
    required this.name,
    required this.parties,
    required this.transactions,
    required this.items,
    required this.bankAccounts,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory Company.fromMap(
    Map<String, dynamic> map, {
    List<Party>? parties,
    List<Transaction>? transactions,
    List<InventoryItem>? items,
    List<BankAccount>? bankAccounts,
  }) {
    return Company(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      parties: parties ?? [],
      transactions: transactions ?? [],
      items: items ?? [],
      bankAccounts: bankAccounts ?? [],
    );
  }
}

class AppSettings {
  final String id;
  final String companyId;
  final bool isOnlineStoreEnabled;
  final String onlineStoreName;
  final String onlineStoreWhatsApp;
  final double onlineStoreDeliveryFee;
  final String invoiceTheme;
  final bool invoiceShowGST;
  final bool invoiceShowQR;
  final bool invoiceShowSignature;
  final String invoiceTermsAndConditions;
  final bool isCloudSyncEnabled;

  AppSettings({
    required this.id,
    required this.companyId,
    this.isOnlineStoreEnabled = true,
    this.onlineStoreName = "Suraj Book Store Online",
    this.onlineStoreWhatsApp = "9876543210",
    this.onlineStoreDeliveryFee = 40.0,
    this.invoiceTheme = "Modern Indigo",
    this.invoiceShowGST = true,
    this.invoiceShowQR = true,
    this.invoiceShowSignature = true,
    this.invoiceTermsAndConditions =
        "1. Goods once sold will not be taken back.\n2. Subject to local jurisdiction.",
    this.isCloudSyncEnabled = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'company_id': companyId,
      'is_online_store_enabled': isOnlineStoreEnabled,
      'online_store_name': onlineStoreName,
      'online_store_whatsapp': onlineStoreWhatsApp,
      'online_store_delivery_fee': onlineStoreDeliveryFee,
      'invoice_theme': invoiceTheme,
      'invoice_show_gst': invoiceShowGST,
      'invoice_show_qr': invoiceShowQR,
      'invoice_show_signature': invoiceShowSignature,
      'invoice_terms_and_conditions': invoiceTermsAndConditions,
      'is_cloud_sync_enabled': isCloudSyncEnabled,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    return AppSettings(
      id: map['id']?.toString() ?? '',
      companyId: map['company_id']?.toString() ?? '',
      isOnlineStoreEnabled: (map['is_online_store_enabled'] as bool?) ?? true,
      onlineStoreName: map['online_store_name']?.toString() ?? "Suraj Book Store Online",
      onlineStoreWhatsApp: map['online_store_whatsapp']?.toString() ?? "9876543210",
      onlineStoreDeliveryFee: (map['online_store_delivery_fee'] as num?)?.toDouble() ?? 40.0,
      invoiceTheme: map['invoice_theme']?.toString() ?? "Modern Indigo",
      invoiceShowGST: (map['invoice_show_gst'] as bool?) ?? true,
      invoiceShowQR: (map['invoice_show_qr'] as bool?) ?? true,
      invoiceShowSignature: (map['invoice_show_signature'] as bool?) ?? true,
      invoiceTermsAndConditions: map['invoice_terms_and_conditions']?.toString() ??
          "1. Goods once sold will not be taken back.\n2. Subject to local jurisdiction.",
      isCloudSyncEnabled: (map['is_cloud_sync_enabled'] as bool?) ?? true,
    );
  }
}
