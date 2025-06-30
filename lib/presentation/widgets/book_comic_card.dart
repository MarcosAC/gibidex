import 'package:flutter/material.dart';
import 'package:gibidex/domain/entities/book_comic.dart';
import 'package:intl/intl.dart';

class BookComicCard extends StatelessWidget {
  final BookComic bookComic;
  final ValueChanged<bool> onToggleReading;
  final ValueChanged<bool> onToggleWishlist;
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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      elevation: 6,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: hintColor.withOpacity(0.3), width: 0.5),
      ),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    bookComic.title,
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
                style: textTheme.bodySmall!.copyWith(fontStyle: FontStyle.italic, color: Colors.white54),
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
                      Text('Desvendando', style: textTheme.bodyLarge),
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
                      Text('Desejo Épico', style: textTheme.bodyLarge),
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
                  style: textTheme.bodySmall!.copyWith(color: Colors.white60),
                ),
              ),
            if (!bookComic.isReading && bookComic.endDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  'Concluído em: ${DateFormat('dd/MM/yyyy').format(bookComic.endDate!)}',
                  style: textTheme.bodySmall!.copyWith(color: Colors.white60),
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
    );
  }
}