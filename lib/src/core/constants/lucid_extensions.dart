import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'lucid_enums.dart';

extension LucidStringExtensions on String {
  bool get isValidEmail {
    const pattern =
        r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]"
        r"(?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?"
        r"(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$";

    return RegExp(pattern).hasMatch(this);
  }

  bool get isStrongPassword {
    if (length < 8) return false;

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(this);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(this);
    final hasDigits = RegExp(r'\d').hasMatch(this);
    final hasSpecialCharacters = RegExp(r'[@$!%*?&]').hasMatch(this);

    return hasUppercase && hasLowercase && hasDigits && hasSpecialCharacters;
  }

  int get passwordStrength {
    int score = 0;
    if (length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(this)) score++;
    if (RegExp(r'[a-z]').hasMatch(this)) score++;
    if (RegExp(r'\d').hasMatch(this)) score++;
    if (RegExp(r'[@$!%*?&]').hasMatch(this)) score++;
    return score;
  }

  bool get isValidPhoneNumber {
    const pattern = r'^\+?[1-9]\d{1,14}$';
    return RegExp(pattern).hasMatch(replaceAll(RegExp(r'[\s\-\(\)]'), ''));
  }

  bool get isValidUrl {
    try {
      final uri = Uri.parse(this);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  bool get isAlphanumeric => RegExp(r'^[a-zA-Z0-9]+$').hasMatch(this);

  bool get isNumeric => double.tryParse(this) != null;

  bool get isHexadecimal => RegExp(r'^[0-9a-fA-F]+$').hasMatch(this);

  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }

  String get titleCase {
    if (isEmpty) return this;
    return split(' ').map((word) => word.isEmpty ? word : word.capitalized).join(' ');
  }

  String get camelCase {
    if (isEmpty) return this;
    final words = split(RegExp(r'[\s_-]+'));
    if (words.isEmpty) return this;

    return words.first.toLowerCase() + words.skip(1).map((word) => word.capitalized).join();
  }

  String get snakeCase {
    return replaceAllMapped(
      RegExp(r'[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceAll(RegExp(r'[\s-]+'), '_').replaceAll(RegExp(r'^_+|_+$'), '').toLowerCase();
  }

  String get kebabCase {
    return snakeCase.replaceAll('_', '-');
  }

  String get withoutAccents {
    const accents = 'ÀÁÂÃÄÅàáâãäåÒÓÔÕÖØòóôõöøÈÉÊËèéêëÇçÌÍÎÏìíîïÙÚÛÜùúûüÿÑñ';
    const withoutAccents = 'AAAAAAaaaaaaOOOOOOooooooEEEEeeeeeCcIIIIiiiiUUUUuuuuyNn';

    String result = this;
    for (int i = 0; i < accents.length; i++) {
      result = result.replaceAll(accents[i], withoutAccents[i]);
    }
    return result;
  }

  String get reversed => split('').reversed.join();

  String get trimmed => trim();

  String get withoutSpaces => replaceAll(' ', '');

  String get cleaned => replaceAll(RegExp(r'[^\x20-\x7E]'), '');

  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  String truncateWords(int maxWords, {String ellipsis = '...'}) {
    final words = split(' ');
    if (words.length <= maxWords) return this;
    return '${words.take(maxWords).join(' ')}$ellipsis';
  }

  int get wordCount => trim().split(RegExp(r'\s+')).where((word) => word.isNotEmpty).length;

  List<double> get extractNumbers {
    final matches = RegExp(r'-?\d+\.?\d*').allMatches(this);
    return matches.map((match) => double.parse(match.group(0)!)).toList();
  }

  String mask({int start = 0, int? end, String maskChar = '*'}) {
    if (isEmpty) return this;
    final actualEnd = end ?? length;
    final beforeMask = substring(0, start);
    final afterMask = substring(actualEnd);
    final maskLength = actualEnd - start;
    return beforeMask + (maskChar * maskLength) + afterMask;
  }

  String get maskedEmail {
    if (!isValidEmail) return this;
    final parts = split('@');
    final name = parts[0];
    final domain = parts[1];

    final maskedName = name.length > 2 ? '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}' : name;

    return '$maskedName@$domain';
  }

  String get slug {
    return withoutAccents
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'[\s_-]+'), '-')
        .replaceAll(RegExp(r'^-+|-+$'), '');
  }

  String get base64Encoded => base64Encode(utf8.encode(this));

  String get base64Decoded {
    try {
      return utf8.decode(base64Decode(this));
    } catch (e) {
      return this;
    }
  }

  Future<void> copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: this));
  }
}

