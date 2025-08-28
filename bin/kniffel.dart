import 'dart:io';
import 'game.dart';

enum Gamestate { juststarted, running, finished }
enum Players { human, computer }

Future<void> main() async 
{
  print("Willkommen zu Kniffel!");
  print("----------------------");

  GameLogic logic = GameLogic();
  Gamestate currentstate = Gamestate.juststarted;
  Players currentplayer = Players.human;

  while(currentstate == Gamestate.juststarted || currentstate == Gamestate.running)
  {
    if(currentplayer == Players.human) 
    {
      // human interaction
      print("Dein Wurf:");
      List<int> wurf = await logic.wurf();
      logic.evaluate(currentplayer, wurf);//2,5,3,2,3]);
      // switch player
      currentplayer = switchPlayer(currentplayer);
      currentstate = Gamestate.running;
    }
    else
    {
      // computer logic
      print("Computer ist am würfeln:");
      List<int> wurf = await logic.wurf();
      logic.evaluate(currentplayer, wurf);//2,5,3,2,3])
      currentplayer = switchPlayer(currentplayer);
      showResult(logic, false); // nach beiden Würfen Zwischenstand anzeigen!
    }

    bool allfieldsHuman = true;
    for (int feldValue in logic.humanResult.values) 
    {
      if (feldValue == 0 || feldValue == -1) 
      {
        allfieldsHuman = false;
        break;
      }
    }
    bool allfieldsComputer = true;
    for (int feldValue in logic.computerResult.values) 
    {
      if (feldValue == 0 || feldValue == -1) 
      {
        allfieldsComputer = false;
        break;
      }
    }
    if(allfieldsHuman || allfieldsComputer)
    {
      showResult((logic), true);
      exit(0);
    }
  }
}

Players switchPlayer(Players currentplayer)
{
  return currentplayer == Players.human?Players.computer:Players.human;
}

void showResult(GameLogic logic, bool endResult) 
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
    int humanValue = logic.humanResult[feld] ?? 0;
    int computerValue = logic.computerResult[feld] ?? 0;

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
