part of 'controller.dart';

/// moves.js: zamanlama düğmesi ve üç yarışlık kupa.
extension MovesLogic on GameController {
  /// Kusursuz pencere: hedefin iki yanında sürenin %15'i (kalite > .7).
  static const perfectWindow = .15;

  void offerMove(String kind, double duration, String label, {double target = .5}) {
    activeMove = ActiveMove(kind, duration, target: target);
    skillMoveHidden = false;
    skillButtonText = label;
    skillMeter = 0;
  }

  void clearMove() {
    activeMove = null;
    skillMoveHidden = true;
  }

  double moveQuality() => activeMove?.quality ?? 0;

  /// Sahaya ya da hamle düğmesine dokunuş: kalite hedefe uzaklıkla düşer.
  bool tapMove() {
    final move = activeMove;
    if (move == null || move.tapped || paused) return false;
    final t = move.elapsed / move.duration;
    move.quality = max(0, 1 - (t - move.target).abs() * 2);
    move.tapped = true;
    skillButtonText = move.quality > .7 ? 'MÜKEMMEL!' : 'HAMLE!';
    showMoveFeedback(
      move.quality > .7
          ? 'MÜKEMMEL!'
          : move.quality > .35
          ? 'İYİ!'
          : t < move.target
          ? 'ERKEN!'
          : 'GEÇ!',
      move.quality > .7,
    );
    beep(720 + move.quality * 260, .08);
    _changed();
    return true;
  }

  void tickMove(double dt) {
    if (moveFeedbackTime > 0) moveFeedbackTime = max(0, moveFeedbackTime - dt);
    final move = activeMove;
    if (move == null) return;
    move.elapsed = min(move.duration, move.elapsed + dt);
    skillMeter = move.elapsed / move.duration;
    if (move.elapsed >= move.duration) {
      if (!move.tapped) showMoveFeedback('KAÇTI!', false);
      move.tapped = true;
      skillMoveHidden = true;
    }
  }

  /// Sahada kısa süre görünen sonuç yazısı.
  void showMoveFeedback(String text, bool perfect) {
    moveFeedback = text;
    moveFeedbackPerfect = perfect;
    moveFeedbackTime = .9;
  }

  void recordTournament(String branch, int place) {
    final t = state.tournament;
    if (t == null || t.branch != branch || t.attempts >= 3) return;
    t.attempts++;
    t.places.add(place);
    if (place <= 3) t.podiums++;
    if (t.attempts == 3) {
      final won = t.podiums >= 2;
      if (won) {
        state.cupChests++;
        state.skillPoints++;
        state.tournamentCups++;
      }
      toast(won ? '🏆 Turnuva tamamlandı · Kupa Çantası, +1 SP' : 'Turnuva bitti · Yeni kupa deneyebilirsin.');
    }
  }

  bool startTournament() {
    final t = state.tournament;
    if (race != null || (t != null && t.attempts < 3)) return false;
    state.tournament = Tournament(state.branch, 0, 0);
    save();
    return true;
  }
}
