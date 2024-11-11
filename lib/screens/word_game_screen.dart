import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'dart:convert';
import 'dart:math';

class WordGameScreen extends StatefulWidget {
  final String category;
  const WordGameScreen({super.key, required this.category});

  @override
  State<WordGameScreen> createState() => _WordGameScreenState();
}

class _WordGameScreenState extends State<WordGameScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ConfettiController _confettiController;

  // Reklam değişkenleri
  BannerAd? bannerAd;
  bool isAdLoaded = false;

  // Oyun değişkenleri
  late Map<String, dynamic> words;
  late List<String> wordList;
  int currentWordIndex = -1;
  String currentWord = "";
  List<String> currentOptions = [];
  String? answerStatus;
  Color? answerColor;

  // İstatistik değişkenleri
  int correctAnswers = 0;
  int totalAttempts = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    if (!kIsWeb) {
      initBannerAd();
    }
    loadWordsFromJson();
  }

  void _initializeControllers() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 10000),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 1.0, end: 0.0).animate(_animationController);
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 1));
  }

  void initBannerAd() {
    bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ID
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    );
    bannerAd?.load();
  }

  Future<void> loadWordsFromJson() async {
    try {
      String jsonFileName = _getJsonFileName();
      final String jsonString = await DefaultAssetBundle.of(context)
          .loadString('assets/$jsonFileName');
      final List<dynamic> jsonArray = json.decode(jsonString);

      setState(() {
        words = Map<String, dynamic>.from(jsonArray[0]);
        wordList = words.keys.toList()..shuffle();
        if (wordList.isNotEmpty) {
          currentWordIndex = 0;
          currentWord = wordList[currentWordIndex];
          showWord();
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error loading words: $e');
      _showError('Kelimeler yüklenirken bir hata oluştu');
    }
  }

  String _getJsonFileName() {
    switch (widget.category) {
      case 'nouns':
        return 'words.json';
      case 'verbs':
        return 'wordfiil.json';
      case 'adjectives':
        return 'wordsifat.json';
      case 'adverbs':
        return 'wordzarf.json';
      case 'conjunctions':
        return 'wordbaglac.json';
      case 'phrasalVerbs':
        return 'wordpharasalverb.json';
      case 'prepPhrases':
        return 'wordprep.json';
      case 'oxford':
        return 'wordoxford.json';
      default:
        return 'words.json';
    }
  }

  void showWord() {
    if (currentWordIndex >= 0 && currentWordIndex < wordList.length) {
      setState(() {
        currentWord = wordList[currentWordIndex];
        String correctAnswer = words[currentWord];

        currentOptions = [correctAnswer];
        Set<String> usedWords = {currentWord};

        while (currentOptions.length < 3) {
          String randomWord = wordList[Random().nextInt(wordList.length)];
          if (!usedWords.contains(randomWord)) {
            String randomAnswer = words[randomWord];
            if (!currentOptions.contains(randomAnswer)) {
              currentOptions.add(randomAnswer);
              usedWords.add(randomWord);
            }
          }
        }
        currentOptions.shuffle();
      });
    }
  }

  void showNextWord() {
    if (currentWordIndex < wordList.length - 1) {
      setState(() {
        currentWordIndex++;
        showWord();
      });
    } else {
      _showAlert('Bilgi', 'Son kelimeye ulaştınız!');
    }
  }

  void showPreviousWord() {
    if (currentWordIndex > 0) {
      setState(() {
        currentWordIndex--;
        showWord();
      });
    } else {
      _showAlert('Bilgi', 'Bu ilk kelime!');
    }
  }

  void checkAnswer(String selectedAnswer) {
    String correctAnswer = words[currentWord];
    setState(() {
      totalAttempts++;
      if (selectedAnswer == correctAnswer) {
        correctAnswers++;
        answerStatus = "Doğru! ✓";
        answerColor = CupertinoColors.systemGreen;
        _confettiController.play();
        _animationController.forward().then((_) {
          if (mounted) {
            setState(() {
              answerStatus = null;
              _animationController.reset();
              showNextWord();
            });
          }
        });
      } else {
        answerStatus = "Yanlış! ✗";
        answerColor = CupertinoColors.systemRed;
        _animationController.forward().then((_) {
          if (mounted) {
            setState(() {
              answerStatus = null;
              _animationController.reset();
            });
          }
        });
      }
    });
  }

  Future<void> addToBasket() async {
    if (currentWord.isNotEmpty) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final basket = prefs.getStringList('basket') ?? [];
        final wordPair = '$currentWord - ${words[currentWord]}';

        if (!basket.contains(wordPair)) {
          basket.add(wordPair);
          await prefs.setStringList('basket', basket);
          if (mounted) {
            _showAlert('Başarılı', 'Kelime sepete eklendi');
          }
        } else {
          if (mounted) {
            _showAlert('Bilgi', 'Bu kelime zaten sepette');
          }
        }
      } catch (e) {
        _showError('Kelime sepete eklenirken bir hata oluştu');
      }
    }
  }

  void showBasket() {
    Navigator.pushNamed(context, '/basket');
  }

  void _showAlert(String title, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            child: const Text('Tamam'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    if (mounted) {
      showCupertinoDialog(
        context: context,
        builder: (BuildContext context) => CupertinoAlertDialog(
          title: const Text('Hata'),
          content: Text(message),
          actions: [
            CupertinoDialogAction(
              child: const Text('Tamam'),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.category),
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () => Navigator.pop(context),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.home),
          onPressed: () =>
              Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false),
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                if (!kIsWeb && isAdLoaded && bannerAd != null)
                  SizedBox(
                    height: bannerAd!.size.height.toDouble(),
                    width: bannerAd!.size.width.toDouble(),
                    child: AdWidget(ad: bannerAd!),
                  ),
                Expanded(
                  child: isLoading
                      ? const Center(child: CupertinoActivityIndicator())
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                CupertinoColors.systemBlue.withOpacity(0.1),
                                CupertinoColors.white,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              children: [
                                _buildProgressIndicator(),
                                const SizedBox(height: 40),
                                _buildWordCard(),
                                const SizedBox(height: 30),
                                _buildOptions(),
                                const Spacer(),
                                _buildBottomButtons(),
                              ],
                            ),
                          ),
                        ),
                ),
              ],
            ),
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 20,
              gravity: 0.05,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Text(
            '${currentWordIndex + 1}/${wordList.length}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (currentWordIndex + 1) / wordList.length,
                backgroundColor: CupertinoColors.systemGrey.withOpacity(0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  CupertinoColors.activeBlue,
                ),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: CupertinoColors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            currentWord,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (answerStatus != null)
            FadeTransition(
              opacity: _fadeAnimation,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  answerStatus!,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: answerColor,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    return Column(
      children: currentOptions
          .map((option) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: CupertinoButton(
                  padding: const EdgeInsets.all(15),
                  color: CupertinoColors.systemBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  onPressed: () => checkAnswer(option),
                  child: Text(
                    option,
                    style: const TextStyle(
                      color: CupertinoColors.systemBlue,
                      fontSize: 18,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildBottomButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          CupertinoIcons.arrow_left,
          'Önceki',
          showPreviousWord,
          currentWordIndex > 0,
        ),
        _buildActionButton(
          CupertinoIcons.shopping_cart,
          'Sepete Ekle',
          addToBasket,
          true,
        ),
        _buildActionButton(
          CupertinoIcons.bag,
          'Sepet',
          showBasket,
          true,
        ),
        _buildActionButton(
          CupertinoIcons.arrow_right,
          'Sonraki',
          showNextWord,
          currentWordIndex < wordList.length - 1,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onPressed,
    bool isEnabled,
  ) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: isEnabled ? onPressed : null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isEnabled
                ? CupertinoColors.activeBlue
                : CupertinoColors.inactiveGray,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isEnabled
                  ? CupertinoColors.activeBlue
                  : CupertinoColors.inactiveGray,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _confettiController.dispose();
    bannerAd?.dispose();
    super.dispose();
  }
}
