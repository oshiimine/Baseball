import samuelal.squelized.*;

class SQLGame {
  int[] score = {0, 0};
  int inning, requiredInnings, requiredBalls;
  int requiredStrikes, requiredOuts;
  int curBalls, curStrikes, curOuts;
  TableRow[] baseRunnerStats = new TableRow[3];
  boolean[] baseRunners = new boolean[3];
  boolean finished;
  String[] teamNames = new String[2];

  Table team1Batters, team2Batters;
  Table team1Pitchers, team2Pitchers;
  TableRow team1CurPitcher, team2CurPitcher;
  int team1LineupCount, team2LineupCount;
  int team1PitcherCount, team2PitcherCount;
  TableRow curBatter, curPitcher;
  Table battingTeam, fieldingTeam;
  
  String pitchText = "";
  String endOfGameText = "Game Over!\n";


  public SQLGame(String team1, String team2, SQLConnection myConnection) {
    score[0] = 0;
    score[1] = 0;
    inning = 0;
    requiredInnings = 18;
    requiredBalls = 4;
    requiredStrikes = 3;
    requiredOuts = 3;

    curBalls = 0;
    curStrikes = 0;
    curOuts = 0;

    finished = false;
    teamNames[0] = team1;
    teamNames[1] = team2;

    team1Batters = myConnection.runQuery( "Select * From Players Where teamName = \'" + team1 + "\' and position = \'Lineup\';");
    team2Batters = myConnection.runQuery( "Select * From Players Where teamName = \'" + team2 + "\' and position = \'Lineup\';");
    team1Pitchers = myConnection.runQuery( "Select * From Players Where teamName = \'" + team1 + "\' and position = \'Pitcher\';");
    team2Pitchers = myConnection.runQuery( "Select * From Players Where teamName = \'" + team2 + "\' and position = \'Pitcher\';");

    team1LineupCount = 0;
    team2LineupCount = 0;

    team1PitcherCount = myConnection.runQuery("Select rotation from Teams where name = \'" + team1 + "\';").getInt(0, "rotation");
    team2PitcherCount = myConnection.runQuery("Select rotation from Teams where name = \'" + team1 + "\';").getInt(0, "rotation");
    
    team1CurPitcher = team1Pitchers.getRow(team1PitcherCount);
    team2CurPitcher = team2Pitchers.getRow(team2PitcherCount);
    
    curBatter = team1Batters.getRow(0);
    curPitcher = team2CurPitcher;
    battingTeam = team1Batters;
    fieldingTeam = team2Batters;
    
  }
  
  String nextMessage() {
    pitchText = "";
     //Check if inning is over
    if (curOuts == requiredOuts) {
      changeSides();
      pitchText = "Change Sides!";
    }
    //Check if we need a new player
    else if (curStrikes == requiredStrikes) {
      nextPlayer();
      curOuts++;
      pitchText = "Strike out!";
    }
    else if (curBalls == requiredBalls) {
      score[inning % 2] += advanceRunners(8411);
      nextPlayer();
      pitchText = "Walk";
    }
    
    else {
      //random events
      if (random(100) < 0.05) {
        float randomEvent = random(100);
        //Upgrade random stat
        if (randomEvent < 55) {
          playerUpgradeEvent(true);
        }
        //Downgrade random stat
        randomEvent -= 55;
        if (randomEvent < 44) {
          playerUpgradeEvent(false);
        }
        //Teams swap random players
        randomEvent -= 44;
        if (randomEvent < 0.3) {
        }
        //Player swaps roles 
        randomEvent -= 0.3;
        if (randomEvent < 0.5) {
        }
        //Player quits 
        else {
          
        }
      } else {
        throwPitch();
      }
    }
    
    if (finished) pitchText = endOfGameText;
    return pitchText;
  }
  
  //Throws one pitch
  public void throwPitch() {
    //Generate a pitch along a logistic curve
    double curPitch = randomGaussian()*0.3+0.1*curPitcher.getFloat("precision");
    
    //Improve low end pitchers
    if (curPitcher.getFloat("precision") < 3) {
      curPitch += (3-curPitcher.getFloat("precision"))/10;
    }
    
    if (1/(1+Math.exp(-curBatter.getFloat("stoicism")+curPitcher.getFloat("whimsicality"))) < random(1)) {
      //Incorrect Read
      if (curPitch > 0.4) {
        curStrikes++;
        pitchText = "Strike";
      }
      else {
        swing(curPitch);
      }
    }
    else if (curPitch < 0.4) {
      curBalls++;
      pitchText = "Ball";
    }
    else {
      swing(curPitch);
    }
  }
  
