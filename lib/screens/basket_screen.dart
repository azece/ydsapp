import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  List<String> basketWords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadBasketWords();
  }

  Future<void> loadBasketWords() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      basketWords = prefs.getStringList('basket') ?? [];
      isLoading = false;
    });
  }

  Future<void> removeWord(String word) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      basketWords.remove(word);
    });
    await prefs.setStringList('basket', basketWords);
  }

  Future<void> clearBasket() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      basketWords.clear();
    });
    await prefs.setStringList('basket', basketWords);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Kelime Sepetim'),
        trailing: basketWords.isNotEmpty
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.trash),
                onPressed: () {
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Sepeti Temizle'),
                      content: const Text(
                          'Tüm kelimeleri silmek istediğinize emin misiniz?'),
                      actions: [
                        CupertinoDialogAction(
                          isDestructiveAction: true,
                          onPressed: () {
                            clearBasket();
                            Navigator.pop(context);
                          },
                          child: const Text('Evet'),
                        ),
                        CupertinoDialogAction(
                          child: const Text('İptal'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  );
                },
              )
            : null,
      ),
      child: SafeArea(
        child: isLoading
            ? const Center(child: CupertinoActivityIndicator())
            : basketWords.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.bag,
                          size: 64,
                          color: CupertinoColors.systemGrey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Sepetiniz boş',
                          style: TextStyle(
                            fontSize: 20,
                            color: CupertinoColors.systemGrey,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: basketWords.length,
                    itemBuilder: (context, index) {
                      final word = basketWords[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: CupertinoColors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color:
                                    CupertinoColors.systemGrey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: CupertinoListTile(
                            title: Text(word),
                            trailing: CupertinoButton(
                              padding: EdgeInsets.zero,
                              child: const Icon(
                                CupertinoIcons.delete,
                                color: CupertinoColors.destructiveRed,
                              ),
                              onPressed: () => removeWord(word),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
