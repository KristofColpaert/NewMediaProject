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




PVector cPos = new PVector(width/2, height/2,0);
ArrayList<PVector> path;
Controller c = new Controller();
Frame f;
LeapMotionP5 leap;
Boolean drawing = false;

int timer = 0;

public void setup() {
	size(displayWidth, displayHeight - 45, P3D);
	noStroke();
	smooth();
	fill(0xffF2DA63);
	stroke(0xffE85E00);
	strokeWeight(11);

	background(0xff333333);

	cPos = new PVector(width*.5f, width*.5f);

	path = new ArrayList<PVector>();
	leap = new LeapMotionP5(this);
	drawGrid();
}

public void draw() {

	Finger f = c.frame().fingers().frontmost();
	
	if (f.isValid() && drawing) {
		cPos = leap.getTip(f);
		int top = path.size() - 1;

		if (top >= 0) {
			line(cPos.x, cPos.y, path.get(top).x, path.get(top).y);
		}
		path.add(cPos);
	}
}

public void drawGrid() {
	// int row, col = 40;

	// draw horizontal
	for (int i = 0; i < len; i+40) {
		
	}

	// draw vertical
	for (int i = 0; i < len; i+40) {
		
	}
}

public void keyPressed() {
	// Reset
	if (key == 'R' || key == 'r') {
		cPos = null;
		path = new ArrayList<PVector>();
		background(0xff333333);
	}

	// Toggle start / stop
	if (key == 'S' || key == 's') {
		if (drawing == false) {
			drawing = true;
		}
		else {
			drawing = false;
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
