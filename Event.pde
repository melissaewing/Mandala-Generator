//abstract event class
abstract class Event {
  
  float c; //color of draw event
  boolean added; //keeps track of whether the event has been added to the event stack so we dont add duplicates
  
  //event constructor
  Event(float c) {
    this.c = c;
    added = false;
  }
  
  abstract void drawEvent();
}

//draw lines by dragging mouse
//BrushEvent class stores all events related to drawing by mouse
class BrushEvent extends Event {
   
  ArrayList<Point> points; //arraylist to store points connected by lines that make up a drawing line
   
  BrushEvent(float c) {
    super(c);
    this.points = new ArrayList<Point>();
  }
  
  void addPoints(int x1, int y1, int x2, int y2) {
    points.add(new Point(x1, y1));
    points.add(new Point(x2, y2));
  }
  
  void drawEvent() {
    stroke(c, 255, 255);
    pushMatrix();
    translate(center.x, center.y);
    
    drawLines();
     
    //mirrored version
    scale(1,-1);
    drawLines(); 
    
    popMatrix();
  }
  
  //draw lines for each section of the mandala (from user mouse data stored in point array)
  void drawLines() {
    for (int j=0; j < numSlices; j++) {
      for (int i=0; i<points.size(); i+=2) {
        line(points.get(i).x-center.x, points.get(i).y-center.y, 
        points.get(i+1).x-center.x, points.get(i+1).y-center.y);
      }
      rotate(j*2*PI/numSlices); //rotate numSlices times and draw lines again
    }
  }
}

//draws triangles on user click
class TriangleEvent extends Event {
  
  Point p;
  int size;
  
  TriangleEvent(float c, Point p) {
    super(c);
    this.p = p;
    this.size = 20;
  }
  
  void drawEvent() {
    noStroke();
    fill(c, 255, 255); 
    triangle(p.x - size, p.y - size, p.x + size, p.y - size, p.x, p.y + size);
  }
}

//draws squares on user click
class SquareEvent extends Event {
 
  Point p;
  int size;
 
  SquareEvent(float c, Point p) {
   super(c);
   this.p = p;
   this.size = 20;
  } 
 
  void drawEvent() {
    noStroke(); 
    fill(c, 255, 255);
    rect(p.x - size, p.y - size, 2*size, 2*size);
  } 
}
