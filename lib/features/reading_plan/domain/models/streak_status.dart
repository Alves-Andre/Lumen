class StreakStatus {
  const StreakStatus({
    required this.currentStreak,
    required this.longestStreak,
    required this.readToday,
    required this.shields,
    required this.shieldDays,
    required this.totalDaysRead,
    required this.nextShieldIn,
  });

  static const empty = StreakStatus(
    currentStreak: 0,
    longestStreak: 0,
    readToday: false,
    shields: 0,
    shieldDays: {},
    totalDaysRead: 0,
    nextShieldIn: null,
  );

  /// Dias com leitura na sequência atual (dias protegidos por escudo mantêm a sequência, mas não somam).
  final int currentStreak;
  final int longestStreak;
  final bool readToday;

  /// Escudos disponíveis agora (cumulativos, sem limite).
  final int shields;

  /// Todos os dias, em todo o histórico, em que um escudo protegeu a ofensiva.
  final Set<DateTime> shieldDays;

  /// Quantidade de dias distintos com leitura em todo o histórico.
  final int totalDaysRead;

  /// Dias de leitura que faltam para ganhar o próximo escudo; `null` com escudos desativados.
  final int? nextShieldIn;

  bool get isActive => currentStreak > 0;

  /// Sequência viva, mas hoje ainda sem leitura.
  bool get atRisk => isActive && !readToday;

  StreakStatus copyWithNextShield(int? next) => StreakStatus(
        currentStreak: currentStreak,
        longestStreak: longestStreak,
        readToday: readToday,
        shields: shields,
        shieldDays: shieldDays,
        totalDaysRead: totalDaysRead,
        nextShieldIn: next,
      );
}
