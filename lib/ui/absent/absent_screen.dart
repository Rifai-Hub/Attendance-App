import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:attendance_app/ui/home_screen.dart';

class AbsentScreen extends StatefulWidget {
  const AbsentScreen({super.key});

  @override
  State<AbsentScreen> createState() => _AbsentScreenState();
}

class _AbsentScreenState extends State<AbsentScreen> {
  final Color primaryColor = const Color(0xFF2B3990);
  final Color backgroundColor = const Color(0xFFF9FAFB);
  final Color textDark = const Color(0xFF1F2937);

  var categoriesList = <String>[
    "Pilih Keterangan:", 
    "Lainnya",
    "Izin",
    "Sakit",
  ];

  final controllerName = TextEditingController();
  double dLat = 0.0, dLong = 0.0;
  final CollectionReference dataCollection =
      FirebaseFirestore.instance.collection('attendance');

  int dateHours = 0, dateMinutes = 0;
  String dropValueCategories = "Pilih Keterangan:"; 
  final fromController = TextEditingController();
  String strAlamat = '', strDate = '', strTime = '', strDateTime = '';
  final toController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  showLoaderDialog(BuildContext context) {
    AlertDialog alert = AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20),
            child: const Text("Mohon Tunggu..."),
          ),
        ],
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
    if (nama.isEmpty ||
        keterangan == "Pilih Keterangan:" || 
        from.isEmpty ||
        until.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white),
              SizedBox(width: 10),
              Text("Pastikan semua data telah diisi!"),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showLoaderDialog(context);

    try {
      await dataCollection.add({
        'address': '-',
        'name': nama,
        'description': keterangan,
        'datetime': '$from - $until',
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white),
              SizedBox(width: 10),
              Text("Berhasil mengirim pengajuan!"),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white),
              const SizedBox(width: 10),
              Expanded(child: Text("Ups, terjadi kesalahan: $e")),
            ],
          ),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: backgroundColor, 
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          "Menu Izin",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0), 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Formulir Pengajuan",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Silakan isi data berikut dengan benar.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[500],
                ),
              ),
              const SizedBox(height: 24),

              const Text("Nama Lengkap", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  controller: controllerName,
                  decoration: InputDecoration(
                    hintText: "Masukkan nama Anda",
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    prefixIcon: Icon(Icons.person_outline, color: primaryColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text("Keterangan", style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: dropValueCategories,
                    icon: Icon(Icons.keyboard_arrow_down, color: primaryColor),
                    isExpanded: true,
                    style: TextStyle(color: textDark, fontSize: 15),
                    dropdownColor: Colors.white,
                    items: categoriesList.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        dropValueCategories = value.toString();
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Dari", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildDatePicker(context, fromController, "Tgl Mulai"),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Sampai", style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _buildDatePicker(context, toController, "Tgl Selesai"),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: size.width,
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    shadowColor: primaryColor.withOpacity(0.4),
                  ),
                  onPressed: () {
                    if (controllerName.text.isEmpty ||
                        dropValueCategories == "Pilih Keterangan:" ||
                        fromController.text.isEmpty ||
                        toController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.white),
                              SizedBox(width: 10),
                              Text("Mohon lengkapi formulir!"),
                            ],
                          ),
                          backgroundColor: Colors.redAccent, 
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      submitAbsen(
                        controllerName.text.toString(),
                        dropValueCategories.toString(),
                        fromController.text,
                        toController.text,
                      );
                    }
                  },
                  child: const Text(
                    "Ajukan Sekarang",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
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

  Widget _buildDatePicker(BuildContext context, TextEditingController controller, String hint) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        style: TextStyle(color: textDark),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          suffixIcon: Icon(Icons.calendar_today, color: primaryColor, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            builder: (BuildContext context, Widget? child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: ColorScheme.light(
                    primary: primaryColor, 
                    onPrimary: Colors.white,
                    onSurface: Colors.black,
                  ),
                  datePickerTheme: const DatePickerThemeData(
                    headerBackgroundColor: Color(0xFF2B3990),
                    backgroundColor: Colors.white,
                    headerForegroundColor: Colors.white,
                  ),
                ),
                child: child!,
              );
            },
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(9999),
          );
          if (pickedDate != null) {
            controller.text = DateFormat('dd/M/yyyy').format(pickedDate);
          }
        },
      ),
    );
  }
}