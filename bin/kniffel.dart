import 'dart:io';
import 'dart:math';

enum Players { human, computer }

enum FieldValue
{
  einser,
  zweier,
  dreier,
  vierer,
  fuenfer,
  sechser,
  dreierpasch,
  viererpasch,
  fullHouse,
  kleineStrasse,
  grosseStrasse,
  kniffel,
  chance,
}

Map<FieldValue, String> fieldNames = 
{
  FieldValue.einser: "Einser",
  FieldValue.zweier: "Zweier",
  FieldValue.dreier: "Dreier",
  FieldValue.vierer: "Vierer",
  FieldValue.fuenfer: "Fünfer",
  FieldValue.sechser: "Sechser",
  FieldValue.dreierpasch: "Dreier Pasch",
  FieldValue.viererpasch: "Vierer Pasch",
  FieldValue.fullHouse: "Full House",
  FieldValue.kleineStrasse: "Kleine Straße",
  FieldValue.grosseStrasse: "Große Straße",
  FieldValue.kniffel: "Kniffel",
  FieldValue.chance: "Chance",
};

 Map<FieldValue, int> humanResult = {};
 Map<FieldValue, int> computerResult = {};

void emptyResults() 
{
  humanResult = {
    FieldValue.einser: 0,
    FieldValue.zweier: 0,
    FieldValue.dreier: 0,
    FieldValue.vierer: 0,
    FieldValue.fuenfer: 0,
    FieldValue.sechser: 0,
    FieldValue.dreierpasch: 0,
    FieldValue.viererpasch: 0,
    FieldValue.fullHouse: 0,
    FieldValue.kleineStrasse: 0,
    FieldValue.grosseStrasse: 0,
    FieldValue.kniffel: 0,
    FieldValue.chance: 0,
  };

  computerResult = {
    FieldValue.einser: 0,
    FieldValue.zweier: 0,
    FieldValue.dreier: 0,
    FieldValue.vierer: 0,
    FieldValue.fuenfer: 0,
    FieldValue.sechser: 0,
    FieldValue.dreierpasch: 0,
    FieldValue.viererpasch: 0,
    FieldValue.fullHouse: 0,
    FieldValue.kleineStrasse: 0,
    FieldValue.grosseStrasse: 0,
    FieldValue.kniffel: 0,
    FieldValue.chance: 0,
  };
}

// erzeugt eine Liste mit 5 Random-Werten und zeigt das "animiert" an
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
    stdout.write('\r$roll1 $roll2 $roll3 $roll4 $roll5 '); // \r für Repeat also wieder zurück an Zeilenanfang!
    await Future.delayed(Duration(milliseconds: 200)); // damit es etwas nach "würfeln" aussieht xD
  }
  roll.add(roll1);
  roll.add(roll2);
  roll.add(roll3);
  roll.add(roll4);
  roll.add(roll5);
  return roll;
}

