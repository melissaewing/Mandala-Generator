import java.util.Map;
import controlP5.*;

//GUI constants
int MARGIN_TOP = 200;
int MARGIN_LEFT = 50;

int BUTTON_WIDTH = 50;
int BUTTON_HEIGHT = 30;
int BUTTON_MARGIN_X = 10;
int BUTTON_MARGIN_Y = 20;

int SLIDER_WIDTH = 225;    
int SLIDER_HEIGHT = 20;

int CHECK_BOX_SIZE = 30;

//mandala constants
int MANDALA_X_OFFSET = 150;
int START_NUM_SECTIONS = 16;

//GUI controls
ControlP5 guiController;
float hue = SLIDER_WIDTH/2;  //initial brush hue value is in the middle

//mandala variables -- radius, number of slices, and center variables 
int radius = 280;
int numSections = START_NUM_SECTIONS;
Point center; 

//event stack keeps track of drawing events for undo/redo/clear
EventStack es = new EventStack();
BrushEvent be = null;

//setup to create drawing area and button objects
void setup() {
  
  size(1000,600);
  colorMode(HSB);
  smooth();
  background(0);
  
  createGUI();
  
  center = new Point(width/2 + MANDALA_X_OFFSET, height/2); //determine center point of mandala
}

void draw(){
  //draw color slider and update brush hue 
  hue = drawColorSlider(MARGIN_LEFT, MARGIN_TOP, SLIDER_WIDTH, SLIDER_HEIGHT, hue);  
  
  drawMandala();
  drawEvents();
  drawMandalaBorder();
}

//draw mandala canvas and sections
void drawMandala() {
  
  stroke(0);
  fill(255);
  pushMatrix();
  translate(center.x, center.y);
  ellipse(0,0, 2*radius, 2*radius);
  
  //divive mandala into subsections that will be reflected across the y axis and repeated after rotation 
  float theta = 0;
  for (int i=0; i < numSections; i++) {
    line(0,0, radius*cos(theta), radius*sin(theta));
    theta += 2*PI/numSections;
  }
  
  popMatrix();
}

//draws all brush strokes in the drawing area
void drawEvents() {
  Event e = es.first();
  while (e != null) {
    e.drawEvent();
    e = es.next();
  }
}

//draw mandala outline
void drawMandalaBorder() {
  //draw border around mandala
  strokeWeight(15);
  stroke(0);
  noFill();
  pushMatrix();
  translate(center.x, center.y);
  ellipse(0,0, 2*radius, 2*radius);
  popMatrix();
  strokeWeight(1);
}

//helper method to check if point is inside mandala
boolean pointInside(float x, float y) {
  return pow(x - center.x, 2) + pow(y - center.y, 2) <= pow(radius, 2);
}

/***** MOUSE DRAW EVENTS *****/

void mouseDragged() {

    //just started to drag mouse, so we have to create the brush event
    if (be == null) {
      float brushSize = guiController.getController("brushSize").getValue();
      boolean mirror =  (((int) guiController.getController("mirror").getValue()) == 1 ? true : false);
      be = new BrushEvent(hue, brushSize, mirror);
   
    //brush event has already been stored in the event stack, retrieve it
    } else {
      be = (BrushEvent) es.pop();
      //check to see if point is inside the mandala. if it is, add points to the brush event 
      if (pointInside(mouseX, mouseY) &&  pointInside(pmouseX, pmouseY)) {
        be.addPoints(mouseX, mouseY, pmouseX, pmouseY);
      }
    }
    
    es.push(be);
}

void mouseReleased() {
  //reset brushevent after we are done with a stroke
  be = null;
}

 /***** END MOUSE DRAW EVENTS *****/
 

/***** GUI FuNCTIONS *****/

void createGUI() {
  
  guiController = new ControlP5(this);
 
  guiController.addSlider("sections")
     .setPosition(MARGIN_LEFT,MARGIN_TOP+(BUTTON_HEIGHT+BUTTON_MARGIN_Y))
     .setSize(SLIDER_WIDTH, SLIDER_HEIGHT)
     .setRange(2,32) 
     .setValue(START_NUM_SECTIONS)
     .setNumberOfTickMarks(16)
     .setSliderMode(Slider.FLEXIBLE);
                
 guiController.addSlider("brushSize")
     .setPosition(MARGIN_LEFT,MARGIN_TOP+2*(BUTTON_HEIGHT+BUTTON_MARGIN_Y))
     .setSize(SLIDER_WIDTH,SLIDER_HEIGHT)
     .setRange(0,20)
     .setValue(1)
     .setCaptionLabel("brush size");
   
  guiController.addButton("undo")
               .setValue(0)
               .setPosition(MARGIN_LEFT, MARGIN_TOP+3*(BUTTON_HEIGHT+BUTTON_MARGIN_Y))
               .setSize(BUTTON_WIDTH, BUTTON_HEIGHT);
               
  guiController.addButton("redo")
               .setValue(0)
               .setPosition(MARGIN_LEFT+BUTTON_WIDTH+BUTTON_MARGIN_X, MARGIN_TOP+3*(BUTTON_HEIGHT+BUTTON_MARGIN_Y))
               .setSize(BUTTON_WIDTH, BUTTON_HEIGHT);
               
  guiController.addButton("clear")
               .setValue(0)
               .setPosition(MARGIN_LEFT+2*(BUTTON_WIDTH+BUTTON_MARGIN_X), MARGIN_TOP+3*(BUTTON_HEIGHT+BUTTON_MARGIN_Y))
               .setSize(BUTTON_WIDTH, BUTTON_HEIGHT);        
     
  guiController.addCheckBox("mirrorCheckBox")
               .setPosition(MARGIN_LEFT+3*(BUTTON_WIDTH+BUTTON_MARGIN_X)+CHECK_BOX_SIZE/2, MARGIN_TOP+3*(BUTTON_HEIGHT+BUTTON_MARGIN_Y))
               .setColorForeground(color(120))
               .setColorActive(color(255))
               .setSize(CHECK_BOX_SIZE, CHECK_BOX_SIZE)
               .addItem("mirror", 1);
}

// undo function receives changes from controller with name undo
void undo(int val) {
  es.undo();
}

// redo function receives changes from controller with name redo
void redo(int val) {
  es.redo();
}

// clear function receives changes from controller with name clear
void clear(int val) {
  es.clear();
}

// sections function receives changes from controller with name sections
// updates numSections variable and rounds label display
void sections(float sections) {
   numSections = (int) sections;
   guiController.getController("sections").setValueLabel(""+numSections);
}

// brushSize function receives changes from controller with name brushSize 
// removes label display
void brushSize(float bs) { 
   guiController.getController("brushSize").setValueLabel("");
}

float drawColorSlider(float x, float y, float sliderWidth, float sliderHeight, float hueVal) {
  
  fill(0);
  noStroke();
  rect(x-5, y-10, sliderWidth+10, sliderHeight+20);  //draw background behind slider
  
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
  
  rect(sliderPos + x - indicatorHeight/2, y - indicatorWidth, indicatorHeight, sliderHeight + 2*indicatorWidth);  //slider indicator that moves
  rect(x + sliderWidth + sliderHeight/2, y, sliderHeight, sliderHeight); // rectangle displays the current hue on the right
  
  strokeWeight(1);
  
  return hueVal;
}

/***** END GUI FUNCTIONS *****/
