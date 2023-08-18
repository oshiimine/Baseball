import samuelal.squelized.*;
public static class Player {
  
  static PlayerFName[] fNames = PlayerFName.values();
  static PlayerLName[] lNames = PlayerLName.values();
  public static int playerId = 0;
  
  public Player() {
    
  }
  
}

public class PlayerGenerator {
  float[] stats = new float[11];
  String fname;
  String lname;
  
  void GeneratePlayer(String team, SQLConnection myConnection, String position) {
    GenerateName();
    GenerateStats();
    
    String query = "INSERT INTO Players VALUES (" + Player.playerId + ", \'" + fname + "\', \'" + lname + "\'";
    for (float f : stats) {
      query += ", " + f;
    }
    query += ", \'" + team + "\', \'" + position + "\');";
    System.out.println(query);
    Player.playerId++;
    
    myConnection.updateQuery(query);
  }
  
  void GenerateName() {
    fname = Player.fNames[int(random(Player.fNames.length))].name();
    lname = Player.lNames[int(random(Player.lNames.length))].name();
    System.out.println(fname + " " + lname);
  }
  
  void GenerateStats() {
    for (int i = 0; i < stats.length; i++) {
      stats[i] = random(7);
    }
  }
  
  void deleteAllPlayers(SQLConnection myConnection) {
    String query = "DELETE FROM Players;";
    myConnection.updateQuery(query);
  }
  
}

void updatePlayer(TableRow player, String stat, float value) {
  String query = "Update Players SET" + stat + "=" + value + " WHERE playerID = " + player.getInt("playerID");
  myConnection.updateQuery(query);
}
