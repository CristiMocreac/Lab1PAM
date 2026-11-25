import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/health_data.dart';

class HealthRepository {
  final AssetBundle bundle;
  HealthRepository({AssetBundle? bundle}) : bundle = bundle ?? rootBundle;
  Future<HealthData> load() async {
    final source = await bundle.loadString('assets/data/health.json');
    return HealthData.fromJson(jsonDecode(source) as Json);
  }
}
