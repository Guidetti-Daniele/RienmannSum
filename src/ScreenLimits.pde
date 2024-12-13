public class ScreenLimits {
   public float up;
   public float down;
   public float right;
   public float left;
   
   ScreenLimits() {
     this.up = (height/2);
     this.down = (-(height/2));
     this.right = (width/2);
     this.left = (-(width/2));
  }
   
   public Point2D getOrigin() {
     return new Point2D(-this.left,this.up);
   }
   
   public void incrementX(float offset) {
     left += offset;
     right += offset;
   }
   
   public void decrementX(float offset) {
     left -= offset;
     right -= offset;
   }
   
   public void incrementY(float offset) {
     up += offset;
     down += offset;     
   }
   
   public void decrementY(float offset) {
     up -= offset;
     down -= offset;     
   }
   
}