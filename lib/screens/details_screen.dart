import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/health_data.dart';
import '../cubit/health_cubit.dart';
import '../widgets/health_widgets.dart';
import 'contact_screen.dart';

class DetailsScreen extends StatefulWidget {
  final AppointmentDetails details;
  final Doctor? doctor;
  const DetailsScreen({required this.details, this.doctor, super.key});
  @override
  State<DetailsScreen> createState() => _DetailsScreenState();
}

class _DetailsScreenState extends State<DetailsScreen> {
  String? hour, date;
  @override
  void initState() {
    super.initState();
    for (final slot in widget.details.hours) {
      if (slot.selected) hour = slot.id;
    }
    for (final slot in widget.details.dates) {
      if (slot.selected) date = slot.id;
    }
  }

  Widget slots(
    String title,
    List<Slot> values,
    String? selected,
    ValueChanged<String> onSelect,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Expanded(child: SectionTitle(title)),
          TextButton(
            onPressed:
                () => showModalBottomSheet<void>(
                  context: context,
                  builder:
                      (sheetContext) => SafeArea(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(title),
                            ),
                            ...values.map(
                              (slot) => ListTile(
                                title: Text(slot.label),
                                trailing:
                                    selected == slot.id
                                        ? const Icon(Icons.check)
                                        : null,
                                onTap: () {
                                  onSelect(slot.id);
                                  Navigator.pop(sheetContext);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                ),
            child: const Text('Show all'),
          ),
        ],
      ),
      Wrap(
        spacing: 12,
        runSpacing: 8,
        children:
            values
                .map(
                  (s) => ChoiceChip(
                    label: Text(s.label),
                    selected: selected == s.id,
                    onSelected: (_) => onSelect(s.id),
                  ),
                )
                .toList(),
      ),
    ],
  );
  Future<void> book() async {
    final d = widget.details;
    final name = widget.doctor?.name ?? d.doctorName;
    final time = d.hours.firstWhere((s) => s.id == hour).label;
    final day = d.dates.firstWhere((s) => s.id == date).label;
    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Appointment selected'),
            content: Text(
              '$name\n$day • $time\n${d.formattedPayment}\n\nLocal demonstration only. No appointment or payment is sent to a clinic.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.details;
    final doctor = widget.doctor;
    return Scaffold(
      appBar: AppBar(
        title: Text(d.title),
        actions: [
          if (doctor != null)
            BlocBuilder<HealthCubit, HealthState>(
              builder:
                  (context, state) => IconButton(
                    tooltip:
                        state.favorites.contains(doctor.id)
                            ? 'Remove from favorites'
                            : 'Add to favorites',
                    onPressed:
                        () => context.read<HealthCubit>().toggleFavorite(
                          doctor.id,
                        ),
                    icon: Icon(
                      state.favorites.contains(doctor.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: Colors.redAccent,
                    ),
                  ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 12),
              Center(
                child: PersonAvatar(
                  doctor?.avatarUrl ?? d.avatarUrl,
                  radius: 65,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                doctor?.name ?? d.doctorName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                doctor?.specialty ?? d.clinic,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.blueGrey, fontSize: 16),
              ),
              if (doctor != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(doctor.distance, textAlign: TextAlign.center),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    d.actions.entries
                        .where((a) => a.value)
                        .map(
                          (action) => Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: IconButton.filledTonal(
                              tooltip: action.key,
                              icon: Icon(
                                action.key == 'message'
                                    ? Icons.chat_bubble_outline
                                    : action.key == 'call'
                                    ? Icons.call_outlined
                                    : Icons.videocam_outlined,
                              ),
                              onPressed:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute<void>(
                                      builder:
                                          (_) => ContactScreen(
                                            doctorName:
                                                doctor?.name ?? d.doctorName,
                                            action: action.key,
                                          ),
                                    ),
                                  ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              Card(
                elevation: 0,
                color: const Color(0xFFE1F1F0),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(child: Text(d.paymentLabel)),
                      Text(
                        d.formattedPayment,
                        style: const TextStyle(
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SectionTitle(d.detailsTitle),
              Text(
                d.description,
                style: const TextStyle(height: 1.7, color: Colors.blueGrey),
              ),
              slots(
                d.hoursTitle,
                d.hours,
                hour,
                (value) => setState(() => hour = value),
              ),
              slots(
                d.dateTitle,
                d.dates,
                date,
                (value) => setState(() => date = value),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed:
                    d.bookingEnabled && hour != null && date != null
                        ? book
                        : null,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.all(18),
                ),
                child: Text(d.bookingLabel),
              ),
              const SizedBox(height: 12),
              const Text(
                'Demo • Local JSON data',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.blueGrey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
