import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  const AttendanceHistoryScreen({super.key});

  @override
  State<AttendanceHistoryScreen> createState() =>
      _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  final CollectionReference dataCollection = FirebaseFirestore.instance
      .collection('attendance');

  final Color primaryColor = const Color(0xFF2B3990);
  final Color backgroundColor = const Color(0xFFF9FAFB);
  final Color textDark = const Color(0xFF1F2937);

  void _editData(
    String docId,
    String currentName,
    String currentAddress,
    String currentDescription,
    String currentDatetime,
  ) {
    TextEditingController nameController = TextEditingController(
      text: currentName,
    );
    TextEditingController addressController = TextEditingController(
      text: currentAddress,
    );
    TextEditingController descriptionController = TextEditingController(
      text: currentDescription,
    );
    TextEditingController datetimeController = TextEditingController(
      text: currentDatetime,
    );

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Ubah Data",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildEditField(nameController, "Nama"),
                  _buildEditField(addressController, "Alamat"),
                  _buildEditField(descriptionController, "Keterangan"),
                  _buildEditField(datetimeController, "Waktu"),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await dataCollection.doc(docId).update({
                    'name': nameController.text,
                    'address': addressController.text,
                    'description': descriptionController.text,
                    'datetime': datetimeController.text,
                  });
                  if (!mounted) return;
                  Navigator.pop(context);
                  setState(() {});
                },
                child: Text(
                  "Simpan",
                  style: TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildEditField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  void _deleteData(String docId) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            title: const Text(
              "Hapus Data",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text("Yakin ingin menghapus data ini?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "Batal",
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await dataCollection.doc(docId).delete();
                  if (!mounted) return;
                  Navigator.pop(context);
                  setState(() {});
                },
                child: const Text(
                  "Ya, Hapus",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          "Riwayat Kehadiran",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textDark,
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: dataCollection.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!.docs;
            return data.isNotEmpty
                ? ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var docId = data[index].id;
                    var name = data[index]['name'];
                    var address = data[index]['address'];
                    var description = data[index]['description'];
                    var datetime = data[index]['datetime'];

                    Color avatarColor =
                        Colors.primaries[Random().nextInt(
                          Colors.primaries.length,
                        )];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(color: Colors.grey.shade100),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        leading: CircleAvatar(
                          backgroundColor: avatarColor.withOpacity(0.1),
                          radius: 25,
                          child: Text(
                            name[0].toUpperCase(),
                            style: TextStyle(
                              color: avatarColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        title: Text(
                          name,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: textDark,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.access_time,
                                  size: 14,
                                  color: Colors.grey[500],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  datetime,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color:
                                    description == "Attend"
                                        ? Colors.green
                                        : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton(
                          icon: Icon(Icons.more_vert, color: Colors.grey[400]),
                          itemBuilder:
                              (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Ubah"),
                                    ],
                                  ),
                                  onTap:
                                      () => Future.delayed(
                                        Duration.zero,
                                        () => _editData(
                                          docId,
                                          name,
                                          address,
                                          description,
                                          datetime,
                                        ),
                                      ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: const Row(
                                    children: [
                                      Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                        size: 20,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Hapus"),
                                    ],
                                  ),
                                  onTap:
                                      () => Future.delayed(
                                        Duration.zero,
                                        () => _deleteData(docId),
                                      ),
                                ),
                              ],
                        ),
                      ),
                    );
                  },
                )
                : Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history_toggle_off,
                        size: 60,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Belum ada riwayat data!",
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                );
          } else {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            );
          }
        },
      ),
    );
  }
}
