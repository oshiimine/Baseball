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
  Table battingTeam, fieldingTeam;


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
    fieldingTeam = team2Batters;
    
    System.out.println(curBatter.getFloat("harmoniousness"));
  }
  
  //Throws one pitch
  public void throwPitch() {
    //Generate a pitch along a logistic curve
    double curPitch = randomGaussian()*0.15+0.1*curPitcher.getFloat("precision");
    if (1/(1+Math.exp(-curBatter.getFloat("stoicism")+curPitcher.getFloat("whimsicality"))) < random(1)) {
      //Incorrect Read
      if (curPitch > 0.5) {
        curStrikes++;
      }
      else {
        swing(curPitch);
      }
    }
    else if (curPitch < 0.5) {
      curBalls++;
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
    }
    else if (swingValue < 0.1) {
    }
    else {
      curStrikes = 0;
      curBalls = 0;
      TableRow randomFielder = fieldingTeam.getRow((int) random(9));
      double contactValue = swingValue*10 + (curBatter.getFloat("spiciness") * randomGaussian() * 2 + 1);
      double fieldingValue = contactValue - randomFielder.getFloat("fluffiness") - randomFielder.getFloat("tastiness");
      
      System.out.println(fieldingValue);
      if (contactValue > 15) {
        System.out.println("Home Run! ");
      }
      if (fieldingValue < -2.5) {
        System.out.println("Ground out");
      } else if (fieldingValue < 0) {
        System.out.println("Fly out");
      } else if (fieldingValue < 5) {
        System.out.println("Single");
      } else {
        System.out.println("Extra Bases");
      }
    }
  }
}
