import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/health_cubit.dart';
import '../widgets/health_widgets.dart';
import 'details_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => BlocBuilder<HealthCubit, HealthState>(
    builder: (context, state) {
      final cubit = context.read<HealthCubit>();
      final data = state.data;
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'healthspace',
            style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: -1),
          ),
          actions: [
            if (data != null)
              IconButton(
                tooltip: 'Notifications',
                onPressed:
                    () => showModalBottomSheet<void>(
                      context: context,
                      builder:
                          (sheetContext) => SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const SectionTitle('Notifications'),
                                  ListTile(
                                    leading: const Icon(Icons.calendar_month),
                                    title: Text(data.appointmentDoctor),
                                    subtitle: Text(
                                      '${data.appointmentDate}\n${data.appointmentTime}',
                                    ),
                                    isThreeLine: true,
                                    trailing: const Icon(Icons.chevron_right),
                                    onTap: () {
                                      Navigator.pop(sheetContext);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute<void>(
                                          builder:
                                              (_) => DetailsScreen(
                                                details: data.details,
                                              ),
                                        ),
                                      );
                                    },
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(sheetContext),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                    ),
                icon: Badge(
                  isLabelVisible: data.hasUnread,
                  child: const Icon(Icons.notifications_outlined),
                ),
              ),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: state.favoritesOnly ? 1 : 0,
          onDestinationSelected: (i) => cubit.showFavorites(i == 1),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              label: 'Favorites',
            ),
          ],
        ),
        body:
            state.status == LoadStatus.loading
                ? const Center(child: CircularProgressIndicator())
                : state.status == LoadStatus.error
                ? Center(
                  child: StatusPanel(
                    icon: Icons.cloud_off,
                    title: 'Could not load data',
                    message: 'Check the local JSON file and try again.',
                    retry: cubit.load,
                  ),
                )
                : data == null
                ? const SizedBox.shrink()
                : RefreshIndicator(
                  onRefresh: cubit.load,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: ListView(
                        padding: const EdgeInsets.all(22),
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data.greeting,
                                      style: const TextStyle(
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      data.subtitle,
                                      style: const TextStyle(
                                        color: Colors.blueGrey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              PersonAvatar(data.userAvatar),
                            ],
                          ),
                          const SizedBox(height: 24),
                          TextFormField(
                            initialValue: state.query,
                            onChanged: cubit.search,
                            decoration: InputDecoration(
                              hintText: data.searchHint,
                              prefixIcon: const Icon(Icons.search),
                            ),
                          ),
                          SectionTitle(data.appointmentTitle),
                          Card(
                            color: const Color(0xFF278D91),
                            elevation: 0,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder:
                                          (_) => DetailsScreen(
                                            details: data.details,
                                          ),
                                    ),
                                  ),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${data.appointmentDate}  •  ${data.appointmentTime}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                    const Divider(
                                      color: Colors.white24,
                                      height: 30,
                                    ),
                                    Row(
                                      children: [
                                        PersonAvatar(data.appointmentAvatar),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                data.appointmentDoctor,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 17,
                                                ),
                                              ),
                                              Text(
                                                data.appointmentSpecialty,
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.arrow_forward,
                                          color: Colors.white,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SectionTitle('Health services'),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children:
                                data.services
                                    .map(
                                      (s) => ActionChip(
                                        avatar: Icon(
                                          s.id == 'tooth'
                                              ? Icons.health_and_safety_outlined
                                              : s.id == 'eye'
                                              ? Icons.visibility_outlined
                                              : s.id == 'ear'
                                              ? Icons.hearing
                                              : Icons.air,
                                          color: const Color(0xFF278D91),
                                        ),
                                        label: Text(s.name),
                                        onPressed:
                                            () => cubit.filter(
                                              s.id == 'tooth'
                                                  ? 'Dental Specialist'
                                                  : '${s.name} Specialist',
                                            ),
                                      ),
                                    )
                                    .toList(),
                          ),
                          SectionTitle(
                            state.favoritesOnly
                                ? 'Favorite doctors'
                                : 'Nearby doctors',
                          ),
                          DropdownButtonFormField<String>(
                            key: ValueKey(state.specialty),
                            initialValue: state.specialty,
                            decoration: const InputDecoration(
                              labelText: 'Specialty',
                            ),
                            items:
                                <String>{
                                      ...data.doctors.map((d) => d.specialty),
                                      if (state.specialty != null)
                                        state.specialty!,
                                    }
                                    .map(
                                      (s) => DropdownMenuItem(
                                        value: s,
                                        child: Text(s),
                                      ),
                                    )
                                    .toList(),
                            onChanged: cubit.filter,
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => cubit.filter(null),
                                child: const Text('All specialties'),
                              ),
                              const Spacer(),
                              DropdownButton<DoctorSort>(
                                value: state.sort,
                                underline: const SizedBox.shrink(),
                                items: const [
                                  DropdownMenuItem(
                                    value: DoctorSort.distance,
                                    child: Text('Nearest first'),
                                  ),
                                  DropdownMenuItem(
                                    value: DoctorSort.name,
                                    child: Text('Name A–Z'),
                                  ),
                                ],
                                onChanged: (value) {
                                  if (value != null) cubit.sortBy(value);
                                },
                              ),
                            ],
                          ),
                          if (state.status == LoadStatus.empty)
                            const StatusPanel(
                              icon: Icons.search_off,
                              title: 'No doctors found',
                              message:
                                  'Try another search or specialty, or add a doctor to favorites.',
                            ),
                          ...state.visibleDoctors.map(
                            (doctor) => DoctorCard(
                              doctor: doctor,
                              favorite: state.favorites.contains(doctor.id),
                              onFavorite: () => cubit.toggleFavorite(doctor.id),
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder:
                                          (_) => DetailsScreen(
                                            details: data.details,
                                            doctor: doctor,
                                          ),
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
      );
    },
  );
}
