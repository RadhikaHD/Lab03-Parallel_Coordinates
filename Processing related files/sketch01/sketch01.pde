FloatTable data;
float xmin, ymin;
float xmax, ymax;


int colPad = 15;


int noCols;
int noRows;
int selectedCol; 
int newCol; 
float linespace;
float newFilterVal; 
float clickVal; 
float minDiff; 
float maxDiff; 
int kval = 3; 



float[] filterMin;
float[] filterMax;

int[] colInvert;
int[] colIdx;
int[] colIdxNew;

PFont labelFont;
PFont numberFont;
PFont titleFont;

void setup() {
  size(755, 600); //size of the main screen

  titleFont = createFont("Ariel Narrow", 26);
  labelFont = createFont("Ariel Narrow", 11.25); 
  numberFont = createFont("Ariel Narrow", 10.5); 

  data = new FloatTable("Cars.txt");
  noCols = data.getColumnCount(); 
  noRows = data.getRowCount();

  colInvert = new int[noCols];
  for (int idx = 0; idx < noCols; idx++) { //for all the elements of the array set default value as 0
    colInvert[idx] = 0;
  }



  filterMin = new float[noCols]; 
  filterMax = new float[noCols];
  for (int col = 0; col < noCols; col++) { //for each column one by one
    filterMin[col] = data.getColumnMin(col); //get the min value for that column and store it in the array
    filterMax[col] = data.getColumnMax(col); //get the max value for that column and store it in the array
  }

  colIdxNew = new int[noCols]; 
  colIdx = new int[noCols]; //11 same for colidx 

  for (int idx = 0; idx < noCols; idx++) { 
    colIdx[idx] = idx; //initialise all the values of the colidx to 0 to no of columns
  }
}

void draw() {
  background(0); 
  drawTitle();
  drawAxes();
  drawAxisLabels();
  drawLines();
  drawFilter();
}

void drawTitle() {
  textFont(titleFont);
  fill(248); 
  textAlign(RIGHT); 
  text("PARALLEL COORDINATES", 535, 50);
}

void drawAxes()
{
  noCols = data.getColumnCount(); //again get column count
  noRows = data.getRowCount();  //rowcount
  linespace = floor(800/noCols); //12 declare linespace as float global and Calculates the closest int value that is less than or equal to the value of the parameter.
  // 

  xmin = 25;
  xmax = width - 25;

  ymin = 100;
  ymax = height - 45;


  stroke(248); //Sets the color used to draw lines and borders around shapes, draw grey lines
  strokeWeight(1); //thickness 

  for (int col = 0; col < noCols; col++) { //draw lines for all columns
    line((col*linespace)+xmin+10, ymin+10, (col*linespace)+xmin+10, ymax-10); //line(x1, y1, x2, y2)
  }
}

void drawAxisLabels() {

  fill(248); 
  for (int col = 0; col < noCols; col++) { //for each column perform the following actions
    String label = data.getColumnName(colIdx[col]);  //string label holds the column name for all the columns

    textFont(labelFont);
    fill(248);
    textAlign(CENTER, CENTER); 
    text(label, (col*linespace)+xmin+10, ymax+10); 

    float colMin = data.getColumnMin(colIdx[col]); //declare column min and obtain it
    float colMax = data.getColumnMax(colIdx[col]); //declare column max and obtain it

    textFont(numberFont); 
    fill(248);
    textAlign(CENTER, CENTER); 

    if (colInvert[colIdx[col]] == 0) { //if axis is flipped then put labels accordingly
      text(colMin, (col*linespace)+xmin+10, ymax-5);
      text(colMax, (col*linespace)+xmin+10, ymin+5);
    } else if (colInvert[colIdx[col]] == 1) {
      text(colMax, (col*linespace)+xmin+10, ymax-5);
      text(colMin, (col*linespace)+xmin+10, ymin+5);
    }
  }
}

