import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/health_repository.dart';
import '../models/health_data.dart';

enum LoadStatus { loading, success, empty, error }

enum DoctorSort { name, distance }

class HealthState {
  final LoadStatus status;
  final HealthData? data;
  final String query;
  final String? specialty;
  final bool favoritesOnly;
  final DoctorSort sort;
  final Set<String> favorites;
  final List<Doctor> visibleDoctors;
  const HealthState({
    this.status = LoadStatus.loading,
    this.data,
    this.query = '',
    this.specialty,
    this.favoritesOnly = false,
    this.sort = DoctorSort.distance,
    this.favorites = const {},
    this.visibleDoctors = const [],
  });
}

class HealthCubit extends Cubit<HealthState> {
  final HealthRepository repository;
  bool _initialized = false;
  HealthCubit(this.repository) : super(const HealthState());

  Future<void> load() async {
    emit(
      HealthState(
        data: state.data,
        favorites: state.favorites,
        query: state.query,
        specialty: state.specialty,
        sort: state.sort,
        favoritesOnly: state.favoritesOnly,
      ),
    );
    try {
      final data = await repository.load();
      if (isClosed) return;
      final favorites =
          _initialized
              ? state.favorites
              : data.doctors
                  .where((d) => d.isFavorite)
                  .map((d) => d.id)
                  .toSet();
      _initialized = true;
      _update(data: data, favorites: favorites);
    } catch (_) {
      if (!isClosed)
        emit(
          HealthState(
            status: LoadStatus.error,
            data: state.data,
            favorites: state.favorites,
            query: state.query,
            specialty: state.specialty,
            sort: state.sort,
            favoritesOnly: state.favoritesOnly,
          ),
        );
    }
  }

  void search(String query) => _update(query: query);
  void filter(String? specialty) =>
      _update(specialty: specialty, replaceSpecialty: true);
  void sortBy(DoctorSort sort) => _update(sort: sort);
  void showFavorites(bool value) => _update(favoritesOnly: value);
  void toggleFavorite(String id) {
    final favorites = {...state.favorites};
    if (!favorites.add(id)) favorites.remove(id);
    _update(favorites: favorites);
  }

  void _update({
    HealthData? data,
    String? query,
    String? specialty,
    bool replaceSpecialty = false,
    DoctorSort? sort,
    bool? favoritesOnly,
    Set<String>? favorites,
  }) {
    final source = data ?? state.data;
    if (source == null) return;
    final q = query ?? state.query;
    final category = replaceSpecialty ? specialty : state.specialty;
    final order = sort ?? state.sort;
    final onlyFavorites = favoritesOnly ?? state.favoritesOnly;
    final ids = favorites ?? state.favorites;
    final doctors =
        source.doctors
            .where(
              (d) =>
                  '${d.name} ${d.specialty} ${d.distance}'
                      .toLowerCase()
                      .contains(q.trim().toLowerCase()) &&
                  (category == null || d.specialty == category) &&
                  (!onlyFavorites || ids.contains(d.id)),
            )
            .toList();
    doctors.sort(
      (a, b) =>
          order == DoctorSort.name
              ? a.name.compareTo(b.name)
              : a.distanceMeters.compareTo(b.distanceMeters),
    );
    emit(
      HealthState(
        status: doctors.isEmpty ? LoadStatus.empty : LoadStatus.success,
        data: source,
        query: q,
        specialty: category,
        sort: order,
        favoritesOnly: onlyFavorites,
        favorites: Set.unmodifiable(ids),
        visibleDoctors: List.unmodifiable(doctors),
      ),
    );
  }
}
