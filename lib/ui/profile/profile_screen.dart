import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna Tema
    final Color primaryColor = const Color(0xFF2B3990);
    final Color backgroundColor = const Color(0xFFF9FAFB);

    // Referensi ke Collection Firebase
    final CollectionReference dataCollection =
        FirebaseFirestore.instance.collection('attendance');

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Profil Saya",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- HEADER SECTION ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 50), // Padding bawah
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 60, color: primaryColor.withOpacity(0.5)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Rifai Gusnian Ahmad",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Mobile Developer | IDN Solo",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // --- STATS CARD SECTION (DATA DARI FIREBASE) ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Transform.translate(
                offset: const Offset(0, -25), // Geser ke atas
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  // Menggunakan StreamBuilder agar Update Otomatis
                  child: StreamBuilder<QuerySnapshot>(
                    stream: dataCollection.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var data = snapshot.data!.docs;
                        
                        // Variabel Penghitung
                        int hadir = 0;
                        int izin = 0;
                        int sakit = 0;

                        // Loop semua data untuk menghitung
                        for (var element in data) {
                          // Ambil field 'description'
                          var status = element['description'].toString().toLowerCase();
                          
                          // Cek isinya (sesuai input di attend/absent screen)
                          if (status.contains("attend") || status.contains("hadir")) {
                            hadir++;
                          } else if (status.contains("permission") || status.contains("izin")) {
                            izin++;
                          } else if (status.contains("sick") || status.contains("sakit")) {
                            sakit++;
                          }
                        }

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem("Hadir", hadir.toString(), Colors.green),
                            _buildDivider(),
                            _buildStatItem("Izin", izin.toString(), Colors.orange),
                            _buildDivider(),
                            // Saya ganti Alpha jadi Sakit agar sesuai data yang ada
                            _buildStatItem("Sakit", sakit.toString(), Colors.red),
                          ],
                        );
                      } else {
                        // Loading state (tampilkan strip -)
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatItem("Hadir", "-", Colors.green),
                            _buildDivider(),
                            _buildStatItem("Izin", "-", Colors.orange),
                            _buildDivider(),
                            _buildStatItem("Sakit", "-", Colors.red),
                          ],
                        );
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // --- TOMBOL LOGOUT ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.logout, color: Colors.redAccent),
                  label: const Text(
                    "Keluar Akun",
                    style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 30,
      width: 1,
      color: Colors.grey.shade200,
    );
  }
}