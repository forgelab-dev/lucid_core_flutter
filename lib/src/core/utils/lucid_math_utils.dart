import 'dart:math' as math;

import '../constants/constants.dart' show LucidRoundingMode;

class LucidMathUtils {
  LucidMathUtils._();

  static const double pi = math.pi;
  static const double e = math.e;
  static const double goldenRatio = 1.618033988749895;
  static const double sqrt2 = 1.4142135623730951;
  static const double sqrt3 = 1.7320508075688772;

  static double power(double base, double exponent) {
    if (base == 0 && exponent == 0) return 1;
    if (base == 0) return 0;
    if (exponent == 0) return 1;
    return math.pow(base, exponent).toDouble();
  }

  static num nthRoot(double value, double n) {
    if (n == 0) throw ArgumentError('Root degree cannot be zero');
    if (value < 0 && n % 2 == 0) throw ArgumentError('Even root of negative number');
    return value < 0 ? -math.pow(-value, 1 / n) : math.pow(value, 1 / n);
  }

  static double logBase(double value, double base) {
    if (value <= 0 || base <= 0 || base == 1) {
      throw ArgumentError('Invalid logarithm parameters');
    }
    return math.log(value) / math.log(base);
  }

  static double factorial(int n) {
    if (n < 0) throw ArgumentError('Factorial undefined for negative numbers');
    if (n == 0 || n == 1) return 1;

    double result = 1;
    for (int i = 2; i <= n; i++) {
      result *= i;
    }
    return result;
  }

  static double factorialApprox(int n) {
    if (n < 0) throw ArgumentError('Factorial undefined for negative numbers');
    if (n <= 20) return factorial(n);

    return math.sqrt(2 * pi * n) * power(n / e, n.toDouble());
  }

  static double combinations(int n, int k) {
    if (k > n || k < 0) return 0;
    if (k == 0 || k == n) return 1;

    k = math.min(k, n - k);

    double result = 1;
    for (int i = 0; i < k; i++) {
      result = result * (n - i) / (i + 1);
    }
    return result;
  }

  static double arrangements(int n, int k) {
    if (k > n || k < 0) return 0;
    if (k == 0) return 1;

    double result = 1;
    for (int i = 0; i < k; i++) {
      result *= (n - i);
    }
    return result;
  }

  static double degreesToRadians(double degrees) => degrees * pi / 180;

  static double radiansToDegrees(double radians) => radians * 180 / pi;

  static double sinh(double x) => (math.exp(x) - math.exp(-x)) / 2;

  static double cosh(double x) => (math.exp(x) + math.exp(-x)) / 2;

  static double tanh(double x) => sinh(x) / cosh(x);

  static double asinh(double x) => math.log(x + math.sqrt(x * x + 1));

  static double acosh(double x) {
    if (x < 1) throw ArgumentError('acosh undefined for x < 1');
    return math.log(x + math.sqrt(x * x - 1));
  }

  static double atanh(double x) {
    if (x.abs() >= 1) throw ArgumentError('atanh undefined for |x| >= 1');
    return 0.5 * math.log((1 + x) / (1 - x));
  }

  static double hypot(double x, double y) {
    x = x.abs();
    y = y.abs();
    if (x < y) {
      final temp = x;
      x = y;
      y = temp;
    }
    if (x == 0) return 0;
    final ratio = y / x;
    return x * math.sqrt(1 + ratio * ratio);
  }

  static double mean(List<double> values) {
    if (values.isEmpty) throw ArgumentError('Cannot calculate mean of empty list');
    return values.reduce((a, b) => a + b) / values.length;
  }

  static double median(List<double> values) {
    if (values.isEmpty) throw ArgumentError('Cannot calculate median of empty list');

    final sorted = List<double>.from(values)..sort();
    final n = sorted.length;

    if (n % 2 == 1) {
      return sorted[n ~/ 2];
    } else {
      return (sorted[n ~/ 2 - 1] + sorted[n ~/ 2]) / 2;
    }
  }

