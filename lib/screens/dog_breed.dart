import 'package:flutter/material.dart';

class DogBreed extends StatelessWidget {
  // const DogBreed({super.key});

  final dogData;

  DogBreed(this.dogData);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(dogData['breeds'][0]['name']),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 400,
          height: 600,
          child: Column(
            children: [
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Image.network(
                        dogData['url'],
                        height: 350,
                        width: 350,
                        errorBuilder: (context, error, stackTrace) {
                          return const Text('Image not available');
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                        child: Column(
                          children: [
                            Text(
                              "Name: ${dogData['breeds'][0]['name'] ?? 'N/A'}",
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Weight: ${dogData['breeds'][0]['weight']['metric'] ?? '-'}",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Height: ${dogData['breeds'][0]['height']['metric'] ?? '-'}",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Origin: ${dogData['breeds'][0]['origin'] ?? '-'}",
                                style: const TextStyle(fontSize: 15),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Life Span: ${dogData['breeds'][0]['life_span'] ?? '-'}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Temperament: ${dogData['breeds'][0]['temperament'] ?? '-'}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Bred for: ${dogData['breeds'][0]['bred_for'] ?? '-'}",
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
