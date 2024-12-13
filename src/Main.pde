// Constants for colors //<>//
final color AXIS_COLOR = color(255);
final color FUNCTION_COLOR = color(255,0,0);
final color TEXT_COLOR = color(255);
final color GRID_COLOR = color(255,255,255,50);
final color RECTANGULAR_COLOR = color(0,255,0);
final color LIMITS_COLOR = color(0,255,0); // it will be removed

// Variables to manage unit of measurementunit and zoom
float unit = 50; // it means that 1 unit corresponds to 50px on the screen

float zoom = 1.0;
float zoomAmount = 0.1;

// Variables to manage drag
ScreenLimits screenLimits;

float dragSensibility = 0.1;
Point2D dragPivotPoint;

enum Direction {
  UP_RIGHT,
  UP_LEFT,
  DOWN_RIGHT,
  DOWN_LEFT
}

Direction dragDirection;

// Variables to implement Rienmann's sum
int n = 10;
float lowerBound = 0;
float upperBound = 10;

final char plusButton = '+';
final char minusButton = '-';

float myFunction(float x) {
  return x*x;
}

void moveToOrigin() {
  pushMatrix();
  Point2D origin = screenLimits.getOrigin();
  translate(origin.x,origin.y);  
}

void drawAxis() {  
  stroke(AXIS_COLOR);
  
  Point2D origin = screenLimits.getOrigin();
  // y-axis
  line(origin.x,0,origin.x,height);
  // x-axis
  line(0,origin.y,width,origin.y);
}

void drawLegend() {
   moveToOrigin();
   int xBarlinesCount = floor(width/unit);
   int yBarlinesCount = floor(height/unit);
   
   int textGap = 15;
   int textSize = 12;
   textSize(textSize);
   textAlign(LEFT);
   
   fill(TEXT_COLOR);
   /*
    I know how many barlines I have to draw on the two axis,
    but I have to get the values of the bounds.
   */
   float xDisplacement = round( (screenLimits.right-width/2) / unit);
   float minX = (-xBarlinesCount/2)+xDisplacement;
   float maxX = minX + xBarlinesCount;
   
   /*
    Now I have to do the same for the y axis,
    but I have to INVERT THE SIGN
   */
   float yDisplacement = round( (screenLimits.up-height/2) / unit );
   float maxY = (yBarlinesCount/2)+yDisplacement;
   float minY = maxY - yBarlinesCount;
      
      
   // Drawing grid
   for(float i = minX; i <= maxX; i++) {
     if( i == 0) continue;
     
     float x = unit*i;
     stroke(GRID_COLOR);
     line(x, -(unit*maxY), x, -unit*minY);
     
     fill(TEXT_COLOR);
     String text = String.format("%.1f",i);
     text(text, x-textWidth(text)/2, textGap);
   }
    
  for(float i = minY; i <= maxY; i++) {
    if(i == 0) continue;
    
    float y = unit*i;
    stroke(GRID_COLOR);
    line(unit*minX, -y, unit*maxX, -y);
    
    fill(TEXT_COLOR);
    text(String.format("%.1f", i), 0, -y+(textSize/4));
  }
   
  popMatrix();
}

void drawZoomText() {
  String text = String.format("Zoom: %d %%", round(100*zoom));
  fill(TEXT_COLOR);
  text(text, 40, 40);
}

void drawScreenLimitsText() {
fill(LIMITS_COLOR);
text(screenLimits.left, 0, height/2);
text(screenLimits.right, width-50, height/2);
text(screenLimits.up, width/2, 10);
text(screenLimits.down, width/2, height-10);
}

void drawMyFunction() {
  moveToOrigin();
  
  stroke(FUNCTION_COLOR);
  noFill();

  beginShape();
  for( float x = screenLimits.left/unit; x <= screenLimits.right/unit; x+= (1/unit))
    vertex(x*unit, -myFunction(x)*unit); //<>//
  endShape();
  
  popMatrix();
}

void drawRienmannSum() {
  float rectWidth = zoom*(upperBound-lowerBound)/n;
  float rectHeight = 0;
  
  moveToOrigin();
  
  noStroke();
  fill(RECTANGULAR_COLOR);
  rectMode(CENTER);
  
  for(float i=lowerBound*zoom; i <= upperBound*zoom; i+= rectWidth) {
    float middleX = i+(rectWidth/2);
    rectHeight = myFunction(i/zoom);
    rect(middleX,(-rectHeight)/2,rectWidth,rectHeight);
  }
  
  String text = String.format("n=%d",n);
  fill(255);
  text(text, (upperBound*zoom)+10, -(rectHeight+10));
  
  popMatrix();
}

void drawView() {
  background(0);
  
  //drawZoomText();
  drawScreenLimitsText();
  drawAxis();
  drawLegend();
  drawMyFunction();
  //drawRienmannSum();
}

void setup() {
  size(1000,600);
  screenLimits = new ScreenLimits();
  
  drawView();
}

void draw() {
  
  if(mousePressed) {
      dragPivotPoint = new Point2D(mouseX,mouseY);
  }
  
}

//void mouseWheel(MouseEvent event) {
  
//  if(event.getCount() > 0) // the wheel goes down
//    zoom = (zoom-zoomAmount) < 0 ? 0 : (zoom-zoomAmount);
//   else
//    zoom += zoomAmount;
      
//  drawView();  
//}

Direction getDirection(float offsetX, float offsetY) {
  
  if(offsetX >= 0 && offsetY >= 0)
    return Direction.UP_LEFT;
    
  if(offsetX >= 0 && offsetY < 0)
    return Direction.DOWN_LEFT;
    
  if(offsetX < 0 && offsetY >= 0)
    return Direction.UP_RIGHT;
  
  return Direction.DOWN_RIGHT;
}

void mouseDragged() {
    
    if(dragPivotPoint == null) return;
  
    float offsetX = mouseX - dragPivotPoint.x;
    float offsetY = mouseY - dragPivotPoint.y;
    
    dragDirection = getDirection(offsetX,offsetY);
    offsetX = abs(offsetX);
    offsetY = abs(offsetY);
    
    if(dragDirection == Direction.UP_RIGHT){
      screenLimits.incrementX(offsetX);
      screenLimits.incrementY(offsetY);
    }
        
    if(dragDirection == Direction.UP_LEFT){
      screenLimits.decrementX(offsetX);
      screenLimits.incrementY(offsetY);
    }    
    
    if(dragDirection == Direction.DOWN_RIGHT){
      screenLimits.incrementX(offsetX);
      screenLimits.decrementY(offsetY);
    }    
    
    if(dragDirection == Direction.DOWN_LEFT){
      screenLimits.decrementX(offsetX);
      screenLimits.decrementY(offsetY);
    }
        
    drawView();
}

void keyPressed() {
  
  if( key == plusButton) {
    n++;
    drawView();
  } else if( key == minusButton && n!= 1) {
    n--;
    drawView();
  }
    
}