extension LucidNullableStringExtensions on String? {
  bool get isNullOrEmpty => this?.isEmpty ?? true;

  bool get isNotNullOrEmpty => !isNullOrEmpty;

  String orDefault(String defaultValue) => isNullOrEmpty ? defaultValue : this!;

  int get lengthOrZero => this?.length ?? 0;
}

extension LucidDateTimeExtensions on DateTime {
  String formatted({String format = "yyyy-MM-dd"}) {
    final formatter = DateFormat(format);
    return formatter.format(this);
  }

  String formattedWithTime({String format = "yyyy-MM-dd HH:mm:ss"}) {
    final formatter = DateFormat(format);
    return formatter.format(this);
  }

  String get iso8601 => toIso8601String();

  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) return 'Hier';
      if (difference.inDays < 7) return 'Il y a ${difference.inDays} jours';
      if (difference.inDays < 30) {
        return 'Il y a ${(difference.inDays / 7).floor()} semaines';
      }
      if (difference.inDays < 365) {
        return 'Il y a ${(difference.inDays / 30).floor()} mois';
      }
      return 'Il y a ${(difference.inDays / 365).floor()} ans';
    }

    if (difference.inHours > 0) {
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    }

    if (difference.inMinutes > 0) {
      return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
    }

    return 'À l\'instant';
  }

  String get monthName {
    const months = [
      'Janvier',
      'Février',
      'Mars',
      'Avril',
      'Mai',
      'Juin',
      'Juillet',
      'Août',
      'Septembre',
      'Octobre',
      'Novembre',
      'Décembre',
    ];
    return months[month - 1];
  }

  String get dayName {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    return days[weekday - 1];
  }

  bool get isToday => isSameDay(DateTime.now());

  bool get isYesterday => isSameDay(DateTime.now().subtract(const Duration(days: 1)));

  bool get isTomorrow => isSameDay(DateTime.now().add(const Duration(days: 1)));

  bool get isPast => isBefore(DateTime.now());

  bool get isFuture => isAfter(DateTime.now());

  bool get isWeekend => weekday == 6 || weekday == 7;

  bool get isWeekday => !isWeekend;

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  bool isSameYear(DateTime other) => year == other.year;

  DateTime get startOfDay => DateTime(year, month, day);

  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  DateTime get startOfWeek => subtract(Duration(days: weekday - 1)).startOfDay;

  DateTime get endOfWeek => add(Duration(days: 7 - weekday)).endOfDay;

  DateTime get startOfMonth => DateTime(year, month, 1);

  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59, 999);

  DateTime get startOfYear => DateTime(year, 1, 1);

  DateTime get endOfYear => DateTime(year, 12, 31, 23, 59, 59, 999);

  DateTime addBusinessDays(int days) {
    DateTime result = this;
    int addedDays = 0;

    while (addedDays < days) {
      result = result.add(const Duration(days: 1));
      if (result.isWeekday) addedDays++;
    }

    return result;
  }

  int get daysInMonth => DateTime(year, month + 1, 0).day;

  int get age {
    final now = DateTime.now();
    int age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }
}

