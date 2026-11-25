/// Parsing and BMI calculation are independent from the user interface.
double? parsePositiveNumber(String input) {
  final normalized = input.trim().replaceAll(',', '.');
  if (!RegExp(r'^(?:\d+(?:\.\d*)?|\.\d+)$').hasMatch(normalized)) {
    return null;
  }
  final value = double.tryParse(normalized);
  return value != null && value.isFinite && value > 0 ? value : null;
}

class BmiResult {
  const BmiResult({required this.value, required this.category});

  final double value;
  final String category;
}

String bmiCategory(double bmi) {
  if (!bmi.isFinite || bmi <= 0) {
    throw ArgumentError.value(
      bmi,
      'bmi',
      'IMC trebuie să fie pozitiv și finit.',
    );
  }
  if (bmi < 18.5) return 'Subponderal';
  if (bmi < 25) return 'Normal';
  if (bmi < 30) return 'Supraponderal';
  if (bmi < 35) return 'Obezitate gradul I';
  if (bmi < 40) return 'Obezitate gradul II';
  return 'Obezitate gradul III';
}

BmiResult calculateBmi({required double weightKg, required double heightCm}) {
  if (!weightKg.isFinite ||
      weightKg <= 0 ||
      !heightCm.isFinite ||
      heightCm <= 0) {
    throw ArgumentError(
      'Greutatea și înălțimea trebuie să fie pozitive și finite.',
    );
  }
  final heightM = heightCm / 100;
  final value = weightKg / (heightM * heightM);
  if (!value.isFinite || value <= 0) {
    throw ArgumentError('Valorile introduse nu permit calcularea IMC.');
  }
  return BmiResult(value: value, category: bmiCategory(value));
}
