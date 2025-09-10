import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/sheet_row.dart';

class SheetService {
  final String apiUrl =
      "https://script.google.com/macros/s/AKfycbzarsErdO7jsSEYlB1CG5m-I94MyMUiz-cWoeLr2ZYTnfch51mBxUtNUKdLncorB10kJA/exec";

  Future<List<SheetRow>> fetchData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        await _saveCache(response.body);
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((e) => SheetRow.fromJson(e)).toList();
      } else {
        throw Exception("Failed to fetch data");
      }
    } catch (e) {
      print("Error fetching data: $e");
      return await loadCache();
    }
  }

  Future<List<SheetRow>> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedJson = prefs.getString("sheet_cache");
    if (cachedJson != null) {
      final List<dynamic> jsonData = json.decode(cachedJson);
      return jsonData.map((e) => SheetRow.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> _saveCache(String jsonData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("sheet_cache", jsonData);
    await prefs.setString("last_updated", DateTime.now().toIso8601String());
  }

  Future<String?> getLastUpdated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("last_updated");
  }
}
