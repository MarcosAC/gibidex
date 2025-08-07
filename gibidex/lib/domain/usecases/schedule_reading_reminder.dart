import 'package:gibidex/domain/entities/book_comic.dart';
import 'package:gibidex/presentation/services/notification_service.dart';

class ScheduleReadingReminder {
  final NotificationService notificationService;

  ScheduleReadingReminder(this.notificationService);

  Future<void> call(BookComic bookComic, DateTime scheduledTime) async {
    final int notificationId = bookComic.id.hashCode;
    await notificationService.scheduleNotification(
      notificationId,
      'Hora de Ler!',
      'Continue sua leitura de "${bookComic.title}"!',
      scheduledTime,
    );
  }
}