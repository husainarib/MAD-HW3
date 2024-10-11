import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Matching Game'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: 16,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                // TODO IMPLEMENT FLIP
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  image: const DecorationImage(
                    image: AssetImage("lib/img/card_back.png"),
                    fit: BoxFit.contain,
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

// data model for the cards
class CardModel {
  final String cardFront;
  bool isFaceUp;

  CardModel({required this.cardFront, this.isFaceUp = false});
}

// manages the state of the card
class CardProvider extends ChangeNotifier {
  List<CardModel> cards = List.generate(
    16,
    (index) => CardModel(cardFront: 'Card $index'),
  );

  int? firstFlippedCardPos;

// card flipping and matching logic
  void flipCard(int index) {
    if (!cards[index].isFaceUp) {
      // check if card tapped on is the first card tapped on
      if (firstFlippedCardPos == null) {
        firstFlippedCardPos = index;
      } else {
        // if this is the second card being tapped on, check for a match
        if (cards[firstFlippedCardPos!].cardFront == cards[index].cardFront) {
          // if its a match leave both cards face up
          firstFlippedCardPos = null;
        } else {
          cards[firstFlippedCardPos!].isFaceUp = false;
          cards[index].isFaceUp = false;
          firstFlippedCardPos = null;
        }
      }
    }
    cards[index].isFaceUp = !cards[index].isFaceUp;
    notifyListeners();
  }
}
