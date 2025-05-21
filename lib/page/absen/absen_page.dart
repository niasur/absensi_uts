import 'dart:io';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dotted_border/dotted_border.dart';

import '../main_page.dart';
import 'camera_page.dart';

class AbsenPage extends StatefulWidget {
  final XFile? image;

  const AbsenPage({Key? key, this.image}) : super(key: key);

  @override
  State<AbsenPage> createState() => _AbsenPageState();
}

class _AbsenPageState extends State<AbsenPage> {
  XFile? image;
  String strAlamat = '';
  String strDate = '';
  String strTime = '';
  String strDateTime = '';
  String strStatus = "Absen Masuk";
  bool isLoading = false;
  final controllerName = TextEditingController();
  final CollectionReference dataCollection = FirebaseFirestore.instance.collection('absensi');

  @override
  void initState() {
    super.initState();
    image = widget.image;
    handleLocationPermission();
    setDateTime();
    setStatusAbsen();

    if (image != null) {
      isLoading = true;
      getGeoLocationPosition();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          color: theme.colorScheme.onPrimary,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Menu Absensi",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
                  color: theme.colorScheme.primary,
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 12),
                    Icon(Icons.face_retouching_natural_outlined, color: theme.colorScheme.onPrimary),
                    const SizedBox(width: 12),
                    Text(
                      "Absen Foto Selfie ya!",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(10, 20, 0, 10),
                child: Text("Ambil Foto", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CameraAbsenPage())),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  height: 150,
                  child: DottedBorder(
                    radius: const Radius.circular(10),
                    borderType: BorderType.RRect,
                    color: theme.colorScheme.primary,
                    strokeWidth: 1,
                    dashPattern: const [5, 5],
                    child: Center(
                      child: image != null
                          ? Image.file(File(image!.path), fit: BoxFit.cover)
                          : Icon(Icons.camera_alt_outlined, color: theme.colorScheme.primary, size: 100),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  controller: controllerName,
                  decoration: InputDecoration(
                    labelText: "Masukan Nama Anda",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Text("Lokasi Anda", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  enabled: false,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: strAlamat.isNotEmpty ? strAlamat : 'Menunggu lokasi...',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(30),
                child: ElevatedButton(
                  onPressed: () {
                    if (image == null || controllerName.text.isEmpty) {
                      showSnack("Ups, foto dan inputan tidak boleh kosong!", Colors.redAccent);
                    } else {
                      submitAbsen(strAlamat, controllerName.text, strStatus);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    minimumSize: const Size.fromHeight(50),
                  ),
                  child: const Text("Absen Sekarang", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  void showSnack(String msg, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(child: Text(msg, style: const TextStyle(color: Colors.white))),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: const StadiumBorder(),
    ));
  }

  Future<void> submitAbsen(String alamat, String nama, String status) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await dataCollection.add({
        'alamat': alamat,
        'nama': nama,
        'keterangan': status,
        'datetime': strDateTime,
      });
      Navigator.pop(context);
      showSnack("Yeay! Absen berhasil!", Colors.green);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainPage()));
    } catch (e) {
      Navigator.pop(context);
      showSnack("Ups! ${e.toString()}", Colors.redAccent);
    }
  }

  void setDateTime() {
    final now = DateTime.now();
    final formatterDate = DateFormat('dd MMMM yyyy');
    final formatterTime = DateFormat('HH:mm:ss');
    strDate = formatterDate.format(now);
    strTime = formatterTime.format(now);
    strDateTime = "$strDate | $strTime";
  }

  void setStatusAbsen() {
    final now = DateTime.now();
    final jam = now.hour;
    final menit = now.minute;

    if (jam < 8 || (jam == 8 && menit <= 30)) {
      strStatus = "Masuk";
    } else if ((jam > 8 && jam < 18) || (jam == 8 && menit >= 31)) {
      strStatus = "Telat";
    } else {
      strStatus = "Keluar";
    }
  }

  Future<void> getGeoLocationPosition() async {
    Position position = await Geolocator.getCurrentPosition();
    await getAddressFromLongLat(position);
    setState(() => isLoading = false);
  }

  Future<void> getAddressFromLongLat(Position position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks.first;
    strAlamat = "${place.street}, ${place.locality}, ${place.country}";
  }

  Future<bool> handleLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      showSnack("Location services are disabled", Colors.redAccent);
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        showSnack("Location permission denied.", Colors.redAccent);
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      showSnack("Location permission permanently denied.", Colors.redAccent);
      return false;
    }

    return true;
  }
}
