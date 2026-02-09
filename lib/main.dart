import 'package:flutter/material.dart';
import 'habit_card.dart';

void main() {
  runApp(const BenimUygulamam());
}

class BenimUygulamam extends StatelessWidget {
  const BenimUygulamam({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Zinciri Kırma"),
        ), 
        body: Center(
          child: Column(
            
            mainAxisAlignment: MainAxisAlignment.center, // Ortala
            children: [
              
              AliskanlikKarti(baslik: "Su İçme", hedef: 5),

              
              AliskanlikKarti(baslik: "Kitap Okuma", hedef: 20),
            ],
          ),
        ),
      ),
    );
  }
}
