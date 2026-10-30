part of 'controller.dart';

/// moves.js: zamanlama düğmesi ve üç yarışlık kupa.
extension MovesLogic on GameController {
  void offerMove(String kind, double duration, String label) {
    activeMove = ActiveMove(kind, duration);
    skillMoveHidden = false;
    skillButtonText = label;
    skillMeter = 0;
  }

  void clearMove() {
    activeMove = null;
    skillMoveHidden = true;
  }

  double moveQuality() => activeMove?.quality ?? 0;

  bool tapMove() {
    final move = activeMove;
    if (move == null || move.tapped || paused) return false;
    final t = move.elapsed / move.duration;
    move.quality = max(0, 1 - (t - .5).abs() * 2);
    move.tapped = true;
    skillButtonText = move.quality > .7 ? 'MÜKEMMEL!' : 'HAMLE!';
    beep(720 + move.quality * 260, .08);
    _changed();
    return true;
  }

  void tickMove(double dt) {
    final move = activeMove;
    if (move == null) return;
    move.elapsed = min(move.duration, move.elapsed + dt);
    skillMeter = move.elapsed / move.duration;
    if (move.elapsed >= move.duration) {
      move.tapped = true;
      skillMoveHidden = true;
    }
  }

  void recordTournament(String branch, int place) {
    final t = state.tournament;
    if (t == null || t.branch != branch || t.attempts >= 3) return;
    t.attempts++;
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
