/**
 * persian-game-of-life
 * by Paul Reiners.
 * Based on Game of Life
 * by Joan Soler-Adillon.
 * A variation of Conway's Game of Life with an additional "zombie" state that introduces fading effects over time. It also includes features like:
 * * Randomized Initial States: Cells start alive with a certain probability.
 * * Background Image: It uses an image (persia.jpg) as the background.
 * * Grid Display: Uses a 5-pixel cell size and colors to represent states.
 * * Zombie Effect: Cells that were once alive fade out over time.
 * * Frame Saving: Saves each frame as a .tif file in a frames/ folder.
 * Key Controls:
 * * R to restart with a new randomized state.
 * * C to clear the grid.
 */
 
// Size of cells
int cellSize = 5;

// How likely for a cell to be alive at start (in percentage)
float probabilityOfAliveAtStart = 15;

// Variables for timer
int interval = 100;
int lastRecordedTime = 0;

// Colors for active/inactive cells
color alive = color(0, 200, 0);
color dead = color(0);
color zombie;
int zombieOpacity = 255;

// Array of cells
int[][] cells; 
int[][] used; 
// Buffer to record the state of the cells and use this 
// while changing the others in the interations
int[][] cellsBuffer; 

PImage bg;
int redAvg;
int greenAvg;
int blueAvg;

void setup() {
  size (640, 360);
  
  // Instantiate arrays 
  cells = new int[width/cellSize][height/cellSize];
  used = new int[width/cellSize][height/cellSize];
  cellsBuffer = new int[width/cellSize][height/cellSize];

  // This stroke will draw the background grid
  stroke(48);

  noSmooth();

  // Initialization of cells
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      float state = random (100);
      if (state > probabilityOfAliveAtStart) { 
        state = 0;
      }
      else {
        state = 1;
      }
      cells[x][y] = int(state); // Save state of each cell
      used[x][y] = int(0);
    }
  }
  // Fill in black in case cells don't cover all the windows
  background(0); 
  bg = loadImage("persia3.jpg");
  if (bg == null) { 
    background(0); 
  } 
  loadPixels();
  int redSum = 0;
  int greenSum = 0;
  int blueSum = 0;
  for (int i = 0; i < width*height; i++) {
    redSum += red(bg.pixels[i]);
    greenSum += green(bg.pixels[i]);
    blueSum += blue(bg.pixels[i]);
  }
  redAvg = redSum / (width * height);
  greenAvg = greenSum / (width * height);
  blueAvg = blueSum / (width * height);
  zombie = color(redAvg, greenAvg, blueAvg, 0);
}


void draw() {
  background(bg);

  //Draw grid
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      if (used[x][y] == 0) {
        if (cells[x][y]==1) {
          fill(alive); // If alive
          used[x][y] = int(1);
        }
        else {
          fill(dead); // If dead
        }
      } else {
        fill(zombie);
      }
      rect (x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }
  // Iterate if timer ticks
  if (millis()-lastRecordedTime>interval) {
    iteration();
    lastRecordedTime = millis();
    if (zombieOpacity > 0) {
      zombieOpacity -= 1;
      zombie = color(redAvg, greenAvg, blueAvg, zombieOpacity);
    }
  }

  saveFrame("/Users/paulreiners/sketches/bach-game-of-life/frames/#####.tif");
}

void iteration() { // When the clock ticks
  // Save cells to buffer (so we opeate with one array keeping the other intact)
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      cellsBuffer[x][y] = cells[x][y];
    }
  }

  // Visit each cell:
  for (int x=0; x<width/cellSize; x++) {
    for (int y=0; y<height/cellSize; y++) {
      // And visit all the neighbours of each cell
      int neighbours = 0; // We'll count the neighbours
      for (int xx=x-1; xx<=x+1;xx++) {
        for (int yy=y-1; yy<=y+1;yy++) {  
          if (((xx>=0)&&(xx<width/cellSize))&&((yy>=0)&&(yy<height/cellSize))) { // Make sure you are not out of bounds
            if (!((xx==x)&&(yy==y))) { // Make sure to to check against self
              if (cellsBuffer[xx][yy]==1){
                neighbours ++; // Check alive neighbours and count them
              }
            } // End of if
          } // End of if
        } // End of yy loop
      } //End of xx loop
      // We've checked the neigbours: apply rules!
      if (cellsBuffer[x][y]==1) { // The cell is alive: kill it if necessary
        if (neighbours < 2 || neighbours > 3) {
          cells[x][y] = 0; // Die unless it has 2 or 3 neighbours
        }
      } 
      else { // The cell is dead: make it live if necessary      
        if (neighbours == 3 ) {
          cells[x][y] = 1; // Only if it has 3 neighbours
        }
      } // End of if
    } // End of y loop
  } // End of x loop
} // End of function

void keyPressed() {
  if (key=='r' || key == 'R') {
    // Restart: reinitialization of cells
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        float state = random (100);
        if (state > probabilityOfAliveAtStart) {
          state = 0;
        }
        else {
          state = 1;
        }
        cells[x][y] = int(state); // Save state of each cell
        used[x][y] = int(0);
        zombieOpacity = 255;
      }
    }
  }
  if (key=='c' || key == 'C') { // Clear all
    for (int x=0; x<width/cellSize; x++) {
      for (int y=0; y<height/cellSize; y++) {
        cells[x][y] = 0; // Save all to zero
        used[x][y] = int(0);
        zombieOpacity = 255;
      }
    }
  }
}
