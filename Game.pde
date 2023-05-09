import samuelal.squelized.*;

class Game {
  int[] score = new int[2]; //score[0] is away, score[1] is home
  int inning, requiredInnings;
  int requiredBalls, requiredStrikes, requiredOuts;
  boolean[] baseRunners = new boolean[3];
  String pitchText;
  
  int flyOutVal;
  int groundOutVal;
  int singleVal;
  int doubleVal;
  int tripleVal;

  int curBalls, curStrikes, curOuts;

  boolean finished;

  Game() {
    pitchText = "Game not yet started";
    score[0] = 0;
    score[1] = 0;
    inning = 0;
    requiredInnings = 18;
    requiredBalls = 4;
    requiredStrikes = 3;
    requiredOuts = 3;

    flyOutVal = 24;
    groundOutVal = 51;
    singleVal = 82;
    doubleVal = 92;
    tripleVal = 95;

    curBalls = 0;
    curStrikes = 0;
    curOuts = 0;

    finished = false;
    System.out.println("Top of the 1st!");
  }
  
  String nextMessage() {
    String str = "";
     //Check if inning is over
    if (curOuts == requiredOuts) {
      changeSides();
      str = "Change Sides!";
    }
    //Check if we need a new player
    else if (curStrikes == requiredStrikes) {
      nextPlayer();
    }
    
    else {
      throwPitch();
      str = pitchText;
    }
    
    return str;
  }
  //Throws one pitch
  void throwPitch() {
    float pitch = random(8);
    if (pitch < 3.5 - (0.75 - curBalls / 4.0)) {
      pitchText = "Strike";
      curStrikes++;
    } else if (pitch < 5.5) {
      pitchText = "Ball";
      curBalls++;
    } else if (pitch < 6.5) {
      if (curStrikes < 2) {
        pitchText = "Foul Ball! ";
        curStrikes++;
      }
    } else {
      float hit = random(100);
      if (hit < flyOutVal) {
        pitchText = "Fly Out!";
        curOuts++;
      } else if (hit < groundOutVal) {
        pitchText = "Ground Out!";
        curOuts++;
      }
      else if (hit < singleVal) {
        pitchText = "Single!";
        score[inning % 2] += advanceRunners(1, hit - groundOutVal, baseRunners);
      } else if (hit < doubleVal) {
        pitchText = "Double!";
        score[inning % 2] += advanceRunners(2, hit - singleVal, baseRunners);
      } else if (hit < tripleVal) {
        pitchText = "Triple!";
        score[inning % 2] += advanceRunners(3, hit - doubleVal, baseRunners);
      } else {
        pitchText = "Home run!";
        score[inning % 2] += advanceRunners(4, hit - tripleVal, baseRunners);
      }
      nextPlayer();
    }
    pitchText += "\n";
    if (curStrikes == requiredStrikes) {
      pitchText +=  "Player struck out!\n";
      curOuts++;
    }
    if (curBalls == requiredBalls) {
      pitchText += "Player walks to first\n";
      nextPlayer();
      score[inning % 2] += advanceRunners(0, 0, baseRunners);
    }
  }

  //Advance Runners after a hit, updates base runners
  int advanceRunners(int hit, float hitValue, boolean[] baseRunners) {
    nextPlayer();
    int numRuns = 0;
    switch (hit) {
    case 0:
      if (baseRunners[0]) {
        if (baseRunners[1]) {
          if (baseRunners[2]) {
            numRuns++;
          } else {
            baseRunners[2] = true;
          }
        } else {
          baseRunners[1] = true;
        }
      } else {
        baseRunners[0] = true;
      }
      break;
    case 1:
      if (baseRunners[2]) {
        numRuns++;
        baseRunners[2] = false;
      } 
      if (baseRunners[1]) {
        if (hitValue > 30) {
          numRuns++;
        } else {
          baseRunners[2] = true;
        }
        baseRunners[1] = false;
      } 
      if (baseRunners[0]) {
        if (hitValue > 30) {
          baseRunners[2] = true;
        } else {
          baseRunners[1] = true;
        }
      } 
      baseRunners[0] = true;
      break;
    case 2:
      if (baseRunners[2]) {
        numRuns++;
        baseRunners[2] = false;
      }
      if (baseRunners[1]) {
        numRuns++;
      } 
      if (baseRunners[0]) {
        if (hitValue > 10) {
          numRuns++;
        } else {
          baseRunners[2] = true;
        }
        baseRunners[0] = false;
      }
      baseRunners[1] = true;
      break;
    case 3:
      if (baseRunners[2]) {
        numRuns++;
      }
      if (baseRunners[1]) {
        numRuns++;
        baseRunners[1] = false;
      }
      if (baseRunners[0]) {
        numRuns++;
        baseRunners[0] = false;
      } 
      baseRunners[2] = true;
      break;
    case 4:
      if (baseRunners[2]) {
        numRuns++;
        baseRunners[2] = false;
      }
      if (baseRunners[1]) {
        numRuns++;
        baseRunners[1] = false;
      }
      if (baseRunners[0]) {
        numRuns++;
        baseRunners[0] = false;
      }
      numRuns++;
    }
    if (numRuns > 0) pitchText += (numRuns + " runs scored!\n");
    return numRuns;
  }

  //Go to next half of inning
  void changeSides() {
    for (int i = 0; i < 3; i++) baseRunners[i] = false;
    curBalls = 0;
    curStrikes = 0;
    curOuts = 0;
    
    if (inning >= requiredInnings - 2 && inning % 2 == 0 && score[1] > score[0] || inning > requiredInnings - 2 && inning % 2 == 1 && score[1] != score[0]) {
      finished = true;
    }
    if (!finished) {
      inning++;
      System.out.println("Change sides! ");
      
      if (inning % 2 == 0) {
        System.out.print("Top ");
      } else {
        System.out.print("Bottom ");
      }
      System.out.println(" of the " + (inning/2 + 1));
    }
      System.out.println("Score: " + score[0] + " - " + score[1]);
    
  }
  
  void nextPlayer() {
    curBalls = 0;
    curStrikes = 0;
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
}
