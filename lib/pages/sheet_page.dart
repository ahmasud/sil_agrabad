import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/sheet_row.dart';
import '../services/sheet_service.dart';
import '../widgets/contact_chip.dart';
import '../widgets/offline_banner.dart';

class SheetPage extends StatefulWidget {
  const SheetPage({super.key});

  @override
  State<SheetPage> createState() => _SheetPageState();
}

class _SheetPageState extends State<SheetPage> {
  final SheetService _service = SheetService();
  List<SheetRow> data = [];
  List<SheetRow> filteredData = [];
  bool isLoading = true;
  bool isError = false;
  bool isOfflineMode = false;
  String? lastUpdated;

  late StreamSubscription<ConnectivityResult> _connectivitySub;

  @override
  void initState() {
    super.initState();

    _connectivitySub =
        Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
          setState(() {
            isOfflineMode = result == ConnectivityResult.none;
          });
        });

    loadData();
  }

  @override
  void dispose() {
    _connectivitySub.cancel();
    super.dispose();
  }

  Future<void> loadData() async {
    setState(() => isLoading = true);
    final fetchedData = await _service.fetchData();
    final updatedTime = await _service.getLastUpdated();

    setState(() {
      data = fetchedData;
      filteredData = data;
      isLoading = false;
      isError = data.isEmpty;
      lastUpdated = updatedTime;
    });
  }

  void filterData(String query) {
    setState(() {
      final q = query.toLowerCase();
      filteredData = data.where((row) {
        return row.customerName.toLowerCase().contains(q) ||
            row.vendor.toLowerCase().contains(q) ||
            row.ipAddress.toLowerCase().contains(q) ||
            row.location.toLowerCase().contains(q) ||
            row.contactField.toLowerCase().contains(q);
      }).toList();
    });
  }

  List<String> splitContacts(String contactField) {
    return contactField.split(RegExp(r'[,;]')).map((e) => e.trim()).toList();
  }

  String formatLastUpdated(String isoString) {
    final dt = DateTime.parse(isoString).toLocal();
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    if (dt.year == now.year &&
        dt.month == now.month &&
        dt.day == now.day) {
      return "Today at ${TimeOfDay.fromDateTime(dt).format(context)}";
    } else if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return "Yesterday at ${TimeOfDay.fromDateTime(dt).format(context)}";
    } else {
      return "${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year} ${TimeOfDay.fromDateTime(dt).format(context)}";
    }
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
        centerTitle: false,
      ),
      body: Column(
        children: [
          if (isOfflineMode) const OfflineBanner(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : isError
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "⚠️ Failed to load data.\nCheck internet or API link.",
                    style:
                    TextStyle(fontSize: 16, color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: loadData,
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
                      "Search by Customer, Contact, Vendor, Location or IP",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                    onChanged: filterData,
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: loadData,
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
                        final contacts =
                        splitContacts(row.contactField);

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius:
                            BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          child: ListTile(
                            title: Text(
                              row.customerName,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold),
                            ),
                            subtitle: Column(
                              crossAxisAlignment:
                              CrossAxisAlignment.start,
                              children: [
                                if (row.vendor.isNotEmpty)
                                  Text("Vendor: ${row.vendor}"),
                                if (row.location.isNotEmpty)
                                  Text(
                                      "Location: ${row.location}"),
                                if (row.ipAddress.isNotEmpty)
                                  Text(
                                    "IP Address: ${row.ipAddress}",
                                    style: const TextStyle(
                                        color: Colors.grey),
                                  ),
                                const SizedBox(height: 6),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 4,
                                  children: contacts
                                      .map((c) =>
                                      ContactChip(contact: c))
                                      .toList(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                if (lastUpdated != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Last Updated: ${formatLastUpdated(lastUpdated!)}",
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
