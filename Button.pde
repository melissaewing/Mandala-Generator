color BUTTON_COLOR = color(200);
color BUTTON_COLOR_HOVER = color(120);
int BUTTON_SIZE = 40;
int IMAGE_MARGIN = 10;

//generic button class for GUI
class Button {
  
  int x, y;
  String name;
  boolean isTool = false; //tool buttons are drawing tools -- brush tool, create circle/square tool, etc.
  boolean pressed = false;  
  
  //button constructor
  Button(int x, int y, String name) {
    this.x = x;
    this.y = y;
    this.name = name;
    this.isTool = true;
  }
  
  //set pressed to true if putton is pressed
  //sets pressed variable of all other tool buttons to false -- cant have two active buttons at once.
  void press() {
      for (Map.Entry b : buttonHash.entrySet()) {
        Button button = (Button) b.getValue();
        if (isTool) {
          button.pressed = false; 
         }
      }
      pressed = true;
  }
  
  
  //displays buttons with text or images
  void display() {
    stroke(255);
    
    //highlight button on hover
    if(isOverButton()) {
      fill(BUTTON_COLOR_HOVER);
    } else {
      fill(BUTTON_COLOR);
    }
    
    rect(x, y, BUTTON_SIZE, BUTTON_SIZE);
    fill(0);
//    text(name, x, y+BUTTON_SIZE/2);
    
    this.displayImage();
  }
  
  void displayImage() {
    
  }
  
  //returns true if curser is over button
  boolean isOverButton() {
    return (mouseX >= x && mouseX <= x + BUTTON_SIZE && mouseY >= y && mouseY <= y + BUTTON_SIZE);
  }
}

class UndoButton extends Button {
   
  EventStack es;
  
  UndoButton(int x, int y, String name, EventStack es) {
    super(x, y, name);
    this.isTool = false;
    this.es = es;
  }
  
  void press() {
    es.undo();
  }
  
  void displayImage() {
    image(undoImg, x+IMAGE_MARGIN/2, y+IMAGE_MARGIN/2, BUTTON_SIZE-IMAGE_MARGIN, BUTTON_SIZE-IMAGE_MARGIN);
  }
}

class RedoButton extends Button {
   
  EventStack es;
  
  RedoButton(int x, int y, String name, EventStack es) {
    super(x, y, name);
    this.isTool = false;
    this.es = es;
  }
  
  void press() {
    es.redo();
  }
  
  void displayImage() {  
    image(redoImg, x+IMAGE_MARGIN/2, y+IMAGE_MARGIN/2, BUTTON_SIZE-IMAGE_MARGIN, BUTTON_SIZE-IMAGE_MARGIN);
  }
  
}

class BackgroundButton extends Button {
  
 BackgroundButton(int x, int y, String name) {
  super(x, y, name);
 } 
}
