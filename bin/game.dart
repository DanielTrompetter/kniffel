import 'dart:io';
import 'dart:async';
import 'dart:math';

typedef KniffelResult = Map<String, int>;

class GameLogic
{
  KniffelResult humanResult = {};
  KniffelResult computerResult = {};

  GameLogic()
  {
    init();
  }

  KniffelResult createEmptyResult() 
  {
    return {
      'Einser': 0,
      'Zweier': 0,
      'Dreier': 0,
      'Vierer': 0,
      'Fünfer': 0,
      'Sechser': 0,
      'Dreierpasch': 0,
      'Viererpasch': 0,
      'Full House': 0,
      'Kleine Straße': 0,
      'Große Straße': 0,
      'Kniffel': 0,
      'Chance': 0,
    };
  }


  void init()
  {
    humanResult = createEmptyResult();
    computerResult = createEmptyResult();
  }

  // has to be async because of the delayed throw inside!
  Future<List<int>> wurf() async 
  {
    final random = Random();
    List<int> roll = [];
    int roll1 = 0;
    int roll2 = 0;
    int roll3 = 0;
    int roll4 = 0;
    int roll5 = 0;

    for (int i = 0; i < 10; i++) 
    {
      roll1 = random.nextInt(6) + 1; // + 1 to skip zeros
      roll2 = random.nextInt(6) + 1;
      roll3 = random.nextInt(6) + 1;
      roll4 = random.nextInt(6) + 1;
      roll5 = random.nextInt(6) + 1;
      stdout.write('\r$roll1 $roll2 $roll3 $roll4 $roll5 ');
      await Future.delayed(Duration(milliseconds: 200));
    }
    roll.add(roll1);
    roll.add(roll2);
    roll.add(roll3);
    roll.add(roll4);
    roll.add(roll5);
    return roll;
  }

  void Evaluate(List<int> wurf)
  {
    Map<int, int> haeufigkeit = {};
    KniffelResult result = 
    {
      'Kniffel': -1,
      'Vierer': -1,
    };

    // Häufigkeiten zählen
    for (var zahl in wurf) 
    {
      haeufigkeit[zahl] = (haeufigkeit[zahl] ?? 0) + 1;
    }

    // Kombinationen prüfen
    result['Kniffel'] =  haeufigkeit.containsValue(5)? getKniffelWert(wurf):0;
    bool istViererPasch = haeufigkeit.containsValue(4);
    bool istDreierPasch = haeufigkeit.containsValue(3);
    bool istFullHouse = haeufigkeit.containsValue(3) && haeufigkeit.containsValue(2);
    bool istKleineStrasse = testAufKleineStrasse(wurf);
    bool istGrosseStrasse = testAufGrosseStrasse(wurf);

    print("Viererpasch: $istViererPasch");
    print("Dreierpasch: $istDreierPasch");
    print("Full House: $istFullHouse");
    print("Kleine Straße: $istKleineStrasse");
    print("Große Straße: $istGrosseStrasse");
    print("Chance: ${wurf.reduce((a, b) => a + b)}");
  }

  bool testAufKleineStrasse(List<int> wurf) 
  {
    var unique = wurf.toSet().toList()..sort();
    var strassen = 
    [
      [1, 2, 3, 4],
      [2, 3, 4, 5],
      [3, 4, 5, 6],
    ];
    return strassen.any((s) => s.every((z) => unique.contains(z)));
  }

  bool testAufGrosseStrasse(List<int> wurf) {
    var sorted = wurf.toSet().toList()..sort();
    return sorted.length == 5 &&
          (sorted.join() == '12345' || sorted.join() == '23456');
  }

  int getKniffelWert(List<int> wurf)
  {
    int result = 0;
    for(int a in wurf)
    {
      result += a;
    }
    return result;
  }
}