// wertet den aktuellen wurf aus und gibt dem Player einige Auswahlmöglichkeiten
void evaluate(Players player, List<int> wurf)
{
  Map<int, int> haeufigkeit = {};

  // Häufigkeiten zählen
  for (var zahl in wurf) {
    haeufigkeit[zahl] = (haeufigkeit[zahl] ?? 0) + 1;
  }

  Map<FieldValue, int> availableCheck = {};
   Map<FieldValue, int> result = player == Players.human ? humanResult : computerResult;

  // Obere Hälfte
  availableCheck[FieldValue.einser] = (wurf.contains(1) && result[FieldValue.einser] == 0) ? haeufigkeit[1]! * 1 : 0;
  availableCheck[FieldValue.zweier] = (wurf.contains(2) && result[FieldValue.zweier] == 0) ? haeufigkeit[2]! * 2 : 0;
  availableCheck[FieldValue.dreier] = (wurf.contains(3) && result[FieldValue.dreier] == 0) ? haeufigkeit[3]! * 3 : 0;
  availableCheck[FieldValue.vierer] = (wurf.contains(4) && result[FieldValue.vierer] == 0) ? haeufigkeit[4]! * 4 : 0;
  availableCheck[FieldValue.fuenfer] = (wurf.contains(5) && result[FieldValue.fuenfer] == 0) ? haeufigkeit[5]! * 5 : 0;
  availableCheck[FieldValue.sechser] = (wurf.contains(6) && result[FieldValue.sechser] == 0) ? haeufigkeit[6]! * 6 : 0;

  // Untere Hälfte
  availableCheck[FieldValue.kniffel] = haeufigkeit.containsValue(5) && result[FieldValue.kniffel] == 0?50:0;
  availableCheck[FieldValue.viererpasch] = (testAufViererPasch(haeufigkeit)!=0 && result[FieldValue.viererpasch] == 0) ? testAufViererPasch(haeufigkeit):0;
  availableCheck[FieldValue.dreierpasch] =  (testAufDreierPasch(haeufigkeit)!=0 && result[FieldValue.dreierpasch] == 0) ? testAufDreierPasch(haeufigkeit):0;
  availableCheck[FieldValue.fullHouse] = (haeufigkeit.containsValue(3) && haeufigkeit.containsValue(2)) && result[FieldValue.fullHouse] == 0?25:0;
  availableCheck[FieldValue.kleineStrasse] = testAufKleineStrasse(wurf) && result[FieldValue.kleineStrasse] == 0?30:0;
  availableCheck[FieldValue.grosseStrasse] = testAufGrosseStrasse(wurf) && result[FieldValue.grosseStrasse] == 0?40:0;
  availableCheck[FieldValue.chance] = result[FieldValue.chance] == 0 ? wurf.reduce((a, b) => a + b) : 0;

  if (player == Players.human) 
  {
    Map<String, FieldValue> availableSelections = {};
    int selectnumber = 1;

    bool somethingAvailable = false;
    for (var value in availableCheck.values) {
      if (value != 0) {
        somethingAvailable = true;
        break;
      }
    }

    if (!somethingAvailable) 
    {
      print("\nKeine gültigen Kombinationen verfügbar");
      for(FieldValue fv in result.keys)
      {
        if(result[fv] == 0)
        {
          availableCheck[fv] = -1; 
          availableSelections[selectnumber.toString()] = fv;
          print('($selectnumber) für ${fieldNames[fv]}');
          selectnumber++;
        }
      }
      print("\nWähle welches Feld du streichen möchtest!");
    }
    else
    {
      print('\nGebe ein, was davon in die Wertung übernommen werden soll:');
      for (FieldValue key in availableCheck.keys) 
      {
        if (availableCheck[key]! > 0) 
        {
          availableSelections[selectnumber.toString()] = key;
          print('($selectnumber) für ${fieldNames[key]} ${availableCheck[key]} Punkte');
          selectnumber++;
        }
      }
    }

    // get selection from Player
    bool goodInput = false;
    String inputValue = '';
    while(!goodInput)
    {
      stdout.write("Deine Auswahl: ");
      String? input = stdin.readLineSync()?.trim();
      if (input == null || !availableSelections.containsKey(input)) 
      {
        print("Ungültige Eingabe. Bitte gib eine Zahl aus der Liste ein.");
      }
      else
      {
        inputValue = input;
        goodInput = true;
      }
    }

    FieldValue choosen = availableSelections[inputValue]!;
    result[choosen] = availableCheck[choosen]!;
    if(result[choosen]! > 0)
    {
      print("Du hast ${fieldNames[choosen]} gewählt und ${availableCheck[choosen]} Punkte erhalten.");
    }
    else
    {
      print("Feld ${fieldNames[choosen]} ist ab jetzt gesperrt und kann keine Punkte mehr erhalten.");
    }
  }
  else
  {
    // set (dumb!) selection for computer
    bool somethingAvailable = false;
    for (var value in availableCheck.values) {
      if (value != 0) {
        somethingAvailable = true;
        break;
      }
    }
    if (!somethingAvailable) 
    {
      FieldValue? key;
      for(FieldValue fv in result.keys)
      {
        if(result[fv]==0)
        {
          result[fv] = -1;
          key = fv;
          break;
        }
      }
      print("\nDer Computer hat ${fieldNames[key]} gestrichen.");
    }
    else
    {
      for (FieldValue key in availableCheck.keys) 
      {
        if (availableCheck[key]! > 0 && result[key]! <= 0) 
        {
          result[key] = availableCheck[key]!;
          print("\nDer Computer hat ${fieldNames[key]} gewählt und ${availableCheck[key]} Punkte erhalten.");
          break;
        }
      }
    }
  }
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

bool testAufGrosseStrasse(List<int> wurf) 
{
  var sorted = wurf.toSet().toList()..sort();
  return sorted.length == 5 &&
        (sorted.join() == '12345' || sorted.join() == '23456');
}

int testAufViererPasch(Map<int, int> haeufigkeit) 
{
  for(var x in haeufigkeit.entries)
  {
    if(x.value == 4)
    {
      return x.key * 4;
    }
  }
  return 0;
}

int testAufDreierPasch(Map<int, int> haeufigkeit) 
{
  for(var x in haeufigkeit.entries)
  {
    if(x.value == 3)
    {
      return x.key * 3;
    }
  }
  return 0;
  
}

// main mit der eigentlichen kleinen State-Machine
Future<void> main() async 
{
  print("Willkommen zu Kniffel!");
  print("----------------------");

  Players currentplayer = Players.human;
  emptyResults();

  while(true)
  {
    if(currentplayer == Players.human) 
    {
      // human interaction
      print("Dein Wurf:");
      List<int> wurfResult = await wurf(); // muss mit await weil siehe dort!
      evaluate(currentplayer, wurfResult);//2,5,3,2,3]);
      // switch player
      currentplayer = switchPlayer(currentplayer);
    }
    else
    {
      // computer logic
      print("Computer ist am würfeln:");
      List<int> wurfResult = await wurf();
      evaluate(currentplayer, wurfResult);//2,5,3,2,3])
      currentplayer = switchPlayer(currentplayer);
      showResult(false); // nach beiden Würfen Zwischenstand anzeigen!
    }

    // prüft für Human ob alle Felder mit einem Wert gefüllt
    bool allfieldsHuman = true;
    for (int feldValue in humanResult.values) 
    {
      if (feldValue == 0) 
      {
        allfieldsHuman = false;
        break;
      }
    }

    // prüft für Computer ob alle Felder mit einem Wert gefüllt
    bool allfieldsComputer = true;
    for (int feldValue in computerResult.values) 
    {
      if (feldValue == 0) 
      {
        allfieldsComputer = false;
        break;
      }
    }

    // sind alle Felder gefüllt, dann zeige Endresultat und beende Game
    if(allfieldsHuman || allfieldsComputer)
    {
      showResult(true);
      exit(0);
    }
  }
}

Players switchPlayer(Players currentplayer)
{
  return currentplayer == Players.human?Players.computer:Players.human;
}

void showResult(bool endResult) 
{
  if(endResult)
  {
    print("Game ist beendet, weil einer der Spieler alle Felder voll hat!\n\n");
  }
  print('+-------------------+----------+----------+');
  print('| Kategorie         | Spieler  | Computer |');
  print('+-------------------+----------+----------+');

  int numberResultHuman = 0;
  int numberResultComputer = 0;
  int lowerResultHuman = 0;
  int lowerResultComputer = 0;
  for (var feld in fieldNames.keys) 
  {
    int humanValue = humanResult[feld] ?? 0;
    int computerValue = computerResult[feld] ?? 0;

    if(feld.index>=FieldValue.einser.index && feld.index<=FieldValue.sechser.index)
    {
      numberResultHuman += humanValue >= 0?humanValue:0;
      numberResultComputer += computerValue>=0?computerValue:0;
    }
    else
    {
      lowerResultHuman += humanValue >= 0?humanValue:0;
      lowerResultComputer += computerValue>=0?computerValue:0;
    }
    String spielerWert = (humanValue == -1) ? '-' : humanValue.toString();
    String computerWert = (computerValue == -1) ? '-' : computerValue.toString();

    print('| ${fieldNames[feld]!.padRight(18)}| ${spielerWert.padLeft(8)} | ${computerWert.padLeft(8)} |');

    if(feld.index==FieldValue.sechser.index)
    {
      String bonusHuman = numberResultHuman.toString() + (numberResultHuman >= 63 ? '   +35' : '(0)');
      String bonusComputer = numberResultComputer.toString() + (numberResultComputer >= 63 ? '   +35' : '(0)');

      numberResultHuman += numberResultHuman >= 63 ? 35 : 0;
      numberResultComputer += numberResultComputer >= 63 ? 35 : 0;

      print('+-------------------+----------+----------+');
      print('| ${'Zwischenstand'.padRight(18)}| ${bonusHuman.padLeft(8)} | ${bonusComputer.padLeft(8)} |');
      print('| ${''.padRight(18)}| ${numberResultHuman.toString().padLeft(8)} | ${numberResultComputer.toString().padLeft(8)} |');
      print('+-------------------+----------+----------+');
    }
  }
  print('+-------------------+----------+----------+');
  
  if(endResult)
  {   
    int resultHuman = numberResultHuman+lowerResultHuman;
    int resultComputer = numberResultComputer+lowerResultComputer;
    print('| ${'Endstand'.padRight(18)}| ${resultHuman.toString().padLeft(8)} | ${resultComputer.toString().padLeft(8)} |');
    print('+-------------------+----------+----------+');

    int winner = resultHuman > resultComputer ? 1 : (resultHuman < resultComputer ? 2 : 0);
    if(winner == 1)
    {
      print("Glückwunsch, Du hast gewonnen!");
    }
    else if(winner==2)
    {
      print("Och nööö, der Computer gewonnen!");
    }
    else
    {
      print("Na sowas! Ein Unentschieden!");
    }
  }
}
