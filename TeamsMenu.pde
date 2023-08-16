void drawTeams() {
  background(0);
  fill(255);
  textSize(40);
  //Top menu buttons
  text("Home", 150, 50);
  text("Teams", 800, 50);
  
  for (int i = 0; i < teamArray.length; i++) {
    int hOffset = 50 + 250 * (i / ((teamArray.length + 1)/ 4));
    int vOffset = 200 + 75 * (i % 6);
    text(teamArray[i], hOffset, vOffset);
    
  }

}

void checkTeamsMouse() {
  //Top Menu
  if (mouseX > 150 && mouseX < 250 && mouseY > 20 && mouseY < 70) {
      gamestate = Gamestate.MenuMain;
  }
  else if (mouseX > 800 && mouseX < 920 && mouseY > 20 && mouseY < 70) {
      gamestate = Gamestate.MenuTeams;
  }
  for (int i = 0; i < teamArray.length; i++) {
    int hOffset = 250 * (i / ((teamArray.length + 1)/ 4));
    int vOffset = 150 + 75 * (i % 6);
    if (mouseBetween(hOffset, hOffset + 250, vOffset, vOffset + 75)) {
      gamestate = Gamestate.MenuTeamInfo;
      curDisplayedTeam = i;
    }
  }
}

void drawTeamInfo(String teamName) {
  int vGap = 30;
  
  background(0);
  fill(255);
  //Top menu buttons
  textSize(40);
  text("Home", 150, 50);
  text("Teams", 800, 50);
  
  text(teamName + ": ", 440, 100);
  Table batters = myConnection.runQuery( "Select * From Players Where teamName = \'" + teamName + "\' and position = \'Lineup\';");
  Table pitchers = myConnection.runQuery( "Select * From Players Where teamName = \'" + teamName + "\' and position = \'Pitcher\';");
  Table bench = myConnection.runQuery( "Select * From Players Where teamName = \'" + teamName + "\' and position = \'Bench\';");
  
  
  textSize(20);
  text("Batters:", 150, 150);
  text("Pitchers", 700, 150);
  text("Bench", 700, 200 + vGap * pitchers.getRowCount());
  textSize(12);
  
  for (int i = 0; i < batters.getRowCount(); i++) {
    TableRow curBatter = batters.getRow(i);
    float battingValue = (curBatter.getFloat("stoicism") + curBatter.getFloat("spiciness") + curBatter.getFloat("harmoniousness"))/3 + 0.5;
    String starString = getStars(battingValue);
    
    text(curBatter.getString("fName") + " " + curBatter.getString("lName"), 50, 200+vGap*i);
    text(starString, 300, 200+vGap*i);
  }
  for (int i = 0; i < pitchers.getRowCount(); i++) {
    TableRow curPitcher = pitchers.getRow(i);
    float pitchingValue = (curPitcher.getFloat("precision") + curPitcher.getFloat("gutturalism") + curPitcher.getFloat("whimsicality"))/3 + 0.5;
    String starString = getStars(pitchingValue);
    
    text(pitchers.getRow(i).getString("fName") + " " + pitchers.getRow(i).getString("lName"), 600, 200 + vGap * i);
    text(starString, 750, 200+vGap*i);
  }
  for (int i = 0; i < pitchers.getRowCount(); i++) {
    text(bench.getRow(i).getString("fName") + " " + bench.getRow(i).getString("lName"), 600, 200 + vGap * (i + pitchers.getRowCount() + 1));
  }
}

void checkTeamInfoMouse() {
  //Top Menu
  if (mouseX > 150 && mouseX < 250 && mouseY > 20 && mouseY < 70) {
      gamestate = Gamestate.MenuMain;
  }
  else if (mouseX > 800 && mouseX < 920 && mouseY > 20 && mouseY < 70) {
      gamestate = Gamestate.MenuTeams;
  }
}

String getStars(float stat) {
  String starCode = "\u2605";
  
  String starString = "";
  for (int j = 0; j < stat; j++) {
    starString += starCode;
  }
  
  return starString;
}
