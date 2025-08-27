import 'dart:io';
import 'dart:convert';
import 'package:async/async.dart';
import 'game.dart';

enum Menuaction { newgame, result, nextthrow, quit }
enum Gamestate { juststarted, running, finished }
enum Players { human, computer }

Future<void> main() async 
{
  print("Willkommen zu Kniffel!");
  print("----------------------");

  // Konsole konfigurieren
  stdin.lineMode = true;
  stdin.echoMode = true;

  // Eingabestream vorbereiten
  final inputQueue = StreamQueue<List<int>>(stdin.asBroadcastStream());

  GameLogic logic = GameLogic();
  Gamestate currentstate = Gamestate.juststarted;
  Players currentplayer = Players.human;

  while (true) {
    Menuaction currentaction = await showMenu(currentstate, inputQueue);
    switch (currentaction) {
      case Menuaction.newgame:
        if (await newGame(logic, inputQueue)) {
          currentstate = Gamestate.juststarted;
        }
        break;
      case Menuaction.result:
        showResult(logic);
        break;
      case Menuaction.nextthrow:
        print(currentplayer == Players.human ? "Dein Wurf:" : "Computer hat gewürfelt:");
        List<int> wurf = await logic.wurf();
        if (currentplayer == Players.human) {
          logic.Evaluate(wurf);
        } else {
          // Computerlogik kann hier ergänzt werden
        }
        currentstate = Gamestate.running;
        break;
      case Menuaction.quit:
        exit(0);
    }
  }
}

Future<bool> newGame(GameLogic game, StreamQueue<List<int>> inputQueue) async 
{
  print('Spiel neu starten? Bist Du sicher? (y/N)');
  while (await inputQueue.hasNext) {
    var codes = await inputQueue.next;
    if (codes.isEmpty) continue;
    String input = utf8.decode(codes).trim().toLowerCase();
    return input == 'y';
  }
  return false;
}

Future<Menuaction> showMenu(Gamestate state, StreamQueue<List<int>> inputQueue) async 
{
  print('\nDrücke eine Taste und bestätige mit Enter:');
  if (state != Gamestate.juststarted) print('(N) Neues Spiel');
  if (state == Gamestate.running) print('(Z) Zwischenstand anzeigen');
  print('(W) Wurf');
  print('(X) Beenden');

  while (await inputQueue.hasNext) 
  {
    var codes = await inputQueue.next;
    if (codes.isEmpty) continue;
    String key = utf8.decode(codes).trim().toLowerCase();

    switch (key) {
      case 'n':
        if (state == Gamestate.running) return Menuaction.newgame;
        break;
      case 'z':
        if (state != Gamestate.juststarted) return Menuaction.result;
        break;
      case 'w':
        return Menuaction.nextthrow;
      case 'x':
        return Menuaction.quit;
    }
    print("Ungültige Eingabe. Bitte erneut versuchen:");
  }
  return Menuaction.quit;
}

void showResult(GameLogic logic) 
{
  print('+-------------------+----------+----------+');
  print('| Kategorie         | Spieler  | Computer |');
  print('+-------------------+----------+----------+');

  for (var feld in logic.humanResult.keys) {
    String name = feld;
    String spielerWert = logic.humanResult[feld]?.toString() ?? '0';
    String computerWert = logic.computerResult[feld]?.toString() ?? '0';

    print('| ${name.padRight(18)}| ${spielerWert.padLeft(8)} | ${computerWert.padLeft(8)} |');
  }
  print('+-------------------+----------+----------+');
}
