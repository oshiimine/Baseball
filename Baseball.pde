import samuelal.squelized.*; //<>// //<>//

final int numGames = 12; //<>// //<>//
boolean allGamesDone;
Game[] gameArray = new Game[numGames];
String[] gameText = new String[numGames];
int pitchCount;
int[] gameLengthCount = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0};
Gamestate gamestate = Gamestate.MenuMain;
int delayTime = 1000;
PlayerGenerator pg = new PlayerGenerator();

Table teams, teamNameTable;
SQLConnection myConnection = new SQLiteConnection("jdbc:sqlite:C:/Users/oshii/Documents/Processing/Projects/Baseball/basedball.db");
SQLGame test;

void setup() {
  teams = myConnection.getTable("Teams");
  
  //Just for now
  teamNameTable = myConnection.getColumns("Teams", new String[] {"location", "name"});
  size(1080, 720);
  
  test = new SQLGame("Otters", "Dragons", myConnection);  //<>// //<>//
}

void draw() {
  background(0);
  if (gamestate == Gamestate.MenuMain) {
    drawMenu();
    if (mousePressed == true) {
      checkMenuMouse();
    }
  }
  else if (gamestate == Gamestate.MenuTeams) {
    drawTeams();
    if (mousePressed == true) {
      checkTeamsMouse();
    }
  }
  else if (gamestate == Gamestate.Playing) {
    fill(255);
    for (int i = 0; i < teamNameTable.getRowCount(); i++) {
      String teamName = teamNameTable.getString(i, 0) + " " + teamNameTable.getString(i, 1);
       text(teamName, 260, 85 + 50 * i);
    }
    drawSingleGame();
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
  if (mouseX > 150 && mouseX < 250 && mouseY > 20 && mouseY < 70) {
      gamestate = Gamestate.MenuMain;
  }
  else if (mouseX > 800 && mouseX < 920 && mouseY > 20 && mouseY < 70) {
      gamestate = Gamestate.MenuTeams;
  }  
  
  //Start Button
  else if (mouseX > 460 && mouseX < 620 && mouseY > 300 && mouseY < 420) {
      gamestate = Gamestate.Playing;
  }
  //Add Delay Time
  else if (mouseX > 740 && mouseX < 800 && mouseY > 450 && mouseY < 480) {
      delayTime += 50;
  }
  //Add Delay Time
  else if (mouseX > 740 && mouseX < 800 && mouseY > 490 && mouseY < 520) {
      delayTime -= 50;
      if (delayTime < 0) {
        delayTime = 0;
      }
  }
  
  //temp
  else if (mouseX > 140 && mouseX < 200 && mouseY > 150 && mouseY < 180) {
    test.throwPitch();  
    /*for (int i = 0; i < 9; i++) {
        pg.GeneratePlayer("Otters", myConnection,"Lineup");
      }
      for (int i = 0; i < 5; i++) {
        pg.GeneratePlayer("Otters", myConnection,"Pitcher");
      }
      for (int i = 0; i < 5; i++) {
        pg.GeneratePlayer("Otters", myConnection,"Bench");
      }*/
  }
  //Add Delay Time
  else if (mouseX > 140 && mouseX < 200 && mouseY > 190 && mouseY < 220) {
      pg.deleteAllPlayers(myConnection);
  }
}

void drawTeams() {
  background(0);
  fill(255);
  //Top menu buttons
  text("Menu", 150, 50);
  text("Teams", 800, 50);
  
  rect(150, 20, 100, 50);

}

void checkTeamsMouse() {
  //Top Menu
  if (mouseX > 150 && mouseX < 250 && mouseY > 20 && mouseY < 70) {
      gamestate = Gamestate.MenuMain;
  }
  else if (mouseX > 800 && mouseX < 920 && mouseY > 20 && mouseY < 70) {
      gamestate = Gamestate.MenuTeams;
  }
}

void drawSingleGame() {
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
    gamestate = Gamestate.MenuMain;
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

    textSize(20);
    text("Away: " + gameScore[0], 60 + hOffset, 110 + vOffset);
    text("Home: " + gameScore[1], 60 + hOffset, 140 + vOffset);

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
    
    //Pitch text
    text(gameArray[i].getPitchText(), 350 + hOffset, 85 + vOffset);
    
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
