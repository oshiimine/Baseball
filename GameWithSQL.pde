import samuelal.squelized.*;

class SQLGame {
  int[] score = {0, 0};
  int inning, requiredInnings, requiredBalls;
  int requiredStrikes, requiredOuts;
  int curBalls, curStrikes, curOuts;

  Table team1Batters, team2Batters;
  Table team1Pitchers, team2Pitchers;
  TableRow team1CurPitcher, team2CurPitcher;
  int team1LineupCount, team2LineupCount;
  int team1PitcherCount, team2PitcherCount;
  TableRow curBatter, curPitcher;


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
    System.out.println("Top of the 1st!");

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
    
    System.out.println(curBatter.getFloat("harmoniousness"));
  }
  
  //Throws one pitch
  public void throwPitch() {
    //Generate a pitch along a logistic curve
    double curPitch = randomGaussian()*0.15+0.1*curPitcher.getFloat("precision");
    System.out.println("Pitch: " + curPitch);
    if (1/(1+Math.exp(-curBatter.getFloat("stoicism")+curPitcher.getFloat("whimsicality"))) < random(1)) {
      //Incorrect Read
      if (curPitch > 0.5) {
        curStrikes++;
        System.out.println("Strike");
      }
      else {
        swing(curPitch);
      }
    }
    else if (curPitch < 0.5) {
      curBalls++;
      System.out.println("Ball");
    }
    else {
      swing(curPitch);
    }
  }
  
  void swing(double pitch) {
    
    //Closer to 0.5 easier to hit
    double hitValue = 2*Math.abs(0.5-pitch);
    double swingValue = 1/(1+Math.exp(-0.1*curBatter.getFloat("harmoniousness")+0.67*hitValue+0.033*curPitcher.getFloat("gutturalism"))) - random(1);
    if (swingValue < 0) {
      System.out.println("Swing and miss: " + swingValue);
    }
    else {
      System.out.println("Swing and hit: " + swingValue);
      curStrikes = 0;
      curBalls = 0;
    }
  }
}
