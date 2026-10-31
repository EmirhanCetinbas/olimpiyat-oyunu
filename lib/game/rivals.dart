part of 'controller.dart';

/// Rakip gücü (docs/tasks.md 1–2). Şimdilik oyuncunun gücüne göre: rakipler
/// oyuncunun yükseltme, kampüs ve ekipman düzeyini kullanır; farkı hayvan,
/// uzmanlık, günlük form ve zamanlama hamlesi belirler. Başka bir model
/// (ör. branş ligi) seçilirse rakip gücü yalnızca buradan değişir.
extension RivalLogic on GameController {
  /// Koşu branşlarında sporcunun o günkü formu (oyuncu dahil): ortalaması 1, iki yana %9.
  /// Uzmanlığın (+%6) yarışı tek başına belirlememesi için uzmanlıktan geniş.
  double raceForm() => .91 + rand() * .18;

  /// Rakibin yarışta kullandığı yükseltme seviyeleri.
  List<int> rivalLevels(List<int> playerLevels) => playerLevels;

  /// Rakibin yarışta kullandığı kampüs kademeleri.
  List<int> rivalCampus(List<int> playerCampus) => playerCampus;
}
