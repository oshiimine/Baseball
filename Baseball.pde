import samuelal.squelized.*;

final int numGames = 12; 
boolean allGamesDone;
SQLGame[] gameArray = new SQLGame[numGames];
String[] gameText = new String[numGames];
int pitchCount;
int[] gameLengthCount = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
Gamestate gamestate = Gamestate.MenuMain;
int delayTime = 1000;
PlayerGenerator pg = new PlayerGenerator();
int curDisplayedTeam = -1;

Table teams;
SQLConnection myConnection = new SQLiteConnection("jdbc:sqlite:Projects/Baseball/basedball.db");
String[] teamArray = {"Dragons", "Pandas", "Warriors", "Gamblers", "Automatons", "Metro", "Penguins", 
                    "Lobsters", "Koalas", "Kangaroos", "Kiwis", "Briskets", "Wizards", "Detectives", "Pizza",
                    "Pasta", "Grapes", "Baguettes", "Axes", "Rockets", "Chefs", "Judges", "Dogs", "Otters"};

void setup() {
  teams = myConnection.getTable("Teams");
  generateGames(); //<>//
  
  size(1080, 720);
}

void draw() {
  background(0);
  switch (gamestate) {
    case MenuMain:
      drawMenu();
      if (mousePressed == true) {
        checkMenuMouse();
      }
      break;
    case MenuTeams:
      drawTeams();
      if (mousePressed == true) {
        checkTeamsMouse();
      }
      break;
    case MenuTeamInfo:
      drawTeamInfo(teamArray[curDisplayedTeam]);
      if (mousePressed == true) {
        checkTeamInfoMouse();
      }
      break;
    case Playing:
      fill(255);
      drawOngoingGames();
      break;
    default:
      System.out.println("Error, invalid gamestate"); 
  }
}

void drawMenu() {
  background(0);
  fill(255);
  //Top menu buttons
  text("Menu", 150, 50);
  text("Teams", 800, 50);
  
  
  
  text("DelayTime: " + delayTime, 400, 500);
  textSize(40);
  
  //start
  rect(460, 300, 160, 120, 20);
  
  //delay buttons
  rect(740, 450, 60, 30, 20);
  rect(740, 490, 60, 30, 20);
  
  //temp
  rect(140, 150, 60, 30, 20);
  rect(140, 190, 60, 30, 20);
  
  fill(0);
  text("START", 480, 378);
  text ("+", 755, 475);
  text ("-", 760, 515);
  text("Generate Players", 120, 160);
}



void checkMenuMouse() {
  //Top Menu
  if (mouseBetween(150, 250, 20, 70)) {
      gamestate = Gamestate.MenuMain;
  }
  else if (mouseBetween(800, 920, 20, 70)) {
      gamestate = Gamestate.MenuTeams;
  }  
  
  //Start Button
  else if (mouseBetween(460, 620, 300, 420)) {
      gamestate = Gamestate.Playing;
  }
  //Add Delay Time
  else if (mouseBetween(740, 800, 450, 480)) {
      delayTime += 50;
  }
  //Add Delay Time
  else if (mouseBetween(740, 800, 490, 520)) {
      delayTime -= 50;
      if (delayTime < 0) {
        delayTime = 0;
      }
  }
  
  //temp
  else if (mouseBetween(140, 200, 150, 180)) {
    pg.deleteAllPlayers(myConnection);
    for (String s : teamArray) {
      for (int i = 0; i < 9; i++) {
        pg.GeneratePlayer(s, myConnection,"Lineup");
      }
      for (int i = 0; i < 5; i++) {
        pg.GeneratePlayer(s, myConnection,"Pitcher");
      }
      for (int i = 0; i < 5; i++) {
        pg.GeneratePlayer(s, myConnection,"Bench");
      }
    }
    generateGames();
  }
    
  else if (mouseBetween(140, 200, 190, 220)) {
    System.out.println("Button not in use");
  }
}

