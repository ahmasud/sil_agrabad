import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart'; // Clipboard

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SIL || CTG DataSheet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade50,
      ),
      home: const SheetPage(),
    );
  }
}

class SheetPage extends StatefulWidget {
  const SheetPage({super.key});

  @override
  State<SheetPage> createState() => _SheetPageState();
}

class _SheetPageState extends State<SheetPage> {
  List<dynamic> data = [];
  List<dynamic> filteredData = [];
  bool isLoading = true;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    const sheetUrl = "https://sheetdb.io/api/v1/wygdedeeqhzu7";
    try {
      final response = await http.get(Uri.parse(sheetUrl));
      if (response.statusCode == 200) {
        setState(() {
          data = json.decode(response.body);
          filteredData = data;
          isLoading = false;
          isError = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        isError = true;
      });
    }
  }

  void filterData(String query) {
    setState(() {
      final q = query.toLowerCase();
      filteredData = data.where((row) {
        final customer = row["Customer Name"]?.toString().toLowerCase() ?? "";
        final contact =
            row["Contact Name & Number"]?.toString().toLowerCase() ?? "";
        final vendor = row["Vendor"]?.toString().toLowerCase() ?? "";
        final ip = row["IP Address"]?.toString().toLowerCase() ?? "";
        return customer.contains(q) ||
            contact.contains(q) ||
            vendor.contains(q) ||
            ip.contains(q); // ✅ include IP in search
      }).toList();
    });
  }

  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Copied: $text")),
    );
  }

  List<String> splitContacts(String contactField) {
    return contactField.split(RegExp(r'[,;]')).map((e) => e.trim()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "SIL || CTG DataSheet",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : isError
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "⚠️ Failed to load data.\nCheck internet or API link.",
              style: TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text("Retry"),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(
                labelText:
                "Search by Customer, Contact, Vendor, or IP",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: filterData,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: fetchData,
              child: filteredData.isEmpty
                  ? ListView(
                children: const [
                  SizedBox(
                    height: 300,
                    child: Center(
                      child: Text("No results found"),
                    ),
                  ),
                ],
              )
                  : ListView.builder(
                itemCount: filteredData.length,
                itemBuilder: (context, index) {
                  final row = filteredData[index];
                  final customer = row["Customer Name"] ?? "";
                  final contactField =
                      row["Contact Name & Number"] ?? "";
                  final vendor = row["Vendor"] ?? "";
                  final ipAddress = row["IP Address"] ?? "";
                  final contacts = splitContacts(contactField);

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(
                        vertical: 6, horizontal: 10),
                    child: ListTile(
                      title: Text(
                        customer,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,

                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          if (vendor.isNotEmpty)
                            Text(
                              "Vendor: $vendor",
                              style: const TextStyle(
                              ),
                            ),
                          if (ipAddress.isNotEmpty)
                            Text(
                              "IP Address: $ipAddress",
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: contacts.map((c) {
                              return OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets
                                      .symmetric(
                                      horizontal: 8,
                                      vertical: 4),
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                  MaterialTapTargetSize
                                      .shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        8),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.copy,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                                label: Text(
                                  c,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.black87,
                                  ),
                                ),
                                onPressed: () =>
                                    copyToClipboard(c),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
