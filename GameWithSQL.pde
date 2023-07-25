import samuelal.squelized.*;

class SQLGame {
  int[] score = {0, 0};
  int inning, requiredInnings, requiredBalls;
  int requiredStrikes, requiredOuts;
  int curBalls, curStrikes, curOuts;
  Table team1Batters, team2Batters;
  
  
  SQLGame(String team1, String team2, SQLiteConnection myConnection) {
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
  }



}
