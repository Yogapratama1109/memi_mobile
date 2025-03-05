import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import './asset_detail_stock.dart';

class LaptopListScreen extends StatefulWidget {
  final String assetId;

  const LaptopListScreen({super.key, required this.assetId});
  @override
  _LaptopListScreenState createState() => _LaptopListScreenState();
}

class _LaptopListScreenState extends State<LaptopListScreen> {
  List<Map<String, dynamic>> laptops = [];

  @override
  void initState() {
    super.initState();
    fetchLaptops();
  }

  Future<void> fetchLaptops() async {
    final String apiUrl =
        'http://203.175.11.163/api/stock-opname/asset/${widget.assetId}';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        // debugPrint(response.body);
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        List<dynamic> data = jsonResponse['data'];
        setState(() {
          laptops =
              data.map((item) {
                String? imageUrl = item['attachment']; // Ambil gambar dari API
                if (imageUrl != null && imageUrl.isNotEmpty) {
                  imageUrl =
                      'http://203.175.11.163/images/$imageUrl'; // Format URL dengan benar
                } else {
                  imageUrl =
                      'http://203.175.11.163/images/default.jpg'; // Gambar default jika null
                }

                return {
                  'id': item['asset_id'].toString(),
                  'serial_number': item['serial_number'].toString(),
                  'status': item['condition_item'],
                  'name': item['asset_name'],
                  'location': item['location']['location'],
                  'notes': item['notesItem'],
                  'image': imageUrl,
                };
              }).toList();
        });
      } else {
        throw Exception('Failed to load laptops');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child:
          laptops.isEmpty
              ? Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: laptops.length,
                itemBuilder: (context, index) {
                  final laptop = laptops[index];
                  return Card(
                    color: Colors.white,
                    elevation: 0,
                    margin: EdgeInsets.symmetric(vertical: 5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.all(10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              laptop['image'] ?? '',
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              loadingBuilder: (
                                context,
                                child,
                                loadingProgress,
                              ) {
                                if (loadingProgress == null) return child;
                                return Center(
                                  child: CircularProgressIndicator(),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return Icon(
                                  Icons.broken_image,
                                  size: 50,
                                  color: Colors.grey,
                                );
                              },
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(
                                laptop['serial_number'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFCBA851),
                                ),
                              ),
                              SizedBox(width: 10),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      laptop['status'] == 'Good'
                                          ? Colors.green
                                          : laptop['status'] == 'Bad'
                                          ? Colors.red
                                          : Colors.white, // Kondisi warna
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  laptop['status'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(laptop['name']),
                              Text(
                                laptop['location'],
                                style: TextStyle(color: Colors.grey.shade700),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.edit, color: Color(0xFFCBA851)),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => LaptopDetailScreen(
                                        laptop: {
                                          "id": widget.assetId,
                                          "assetId": laptop['id'],
                                          "condition": laptop['status'],
                                          "notes": laptop['notes'],
                                        },
                                      ),
                                ),
                              ).then((value) {
                                if (value == true) {
                                  fetchLaptops(); // Panggil ulang fetchLaptops untuk memperbarui list
                                }
                              });
                            },
                          ),
                        ),
                        Divider(color: Colors.grey.shade300),
                      ],
                    ),
                  );
                },
              ),
    );
  }
}