void drawOngoingGames() {
  background(0);
  fill(255);
  pitchCount++;

  //Play Game
  if (!allGamesDone) {
    for (int i = 0; i < numGames; i++) {
      if (!gameArray[i].isFinished()) {
        gameText[i] = gameArray[i].nextMessage();
      } else if (gameLengthCount[i] == 0) {
        gameLengthCount[i] = pitchCount - 1;
      }
    }
  } else {
    if (mousePressed == true) {
      gamestate = Gamestate.MenuMain;
      generateGames();
    } //<>//
  }
  DrawFrame();
}


void DrawFrame() {
  //Draw
  for (int i = 0; i < numGames; i++) {
    boolean[] baseRunners = gameArray[i].getBaseRunners();
    int[] gameScore = gameArray[i].getScore();
    int hOffset = 500 * (i / ((numGames + 1)/ 2));
    int vOffset = -50+115 * (i % 6);
    String inningString = (gameArray[i].getInning()/2 + 1) + " ";
    if (gameArray[i].getInning() % 2 == 0) inningString += "\u25B2";
    else inningString += "\u25BC";

    noFill();
    stroke(255);
    rect(50 + hOffset, 60 + vOffset, 500, 100);
    noStroke();
    fill(255);

    textSize(15);
    text(gameArray[i].getAwayName() + ": " + gameScore[0], 60 + hOffset, 110 + vOffset);
    text(gameArray[i].getHomeName() + ": " + gameScore[1], 60 + hOffset, 140 + vOffset);

    textSize(12);
    text(inningString, 60 + hOffset, 85 + vOffset);

    //Bases
    fill(64);
    if (baseRunners[2]) fill(200);
    quad(170 + hOffset, 100 + vOffset, 185 + hOffset, 85 + vOffset, 200 + hOffset, 100 + vOffset, 185 + hOffset, 115 + vOffset);

    fill(64);
    if (baseRunners[1]) fill(200);
    quad(190 + hOffset, 80 + vOffset, 205 + hOffset, 65 + vOffset, 220 + hOffset, 80 + vOffset, 205 + hOffset, 95 + vOffset);

    fill(64);
    if (baseRunners[0]) fill(200);
    quad(210 + hOffset, 100 + vOffset, 225 + hOffset, 85 + vOffset, 240 + hOffset, 100 + vOffset, 225 + hOffset, 115 + vOffset);

    //Infos
    fill(255);
    textSize(12);
    text("Balls: " + gameArray[i].getBalls(), 260 + hOffset, 85 + vOffset);
    text("Strikes: " + gameArray[i].getStrikes(), 260 + hOffset, 100 + vOffset);
    text("Outs: " + gameArray[i].getOuts(), 260 + hOffset, 115 + vOffset);
    
    text("Pitcher: " + gameArray[i].getPitcherName(), 165 + hOffset, 135 + vOffset);
    text("Batter: " + gameArray[i].getBatterName(), 165 + hOffset, 150 + vOffset);
    
    String temp = gameText[i];
    //Pitch text
    text(temp, 350 + hOffset, 85 + vOffset);
    
    //Pitch Count
    if (gameLengthCount[i] != 0)  text(gameLengthCount[i], 475 + hOffset, 155 + vOffset);
    else text(pitchCount, 475 + hOffset, 155 + vOffset);
  }
  
  allGamesDone = true;
  for (int i = 0; i < numGames; i++) {
    allGamesDone &= gameArray[i].isFinished();
  }
  delay(delayTime);
}

void generateGames() {
  for (int i = 0; i < numGames; i++) {
    gameArray[i] = new SQLGame(teamArray[2*i],teamArray[2*i+1], myConnection);
  }
}

boolean mouseBetween(int minX, int maxX, int minY, int maxY) {
  return mouseX > minX && mouseX < maxX && mouseY > minY && mouseY < maxY;
}
