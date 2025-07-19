import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gibidex/domain/entities/book_comic.dart';
import 'package:gibidex/presentation/providers/book_comic_provider.dart';
import 'package:gibidex/presentation/screens/add_edit_book_comic_screen.dart';
//import 'package:gibidex/presentation/widgets/book_comic_card.dart';
import 'package:gibidex/presentation/widgets/book_comic_card.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      Provider.of<BookComicProvider>(context, listen: false).updateSearchQuery(_searchController.text);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _showScheduleReminderDialog(BuildContext context, BookComic bookComic) async {
    // Captura o BuildContext antes de qualquer operação assíncrona
    final BuildContext dialogContext = context;

    DateTime now = DateTime.now();
    DateTime initialDate = DateTime(now.year, now.month, now.day, now.hour + 1, 0);

    DateTime? pickedDate = await showDatePicker(
      context: dialogContext, // Usando o contexto capturado
      initialDate: initialDate,
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: Theme.of(context).hintColor,
              onPrimary: Colors.white,
              surface: Theme.of(context).cardColor,
              onSurface: Colors.white70,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: Theme.of(context).hintColor),
            ),
          ),
          child: child!,
        );
      },
    );

    // Verifica se o widget ainda está montado após a primeira operação assíncrona
    if (!dialogContext.mounted) return;

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: dialogContext, // Usando o contexto capturado
        initialTime: TimeOfDay.fromDateTime(initialDate),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.dark(
                primary: Theme.of(context).hintColor,
                onPrimary: Colors.white,
                surface: Theme.of(context).cardColor,
                onSurface: Colors.white70, // CORRIGIDO: de onOnSurface para onSurface
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(foregroundColor: Theme.of(context).hintColor),
              ),
            ),
            child: child!,
          );
        },
      );

      // Verifica se o widget ainda está montado após a segunda operação assíncrona
      if (!dialogContext.mounted) return;

      if (pickedTime != null) {
        final scheduledTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        if (scheduledTime.isAfter(now)) {
          Provider.of<BookComicProvider>(dialogContext, listen: false) // Usando o contexto capturado
              .scheduleReminder(bookComic, scheduledTime);
          
          // Verifica novamente antes de usar ScaffoldMessenger
          if (!dialogContext.mounted) return;
          ScaffoldMessenger.of(dialogContext).showSnackBar( // Usando o contexto capturado
            SnackBar(
              content: Text(
                'Lembrete agendado para ${bookComic.title} em ${DateFormat('dd/MM/yyyy HH:mm').format(scheduledTime)}',
                style: Theme.of(dialogContext).textTheme.bodyMedium!.copyWith(color: Colors.white), // Usando o contexto capturado
              ),
              backgroundColor: Theme.of(dialogContext).primaryColor, // Usando o contexto capturado
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        } else {
          // Verifica novamente antes de usar ScaffoldMessenger
          if (!dialogContext.mounted) return;
          ScaffoldMessenger.of(dialogContext).showSnackBar( // Usando o contexto capturado
            SnackBar(
              content: Text(
                'A data/hora do lembrete deve ser no futuro.',
                style: Theme.of(dialogContext).textTheme.bodyMedium!.copyWith(color: Colors.white), // Usando o contexto capturado
              ),
              backgroundColor: Colors.redAccent,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GibiDex'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Buscar em sua coleção...',
                    hintStyle: Theme.of(context).inputDecorationTheme.hintStyle,
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: const Color(0xCC2C3E50),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30.0),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                  ),
                  style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white),
                  cursorColor: Theme.of(context).hintColor,
                ),
              ),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Crônicas Atuais'),
                  Tab(text: 'Grimório de Desejos'),
                ],
                labelStyle: Theme.of(context).tabBarTheme.labelStyle,
                unselectedLabelStyle: Theme.of(context).tabBarTheme.unselectedLabelStyle,
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReadingList(context),
          _buildWishlist(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddEditBookComicScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildReadingList(BuildContext context) {
    return Consumer<BookComicProvider>(
      builder: (context, provider, child) {
        final readingItems = provider.readingItems;

        if (readingItems.isEmpty && provider.bookComics.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Nenhum tomo sendo desvendado no momento. Adicione um novo épico!',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (readingItems.isEmpty && provider.bookComics.isNotEmpty) {
           return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Nenhuma crônica encontrada com sua busca. Explore outros reinos!',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: readingItems.length,
          itemBuilder: (context, index) {
            final item = readingItems[index];
            return BookComicCard(
              bookComic: item,
              onToggleReading: (value) => provider.toggleReadingStatus(item),
              onToggleWishlist: (value) => provider.toggleWishlistStatus(item),
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditBookComicScreen(bookComic: item),
                  ),
                );
              },
              onDelete: () => _confirmDelete(context, item),
              onScheduleReminder: () => _showScheduleReminderDialog(context, item),
            );
          },
        );
      },
    );
  }

  Widget _buildWishlist(BuildContext context) {
    return Consumer<BookComicProvider>(
      builder: (context, provider, child) {
        final wishlistItems = provider.wishlistItems;

        if (wishlistItems.isEmpty && provider.bookComics.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Seu Grimório de Desejos está vazio. Que novos contos você anseia?',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          );
        } else if (wishlistItems.isEmpty && provider.bookComics.isNotEmpty) {
           return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Nenhum desejo encontrado com sua busca. O vazio se estende!',
                style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: wishlistItems.length,
          itemBuilder: (context, index) {
            final item = wishlistItems[index];
            return BookComicCard(
              bookComic: item,
              onToggleReading: (value) => provider.toggleReadingStatus(item),
              onToggleWishlist: (value) => provider.toggleWishlistStatus(item),
              onEdit: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditBookComicScreen(bookComic: item),
                  ),
                );
              },
              onDelete: () => _confirmDelete(context, item),
              onScheduleReminder: null,
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, BookComic item) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: Theme.of(context).cardColor,
          title: Text('Banir Tomo?', style: Theme.of(context).textTheme.headlineMedium!.copyWith(color: Theme.of(context).hintColor)),
          content: Text(
            'Tem certeza que deseja apagar "${item.title}" do seu Grimório?',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Manter', style: TextStyle(color: Theme.of(context).hintColor)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Excluir', style: TextStyle(fontFamily: 'Georgia')),
              onPressed: () {
                Provider.of<BookComicProvider>(context, listen: false).removeBookComic(item.id);
                Navigator.of(dialogContext).pop();
              },
            ),
          ],
        );
      },
    );
  }
}