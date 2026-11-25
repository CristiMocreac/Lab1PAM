import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/health_cubit.dart';
import 'data/health_repository.dart';
import 'screens/home_screen.dart';

void main() => runApp(const HealthApp());

class HealthApp extends StatelessWidget {
  const HealthApp({super.key});
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => HealthCubit(HealthRepository())..load(),
    child: MaterialApp(
      title: 'Healthspace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF278D91)),
        scaffoldBackgroundColor: const Color(0xFFF6F9FA),
        appBarTheme: const AppBarTheme(backgroundColor: Color(0xFFF6F9FA)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const HomeScreen(),
    ),
  );
}
