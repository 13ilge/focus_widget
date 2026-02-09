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
        appBar: AppBar(title: const Text("Zinciri Kırma")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const AliskanlikKarti(
                baslik: "Su İçme",
                hedef: 5,
                isIncreasing: true,
                id: "su_v1",
              ),

              const SizedBox(height: 20),

              const AliskanlikKarti(
                baslik: "Sigara Limiti",
                hedef: 5,
                isIncreasing: false,
                id: "sigara_v1",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
