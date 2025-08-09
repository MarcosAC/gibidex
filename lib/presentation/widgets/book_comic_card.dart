import 'package:flutter/material.dart';
import 'package:gibidex/domain/entities/book_comic.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class BookComicCard extends StatelessWidget {
  final BookComic bookComic;
  final ValueChanged<bool?> onToggleReading;
  final ValueChanged<bool?> onToggleWishlist;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onScheduleReminder;

  const BookComicCard({
    super.key,
    required this.bookComic,
    required this.onToggleReading,
    required this.onToggleWishlist,
    required this.onEdit,
    required this.onDelete,
    this.onScheduleReminder,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final hintColor = Theme.of(context).hintColor;

    Widget imageWidget;
    if (bookComic.imageUrl != null && bookComic.imageUrl!.startsWith('http')) {
      imageWidget = FadeInImage.assetNetwork(
        placeholder: '',
        image: bookComic.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 150,
        imageErrorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 150,
            color: Colors.grey[300],
            child: Icon(Icons.broken_image, color: Colors.grey[600]),
          );
        },
      );
    } else if (bookComic.imageUrl != null && File(bookComic.imageUrl!).existsSync()) {
      imageWidget = Image.file(
        File(bookComic.imageUrl!),
        fit: BoxFit.cover,
        width: double.infinity,
        height: 150,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: double.infinity,
            height: 150,
            color: Colors.grey[300],
            child: Icon(Icons.library_books_rounded, color: Colors.grey[600]),
          );
        },
      );
    } else {      
      imageWidget = Container(
        width: double.infinity,
        height: 150,
        color: Theme.of(context).dividerColor.withAlpha(
          ((Theme.of(context).dividerColor.a * 255.0).round() * 0.2).round() & 0xff,
        ),
        child: Icon(Icons.library_books_rounded, size: 50, color: Theme.of(context).hintColor.withAlpha(
          ((Theme.of(context).hintColor.a * 255.0).round() * 0.5).round() & 0xff,
        )),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: const BorderSide(color: Color(0x4DF39C12), width: 0.5),
      ),
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
            child: imageWidget,
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        bookComic.title + (bookComic.edition != null && bookComic.type == 'Gibi' ? ' #${bookComic.edition}' : ''),
                        style: textTheme.headlineMedium!.copyWith(color: hintColor),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.edit, color: hintColor),
                      onPressed: onEdit,
                      tooltip: 'Editar Crônica',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                      onPressed: onDelete,
                      tooltip: 'Banir do Grimório',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Autor: ${bookComic.author}',
                  style: textTheme.bodyLarge,
                ),
                const SizedBox(height: 4),
                Text(
                  'Tipo: ${bookComic.type}',
                  style: textTheme.bodyMedium,
                ),
                if (bookComic.notes != null && bookComic.notes!.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    'Anotações: ${bookComic.notes}',
                    style: textTheme.bodySmall!.copyWith(fontStyle: FontStyle.italic, color: const Color(0x8AFFFFFF)),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: bookComic.isReading,
                            onChanged: onToggleReading,
                            activeColor: const Color(0xFF27AE60),
                            checkColor: Colors.white,
                          ),
                          Expanded(child: Text('Desvendando', style: textTheme.bodyLarge)),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: bookComic.isWishlist,
                            onChanged: onToggleWishlist,
                            activeColor: const Color(0xFF8E44AD),
                            checkColor: Colors.white,
                          ),
                          Expanded(child: Text('Desejo Épico', style: textTheme.bodyLarge)),
                        ],
                      ),
                    ),
                  ],
                ),
                if (bookComic.isReading && bookComic.startDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Iniciado em: ${DateFormat('dd/MM/yyyy').format(bookComic.startDate!)}',
                      style: textTheme.bodySmall!.copyWith(color: const Color(0x99FFFFFF)),
                    ),
                  ),
                if (!bookComic.isReading && bookComic.endDate != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Text(
                      'Concluído em: ${DateFormat('dd/MM/yyyy').format(bookComic.endDate!)}',
                      style: textTheme.bodySmall!.copyWith(color: const Color(0x99FFFFFF)),
                    ),
                  ),
                if (bookComic.isReading && onScheduleReminder != null)
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: onScheduleReminder,
                      icon: Icon(Icons.alarm_add, color: hintColor),
                      label: Text('Agendar Lembrete', style: textTheme.labelLarge!.copyWith(color: hintColor)),
                      style: TextButton.styleFrom(
                        foregroundColor: hintColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}