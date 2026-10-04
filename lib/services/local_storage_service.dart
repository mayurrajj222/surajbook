import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class LocalStorageService {
  static const String _keyCompanies = 'vyapar_saved_companies_v1';
  static const String _keyActiveIndex = 'vyapar_active_company_idx';
  static const String _keySettings = 'vyapar_app_settings';

  /// Save full state to local disk / browser localStorage
  static Future<void> saveState({
    required List<Company> companies,
    required int activeIndex,
    AppSettings? settings,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> serializedCompanies = [];
      for (final comp in companies) {
        serializedCompanies.add({
          'id': comp.id,
          'name': comp.name,
          'parties': comp.parties.map((p) => p.toMap(companyId: comp.id)).toList(),
          'items': comp.items.map((i) => i.toMap(companyId: comp.id)).toList(),
          'bankAccounts':
              comp.bankAccounts.map((b) => b.toMap(companyId: comp.id)).toList(),
          'transactions':
              comp.transactions.map((t) => t.toMap(companyId: comp.id)).toList(),
        });
      }

      await prefs.setString(_keyCompanies, jsonEncode(serializedCompanies));
      await prefs.setInt(_keyActiveIndex, activeIndex);

      if (settings != null) {
        await prefs.setString(_keySettings, jsonEncode(settings.toMap()));
      }
    } catch (e) {
      debugPrint('Error saving local storage state: $e');
    }
  }

  /// Load state from local disk / browser localStorage
  static Future<List<Company>?> loadCompanies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyCompanies);
      if (raw == null || raw.isEmpty) return null;

      final List<dynamic> list = jsonDecode(raw) as List<dynamic>;
      List<Company> loaded = [];

      for (final compRaw in list) {
        final compMap = Map<String, dynamic>.from(compRaw as Map);
        final partiesRaw = (compMap['parties'] as List<dynamic>? ?? []);
        final itemsRaw = (compMap['items'] as List<dynamic>? ?? []);
        final bankRaw = (compMap['bankAccounts'] as List<dynamic>? ?? []);
        final txRaw = (compMap['transactions'] as List<dynamic>? ?? []);

        final parties = partiesRaw
            .map((p) => Party.fromMap(Map<String, dynamic>.from(p as Map)))
            .toList();
        final items = itemsRaw
            .map((i) => InventoryItem.fromMap(Map<String, dynamic>.from(i as Map)))
            .toList();
        final bankAccounts = bankRaw
            .map((b) => BankAccount.fromMap(Map<String, dynamic>.from(b as Map)))
            .toList();
        final transactions = txRaw
            .map((t) => Transaction.fromMap(Map<String, dynamic>.from(t as Map)))
            .toList();

        loaded.add(Company.fromMap(
          compMap,
          parties: parties,
          items: items,
          bankAccounts: bankAccounts,
          transactions: transactions,
        ));
      }

      return loaded.isNotEmpty ? loaded : null;
    } catch (e) {
      debugPrint('Error loading local storage state: $e');
      return null;
    }
  }

  static Future<int> loadActiveIndex() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyActiveIndex) ?? 0;
    } catch (_) {
      return 0;
    }
  }

  static Future<AppSettings?> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keySettings);
      if (raw == null || raw.isEmpty) return null;
      return AppSettings.fromMap(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }
}
