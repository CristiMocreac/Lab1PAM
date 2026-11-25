import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:imc_calculator/cubit/health_cubit.dart';
import 'package:imc_calculator/data/health_repository.dart';
import 'package:imc_calculator/models/health_data.dart';

class FakeRepository extends HealthRepository {
  bool fail = false;
  @override
  Future<HealthData> load() async {
    if (fail) throw const FormatException('Invalid JSON');
    return HealthData.fromJson(
      jsonDecode(await File('assets/data/health.json').readAsString()) as Json,
    );
  }
}

void main() {
  test('Local data, search, filtering, sorting and favorites', () async {
    final cubit = HealthCubit(FakeRepository());
    addTearDown(cubit.close);
    expect(cubit.state.status, LoadStatus.loading);
    await cubit.load();
    expect(cubit.state.status, LoadStatus.success);
    expect(cubit.state.visibleDoctors.length, 2);
    cubit.search('SONJA');
    expect(cubit.state.visibleDoctors.single.id, 'doctor-002');
    cubit.search('missing');
    expect(cubit.state.status, LoadStatus.empty);
    cubit.search('');
    cubit.filter('Dental Specialist');
    expect(cubit.state.visibleDoctors.single.id, 'doctor-002');
    cubit.filter(null);
    cubit.sortBy(DoctorSort.distance);
    expect(cubit.state.visibleDoctors.first.distanceMeters, 500);
    cubit.sortBy(DoctorSort.name);
    expect(cubit.state.visibleDoctors.first.id, 'doctor-001');
    cubit.showFavorites(true);
    expect(cubit.state.status, LoadStatus.empty);
    cubit.toggleFavorite('doctor-002');
    expect(cubit.state.visibleDoctors.single.id, 'doctor-002');
    await cubit.load();
    expect(cubit.state.favorites, contains('doctor-002'));
    cubit.toggleFavorite('doctor-002');
    expect(cubit.state.status, LoadStatus.empty);
  });
  test('Repository failure and retry', () async {
    final repository = FakeRepository()..fail = true;
    final cubit = HealthCubit(repository);
    addTearDown(cubit.close);
    await cubit.load();
    expect(cubit.state.status, LoadStatus.error);
    repository.fail = false;
    await cubit.load();
    expect(cubit.state.status, LoadStatus.success);
    expect(
      cubit.state.data!.details.hours.where((s) => s.selected).single.id,
      '11am',
    );
  });
}
