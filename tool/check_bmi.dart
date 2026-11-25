// ignore_for_file: avoid_print
import '../lib/bmi.dart';

void main() {
  var checks = 0;
  void verify(bool condition, String description) {
    checks++;
    if (!condition) throw StateError(description);
  }

  final standard = calculateBmi(weightKg: 70, heightCm: 175);
  verify(
    (standard.value - 22.857142857).abs() < 0.000001,
    'Formula și conversia cm → m',
  );
  verify(standard.category == 'Normal', 'Categoria exemplului 70 kg / 175 cm');
  final examples = {
    18.49: 'Subponderal',
    18.5: 'Normal',
    24.99: 'Normal',
    25.0: 'Supraponderal',
    29.99: 'Supraponderal',
    30.0: 'Obezitate gradul I',
    34.99: 'Obezitate gradul I',
    35.0: 'Obezitate gradul II',
    39.99: 'Obezitate gradul II',
    40.0: 'Obezitate gradul III',
  };
  for (final e in examples.entries) {
    verify(bmiCategory(e.key) == e.value, 'Pragul ${e.key}');
  }
  verify(parsePositiveNumber(' 70,5 ') == 70.5, 'Virgulă zecimală');
  verify(parsePositiveNumber('175.5') == 175.5, 'Punct zecimal');
  verify(parsePositiveNumber('.5') == 0.5, 'Fracție');
  for (final input in [
    '',
    ' ',
    '0',
    '0,0',
    '-70',
    'abc',
    'NaN',
    'Infinity',
    '1e3',
    '70,2.3',
    '1 000',
    '1,2,3',
  ]) {
    verify(parsePositiveNumber(input) == null, 'Respingere: $input');
  }
  for (final pair in [
    (70.0, 0.0),
    (-1.0, 175.0),
    (double.infinity, 175.0),
    (70.0, 1e-300),
  ]) {
    var rejected = false;
    try {
      calculateBmi(weightKg: pair.$1, heightCm: pair.$2);
    } on ArgumentError {
      rejected = true;
    }
    verify(rejected, 'Respingere date numerice invalide: $pair');
  }
  print('$checks verificări trecute.');
}
