import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('absensi');

  String _searchKeyword = "";
  String _selectedKeterangan = "Semua";
  bool _sortByNameAsc = true;

  final TextEditingController _searchController = TextEditingController();

  // ✅ Tambahkan opsi baru di sini
  List<String> keteranganOptions = [
    "Semua",
    "Masuk",
    "Telat",
    "Keluar",
    "Cuti",
    "Izin",
    "Sakit"
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Riwayat Absensi",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          // 🔍 Filter Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Search by name/keterangan
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan nama / keterangan...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchKeyword = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 10),

                // Filter dan Sort dalam 1 baris
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        value: _selectedKeterangan,
                        items: keteranganOptions
                            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedKeterangan = val!;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text("Urutkan Nama: "),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _sortByNameAsc = !_sortByNameAsc;
                        });
                      },
                      icon: Icon(_sortByNameAsc ? Icons.arrow_upward : Icons.arrow_downward),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: dataCollection.orderBy('datetime', descending: true).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data!.docs;

                  // 🔍 Apply filters
                  var filteredData = data.where((doc) {
                    final nama = doc['nama'].toString().toLowerCase();
                    final keterangan = doc['keterangan'].toString().toLowerCase();

                    bool matchesSearch = nama.contains(_searchKeyword) || keterangan.contains(_searchKeyword);
                    bool matchesKeterangan = _selectedKeterangan == "Semua" ||
                        keterangan == _selectedKeterangan.toLowerCase();

                    return matchesSearch && matchesKeterangan;
                  }).toList();

                  // 🔃 Sort by name
                  filteredData.sort((a, b) {
                    String nameA = a['nama'].toString().toLowerCase();
                    String nameB = b['nama'].toString().toLowerCase();
                    return _sortByNameAsc ? nameA.compareTo(nameB) : nameB.compareTo(nameA);
                  });

                  return filteredData.isNotEmpty
                      ? ListView.builder(
                    itemCount: filteredData.length,
                    itemBuilder: (context, index) {
                      final doc = filteredData[index];
                      return _buildCard(doc, textTheme, theme, colorScheme);
                    },
                  )
                      : Center(
                    child: Text("Tidak ada data yang cocok!", style: textTheme.headlineSmall),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(flex: 4, child: Text(label, style: textTheme.bodyMedium)),
        const Expanded(flex: 1, child: Text(" : ")),
        Expanded(flex: 8, child: Text(value, style: textTheme.bodyMedium)),
      ],
    );
  }

  Widget _buildCard(QueryDocumentSnapshot doc, TextTheme textTheme, ThemeData theme, ColorScheme colorScheme) {
    return GestureDetector(
      onTap: () {
        AlertDialog dialogHapus = AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          title: Text("Hapus Data", style: textTheme.titleMedium),
          content: const SingleChildScrollView(child: Text("Yakin ingin menghapus data ini?")),
          actions: [
            TextButton(
              onPressed: () {
                dataCollection.doc(doc.id).delete();
                Navigator.pop(context);
                setState(() {});
              },
              child: Text("Ya", style: TextStyle(color: colorScheme.primary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tidak", style: TextStyle(color: colorScheme.onSurface.withOpacity(0.6))),
            ),
          ],
        );
        showDialog(context: context, builder: (context) => dialogHapus);
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 5,
        margin: const EdgeInsets.all(10),
        color: theme.cardColor,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.primaries[Random().nextInt(Colors.primaries.length)],
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Center(
                  child: Text(
                    doc['nama'][0].toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildRow("Nama", doc['nama'], textTheme),
                    _buildRow("Alamat", doc['alamat'], textTheme),
                    _buildRow("Keterangan", doc['keterangan'], textTheme),
                    _buildRow("Waktu Absen", doc['datetime'], textTheme),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}