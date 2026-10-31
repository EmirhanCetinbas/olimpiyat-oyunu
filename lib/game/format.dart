/// tr-TR sayı biçimlendirme ve tarih yardımcıları (JS toLocaleString('tr-TR') karşılığı).
String trNumber(num value, [int maxFractionDigits = 0]) {
  var text = value.toStringAsFixed(maxFractionDigits);
  var fraction = '';
  if (text.contains('.')) {
    final parts = text.split('.');
    text = parts[0];
    fraction = parts[1].replaceAll(RegExp(r'0+$'), '');
  }
  final negative = text.startsWith('-');
  if (negative) text = text.substring(1);
  final grouped = StringBuffer();
  for (var i = 0; i < text.length; i++) {
    if (i > 0 && (text.length - i) % 3 == 0) grouped.write('.');
    grouped.write(text[i]);
  }
  final sign = negative && (grouped.toString() != '0' || fraction.isNotEmpty) ? '-' : '';
  return '$sign$grouped${fraction.isEmpty ? '' : ',$fraction'}';
}

/// game.js `fmt`
String fmt(num n) {
  if (n >= 1e6) return '${trNumber(n / 1e6, 1)}M';
  if (n >= 1e4) return '${trNumber(n / 1e3, 1)}K';
  return trNumber(n.floor());
}

String _two(int n) => n.toString().padLeft(2, '0');

/// Europe/Istanbul (UTC+3, yaz saati yok) gün anahtarı: yyyy-mm-dd
String istanbulDayKey(int millis) {
  final d = DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).add(const Duration(hours: 3));
  return '${d.year}-${_two(d.month)}-${_two(d.day)}';
}

/// Kısa süre: bir dakikadan uzunsa dakika ("15 dk"), değilse saniye ("42 sn").
String shortDuration(int ms) {
  final seconds = (ms / 1000).ceil();
  return seconds >= 60 ? '${(seconds / 60).ceil()} dk' : '$seconds sn';
}

String jumpMetres(num n) => '${n.toStringAsFixed(2).replaceAll('.', ',')} m';

String stopwatch(double seconds) => '◴ ${_two((seconds / 60).floor())}:${_two((seconds % 60).floor())}';
