import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import com.onformative.leap.*; 
import com.leapmotion.leap.*; 
import com.leapmotion.leap.Gesture.*; 

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





PVector cPos = new PVector(width/2, height/2,0);
ArrayList<PVector> path;
Controller c = new Controller();
Frame f;
LeapMotionP5 leap;
Boolean drawing = true;

public void setup() {
	size(1920, 900, P3D);
	noStroke();
	smooth();
	fill(0xffF2DA63);
	stroke(0xffE85E00);
	strokeWeight(10);

	background(0xff333333);

	cPos = new PVector(width*.5f, width*.5f);

	path = new ArrayList<PVector>();
	leap = new LeapMotionP5(this);
}

public void draw() {

	Finger f = c.frame().fingers().frontmost();
	
	if (f.isValid() && drawing) {
		cPos = leap.getTip(f);

		path.add(cPos);

		for (int i = path.size() - 1 ; i > 0; i--) {
			line(path.get(i).x, path.get(i).y, path.get(i - 1).x, path.get(i - 1).y);
		}
	}
}

public void circleGestureRecognized(CircleGesture gesture, String clockWiseness) {
	// START, UPDATE, STOP
	if (gesture.state() == State.STATE_STOP) {
		drawing = false;
	}
	else if (gesture.state() == State.STATE_UPDATE) {
		drawing = false;
	}
	else if (gesture.state() == State.STATE_START) {
		drawing = false;
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
