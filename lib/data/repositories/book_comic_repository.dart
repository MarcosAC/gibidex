import 'package:gibidex/domain/entities/book_comic.dart';
import 'package:gibidex/domain/repositories/book_comic_repository.dart';
import 'package:gibidex/data/datasources/book_comic_local_data_source.dart';
import 'dart:async'; // Mantido para StreamController, mas o uso é diferente agora

class BookComicRepositoryImpl implements BookComicRepository {
  final BookComicLocalDataSource localDataSource;

  // StreamController para notificar mudanças na UI (ex: após loadBookComics)
  final StreamController<List<BookComic>> _bookComicsStreamController = StreamController.broadcast();

  BookComicRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<void> addBookComic(BookComic bookComic) async {
    await localDataSource.addBookComic(bookComic);
    // Notifica os ouvintes que a lista foi atualizada (após operação local)
    _bookComicsStreamController.add(await localDataSource.getAllBookComics());
  }

  @override
  Future<List<BookComic>> getAllBookComics() async {
    // Apenas busca dados localmente
    return await localDataSource.getAllBookComics();
  }

  @override
  Future<void> updateBookComic(BookComic bookComic) async {
    await localDataSource.updateBookComic(bookComic);
    // Notifica os ouvintes que a lista foi atualizada (após operação local)
    _bookComicsStreamController.add(await localDataSource.getAllBookComics());
  }

  @override
  Future<void> deleteBookComic(String id) async {
    await localDataSource.deleteBookComic(id);
    // Notifica os ouvintes que a lista foi atualizada (após operação local)
    _bookComicsStreamController.add(await localDataSource.getAllBookComics());
  }

  // Este stream agora é para mudanças locais, mas não é usado diretamente no provider como antes.
  // O provider chama loadBookComics diretamente, que atualiza sua própria lista.
  // No entanto, para conformidade com a interface, ele permanece, mas sem uso prático no estado atual.
  @override
  Stream<List<BookComic>> streamBookComics(String userId) {
    return _bookComicsStreamController.stream;
  }
}