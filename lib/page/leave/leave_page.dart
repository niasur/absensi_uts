import 'package:absensi_app/page/main_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeavePage extends StatefulWidget {
  const LeavePage({super.key});

  @override
  State<LeavePage> createState() => _LeavePageState();
}

class _LeavePageState extends State<LeavePage> {
  final controllerName = TextEditingController();
  final fromController = TextEditingController();
  final toController = TextEditingController();

  String dropValueCategories = "Pilih:";
  final categoriesList = ["Pilih:", "Cuti", "Izin", "Sakit"];

  final CollectionReference dataCollection =
  FirebaseFirestore.instance.collection('absensi');

  @override
  void dispose() {
    controllerName.dispose();
    fromController.dispose();
    toController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Menu Pengajuan Cuti / Izin",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        child: Card(
          color: theme.cardColor,
          margin: const EdgeInsets.fromLTRB(10, 10, 10, 30),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          elevation: 5,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                  color: theme.colorScheme.primary,
                ),
                child: const Row(
                  children: [
                    SizedBox(width: 12),
                    Icon(Icons.maps_home_work_outlined, color: Colors.white),
                    SizedBox(width: 12),
                    Text(
                      "Isi Form Sesuai Pengajuan ya!",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 20),
                child: TextField(
                  controller: controllerName,
                  style: theme.textTheme.bodyMedium,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                    labelText: "Masukan Nama Anda",
                    hintText: "Nama Anda",
                    hintStyle: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
                    labelStyle: theme.textTheme.bodySmall,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: theme.colorScheme.primary),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                child: Text(
                  "Keterangan",
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: theme.colorScheme.primary, width: 1),
                  ),
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: dropValueCategories,
                    onChanged: (value) {
                      setState(() {
                        dropValueCategories = value!;
                      });
                    },
                    underline: const SizedBox(),
                    style: theme.textTheme.bodyMedium,
                    items: categoriesList.map((value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value, style: theme.textTheme.bodyMedium),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Text("From: ", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: TextField(
                              readOnly: true,
                              controller: fromController,
                              style: theme.textTheme.bodyMedium,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(9999),
                                  builder: (context, child) {
                                    return Theme(
                                      data: theme.copyWith(
                                        colorScheme: theme.colorScheme.copyWith(
                                          primary: theme.colorScheme.primary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (pickedDate != null) {
                                  fromController.text = DateFormat('dd/M/yyyy').format(pickedDate);
                                }
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(8),
                                hintText: "Starting From",
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Row(
                        children: [
                          Text("Until: ", style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                          Expanded(
                            child: TextField(
                              readOnly: true,
                              controller: toController,
                              style: theme.textTheme.bodyMedium,
                              onTap: () async {
                                DateTime? pickedDate = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1900),
                                  lastDate: DateTime(9999),
                                  builder: (context, child) {
                                    return Theme(
                                      data: theme.copyWith(
                                        colorScheme: theme.colorScheme.copyWith(
                                          primary: theme.colorScheme.primary,
                                        ),
                                      ),
                                      child: child!,
                                    );
                                  },
                                );
                                if (pickedDate != null) {
                                  toController.text = DateFormat('dd/M/yyyy').format(pickedDate);
                                }
                              },
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.all(8),
                                hintText: "Until",
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(30),
                child: Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: size.width,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: theme.colorScheme.primary,
                    ),
                    child: InkWell(
                      splashColor: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        if (controllerName.text.isEmpty ||
                            dropValueCategories == "Pilih:" ||
                            fromController.text.isEmpty ||
                            toController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.info_outline, color: Colors.white),
                                  SizedBox(width: 10),
                                  Text("Ups, inputan tidak boleh kosong!",
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                              backgroundColor: Colors.redAccent,
                              shape: StadiumBorder(),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else {
                          submitAbsen(
                            controllerName.text,
                            dropValueCategories,
                            fromController.text,
                            toController.text,
                          );
                        }
                      },
                      child: const Center(
                        child: Text(
                          "Ajukan Sekarang",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: SingleChildScrollView(
        child: Row(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(width: 20),
            const Text("Mohon tunggu..."),
          ],
        ),
      ),
    );
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Future<void> submitAbsen(
      String nama,
      String keterangan,
      String from,
      String until,
      ) async {
    showLoaderDialog(context);
    try {
      await dataCollection.add({
        'alamat': '-',
        'nama': nama,
        'keterangan': keterangan,
        'datetime': '$from-$until',
      });

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Expanded(
              child: Text("Yeay! Absen berhasil!", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        shape: StadiumBorder(),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ));

      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPage()));
    } catch (error) {
      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text("Ups, $error", style: const TextStyle(color: Colors.white))),
          ],
        ),
        backgroundColor: Colors.redAccent,
        shape: const StadiumBorder(),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }
}