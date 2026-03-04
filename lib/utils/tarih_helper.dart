String tarihFormatla(DateTime tarih) {
  final yil = tarih.year.toString();
  final ay = tarih.month.toString().padLeft(2, '0');
  final gun = tarih.day.toString().padLeft(2, '0');
  return '$yil-$ay-$gun';
}