  static List<double> mode(List<double> values) {
    if (values.isEmpty) return [];

    final frequency = <double, int>{};
    for (final value in values) {
      frequency[value] = (frequency[value] ?? 0) + 1;
    }

    final maxFreq = frequency.values.reduce(math.max);
    return frequency.entries.where((entry) => entry.value == maxFreq).map((entry) => entry.key).toList();
  }

  static double variance(List<double> values, {bool sample = false}) {
    if (values.isEmpty) throw ArgumentError('Cannot calculate variance of empty list');
    if (values.length == 1 && sample) {
      throw ArgumentError('Sample variance undefined for single value');
    }

    final avg = mean(values);
    final sumSquaredDiff = values.map((x) => power(x - avg, 2)).reduce((a, b) => a + b);

    final divisor = sample ? values.length - 1 : values.length;
    return sumSquaredDiff / divisor;
  }

  static double standardDeviation(List<double> values, {bool sample = false}) {
    return math.sqrt(variance(values, sample: sample));
  }

  static double coefficientOfVariation(List<double> values, {bool sample = false}) {
    final avg = mean(values);
    if (avg == 0) throw ArgumentError('Cannot calculate CV when mean is zero');
    return standardDeviation(values, sample: sample) / avg.abs();
  }

  static double pearsonCorrelation(List<double> x, List<double> y) {
    if (x.length != y.length || x.isEmpty) {
      throw ArgumentError('Lists must have same non-zero length');
    }

    final n = x.length;
    final meanX = mean(x);
    final meanY = mean(y);

    double numerator = 0;
    double sumXSquared = 0;
    double sumYSquared = 0;

    for (int i = 0; i < n; i++) {
      final deltaX = x[i] - meanX;
      final deltaY = y[i] - meanY;
      numerator += deltaX * deltaY;
      sumXSquared += deltaX * deltaX;
      sumYSquared += deltaY * deltaY;
    }

    final denominator = math.sqrt(sumXSquared * sumYSquared);
    return denominator == 0 ? 0 : numerator / denominator;
  }

  static double distance2D(double x1, double y1, double x2, double y2) {
    return hypot(x2 - x1, y2 - y1);
  }

  static double distance3D(double x1, double y1, double z1, double x2, double y2, double z2) {
    final dx = x2 - x1;
    final dy = y2 - y1;
    final dz = z2 - z1;
    return math.sqrt(dx * dx + dy * dy + dz * dz);
  }

  static double circleArea(double radius) {
    if (radius < 0) throw ArgumentError('Radius cannot be negative');
    return pi * radius * radius;
  }

  static double circleCircumference(double radius) {
    if (radius < 0) throw ArgumentError('Radius cannot be negative');
    return 2 * pi * radius;
  }

  static double triangleAreaHeron(double a, double b, double c) {
    if (a <= 0 || b <= 0 || c <= 0) {
      throw ArgumentError('All sides must be positive');
    }
    if (a + b <= c || a + c <= b || b + c <= a) {
      throw ArgumentError('Invalid triangle: triangle inequality violated');
    }

    final s = (a + b + c) / 2;
    return math.sqrt(s * (s - a) * (s - b) * (s - c));
  }

  static double sphereVolume(double radius) {
    if (radius < 0) throw ArgumentError('Radius cannot be negative');
    return (4 / 3) * pi * power(radius, 3);
  }

  static double sphereSurface(double radius) {
    if (radius < 0) throw ArgumentError('Radius cannot be negative');
    return 4 * pi * radius * radius;
  }

  static int gcd(int a, int b) {
    a = a.abs();
    b = b.abs();
    while (b != 0) {
      final temp = b;
      b = a % b;
      a = temp;
    }
    return a;
  }

  static int lcm(int a, int b) {
    if (a == 0 || b == 0) return 0;
    return (a * b).abs() ~/ gcd(a, b);
  }

