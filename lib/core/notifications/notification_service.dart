import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../database/app_database.dart';

/// Notificações locais (sem servidor): lembrete diário de leitura e
/// "Há N anos você recitou…" no aniversário de cada recitativo.
class NotificationService {
  NotificationService([FlutterLocalNotificationsPlugin? plugin])
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const int _dailyReminderId = 1;
  static const int _memoryIdBase = 100000;
  static const int _memoryHour = 8;

  static const _readingChannel = AndroidNotificationDetails(
    'daily_reading',
    'Lembrete de leitura',
    channelDescription: 'Lembrete diário para ler a Bíblia',
    importance: Importance.high,
    priority: Priority.high,
  );

  static const _memoryChannel = AndroidNotificationDetails(
    'recitative_memories',
    'Lembranças de recitativos',
    channelDescription: 'Aniversário dos versos que você recitou',
  );

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  /// Só Android e iOS recebem notificações neste app.
  bool get isSupported =>
      !kIsWeb && (defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS);

  Future<void> init() async {
    if (_initialized || !isSupported) return;
    tz_data.initializeTimeZones();
    try {
      final info = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(info.identifier));
    } on Exception {
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  /// Pede permissão ao sistema (Android 13+ / iOS). Retorna se foi concedida.
  Future<bool> requestPermission() async {
    if (!isSupported) return false;
    await init();
    if (defaultTargetPlatform == TargetPlatform.android) {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    return await ios?.requestPermissions(alert: true, badge: true, sound: true) ?? false;
  }

  Future<void> scheduleDailyReminder({required int hour, required int minute}) async {
    if (!isSupported) return;
    await init();
    final now = tz.TZDateTime.now(tz.local);
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) next = next.add(const Duration(days: 1));
    await _plugin.zonedSchedule(
      id: _dailyReminderId,
      scheduledDate: next,
      title: 'Hora da leitura bíblica 📖',
      body: 'Separe um tempo com a Palavra e mantenha sua ofensiva!',
      notificationDetails: const NotificationDetails(android: _readingChannel, iOS: DarwinNotificationDetails()),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelDailyReminder() async {
    if (!isSupported) return;
    await init();
    await _plugin.cancel(id: _dailyReminderId);
  }

  /// Agenda a próxima lembrança (até 1 ano à frente) de cada recitativo.
  /// Reagendado a cada abertura do app e a cada alteração nos recitativos,
  /// para que o "Há N anos" fique sempre correto.
  Future<void> syncRecitativeAnniversaries(List<RecitativeWithBook> items) async {
    if (!isSupported) return;
    await cancelRecitativeAnniversaries();
    final now = tz.TZDateTime.now(tz.local);
    for (final item in items) {
      final service = item.recitative.serviceDate;
      var year = now.year;
      var fireAt = tz.TZDateTime(tz.local, year, service.month, service.day, _memoryHour);
      if (!fireAt.isAfter(now)) {
        year++;
        fireAt = tz.TZDateTime(tz.local, year, service.month, service.day, _memoryHour);
      }
      final yearsAgo = year - service.year;
      if (yearsAgo < 1) continue;
      await _plugin.zonedSchedule(
        id: _memoryIdBase + _stableSlot(item.recitative.id),
        scheduledDate: fireAt,
        title: yearsAgo == 1 ? 'Há 1 ano, neste dia' : 'Há $yearsAgo anos, neste dia',
        body: 'Você recitou ${item.reference}: "${_excerpt(item.recitative.verseTextSnapshot)}"',
        notificationDetails: const NotificationDetails(android: _memoryChannel, iOS: DarwinNotificationDetails()),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  Future<void> cancelRecitativeAnniversaries() async {
    if (!isSupported) return;
    await init();
    final pending = await _plugin.pendingNotificationRequests();
    for (final p in pending.where((p) => p.id >= _memoryIdBase)) {
      await _plugin.cancel(id: p.id);
    }
  }

  /// Número estável (0..999.999) derivado do UUID do recitativo (FNV-1a),
  /// para o id da notificação ser o mesmo a cada reagendamento.
  static int _stableSlot(String id) {
    var hash = 0x811c9dc5;
    for (final unit in id.codeUnits) {
      hash = ((hash ^ unit) * 0x01000193) & 0xffffffff;
    }
    return hash % 1000000;
  }

  static String _excerpt(String text) => text.length <= 90 ? text : '${text.substring(0, 87)}…';
}

