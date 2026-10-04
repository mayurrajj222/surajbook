import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/models.dart';

class SupabaseService {
  static const String supabaseUrl = 'https://gyebnyhkcdbgcavhtmgs.supabase.co';
  static const String supabaseAnonKey =
      'sb_publishable_4jrfYKXjBkYnfjcJYOaB9w_89XwuOCr';
  static const String supabaseSecretKey =
      'sb_secret_mum8YrThKyxAe7qtKTcaEA_qinVXoSD';

  static SupabaseClient? _client;
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized && _client != null;

  static SupabaseClient get client {
    if (_client == null) {
      try {
        _client = Supabase.instance.client;
        _isInitialized = true;
      } catch (e) {
        debugPrint('Supabase not yet initialized: $e');
      }
    }
    return _client ?? Supabase.instance.client;
  }

  /// Initialize Supabase
  static Future<void> initialize() async {
    try {
      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        debug: kDebugMode,
      );
      _client = Supabase.instance.client;
      _isInitialized = true;
      debugPrint('✓ Supabase initialized successfully!');
    } catch (e) {
      debugPrint('Supabase initialization error: $e');
      _isInitialized = false;
    }
  }

  // ===========================================================================
  // COMPANIES
  // ===========================================================================

  static Future<List<Company>> fetchCompanies() async {
    if (!isInitialized) return [];
    try {
      final response = await client
          .from('companies')
          .select()
          .order('name', ascending: true);
      final List<dynamic> data = response as List<dynamic>;

      List<Company> companies = [];
      for (final compMap in data) {
        final map = Map<String, dynamic>.from(compMap as Map);
        final String companyId = map['id'].toString();

        final parties = await fetchParties(companyId);
        final items = await fetchItems(companyId);
        final bankAccounts = await fetchBankAccounts(companyId);
        final transactions = await fetchTransactions(companyId);

        companies.add(Company.fromMap(
          map,
          parties: parties,
          items: items,
          bankAccounts: bankAccounts,
          transactions: transactions,
        ));
      }
      return companies;
    } catch (e) {
      debugPrint('Error fetching companies from Supabase: $e');
      return [];
    }
  }

  static Future<bool> saveCompany(Company company) async {
    if (!isInitialized) return false;
    try {
      await client.from('companies').upsert(company.toMap());
      return true;
    } catch (e) {
      debugPrint('Error saving company: $e');
      return false;
    }
  }

  // ===========================================================================
  // PARTIES (Customers & Suppliers)
  // ===========================================================================

  static Future<List<Party>> fetchParties(String companyId) async {
    if (!isInitialized) return [];
    try {
      final response = await client
          .from('parties')
          .select()
          .eq('company_id', companyId)
          .order('name', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((item) => Party.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching parties for $companyId: $e');
      return [];
    }
  }

  static Future<bool> saveParty(Party party, String companyId) async {
    if (!isInitialized) return false;
    try {
      await client.from('companies').upsert({
        'id': companyId,
        'name': 'My Business',
        'updated_at': DateTime.now().toIso8601String(),
      });
      await client.from('parties').upsert(party.toMap(companyId: companyId));
      return true;
    } catch (e) {
      debugPrint('Error saving party: $e');
      return false;
    }
  }

  static Future<bool> updatePartyBalance(
      String partyId, double currentBalance) async {
    if (!isInitialized) return false;
    try {
      await client.from('parties').update({
        'current_balance': currentBalance,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', partyId);
      return true;
    } catch (e) {
      debugPrint('Error updating party balance: $e');
      return false;
    }
  }

  static Future<bool> deleteParty(String partyId) async {
    if (!isInitialized) return false;
    try {
      await client.from('parties').delete().eq('id', partyId);
      return true;
    } catch (e) {
      debugPrint('Error deleting party: $e');
      return false;
    }
  }

  // ===========================================================================
  // INVENTORY ITEMS (Products & Services)
  // ===========================================================================

  static Future<List<InventoryItem>> fetchItems(String companyId) async {
    if (!isInitialized) return [];
    try {
      final response = await client
          .from('inventory_items')
          .select()
          .eq('company_id', companyId)
          .order('name', ascending: true);
      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((item) =>
              InventoryItem.fromMap(Map<String, dynamic>.from(item as Map)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching inventory items for $companyId: $e');
      return [];
    }
  }

  static Future<bool> saveItem(InventoryItem item, String companyId) async {
    if (!isInitialized) return false;
    try {
      await client.from('companies').upsert({
        'id': companyId,
        'name': 'My Business',
        'updated_at': DateTime.now().toIso8601String(),
      });
      await client
          .from('inventory_items')
          .upsert(item.toMap(companyId: companyId));
      return true;
    } catch (e) {
      debugPrint('Error saving inventory item: $e');
      return false;
    }
  }

  static Future<bool> updateItemStock(String itemId, double newStock) async {
    if (!isInitialized) return false;
    try {
      await client.from('inventory_items').update({
        'stock': newStock,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', itemId);
      return true;
    } catch (e) {
      debugPrint('Error updating item stock: $e');
      return false;
    }
  }

  static Future<bool> deleteItem(String itemId) async {
    if (!isInitialized) return false;
    try {
      await client.from('inventory_items').delete().eq('id', itemId);
      return true;
    } catch (e) {
      debugPrint('Error deleting inventory item: $e');
      return false;
    }
  }

  // ===========================================================================
  // BANK ACCOUNTS & CASH REGISTERS
  // ===========================================================================

  static Future<List<BankAccount>> fetchBankAccounts(String companyId) async {
    if (!isInitialized) return [];
    try {
      final response = await client
          .from('bank_accounts')
          .select()
          .eq('company_id', companyId)
          .order('is_cash', ascending: false);
      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((acc) =>
              BankAccount.fromMap(Map<String, dynamic>.from(acc as Map)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching bank accounts for $companyId: $e');
      return [];
    }
  }

  static Future<bool> saveBankAccount(
      BankAccount account, String companyId) async {
    if (!isInitialized) return false;
    try {
      await client.from('companies').upsert({
        'id': companyId,
        'name': 'My Business',
        'updated_at': DateTime.now().toIso8601String(),
      });
      await client
          .from('bank_accounts')
          .upsert(account.toMap(companyId: companyId));
      return true;
    } catch (e) {
      debugPrint('Error saving bank account: $e');
      return false;
    }
  }

  static Future<bool> updateBankAccountBalance(
      String accountId, double balance) async {
    if (!isInitialized) return false;
    try {
      await client.from('bank_accounts').update({
        'balance': balance,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', accountId);
      return true;
    } catch (e) {
      debugPrint('Error updating bank account balance: $e');
      return false;
    }
  }

  // ===========================================================================
  // TRANSACTIONS
  // ===========================================================================

  static Future<List<Transaction>> fetchTransactions(String companyId) async {
    if (!isInitialized) return [];
    try {
      final response = await client
          .from('transactions')
          .select()
          .eq('company_id', companyId)
          .order('date', ascending: false);
      final List<dynamic> data = response as List<dynamic>;
      return data
          .map((tx) =>
              Transaction.fromMap(Map<String, dynamic>.from(tx as Map)))
          .toList();
    } catch (e) {
      debugPrint('Error fetching transactions for $companyId: $e');
      return [];
    }
  }

  static Future<bool> saveTransaction(
      Transaction tx, String companyId) async {
    if (!isInitialized) return false;
    try {
      await client.from('companies').upsert({
        'id': companyId,
        'name': 'My Business',
        'updated_at': DateTime.now().toIso8601String(),
      });
      await client
          .from('transactions')
          .upsert(tx.toMap(companyId: companyId));
      return true;
    } catch (e) {
      debugPrint('Error saving transaction: $e');
      return false;
    }
  }

  // ===========================================================================
  // APP SETTINGS
  // ===========================================================================

  static Future<AppSettings?> fetchSettings(String companyId) async {
    if (!isInitialized) return null;
    try {
      final response = await client
          .from('app_settings')
          .select()
          .eq('company_id', companyId)
          .maybeSingle();
      if (response != null) {
        return AppSettings.fromMap(Map<String, dynamic>.from(response));
      }
    } catch (e) {
      debugPrint('Error fetching app settings for $companyId: $e');
    }
    return null;
  }

  static Future<bool> saveSettings(AppSettings settings) async {
    if (!isInitialized) return false;
    try {
      await client.from('app_settings').upsert(settings.toMap());
      return true;
    } catch (e) {
      debugPrint('Error saving app settings: $e');
      return false;
    }
  }

  // ===========================================================================
  // FULL SEED SYNC (Uploads local data to Supabase in background)
  // ===========================================================================

  static Future<void> syncCompanyToSupabase(Company company, AppSettings settings) async {
    if (!isInitialized) return;
    try {
      await saveCompany(company);
      await saveSettings(settings);

      for (final bank in company.bankAccounts) {
        await saveBankAccount(bank, company.id);
      }
      for (final party in company.parties) {
        await saveParty(party, company.id);
      }
      for (final item in company.items) {
        await saveItem(item, company.id);
      }
      for (final tx in company.transactions) {
        await saveTransaction(tx, company.id);
      }
      debugPrint('✓ Company ${company.name} synced to Supabase successfully!');
    } catch (e) {
      debugPrint('Error syncing company to Supabase: $e');
    }
  }
}
