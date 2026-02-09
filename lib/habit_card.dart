import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

String bugununTarihiniAl() {
  DateTime simdi = DateTime.now();
  return "${simdi.year}-${simdi.month}-${simdi.day}";
}

class AliskanlikKarti extends StatefulWidget {
  final String baslik;
  final int hedef;
  final bool isIncreasing;
  final String id;

  const AliskanlikKarti({
    super.key,
    required this.baslik,
    required this.hedef,
    required this.isIncreasing,
    required this.id,
  });

  @override
  State<AliskanlikKarti> createState() => _AliskanlikKartiState();
}

class _AliskanlikKartiState extends State<AliskanlikKarti> {
  int anlikSayi = 0;

  void initState() {
    super.initState();
    veriYukle();
  }

  void veriYukle() async {
    final prefs = await SharedPreferences.getInstance();

    
    String bugununAnahtari = "${widget.id}_${bugununTarihiniAl()}";

    setState(() {
      
      anlikSayi = prefs.getInt(bugununAnahtari) ?? 0;
    });
  }

  void veriKaydet() async {
   final prefs = await SharedPreferences.getInstance();
    
    String bugununAnahtari = "${widget.id}_${bugununTarihiniAl()}";
    
    await prefs.setInt(bugununAnahtari, anlikSayi);
  }

  void sayiyiArttir() {
    setState(() {
      anlikSayi++;
    });
    veriKaydet();
  }

  Color renkSec(int yuzde) {
    if (widget.isIncreasing == false) {
      if (yuzde < 50) return Colors.green;
      if (yuzde <= 100) return Colors.orange;
      return Colors.red;
    } else {
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
                widget.baslik,
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
