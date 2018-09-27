import java.util.Map;

int MARGIN = 30;

PFont fontA;
color backgroundcolor = 255;
PImage undoImg, redoImg;

float colorPickerWidth = 400;    //color picker slider bar width;
float hue = colorPickerWidth/2;  //initial hue value is in the middle

//radius, number of slices, and center variables of mandala
int r = 230;
int numSlices = 12;
Point center; 

HashMap<String, Button> buttonHash = new HashMap<String, Button>(); //hashmap to store the buttons
Button currentButton = null; //currently active button

EventStack es = new EventStack();
BrushEvent be = null;

//setup to create drawing area and button objects
void setup() {
  
  colorMode(HSB);
  size(800, 600);
  smooth();
  background(255);
  
  undoImg  = loadImage("undo.png");
  redoImg = loadImage("redo.png");
  fontA = loadFont("AgencyFB-Reg-20.vlw");
  textFont(fontA, 28);
  
  createButtons();
  
  center = new Point(width/2, height/2 + 35); //determine center point of mandala
}

void draw(){

  //update and draw GUI 
  displayButtons();
  hue = drawColorSlider(200, MARGIN, colorPickerWidth,40,hue);  
  
  //draw mandala outline
  drawMandala();

  //draws everything in the area (all previous events)
  Event e = es.first();
  while (e != null) {
    e.drawEvent();
    e = es.next();
  }
  
  //draw border around mandala
  strokeWeight(15);
  stroke(0);
  noFill();
  pushMatrix();
  translate(center.x, center.y);
  ellipse(0,0, r*2, 2*r);
  popMatrix();
  strokeWeight(1);
 
}

void displayButtons() {
   for (Map.Entry b : buttonHash.entrySet()) {
    Button button = (Button) b.getValue();
    button.display();
  }
}

void drawMandala() {
  
  fill(backgroundcolor);
  pushMatrix();
  translate(center.x, center.y);
  ellipse(0,0, r*2, 2*r);
  stroke(0);
  
  //divive mandala into subsections that will be reflected across the y axis and repeated after rotation 
  float theta = 0;
  for (int i=0; i < numSlices; i++) {
    line(0,0, r*cos(theta), r*sin(theta));
    theta += 2*PI/numSlices;
  }
  
  popMatrix();
}

void createButtons() {
  buttonHash.put("undo", new UndoButton(MARGIN, MARGIN, "undo", es));
  buttonHash.put("redo", new RedoButton(BUTTON_SIZE + MARGIN, MARGIN, "redo", es));
  
 // buttonHash.put("background", new Button(MARGIN, BUTTON_SIZE + MARGIN, "background"));
  
  Button brushButton = new Button(BUTTON_SIZE + MARGIN, BUTTON_SIZE + MARGIN, "brush");
  //buttonHash.put("brush", brushButton);
  currentButton = brushButton;
}


float drawColorSlider(float x, float y, float sliderWidth, float sliderHeight, float hueVal) {
  
  fill(255);
  noStroke();
  rect(x-5, y-10, sliderWidth+10, sliderHeight+20);  //draw white background behind slider
  
  float sliderPos = map(hueVal,0,255,0,sliderWidth); //find the current sliderPosition from hueVal
  
  for(int i=0; i<sliderWidth; i++){  //draw 1 line for each hueValue from 0-255
      float hueValue = map(i, 0, sliderWidth, 0, 255);  //get hueVal for each i position
      stroke(hueValue,255,255);
      line(x+i, y, x+i, y+sliderHeight);
  } 
  
  if(mousePressed && mouseX > x && mouseX < (x+sliderWidth) && mouseY > y && mouseY < y + sliderHeight) {
     sliderPos = mouseX - x;
     hueVal = map(sliderPos, 0, sliderWidth, 0, 255);  // get new hueVal based on moved slider
  }
  
  stroke(20);
  strokeWeight(.1);
  fill(hueVal,255,255);  //either new or old hueVal 
  
  int indicatorHeight = 6;
  int indicatorWidth = 5;
  
  rect(sliderPos + x - indicatorHeight/2, y - indicatorWidth, indicatorHeight, sliderHeight + 2*indicatorWidth);  //this is our slider indicator that moves
  rect(y + sliderWidth + 200, y, sliderHeight, sliderHeight); // this rectangle displays the current hue on the right
  
  strokeWeight(1);
  
  return hueVal;
}

void mouseDragged() {

  if (currentButton != null && currentButton.name.equals("brush")) {
    //just started to drag mouse, so we have to create the event
    if (be == null) {
      be = new BrushEvent(hue);
    //brush event has already been stored in the event stack
    } else {
      be = (BrushEvent) es.pop();
      //check to see if point is inside the mandala
      if (pointInside(mouseX, mouseY) &&  pointInside(pmouseX, pmouseY)) {
        be.addPoints(mouseX, mouseY, pmouseX, pmouseY);
      //last point was inside mandala but user has gone outside of bounds      
      } else if (pointInside(pmouseX, pmouseY)) {
        
      }
    }
    es.push(be);
  }
}

//helper method to check if point is inside mandala
boolean pointInside(float x, float y) {
  return pow(x - center.x, 2) + pow(y - center.y, 2) <= pow(r, 2);
}


void mouseReleased() {
  //set brushevent back to null after we are done with a stroke
  if (currentButton != null && currentButton.name.equals("brush")) {
    be = null;
  }
}

void mousePressed() {
  //if user clicks, check to see if its on a button
  for (Map.Entry b : buttonHash.entrySet()) {
    Button button = (Button) b.getValue();
    if (button.isOverButton()) {
      button.press();
      if (button.isTool) {
        currentButton = button;
      }
    }  
  }
}
