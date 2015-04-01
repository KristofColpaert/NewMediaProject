import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import com.onformative.leap.*; 
import com.leapmotion.leap.*; 

import com.onformative.leap.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class LeapDraw extends PApplet {




PVector cPos;
ArrayList<PVector> trail;
int trailSize = 20;
Controller c = new Controller();
Frame f;
LeapMotionP5 leap;

public void setup() {
	size(1920, 900, P3D);
	noStroke();
	cPos = new PVector(width*.5f, width*.5f);
	trail = new ArrayList<PVector>();
	leap = new LeapMotionP5(this);
	smooth();

	fill(0xffF2DA63);
	stroke(0xffE85E00);
	strokeWeight(10);
	
	background(0xff333333);
}

public void draw() {
	Finger f = c.frame().fingers().frontmost();
	
	if (f.isValid()) {
		cPos = leap.getTip(f);	
		//if (trail.size() < trailSize) {
			trail.add(cPos);
		//}
		// else {
		// 	trail = new ArrayList<PVector>(trail.subList(1, trailSize - 1));
		// 	trail.add(cPos);
		// }
	
		for (int i = trail.size() - 2 ; i > 0; i--) {
			line(trail.get(i).x, trail.get(i).y, trail.get(i - 1).x, trail.get(i - 1).y);
		}	
	}

}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "LeapDraw" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
