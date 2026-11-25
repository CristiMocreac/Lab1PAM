typedef Json = Map<String, dynamic>;

class Doctor {
  final String id, name, specialty, distance, avatarUrl;
  final bool isFavorite;
  const Doctor({
    required this.id,
    required this.name,
    required this.specialty,
    required this.distance,
    required this.avatarUrl,
    this.isFavorite = false,
  });
  factory Doctor.fromJson(Json j) => Doctor(
    id: j['id'] as String,
    name: j['name'] as String,
    specialty: j['specialty'] as String,
    distance: j['distance'] as String,
    avatarUrl: j['avatarUrl'] as String,
    isFavorite: j['isFavorite'] as bool? ?? false,
  );
  int get distanceMeters =>
      int.tryParse(
        RegExp(r'(\d+)M from you').firstMatch(distance)?.group(1) ?? '',
      ) ??
      0;
}

class HealthService {
  final String id, name, iconUrl;
  const HealthService(this.id, this.name, this.iconUrl);
  factory HealthService.fromJson(Json j) => HealthService(
    j['id'] as String,
    j['name'] as String,
    j['iconUrl'] as String,
  );
}

class Slot {
  final String id, label;
  final bool selected;
  const Slot(this.id, this.label, this.selected);
  factory Slot.fromJson(Json j) =>
      Slot(j['id'] as String, j['label'] as String, j['selected'] as bool);
}

class AppointmentDetails {
  final String title,
      doctorName,
      clinic,
      avatarUrl,
      paymentLabel,
      formattedPayment,
      detailsTitle,
      description,
      hoursTitle,
      dateTitle,
      bookingLabel;
  final bool bookingEnabled;
  final Map<String, bool> actions;
  final List<Slot> hours, dates;
  AppointmentDetails.fromJson(Json j)
    : title = j['title'] as String,
      doctorName = j['doctor']['name'] as String,
      clinic = j['doctor']['clinic'] as String,
      avatarUrl = j['doctor']['avatarUrl'] as String,
      actions = Map<String, bool>.from(j['doctor']['actions'] as Map),
      paymentLabel = j['payment']['label'] as String,
      formattedPayment = j['payment']['formatted'] as String,
      detailsTitle = j['details']['title'] as String,
      description = j['details']['description'] as String,
      hoursTitle = j['workingHours']['title'] as String,
      dateTitle = j['date']['title'] as String,
      hours = List.unmodifiable(
        (j['workingHours']['slots'] as List).map(
          (e) => Slot.fromJson(e as Json),
        ),
      ),
      dates = List.unmodifiable(
        (j['date']['slots'] as List).map((e) => Slot.fromJson(e as Json)),
      ),
      bookingLabel = j['actions']['bookAppointment']['label'] as String,
      bookingEnabled = j['actions']['bookAppointment']['enabled'] as bool;
}

class HealthData {
  final String greeting,
      subtitle,
      userAvatar,
      searchHint,
      appointmentTitle,
      appointmentDate,
      appointmentTime,
      appointmentDoctor,
      appointmentSpecialty,
      appointmentAvatar;
  final bool hasUnread;
  final List<Doctor> doctors;
  final List<HealthService> services;
  final AppointmentDetails details;
  HealthData.fromJson(Json j)
    : greeting = j['homeScreen']['user']['greeting'] as String,
      subtitle = j['homeScreen']['user']['subtitle'] as String,
      userAvatar = j['homeScreen']['user']['avatarUrl'] as String,
      searchHint = j['homeScreen']['search']['hint'] as String,
      hasUnread = j['homeScreen']['notifications']['hasUnread'] as bool,
      appointmentTitle = j['homeScreen']['appointment']['title'] as String,
      appointmentDate = j['homeScreen']['appointment']['date'] as String,
      appointmentTime = j['homeScreen']['appointment']['time'] as String,
      appointmentDoctor =
          j['homeScreen']['appointment']['doctor']['name'] as String,
      appointmentSpecialty =
          j['homeScreen']['appointment']['doctor']['specialty'] as String,
      appointmentAvatar =
          j['homeScreen']['appointment']['doctor']['avatarUrl'] as String,
      doctors = List.unmodifiable(
        (j['homeScreen']['nearbyDoctors'] as List).map(
          (e) => Doctor.fromJson(e as Json),
        ),
      ),
      services = List.unmodifiable(
        (j['homeScreen']['healthServices'] as List).map(
          (e) => HealthService.fromJson(e as Json),
        ),
      ),
      details = AppointmentDetails.fromJson(j['appointmentDetails'] as Json);
}
