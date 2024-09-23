import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:a_dog_breeds/screens/home.dart';
import 'package:a_dog_breeds/screens/carousel.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const ProviderScope(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Dog Breeds',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routerConfig: _router,
    );
  }
}

final GoRouter _router = GoRouter(
  initialLocation: "/home",
  routes: [
    GoRoute(
      name: "/home",
      path: "/home",
      builder: (context, state) {
        return const Home();
      },
    ),
    GoRoute(
      name: "/carousel",
      path: "/carousel",
      builder: (context, state) {
        return const CarouselPage();
      },
    )
  ],
);