void drawLines() {
  for (int sample = 0; sample < noRows; sample++) {
    int inFilter = 1; 
    for (int col = 0; col < noCols; col++) {
      float dataVal = data.getFloat(sample, colIdx[col]); 
      if (dataVal > filterMax[colIdx[col]] || dataVal < filterMin[colIdx[col]]) {
        inFilter = 0;
      }
    }
    if (inFilter == 1) {
      stroke(0, 255, 0); //stroke(v1, v2, v3) green lines
      strokeWeight(0.5);
      noFill(); 
      beginShape(); 
      for (int col = 0; col < noCols; col++) {
        float colMin = data.getColumnMin(colIdx[col]); 
        float colMax = data.getColumnMax(colIdx[col]); 
        float value = data.getFloat(sample, colIdx[col]);

        if (colInvert[colIdx[col]] == 0) {
          float y = map(value, colMin, colMax, ymax-15, ymin+15);
          vertex((col*linespace)+xmin+10, y);
        } else if (colInvert[colIdx[col]] == 1) {
          float y = map(value, colMax, colMin, ymax-15, ymin+15); 
          vertex((col*linespace)+xmin+10, y);
        }
      }
      endShape();
    } else if (inFilter == 0) {
      stroke(144, 144, 144, 255); 
      strokeWeight(0.5);
      noFill(); 
      beginShape(); 
      for (int col = 0; col < noCols; col++) {
        float colMin = data.getColumnMin(colIdx[col]); 
        float colMax = data.getColumnMax(colIdx[col]); 
        float value = data.getFloat(sample, colIdx[col]);

        if (colInvert[colIdx[col]] == 0) {
          float y = map(value, colMin, colMax, ymax-15, ymin+15);
          vertex((col*linespace)+xmin+10, y);
        } else if (colInvert[colIdx[col]] == 1) {
          float y = map(value, colMax, colMin, ymax-15, ymin+15); 
          vertex((col*linespace)+xmin+10, y);
        }
      }
      endShape();
    }
  }
} 

void mousePressed() {
  if (mouseY > ymax && mouseY < 600) {
    for (int col = 0; col < noCols; col++) {
      if (mouseX >= (col*linespace)+xmin+10-(linespace/3) && mouseX <= (col*linespace)+xmin+10+(linespace/3)) {
        if (colInvert[colIdx[col]] == 0) {
          colInvert[colIdx[col]] = 1;
        } else if (colInvert[colIdx[col]] == 1) {
          colInvert[colIdx[col]] = 0;
        }
      }
    }
  }
  if (mouseY > ymin+10 && mouseY < ymax-20) {
    clickVal = mouseY; 
    for (int col = 0; col < noCols; col++) {
      if (mouseX > (col*linespace)+xmin+10-colPad && mouseX < (col*linespace)+xmin+10+colPad) {
        selectedCol = col;
      }
    }
  }
}


void mouseReleased() {
  if (mouseY > ymin+10 && mouseY < ymax-20) {
    for (int col = 0; col < noCols; col++) { 
      if (mouseX > (col*linespace)+xmin+10-colPad && mouseX < (col*linespace)+xmin+10+colPad) {
        newCol = col;

        if (newCol != selectedCol) {
          updateIndex();
        } else if (newCol == selectedCol) {
          newFilterVal = mouseY; 
          updateFilter();
        }
      }
    }
  }
}

void updateIndex() {

  if (newCol > selectedCol) {
    for (int col = 0; col < noCols; col++) {
      if (col == newCol) {
        colIdxNew[col] = colIdx[selectedCol];
      } else if (col < selectedCol) {
        colIdxNew[col] = colIdx[col];
      } else if (selectedCol <= col && newCol > col) {
        colIdxNew[col] = colIdx[col+1];
      } else if (col > newCol) {
        colIdxNew[col] = colIdx[col];
      }
    }
  } else if (newCol < selectedCol) {
    for (int col = 0; col < noCols; col++) {
      if (col == newCol) {
        colIdxNew[col] = colIdx[selectedCol];
      } else if (col < newCol) {
        colIdxNew[col] = colIdx[col];
      } else if (newCol < col && selectedCol >= col) {
        colIdxNew[col] = colIdx[col-1];
      } else if (col > selectedCol) {
        colIdxNew[col] = colIdx[col];
      }
    }
  }

  for (int idx = 0; idx < noCols; idx++) {
    colIdx[idx] = colIdxNew[idx];
  }
}

