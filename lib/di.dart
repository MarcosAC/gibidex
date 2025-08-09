import 'package:get_it/get_it.dart';
import 'package:uuid/uuid.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'package:gibidex/data/datasources/book_comic_local_data_source.dart';
// import 'package:gibidex/data/datasources/book_comic_remote_data_source.dart'; // Removido
import 'package:gibidex/data/repositories/book_comic_repository.dart';
import 'package:gibidex/domain/repositories/book_comic_repository.dart';
import 'package:gibidex/domain/usecases/add_book_comic.dart';
import 'package:gibidex/domain/usecases/get_all_book_comic.dart';
import 'package:gibidex/domain/usecases/update_book_comic.dart';
import 'package:gibidex/domain/usecases/delete_book_comic.dart';
// import 'package:gibidex/domain/usecases/sign_in_anonymously.dart'; // Removido
// import 'package:gibidex/domain/usecases/sign_out.dart'; // Removido
import 'package:gibidex/domain/usecases/schedule_reading_reminder.dart';
import 'package:gibidex/domain/usecases/cancel_reading_reminder.dart';
import 'package:gibidex/presentation/providers/book_comic_provider.dart';
import 'package:gibidex/presentation/services/notification_service.dart';
import 'package:gibidex/core/app_constants.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Inicialização do Hive
  await Hive.initFlutter();
  final bookComicBox = await Hive.openBox<String>(AppConstants.allItemsBoxName);
  locator.registerSingleton<Box<String>>(bookComicBox);

  // Inicialização do Fuso Horário para Notificações
  tz.initializeTimeZones();

  // Removido: Firebase Instances
  // locator.registerLazySingleton(() => FirebaseAuth.instance);
  // locator.registerLazySingleton(() => FirebaseFirestore.instance);

  // Notifications
  locator.registerLazySingleton(() => FlutterLocalNotificationsPlugin());
  locator.registerLazySingleton(() => NotificationService(locator()));

  // Datasources
  locator.registerLazySingleton<BookComicLocalDataSource>(
    () => BookComicLocalDataSourceImpl(bookComicBox: locator()),
  );
  // Removido: Remote DataSource
  // locator.registerLazySingleton<BookComicRemoteDataSource>(
  //   () => BookComicFirebaseDataSourceImpl(firestore: locator(), auth: locator()),
  // );

  // Repositórios
  locator.registerLazySingleton<BookComicRepository>(
    () => BookComicRepositoryImpl(
      localDataSource: locator(),
      // Removido: remoteDataSource, auth
    ),
  );

  // Casos de Uso
  locator.registerLazySingleton(() => AddBookComic(locator()));
  locator.registerLazySingleton(() => GetAllBookComics(locator()));
  locator.registerLazySingleton(() => UpdateBookComic(locator()));
  locator.registerLazySingleton(() => DeleteBookComic(locator()));
  // Removido: Casos de uso de autenticação Firebase
  // locator.registerLazySingleton(() => SignInAnonymously(locator()));
  // locator.registerLazySingleton(() => SignOut(locator()));
  locator.registerLazySingleton(() => ScheduleReadingReminder(locator()));
  locator.registerLazySingleton(() => CancelReadingReminder(locator()));

  // Provedores (ViewModels)
  locator.registerLazySingleton(
    () => BookComicProvider(
      addBookComicUseCase: locator(),
      getAllBookComicsUseCase: locator(),
      updateBookComicUseCase: locator(),
      deleteBookComicUseCase: locator(),
      // Removido: Casos de uso de autenticação Firebase
      // signInAnonymouslyUseCase: locator(),
      // signOutUseCase: locator(),
      scheduleReadingReminderUseCase: locator(),
      cancelReadingReminderUseCase: locator(),
      uuid: locator(),
      // Removido: auth
    ),
  );

  // Utilitários
  locator.registerLazySingleton(() => Uuid());
}