extension LucidBuildContextExtensions on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => theme.colorScheme;

  TextTheme get textTheme => theme.textTheme;

  bool get isDarkTheme => theme.brightness == Brightness.dark;

  bool get isLightTheme => !isDarkTheme;

  MediaQueryData get mediaQuery => MediaQuery.of(this);

  Size get screenSize => mediaQuery.size;

  double get screenWidth => screenSize.width;

  double get screenHeight => screenSize.height;

  double get aspectRatio => screenWidth / screenHeight;

  EdgeInsets get safeAreaPadding => mediaQuery.padding;

  bool get isPortrait => mediaQuery.orientation == Orientation.portrait;

  bool get isLandscape => !isPortrait;

  bool get isExtraSmallScreen => screenWidth < 360;

  bool get isSmallScreen => screenWidth >= 360 && screenWidth < 600;

  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1024;

  bool get isLargeScreen => screenWidth >= 1024 && screenWidth < 1440;

  bool get isExtraLargeScreen => screenWidth >= 1440;

  LucidScreenSize get screenSizeClass {
    if (isExtraSmallScreen) return LucidScreenSize.extraSmall;
    if (isSmallScreen) return LucidScreenSize.small;
    if (isMediumScreen) return LucidScreenSize.medium;
    if (isLargeScreen) return LucidScreenSize.large;
    return LucidScreenSize.extraLarge;
  }

  NavigatorState get navigator => Navigator.of(this);

  Future<T?> push<T>(Widget page) => navigator.push<T>(MaterialPageRoute(builder: (_) => page));

  Future<T?> pushReplacement<T>(Widget page) =>
      navigator.pushReplacement<T, void>(MaterialPageRoute(builder: (_) => page));

  Future<T?> pushAndRemoveUntil<T>(Widget page) =>
      navigator.pushAndRemoveUntil<T>(MaterialPageRoute(builder: (_) => page), (route) => false);

  void pop<T>([T? result]) => navigator.pop<T>(result);

  bool get canPop => navigator.canPop();

  void hideKeyboard() => FocusScope.of(this).unfocus();

  void showKeyboard(FocusNode focusNode) => FocusScope.of(this).requestFocus(focusNode);
}

extension LucidListExtensions<T> on List<T> {
  bool all(bool Function(T) test) => every(test);

  bool none(bool Function(T) test) => !any(test);

  T get random {
    if (isEmpty) throw StateError('Cannot get random element from empty list');
    return this[math.Random().nextInt(length)];
  }

  T? get randomOrNull => isEmpty ? null : random;

  List<T> get shuffled => [...this]..shuffle();

  List<T> separated(T separator) {
    if (isEmpty) return this;
    final result = <T>[];
    for (int i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) result.add(separator);
    }
    return result;
  }

  List<List<T>> chunk(int size) {
    if (size <= 0) throw ArgumentError('Chunk size must be positive');
    if (isEmpty) return [];

    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, math.min(i + size, length)));
    }
    return chunks;
  }

  List<T> get distinct => toSet().toList();

  List<T> distinctBy<K>(K Function(T) keySelector) {
    final seen = <K>{};
    return where((element) => seen.add(keySelector(element))).toList();
  }

  List<T> take(int count) => sublist(0, math.min(count, length));

  List<T> takeLast(int count) => sublist(math.max(0, length - count));

  List<T> skip(int count) => sublist(math.min(count, length));

  T? maxBy<K extends Comparable<K>>(K Function(T) keySelector) {
    if (isEmpty) return null;
    return reduce((a, b) => keySelector(a).compareTo(keySelector(b)) > 0 ? a : b);
  }

  T? minBy<K extends Comparable<K>>(K Function(T) keySelector) {
    if (isEmpty) return null;
    return reduce((a, b) => keySelector(a).compareTo(keySelector(b)) < 0 ? a : b);
  }

  Map<K, List<T>> groupBy<K>(K Function(T) keySelector) {
    final map = <K, List<T>>{};
    for (final element in this) {
      final key = keySelector(element);
      map.putIfAbsent(key, () => []).add(element);
    }
    return map;
  }

  Map<K, int> countBy<K>(K Function(T) keySelector) {
    final map = <K, int>{};
    for (final element in this) {
      final key = keySelector(element);
      map[key] = (map[key] ?? 0) + 1;
    }
    return map;
  }

  List<R> filterMap<R>(R? Function(T) transform) {
    final result = <R>[];
    for (final element in this) {
      final transformed = transform(element);
      if (transformed != null) {
        result.add(transformed);
      }
    }
    return result;
  }
}

extension LucidNullableListExtensions<T> on List<T>? {
  bool get isNullOrEmpty => this?.isEmpty ?? true;

  bool get isNotNullOrEmpty => !isNullOrEmpty;

  int get lengthOrZero => this?.length ?? 0;

  List<T> orEmpty() => this ?? [];
}

