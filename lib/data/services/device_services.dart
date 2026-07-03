import 'package:flutter/services.dart';
import 'package:memox_v4/core/error/failure.dart';
import 'package:memox_v4/core/error/result.dart';
import 'package:memox_v4/domain/entities/reminder.dart';
import 'package:memox_v4/domain/services/audio_service.dart';
import 'package:memox_v4/domain/services/backup_restore_service.dart';
import 'package:memox_v4/domain/services/import_export_file_service.dart';
import 'package:memox_v4/domain/services/reminder_notification_service.dart';

/// Text-to-speech adapter (DT.7). **The TTS plugin is deferred** — `speak`/`stop`
/// are best-effort no-ops that succeed (audio is never load-bearing; a failure is
/// only ever logged, never surfaced). The contract is satisfied so screens depend
/// on the seam, not a plugin; a real `flutter_tts` adapter drops in here later.
class NoopAudioService implements AudioService {
  const NoopAudioService();

  @override
  Future<Result<void>> speak(String text, {required String languageCode}) async =>
      const Ok<void>(null);

  @override
  Future<Result<void>> stop() async => const Ok<void>(null);
}

/// Local-notification adapter (DT.7). **The notifications plugin is deferred** —
/// there is no permission to grant and nothing is scheduled yet; the methods are
/// no-ops that report "no permission" so the reminder UI stays honest. A real
/// `flutter_local_notifications` adapter drops in here later.
class NoopReminderNotificationService implements ReminderNotificationService {
  const NoopReminderNotificationService();

  @override
  Future<Result<bool>> hasPermission() async => const Ok(false);

  @override
  Future<Result<bool>> requestPermission() async => const Ok(false);

  @override
  Future<Result<void>> schedule(Reminder reminder) async => const Ok<void>(null);

  @override
  Future<Result<void>> cancelAll() async => const Ok<void>(null);
}

/// Import/export IO adapter (DT.7). **Clipboard is fully implemented** (via the
/// framework `Clipboard`); the **file picker / share sheet is deferred** (no
/// `file_picker`/`share_plus` plugin) — `pickTextFile` reports no selection and
/// `writeTextFile` reports the file path is unavailable, so import/export via
/// clipboard works and via file is a documented, localized "unavailable".
class ClipboardImportExportFileService implements ImportExportFileService {
  const ClipboardImportExportFileService();

  @override
  Future<Result<String?>> pickTextFile() async => const Ok(null);

  @override
  Future<Result<void>> writeTextFile({
    required String suggestedName,
    required String content,
  }) async =>
      const Err(ServiceFailure('File export is unavailable on this build'));

  @override
  Future<Result<String>> readClipboard() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    return Ok(data?.text ?? '');
  }

  @override
  Future<Result<void>> writeClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    return const Ok<void>(null);
  }
}

/// Backup/restore adapter (DT.7). **Local backup is deferred** (D-027 snapshot
/// level not yet built) — both methods report a localized "unavailable" so the
/// settings UI stays honest; a local-file snapshot adapter drops in here later.
class DeferredBackupRestoreService implements BackupRestoreService {
  const DeferredBackupRestoreService();

  @override
  Future<Result<String>> createBackup() async =>
      const Err(ServiceFailure('Backup is unavailable on this build'));

  @override
  Future<Result<void>> restoreBackup(String source) async =>
      const Err(ServiceFailure('Restore is unavailable on this build'));
}