void drawFilter() {
  rectMode(CORNERS); 
  fill(176, 176, 176, 150); 
  noStroke();
  for (int col = 0; col < noCols; col++) {
    if (colInvert[colIdx[col]] == 0) {
      float colMin = data.getColumnMin(colIdx[col]); 
      float colMax = data.getColumnMax(colIdx[col]); 
      float y1 = map(filterMax[colIdx[col]], colMin, colMax, ymax-15, ymin+15); 
      float y2 = map(filterMin[colIdx[col]], colMin, colMax, ymax-15, ymin+15);   
      rect((col*linespace)+xmin+5, y1, (col*linespace)+xmin+15, y2);
    } else if (colInvert[colIdx[col]] == 1) {
      float colMin = data.getColumnMin(colIdx[col]); 
      float colMax = data.getColumnMax(colIdx[col]);   
      float y1 = map(filterMax[colIdx[col]], colMax, colMin, ymax-15, ymin+15); 
      float y2 = map(filterMin[colIdx[col]], colMax, colMin, ymax-15, ymin+15);   
      rect((col*linespace)+xmin+5, y2, (col*linespace)+xmin+15, y1);
    }
  }
}

void updateFilter() {
  if (colInvert[colIdx[selectedCol]] == 0) {
    float currentMax = filterMax[colIdx[selectedCol]]; 
    float currentMin = filterMin[colIdx[selectedCol]]; 

    float colMin = data.getColumnMin(colIdx[selectedCol]); 
    float colMax = data.getColumnMax(colIdx[selectedCol]);   
    float clickValScale = map(clickVal, ymax-15, ymin+15, colMin, colMax);

    maxDiff = abs(clickValScale-currentMax); 
    minDiff = abs(clickValScale-currentMin);
  } else if (colInvert[colIdx[selectedCol]] == 1) {
    float currentMax = filterMax[colIdx[selectedCol]]; 
    float currentMin = filterMin[colIdx[selectedCol]]; 

    float colMin = data.getColumnMin(colIdx[selectedCol]); 
    float colMax = data.getColumnMax(colIdx[selectedCol]);   
    float clickValScale = map(clickVal, ymax-15, ymin+15, colMax, colMin);

    maxDiff = abs(currentMax-clickValScale); 
    minDiff = abs(currentMin-clickValScale);
  }

  if (minDiff < maxDiff) {
    if (colInvert[colIdx[selectedCol]] == 0) {
      float colMin = data.getColumnMin(colIdx[selectedCol]); 
      float colMax = data.getColumnMax(colIdx[selectedCol]);   
      float yVal = map(newFilterVal, ymax-15, ymin+15, colMin, colMax);
      filterMin[colIdx[selectedCol]] = yVal;
    } else if (colInvert[colIdx[selectedCol]] == 1) {
      float colMin = data.getColumnMin(colIdx[selectedCol]); 
      float colMax = data.getColumnMax(colIdx[selectedCol]);   
      float yVal = map(newFilterVal, ymax-15, ymin+15, colMax, colMin);
      filterMin[colIdx[selectedCol]] = yVal;
    }
  } else if (minDiff > maxDiff) {
    if (colInvert[colIdx[selectedCol]] == 0) {
      float colMin = data.getColumnMin(colIdx[selectedCol]); 
      float colMax = data.getColumnMax(colIdx[selectedCol]);   
      float yVal = map(newFilterVal, ymax-15, ymin+15, colMin, colMax);
      filterMax[colIdx[selectedCol]] = yVal;
    } else if (colInvert[colIdx[selectedCol]] == 1) {
      float colMin = data.getColumnMin(colIdx[selectedCol]); 
      float colMax = data.getColumnMax(colIdx[selectedCol]);   
      float yVal = map(newFilterVal, ymax-15, ymin+15, colMax, colMin);
      filterMax[colIdx[selectedCol]] = yVal;
    }
  }
}