  void swing(double pitch) {
    
    //Closer to 0.5 easier to hit
    double hitValue = 2*Math.abs(0.5-pitch);
    double swingValue = 0.8/(1+Math.exp(-0.1*curBatter.getFloat("harmoniousness")+0.67*hitValue+0.033*curPitcher.getFloat("gutturalism"))) + 0.2 - random(1);
    if (swingValue < -0.1) {
      pitchText = "Swing and miss!";
      curStrikes++;
    }
    else if (swingValue < 0.1) {
      pitchText = "Foul Ball!";
      if (curStrikes < 2) curStrikes++;
    }
    else {
      TableRow randomFielder = fieldingTeam.getRow((int) random(9));
      double contactValue = swingValue*10 + (curBatter.getFloat("spiciness") * randomGaussian() * 2 + 1);
      double fieldingValue = contactValue - 2*randomFielder.getFloat("fluffiness") - randomFielder.getFloat("tastiness");
      
      if (contactValue > 15) {
        pitchText = curBatter.getString("fName") + " " + curBatter.getString("lName") + " hits a home run!";
        score[inning % 2] += advanceRunners(999);
      }
      else {
          if (fieldingValue < -2.5) {
          pitchText = "Ground out!";
          curOuts++;
        } else {
            if (fieldingValue < 0) {
            pitchText = "Fly out!";
            curOuts++;
          } else if (fieldingValue < 5) {
            pitchText = curBatter.getString("fName") + " " + curBatter.getString("lName") + " hits a single";
          }       
          score[inning % 2] += advanceRunners(fieldingValue);
        }
      }
      nextPlayer();
    }
  }
  
  int advanceRunners(double fieldingValue) {
    int numRuns = 0;
    //Flyout
    if (fieldingValue < 0 && curOuts < 3) {
      if (baseRunners[2]) {
        if (fieldingValue + 1 + baseRunnerStats[2].getFloat("zigzagedness")/10 > 0) {
          baseRunners[2] = false;
          numRuns++;
        }
      }
      if (baseRunners[1] && !baseRunners[2]) {
        if (fieldingValue + 1 + baseRunnerStats[1].getFloat("zigzagedness")/10 > 0) {
          baseRunners[1] = false;
          baseRunners[2] = true;
          baseRunnerStats[2] = baseRunnerStats[1]; 
        }
      }
      if (baseRunners[0] && !baseRunners[1]) {
        if (fieldingValue + 1 + baseRunnerStats[0].getFloat("zigzagedness")/10 > 0) {
          baseRunners[0] = false;
          baseRunners[1] = true;
          baseRunnerStats[1] = baseRunnerStats[0]; 
        }
      }
    }
    
    //Single
    else if (fieldingValue < 5) {
      if (baseRunners[2]) {
        baseRunners[2] = false;
        numRuns++;
      }
      if (baseRunners[1]) {
        if (fieldingValue + baseRunnerStats[1].getFloat("zigzagedness")/4 > 5) {
          baseRunners[1] = false;
          numRuns++;
        }
        else {
          baseRunners[1] = false;
          baseRunners[2] = true;
          baseRunnerStats[2] = baseRunnerStats[1]; 
        }
      }
      if (baseRunners[0]) {
        if (!baseRunners[2] && fieldingValue + baseRunnerStats[0].getFloat("zigzagedness")/4 > 5) {
          baseRunners[2] = true;
          baseRunnerStats[2] = baseRunnerStats[0]; 
        }
        else {
          baseRunners[1] = true;
          baseRunnerStats[1] = baseRunnerStats[0]; 
        }
      }
      
      baseRunners[0] = true;
      baseRunnerStats[0] = curBatter;
    } 
    
    //Home Run
    else if (fieldingValue == 999){
      for (int i = 0; i <= 2; i++) {
        if (baseRunners[i]) {
          baseRunners[i] = false;
          numRuns++;
        }
      }
      numRuns++;
    }
    
    //walk
    else if (fieldingValue == 8411) {
      if (baseRunners[0]) {
        if (baseRunners[1]) {
          if (baseRunners[2]) {
            numRuns++;
          }
          baseRunners[2] = true;
          baseRunnerStats[2] = baseRunnerStats[1];
        }
        baseRunners[1] = true;
        baseRunnerStats[1] = baseRunnerStats[0];
      }
      baseRunners[0] = true;
      baseRunnerStats[0] = curBatter;
    }
    
    //Extra bases
    else {
      if (baseRunners[2]) {
        baseRunners[2] = false;
        numRuns++;
      }
      if (baseRunners[1]) {
        baseRunners[1] = false;
        numRuns++;
      }
      if (baseRunners[0]) {
        if (fieldingValue + baseRunnerStats[0].getFloat("zigzagedness")/4 > 8) {
          baseRunners[0] = false;
          baseRunners[2] = true;
          baseRunnerStats[2] = baseRunnerStats[0]; 
        }
        else {
          baseRunners[0] = false;
          baseRunners[1] = true;
          baseRunnerStats[1] = baseRunnerStats[0]; 
        }
      }
      
      if (!baseRunners[2] && fieldingValue + curBatter.getFloat("zigzagedness")/4 > 10) {
        baseRunners[2] = true;
        baseRunnerStats[2] = curBatter; 
        pitchText = "Triple!";
      }
      else {
        baseRunners[1] = true;
        baseRunnerStats[1] = curBatter; 
        pitchText = "Double!";
      }
    }
    return numRuns;
  }
  
