import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lichess_mobile/src/model/common/chess.dart';
import 'package:lichess_mobile/src/styles/lichess_icons.dart';

part 'practice_comment.freezed.dart';
part 'practice_comment.g.dart';

enum MoveVerdict {
  brilliant,
  greatMove,
  bestMove,
  bookMove,
  blunder,
  mistake,
  inaccuracy,
  notBest,
  goodMove;

  static MoveVerdict fromShift(
    double shift, {
    required bool hasBetterMove,
    required double winningChancesBefore,
    required double winningChancesAfter,
    bool isBookMove = false,
  }) {
    if (isBookMove) return MoveVerdict.bookMove;
    if (!hasBetterMove) return MoveVerdict.bestMove;
    if (shift < 0.01) return MoveVerdict.brilliant;
    if (shift < 0.02) return MoveVerdict.bestMove;
    if (shift < 0.05) return MoveVerdict.greatMove;
    if (winningChancesBefore >= 0.5 && winningChancesAfter >= 0.5) return MoveVerdict.notBest;
    if (shift < 0.11) return MoveVerdict.inaccuracy;
    if (shift < 0.24) return MoveVerdict.mistake;
    return MoveVerdict.blunder;
  }

  IconData get icon => switch (this) {
    MoveVerdict.brilliant => Icons.auto_awesome,
    MoveVerdict.greatMove => Icons.stars,
    MoveVerdict.bestMove => Icons.check_circle,
    MoveVerdict.bookMove => LichessIcons.book_lichess,
    MoveVerdict.blunder => Icons.cancel,
    MoveVerdict.mistake => Icons.error,
    MoveVerdict.inaccuracy => Icons.help,
    MoveVerdict.notBest => Icons.info,
    MoveVerdict.goodMove => Icons.check,
  };

  Color get color => switch (this) {
    MoveVerdict.brilliant => Colors.cyan,
    MoveVerdict.greatMove => Colors.blue,
    MoveVerdict.bestMove => Colors.green,
    MoveVerdict.bookMove => Colors.brown,
    MoveVerdict.blunder => Colors.red,
    MoveVerdict.mistake => Colors.orange,
    MoveVerdict.inaccuracy => Colors.yellow,
    MoveVerdict.notBest => Colors.grey,
    MoveVerdict.goodMove => Colors.lightGreen,
  };
}

@Freezed(fromJson: true, toJson: true)
class PracticeComment with _$PracticeComment {
  const PracticeComment._();
  const factory PracticeComment({
    required MoveVerdict verdict,
    SanMove? moveSuggestion,
    String? evalAfter,
    @Default(false) bool isBookMove,
  }) = _PracticeComment;
  factory PracticeComment.fromJson(Map<String, dynamic> json) => _$PracticeCommentFromJson(json);
}
