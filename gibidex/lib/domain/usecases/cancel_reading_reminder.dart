import 'package:gibidex/domain/entities/book_comic.dart';
import 'package:gibidex/presentation/services/notification_service.dart';

class CancelReadingReminder {
  final NotificationService notificationService;

  CancelReadingReminder(this.notificationService);

  Future<void> call(BookComic bookComic) async {
    final int notificationId = bookComic.id.hashCode;
    await notificationService.cancelNotification(notificationId);
  }
}