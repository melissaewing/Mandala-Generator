//simple stack-like data structure to store drawing events 
class EventStack {
  
  int drawIndex; //counter variable to keep track of which event we're drawing when looping through event list
  ArrayList<Event> events; //event storage backed by array list
  ArrayList<Event> undoEvents; //another arraylist to store the undone events to use in redo
  
  EventStack() {
    this.drawIndex = 0;
    events = new ArrayList<Event>();  
    undoEvents = new ArrayList<Event>();
  }
  
  //adds event object to event array
  void push(Event e) {
    if (!e.added) {
      events.add(e);
      e.added = true;
    }
  }

  //gets most recent event object from event array
  Event pop() {
    if (events.size() > 0) {
      return events.get(events.size()-1);
    } else  
      return null;
    
  }
  
  //gets oldest event from event array
  Event first() {
    drawIndex = 0;
    Event e;
    if (events.size() > 0) {
      e = events.get(drawIndex);
    } else {
      e = null;
    }
    return e;
  }
  
  //gets next event while iterating through event array to draw events
  Event next() {
    Event e;
    if (drawIndex < events.size()) {
      e = events.get(drawIndex);
      drawIndex++;
    } else {
      e = null;
    }
    return e;
  }
  
  //undo event -- remove from event array and add event to undone event list
  void undo() {
    Event undoEvent = pop();
    if (undoEvent != null) {
      undoEvents.add(undoEvent);
      events.remove(events.size()-1);
    }
  }
  
  //redo event -- take event from undoevents and add it back to event array
  void redo() {
    if (undoEvents.size() > 0) {
      Event redoEvent = undoEvents.remove(0);
      events.add(redoEvent);
    }
  }
  
  //removes all events from event stack
  void clear() {
    events.clear();
    undoEvents.clear();
  }
}
