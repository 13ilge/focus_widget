import 'package:flutter/material.dart';

class AliskanlikKarti extends StatefulWidget {
  // 1. Dışarıdan gelecek bilgileri tanımlıyoruz
  final String baslik; // Örn: "Su İçme"
  final int hedef; // Örn: 5
  final bool isIncreasing;
  // 2. Constructor (Kurucu): Bu widget oluşturulurken bu bilgileri istemesini sağlıyoruz.
  const AliskanlikKarti({super.key, required this.baslik, required this.hedef, required this.isIncreasing});

  @override
  State<AliskanlikKarti> createState() => _AliskanlikKartiState();
}

class _AliskanlikKartiState extends State<AliskanlikKarti> {
  
  int anlikSayi = 0;

  
  void sayiyiArttir() {
    setState(() {
      anlikSayi++; 
    });
  }

  
Color renkSec(int yuzde) {
  
  if (widget.isIncreasing == false) {
    if (yuzde < 50) return Colors.green; 
    if (yuzde <= 100) return Colors.orange; 
    return Colors.red; 
  } 
  
  else {
    if (yuzde < 50) return Colors.red; 
    if (yuzde < 100) return Colors.orange; 
    return Colors.green; 
  }
}
  @override
  Widget build(BuildContext context) {
    int yuzde = widget.hedef > 0 ? (anlikSayi / widget.hedef * 100).round() : 0;
    return Container(
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: renkSec(yuzde),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, 
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              Text(
                widget
                    .baslik, 
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                "İlerleme: $anlikSayi / ${widget.hedef}", 
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),

          IconButton(
            onPressed: sayiyiArttir, 
            icon: const Icon(Icons.add_circle, size: 40, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
