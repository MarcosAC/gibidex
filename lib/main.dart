import 'package:flutter/material.dart';
import 'package:gibidex/presentation/providers/book_comic_provider.dart';
import 'package:gibidex/presentation/screens/home_screen.dart';
import 'package:gibidex/presentation/services/notification_service.dart';
import 'package:provider/provider.dart';

// import 'package:gibidex/presentation/screens/home_screen.dart';
// import 'package:gibidex/presentation/providers/book_comic_provider.dart';
import 'package:gibidex/di.dart';
// import 'package:book_comic_manager/presentation/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator(); // Configura todas as dependências com GetIt

  // Inicializa as notificações
  await locator<NotificationService>().initializeNotifications();

  runApp(
    ChangeNotifierProvider( // Usa ChangeNotifierProvider para expor o BookComicProvider
      create: (_) => locator<BookComicProvider>()..loadBookComics(), // Obtém a instância do provider via GetIt
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GibiDex',
      theme: ThemeData(
        // Paleta de Cores do Grimório: Tons escuros, dourado e detalhes em tons de joia
        primaryColor: const Color(0xFF2C3E50), // Azul petróleo escuro
        hintColor: const Color(0xFFF39C12), // Dourado/Âmbar para destaque
        scaffoldBackgroundColor: const Color(0xFF212F3D), // Fundo quase preto    
        cardColor: const Color(0xFF34495E), // Azul acinzentado escuro para cards
        dividerColor: const Color(0xFF7F8C8D), // Cinza para divisores
        shadowColor: const Color(0x80000000), // Sombra para profundidade

        // Estilo da AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2C3E50), // Fundo da AppBar igual ao primaryColor
          foregroundColor: Colors.white, // Cor do texto e ícones na AppBar
          centerTitle: true,
          elevation: 8,
          titleTextStyle: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // Estilo do FloatingActionButton
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xFFF39C12), // Dourado para o FAB
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0))),
          elevation: 8,
        ),

        // Estilo do Card (Grimório/Tomo)
        cardTheme: CardThemeData(
          elevation: 6, // Maior elevação para destaque
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // Cantos arredondados
            side: const BorderSide(color: Color(0xFF7F8C8D), width: 0.5), // Borda sutil
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: const Color(0xFF34495E), // Cor do card
        ),

        // Estilo do Texto
        textTheme: const TextTheme(
          headlineLarge: TextStyle( // Título principal
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            fontSize: 26,
            color: Color(0xFFF39C12), // Título em dourado
          ),
          headlineMedium: TextStyle( // Subtítulos/Nomes em destaque
            fontFamily: 'Georgia',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
          bodyLarge: TextStyle( // Corpo de texto principal
            fontFamily: 'Georgia',
            fontSize: 16,
            color: Colors.white70,
          ),
          bodyMedium: TextStyle( // Texto secundário/detalhes
            fontFamily: 'Georgia',
            fontSize: 14,
            color: Colors.white60,
          ),
          labelLarge: TextStyle( // Botões e labels maiores
            fontFamily: 'Georgia',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),

        // Estilo do Botão Elevado
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF39C12), // Cor do botão em dourado
            foregroundColor: Colors.white, // Cor do texto do botão
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Cantos arredondados
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
            elevation: 5,
            textStyle: const TextStyle(
              fontFamily: 'Georgia',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Estilo dos Campos de Texto
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C3E50), // Fundo do campo em azul petróleo
          labelStyle: const TextStyle(color: Color(0xFFF39C12), fontFamily: 'Georgia'), // Label em dourado
          hintStyle: TextStyle(color: Color(0x80000000), fontFamily: 'Georgia'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF7F8C8D)), // Borda sutil
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFFF39C12), width: 2), // Borda focada em dourado
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: Color(0xFF7F8C8D)),
          ),
          prefixIconColor: const Color(0xFFF39C12), // Ícones de prefixo em dourado
        ),

        // Estilo dos Checkboxes e Switches
        checkboxTheme: CheckboxThemeData(
          fillColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0xFF27AE60); // Verde para 'Lendo'
              }
              return const Color(0xFF7F8C8D); // Cinza para não selecionado
            },
          ),
          checkColor: MaterialStateProperty.all(Colors.white),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0xFF8E44AD); // Roxo para 'Desejo'
              }
              return const Color(0xFF7F8C8D);
            },
          ),
          trackColor: MaterialStateProperty.resolveWith<Color>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.selected)) {
                return const Color(0x998E44AD); // Roxo translúcido
              }
              return const Color(0x997F8C8D);
            },
          ),
        ),

        // Estilo das TabBar
        tabBarTheme: TabBarThemeData(
          labelStyle: const TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Georgia',
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: const Color(0xB3FFFFFF),
          ),
          indicator: UnderlineTabIndicator( // Indicador de aba
            borderSide: BorderSide(width: 4.0, color: Theme.of(context).hintColor),
          ),
        ),

        colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.blueGrey).copyWith(
          secondary: const Color(0xFFF39C12), // Cor de destaque dourada
          surface: const Color(0xFF34495E), // Superfícies (cards)
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