extension LucidNumExtensions on num {
  String get asPercentage => '${(this * 100).toStringAsFixed(1)}%';

  String get formatted {
    final formatter = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    return toString().replaceAllMapped(formatter, (match) => '${match[1]} ');
  }

  String asCurrency({String symbol = "F CFA", int decimals = 2}) {
    return '${toStringAsFixed(decimals)} $symbol';
  }

  String get asFileSize {
    if (this < 1024) return '${toInt()} B';
    if (this < 1024 * 1024) return '${(this / 1024).toStringAsFixed(1)} KB';
    if (this < 1024 * 1024 * 1024) {
      return '${(this / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(this / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  bool isBetween(num min, num max) => this >= min && this <= max;

  bool get isEven => this % 2 == 0;

  bool get isOdd => !isEven;

  bool get isPositive => this > 0;

  bool get isNegative => this < 0;

  bool get isZero => this == 0;

  bool get isInteger => this == toInt();

  double roundToDecimals(int decimals) {
    final mod = math.pow(10.0, decimals);
    return (this * mod).round() / mod;
  }

  num clamp(num min, num max) => math.min(math.max(this, min), max);

  num get absolute => abs();

  num get squared => this * this;

  num get cubed => this * this * this;

  double get sqrt => math.sqrt(toDouble());

  num power(num exponent) => math.pow(this, exponent);

  int get factorial {
    if (!isInteger || this < 0) {
      throw ArgumentError('Factorial is only defined for non-negative integers');
    }
    if (this <= 1) return 1;
    int result = 1;
    for (int i = 2; i <= this; i++) {
      result *= i;
    }
    return result;
  }

  int get sign => compareTo(0);

  double lerp(num target, double t) => this + (target - this) * t;

  double get toRadians => this * (math.pi / 180);

  double get toDegrees => this * (180 / math.pi);

  Duration get milliseconds => Duration(milliseconds: toInt());

  Duration get seconds => Duration(seconds: toInt());

  Duration get minutes => Duration(minutes: toInt());

  Duration get hours => Duration(hours: toInt());

  Duration get days => Duration(days: toInt());

  EdgeInsets get padding => EdgeInsets.all(toDouble());

  EdgeInsets get paddingHorizontal => EdgeInsets.symmetric(horizontal: toDouble());

  EdgeInsets get paddingVertical => EdgeInsets.symmetric(vertical: toDouble());

  BorderRadius get borderRadius => BorderRadius.circular(toDouble());

  SizedBox get height => SizedBox(height: toDouble());

  SizedBox get width => SizedBox(width: toDouble());

  SizedBox get square => SizedBox.square(dimension: toDouble());
}

extension LucidDurationExtensions on Duration {
  String get formatted {
    final hours = inHours;
    final minutes = inMinutes % 60;
    final seconds = inSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes.toString().padLeft(2, '0')}min';
    } else if (minutes > 0) {
      return '${minutes}min ${seconds.toString().padLeft(2, '0')}s';
    } else {
      return '${seconds}s';
    }
  }

  String get shortFormat {
    final hours = inHours;
    final minutes = inMinutes % 60;
    final seconds = inSeconds % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  bool get isZero => this == Duration.zero;

  bool get isPositive => inMicroseconds > 0;

  bool get isNegative => inMicroseconds < 0;

  Duration get absolute => Duration(microseconds: inMicroseconds.abs());
}

extension LucidMapExtensions<K, V> on Map<K, V> {
  Map<K, V> filterKeys(bool Function(K) predicate) {
    return Map.fromEntries(entries.where((entry) => predicate(entry.key)));
  }

  Map<K, V> filterValues(bool Function(V) predicate) {
    return Map.fromEntries(entries.where((entry) => predicate(entry.value)));
  }

  Map<K2, V> mapKeys<K2>(K2 Function(K) transform) {
    return Map.fromEntries(entries.map((entry) => MapEntry(transform(entry.key), entry.value)));
  }

  Map<K, V2> mapValues<V2>(V2 Function(V) transform) {
    return Map.fromEntries(entries.map((entry) => MapEntry(entry.key, transform(entry.value))));
  }

  V getOrDefault(K key, V defaultValue) => this[key] ?? defaultValue;

