import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'screens/word_game_screen.dart';
import 'screens/basket_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    MobileAds.instance.initialize();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      debugShowCheckedModeBanner: false,
      title: 'YDS App',
      theme: const CupertinoThemeData(
        primaryColor: CupertinoColors.systemBlue,
        brightness: Brightness.light,
        scaffoldBackgroundColor: CupertinoColors.systemBackground,
      ),
      home: const MainActivity(),
      routes: {
        '/word-game': (context) => const WordGameScreen(category: 'nouns'),
        '/word-game-fiil': (context) => const WordGameScreen(category: 'verbs'),
        '/word-game-sifat': (context) =>
            const WordGameScreen(category: 'adjectives'),
        '/word-game-zarf': (context) =>
            const WordGameScreen(category: 'adverbs'),
        '/word-game-baglac': (context) =>
            const WordGameScreen(category: 'conjunctions'),
        '/word-game-phrasal': (context) =>
            const WordGameScreen(category: 'phrasalVerbs'),
        '/word-game-prep': (context) =>
            const WordGameScreen(category: 'prepPhrases'),
        '/word-game-oxford': (context) =>
            const WordGameScreen(category: 'oxford'),
        '/basket': (context) => const BasketScreen(),
      },
    );
  }
}

class MainActivity extends StatelessWidget {
  const MainActivity({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'name': 'Nouns',
        'route': '/word-game',
        'icon': CupertinoIcons.book,
        'color': CupertinoColors.systemBlue,
      },
      {
        'name': 'Verbs',
        'route': '/word-game-fiil',
        'icon': CupertinoIcons.arrow_right_arrow_left,
        'color': CupertinoColors.systemGreen,
      },
      {
        'name': 'Adjectives',
        'route': '/word-game-sifat',
        'icon': CupertinoIcons.textformat_abc,
        'color': CupertinoColors.systemIndigo,
      },
      {
        'name': 'Adverbs',
        'route': '/word-game-zarf',
        'icon': CupertinoIcons.text_quote,
        'color': CupertinoColors.systemOrange,
      },
      {
        'name': 'Conjunctions',
        'route': '/word-game-baglac',
        'icon': CupertinoIcons.link,
        'color': CupertinoColors.systemPink,
      },
      {
        'name': 'Phrasal Verbs',
        'route': '/word-game-phrasal',
        'icon': CupertinoIcons.arrow_2_circlepath,
        'color': CupertinoColors.systemPurple,
      },
      {
        'name': 'Prep Phrases',
        'route': '/word-game-prep',
        'icon': CupertinoIcons.text_aligncenter,
        'color': CupertinoColors.systemTeal,
      },
      {
        'name': 'Oxford',
        'route': '/word-game-oxford',
        'icon': CupertinoIcons.book_fill,
        'color': CupertinoColors.systemRed,
      },
    ];

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('YDS App'),
      ),
      child: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CupertinoColors.systemGrey6,
                CupertinoColors.white,
              ],
            ),
          ),
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.1,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final category = categories[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(
                              context, category['route'] as String);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: (category['color'] as Color)
                                    .withOpacity(0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: (category['color'] as Color)
                                      .withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  category['icon'] as IconData,
                                  color: category['color'] as Color,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                category['name'] as String,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: categories.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
