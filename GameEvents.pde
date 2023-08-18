class GameEventHandler {
  Table team1Batters, team1Pitchers, team2Batters, team2Pitchers;
  String pitchText;
  
  public GameEventHandler(Table t1, Table t2, Table t3, Table t4) {
    team1Batters = t1;
    team1Pitchers = t2;
    team2Batters = t3;
    team2Pitchers = t4;
  }
  
  public String randomEvent() {
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
      return pitchText;
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
    TableRow player = findRandomPlayer();
    updatePlayer(player, stat, player.getFloat(stat) + upgradeAmount);
    playerStatPitchText(player, stat, upgradeAmount);
  }
  
  void playerSwapEvent() {
    
  }
  
  void playerRoleSwapEvent() {
  
  }
  
  void playerRetireEvent() {
    
  }
  
  TableRow findRandomPlayer() {
    float randomPlayer;
    if (random(2) < 1) {
      int eligiblePlayers = team1Batters.getRowCount() + team1Pitchers.getRowCount();
      randomPlayer = random(eligiblePlayers);
      if (randomPlayer < team1Batters.getRowCount()) {
        return team1Batters.getRow((int) randomPlayer);
      }
      else {
        randomPlayer -= team1Batters.getRowCount();
        return team1Pitchers.getRow((int) randomPlayer);
      }
    } 
    //team 2
    else {
      int eligiblePlayers = team2Batters.getRowCount() + team2Pitchers.getRowCount();
      randomPlayer = random(eligiblePlayers);
      if (randomPlayer < team2Batters.getRowCount()) {
        return team2Batters.getRow((int) randomPlayer);
      }
      else {
        randomPlayer -= team2Batters.getRowCount();
        return team2Pitchers.getRow((int) randomPlayer);
      }
    }
  }
  
  void playerStatPitchText(TableRow player, String stat, float delta) {
    String upgradeText = " upgraded by ";
    if (delta < 0) {
      upgradeText = " downgraded by ";
      delta *= -1;
    }
    
    pitchText = player.getString("fName") + " " + player.getString("lName") + " had their " + stat + 
                                        "\n" + upgradeText + nf(delta, 1, 2) + "!";
  }
}