  V getOrElse(K key, V Function() defaultValue) => this[key] ?? defaultValue();

  Map<V, K> get inverted => Map.fromEntries(entries.map((entry) => MapEntry(entry.value, entry.key)));

  Map<K, V> merge(Map<K, V> other) => {...this, ...other};

  String toJsonString() {
    try {
      return jsonEncode(this);
    } catch (e) {
      throw ArgumentError('Map cannot be converted to JSON: $e');
    }
  }
}

extension LucidSetExtensions<T> on Set<T> {
  Set<T> unionWith(Set<T> other) => {...this, ...other};

  Set<T> intersectionWith(Set<T> other) => intersection(other);

  Set<T> differenceWith(Set<T> other) => difference(other);

  Set<T> symmetricDifferenceWith(Set<T> other) {
    return difference(other).union(other.difference(this));
  }

  bool isSubsetOf(Set<T> other) => every(other.contains);

  bool isSupersetOf(Set<T> other) => other.isSubsetOf(this);
}

extension LucidColorExtensions on Color {
  String get hex {
    final argb = toARGB32();
    return '#${argb.toRadixString(16).padLeft(8, '0').substring(2)}';
  }

  double get luminance => computeLuminance();

  bool get isDark => luminance < 0.5;

  bool get isLight => !isDark;

  Color withOpacityValue(double opacity) => withValues(alpha: opacity.clamp(0.0, 1.0));

  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }

  Color blend(Color other, [double factor = 0.5]) {
    return Color.lerp(this, other, factor.clamp(0.0, 1.0))!;
  }

  Color get complementary {
    final hsl = HSLColor.fromColor(this);
    final complementaryHue = (hsl.hue + 180) % 360;
    return hsl.withHue(complementaryHue).toColor();
  }
}

extension LucidTextEditingControllerExtensions on TextEditingController {
  bool get isEmpty => text.isEmpty;

  bool get isNotEmpty => text.isNotEmpty;

  void clear() => text = '';

  void selectAll() => selection = TextSelection(baseOffset: 0, extentOffset: text.length);

  void moveToEnd() => selection = TextSelection.collapsed(offset: text.length);

  void moveToStart() => selection = const TextSelection.collapsed(offset: 0);

  void insertText(String textToInsert) {
    final currentSelection = selection;
    final newText = text.replaceRange(currentSelection.start, currentSelection.end, textToInsert);
    text = newText;
    selection = TextSelection.collapsed(offset: currentSelection.start + textToInsert.length);
  }

  void deleteSelection() {
    if (selection.isValid) {
      final newText = text.replaceRange(selection.start, selection.end, '');
      text = newText;
      selection = TextSelection.collapsed(offset: selection.start);
    }
  }
}

extension LucidGlobalKeyExtensions on GlobalKey {
  RenderBox? get renderBox {
    final context = currentContext;
    if (context == null) return null;
    return context.findRenderObject() as RenderBox?;
  }

  Size? get size => renderBox?.size;

  Offset? get globalPosition => renderBox?.localToGlobal(Offset.zero);

  bool get isMounted => currentContext != null;
}

extension LucidScrollControllerExtensions on ScrollController {
  Future<void> animateToTop({Duration duration = const Duration(milliseconds: 500), Curve curve = Curves.easeOut}) {
    return animateTo(0, duration: duration, curve: curve);
  }

  Future<void> animateToBottom({Duration duration = const Duration(milliseconds: 500), Curve curve = Curves.easeOut}) {
    return animateTo(position.maxScrollExtent, duration: duration, curve: curve);
  }

  bool get isAtTop => position.pixels == 0;

  bool get isAtBottom => position.pixels == position.maxScrollExtent;

  Future<void> pageUp({Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.easeOut}) {
    final targetOffset = (offset - position.viewportDimension).clamp(0.0, position.maxScrollExtent);
    return animateTo(targetOffset, duration: duration, curve: curve);
  }

  Future<void> pageDown({Duration duration = const Duration(milliseconds: 300), Curve curve = Curves.easeOut}) {
    final targetOffset = (offset + position.viewportDimension).clamp(0.0, position.maxScrollExtent);
    return animateTo(targetOffset, duration: duration, curve: curve);
  }
}