  static bool isPrime(int n) {
    if (n < 2) return false;
    if (n == 2) return true;
    if (n % 2 == 0) return false;

    for (int i = 3; i * i <= n; i += 2) {
      if (n % i == 0) return false;
    }
    return true;
  }

  static List<int> sieveOfEratosthenes(int n) {
    if (n < 2) return [];

    final isPrime = List.filled(n + 1, true);
    isPrime[0] = isPrime[1] = false;

    for (int i = 2; i * i <= n; i++) {
      if (isPrime[i]) {
        for (int j = i * i; j <= n; j += i) {
          isPrime[j] = false;
        }
      }
    }

    return [
      for (int i = 2; i <= n; i++)
        if (isPrime[i]) i,
    ];
  }

  static List<int> primeFactors(int n) {
    if (n <= 1) return [];

    final factors = <int>[];
    int divisor = 2;

    while (divisor * divisor <= n) {
      while (n % divisor == 0) {
        factors.add(divisor);
        n ~/= divisor;
      }
      divisor++;
    }

    if (n > 1) factors.add(n);
    return factors;
  }

  static List<int> fibonacciSequence(int n) {
    if (n <= 0) return [];
    if (n == 1) return [0];
    if (n == 2) return [0, 1];

    final sequence = [0, 1];
    for (int i = 2; i < n; i++) {
      sequence.add(sequence[i - 1] + sequence[i - 2]);
    }
    return sequence;
  }

  static int fibonacciNumber(int n) {
    if (n <= 0) return 0;
    if (n == 1) return 1;

    int a = 0, b = 1;
    for (int i = 2; i <= n; i++) {
      final temp = a + b;
      a = b;
      b = temp;
    }
    return b;
  }

  static double lerp(double a, double b, double t) {
    return a + (b - a) * t.clamp(0.0, 1.0);
  }

  static double inverseLerp(double a, double b, double value) {
    if ((b - a).abs() < 1e-10) return 0;
    return ((value - a) / (b - a)).clamp(0.0, 1.0);
  }

  static double quadraticBezier(double p0, double p1, double p2, double t) {
    t = t.clamp(0.0, 1.0);
    final oneMinusT = 1 - t;
    return oneMinusT * oneMinusT * p0 + 2 * oneMinusT * t * p1 + t * t * p2;
  }

  static double cubicBezier(double p0, double p1, double p2, double p3, double t) {
    t = t.clamp(0.0, 1.0);
    final oneMinusT = 1 - t;
    return oneMinusT * oneMinusT * oneMinusT * p0 +
        3 * oneMinusT * oneMinusT * t * p1 +
        3 * oneMinusT * t * t * p2 +
        t * t * t * p3;
  }

  static double mapRange(double value, double fromMin, double fromMax, double toMin, double toMax) {
    if ((fromMax - fromMin).abs() < 1e-10) return toMin;
    final normalized = (value - fromMin) / (fromMax - fromMin);
    return toMin + normalized * (toMax - toMin);
  }

  static bool isCloseTo(double a, double b, {double tolerance = 1e-10}) {
    return (a - b).abs() <= tolerance;
  }

  static double roundToDecimals(double value, int decimals, {LucidRoundingMode mode = LucidRoundingMode.round}) {
    final factor = power(10, decimals.toDouble());
    switch (mode) {
      case LucidRoundingMode.round:
        return (value * factor).round() / factor;
      case LucidRoundingMode.floor:
        return (value * factor).floor() / factor;
      case LucidRoundingMode.ceil:
        return (value * factor).ceil() / factor;
      case LucidRoundingMode.truncate:
        return (value * factor).truncate() / factor;
    }
  }

  static double? clampNullable(double? value, double min, double max) {
    return value?.clamp(min, max);
  }

  static double randomInRange(double min, double max, [math.Random? random]) {
    random ??= math.Random();
    return min + random.nextDouble() * (max - min);
  }

  static int randomIntInRange(int min, int max, [math.Random? random]) {
    random ??= math.Random();
    return min + random.nextInt(max - min + 1);
  }
}
