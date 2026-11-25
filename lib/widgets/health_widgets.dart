import 'package:flutter/material.dart';
import '../models/health_data.dart';

class PersonAvatar extends StatelessWidget {
  final String url;
  final double radius;
  const PersonAvatar(this.url, {this.radius = 28, super.key});
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Image.network(
      url,
      width: radius * 2,
      height: radius * 2,
      fit: BoxFit.cover,
      errorBuilder:
          (_, error, stack) => Container(
            width: radius * 2,
            height: radius * 2,
            color: const Color(0xFFDCEDED),
            child: const Icon(Icons.person_outline),
          ),
      loadingBuilder:
          (_, child, progress) =>
              progress == null
                  ? child
                  : SizedBox(
                    width: radius * 2,
                    height: radius * 2,
                    child: const Center(child: Icon(Icons.person_outline)),
                  ),
    ),
  );
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle(this.title, {super.key});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
    ),
  );
}

class DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final bool favorite;
  final VoidCallback onTap, onFavorite;
  const DoctorCard({
    required this.doctor,
    required this.favorite,
    required this.onTap,
    required this.onFavorite,
    super.key,
  });
  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 0,
    color: Colors.white,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            PersonAvatar(doctor.avatarUrl, radius: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doctor.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(doctor.specialty),
                  const SizedBox(height: 7),
                  Text(
                    doctor.distance,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
              onPressed: onFavorite,
              icon: Icon(
                favorite ? Icons.favorite : Icons.favorite_border,
                color: Colors.redAccent,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class StatusPanel extends StatelessWidget {
  final IconData icon;
  final String title, message;
  final VoidCallback? retry;
  const StatusPanel({
    required this.icon,
    required this.title,
    required this.message,
    this.retry,
    super.key,
  });
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(28),
    child: Column(
      children: [
        Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 12),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        if (retry != null)
          TextButton(onPressed: retry, child: const Text('Try again')),
      ],
    ),
  );
}