  void changeSides() {
    for (int i = 0; i < 3; i++) baseRunners[i] = false;
    nextPlayer();
    curOuts = 0;
    
    if (inning >= requiredInnings - 2 && inning % 2 == 0 && score[1] > score[0] || inning > requiredInnings - 2 && inning % 2 == 1 && score[1] != score[0]) {
      finished = true;
    }
    else {
      inning++;
      System.out.println("Change sides! ");
      
      if (inning % 2 == 0) {
        System.out.print("Top ");
        battingTeam = team1Batters;
        fieldingTeam = team2Batters;
        curBatter = battingTeam.getRow(team1LineupCount);
        curPitcher = team2CurPitcher;
      } else {
        System.out.print("Bottom ");
        battingTeam = team2Batters;
        fieldingTeam = team1Batters;
        curBatter = battingTeam.getRow(team2LineupCount);
        curPitcher = team1CurPitcher;
      }
      System.out.println(" of the " + (inning/2 + 1));
    }
      System.out.println("Score: " + score[0] + " - " + score[1]);
      
  }
  
  void nextPlayer() {
    curBalls = 0;
    curStrikes = 0;
    if (inning % 2 == 0) {
      team1LineupCount = (team1LineupCount + 1) % 9;
      curBatter = battingTeam.getRow(team1LineupCount);
    } else {
      team2LineupCount = (team2LineupCount + 1) % 9;
      curBatter = battingTeam.getRow(team2LineupCount);
    }
  }
  
  void playerUpgradeEvent(boolean upgrade) {
    //team 1
    String stat = "temp";
    float upgradeAmount = random(1)/5;
    
    if (!upgrade) {
      upgradeAmount *= -1;
    }
    
    int randomStat = (int) random(11);
    String[] statArray = {"stoicism", "spiciness", "harmoniousness", "gutturalism", "whimsicality", "protectiveness", "tastiness", "fluffiness",
                          "flamboyance", "zigzagedness"};
    
    stat = statArray[randomStat];
    
    if (random(2) < 1) {
      int eligiblePlayers = team1Batters.getRowCount() + team1Pitchers.getRowCount();
      float randomPlayer = random(eligiblePlayers);
      if (randomPlayer < team1Batters.getRowCount()) {
        updatePlayer(team1Batters.getRow((int) randomPlayer), stat, team1Batters.getRow((int) randomPlayer).getFloat(stat) + upgradeAmount);
        playerStatPitchText(team1Batters, (int) randomPlayer, stat, upgradeAmount);
      }
      else {
        randomPlayer -= team1Batters.getRowCount();
        updatePlayer(team1Pitchers.getRow((int) randomPlayer), stat, team1Pitchers.getRow((int) randomPlayer).getFloat(stat) + upgradeAmount);
        playerStatPitchText(team1Pitchers, (int) randomPlayer, stat, upgradeAmount);
      }
      
    } 
    //team 2
    else {
      int eligiblePlayers = team2Batters.getRowCount() + team2Pitchers.getRowCount();
      float randomPlayer = random(eligiblePlayers);
      if (randomPlayer < team2Batters.getRowCount()) {
        updatePlayer(team2Batters.getRow((int) randomPlayer), stat, team2Batters.getRow((int) randomPlayer).getFloat(stat) + upgradeAmount);
        playerStatPitchText(team2Batters, (int) randomPlayer, stat, upgradeAmount);
      }
      else {
        randomPlayer -= team2Batters.getRowCount();
        updatePlayer(team2Pitchers.getRow((int) randomPlayer), stat, team2Pitchers.getRow((int) randomPlayer).getFloat(stat) + upgradeAmount);
        playerStatPitchText(team2Pitchers, (int) randomPlayer, stat, upgradeAmount);
      }
    }
    
    
  }
  
  void playerStatPitchText(Table players, int index, String stat, float delta) {
    String upgradeText = " upgraded by ";
    if (delta < 0) {
      upgradeText = " downgraded by ";
      delta *= -1;
    }
    
    pitchText = players.getRow(index).getString("fName") + " " + players.getRow(index).getString("lName") +
                    " had their " + stat + "\n" + upgradeText + nf(delta, 1, 2) + "!";
    
    endOfGameText += pitchText + "\n";
  }
  
  public void printScore() {
    System.out.println("Score: " + score[0] + " - " + score[1]);
  }
  
  public int[] getScore() {
    return score;
  }
  public boolean[] getBaseRunners() {
    return baseRunners;
  }
  public String getPitchText() {
    return pitchText;
  }
  public int getBalls() {
    return curBalls;
  }
  public int getStrikes() {
    return curStrikes;
  }
  public int getOuts() {
    return curOuts;
  }
  public int getInning() {
    return inning;
  }
  public boolean isFinished() {
    return finished;
  }
  public String getAwayName() {
    return teamNames[0];
  }
  public String getHomeName() {
    return teamNames[1];
  }
  public String getPitcherName() {
    return curPitcher.getString("fName") + " " + curPitcher.getString("lName");
  }
  public String getBatterName() {
    return curBatter.getString("fName") + " " + curBatter.getString("lName");
  }
  public int getBatterCount() {
    if (inning % 2 == 0) {
      return team1LineupCount;
    }
    return team2LineupCount;
  }
}
