import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CardProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Matching Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String cardBack = "lib/img/card_back.png";
  @override
  Widget build(BuildContext context) {
    final cardProvider = Provider.of<CardProvider>(context);
    // variables to control sizing
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double cardSize = min(screenWidth / 4.5, screenHeight / 8);
    ScrollController scrollController = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Scrollbar(
          controller: scrollController,
          thumbVisibility: true,
          thickness: 10,
          radius: const Radius.circular(10),
          trackVisibility: true,
          scrollbarOrientation: ScrollbarOrientation.right,
          child: GridView.builder(
            controller: scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: cardProvider.cards.length,
            itemBuilder: (context, index) {
              final card = cardProvider.cards[index];

              return GestureDetector(
                onTap: () {
                  cardProvider.flipCard(index);
                },
                // animation
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder:
                      (Widget child, Animation<double> animation) {
                    return AnimatedBuilder(
                      animation: animation,
                      builder: (context, child) {
                        final rotationY = animation.value * pi;
                        return Transform(
                          transform: Matrix4.identity()..rotateY(rotationY),
                          alignment: Alignment.center,
                          child: rotationY >= pi / 2
                              ? Transform(
                                  transform: Matrix4.identity()..rotateY(pi),
                                  alignment: Alignment.center,
                                  child: child,
                                )
                              : child,
                        );
                      },
                      child: child,
                    );
                  },
                  child: card.isFaceUp
                      ? Container(
                          key: const ValueKey(true),
                          width: cardSize,
                          height: cardSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.black, width: 5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              card.cardNum,
                              style: TextStyle(
                                fontSize: cardSize / 2.5,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        )
                      : Container(
                          key: const ValueKey(false),
                          width: cardSize,
                          height: cardSize,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.transparent, width: 10),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Image.asset(
                            "lib/img/card_back.png",
                            fit: BoxFit.contain,
                            height: cardSize,
                            width: cardSize,
                          ),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// data model for cards
class CardModel {
  final String cardNum;
  bool isFaceUp;

  CardModel({required this.cardNum, this.isFaceUp = false});
}

class CardProvider extends ChangeNotifier {
  List<CardModel> cards = [];

  int? firstFlippedCardPos;
  bool isMatch = false;

  CardProvider() {
    _initializeCards();
  }

  // create cards with random numbers
  void _initializeCards() {
    List<String> cardNums = List.generate(8, (index) => '${index + 1}');
    cardNums = [...cardNums, ...cardNums];
    // shuffle cards around the screen
    cardNums.shuffle(Random());
    cards = cardNums.map((number) => CardModel(cardNum: number)).toList();
  }

  // flipCard method to match cards
  void flipCard(int index) {
    if (isMatch || cards[index].isFaceUp) return;
    cards[index].isFaceUp = true;

    if (firstFlippedCardPos == null) {
      firstFlippedCardPos = index;
    } else {
      // checks if the second card matches with first card up
      if (cards[firstFlippedCardPos!].cardNum == cards[index].cardNum) {
        // keep both cards face-up
        firstFlippedCardPos = null;
      } else {
        // flip both cards back to show back of card
        isMatch = true;
        // delay to keep card with face up, visible when another card is tapped
        Future.delayed(const Duration(milliseconds: 500), () {
          // flip both cards back to original position
          cards[firstFlippedCardPos!].isFaceUp = false;
          cards[index].isFaceUp = false;
          firstFlippedCardPos = null;
          isMatch = false;
          notifyListeners();
        });
      }
    }
    notifyListeners();
  }
}
