import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import fingertracker.*; 
import SimpleOpenNI.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class KinectTest extends PApplet {




FingerTracker fingers;
SimpleOpenNI kinect;
int threshold = 625;

PVector position = new PVector(0, 0);
PVector previousPosition = new PVector(0, 0);

public void setup()
{
	size(640, 480);

	kinect = new SimpleOpenNI(this);
	kinect.enableDepth();
	kinect.setMirror(true);

	fingers = new FingerTracker(this, 640, 480);
	fingers.setMeltFactor(100);
}

public void draw()
{
	kinect.update();

	fingers.setThreshold(threshold);

	int[] depthMap = kinect.depthMap();
	fingers.update(depthMap);

	//Get fingers
	previousPosition = position;
	position = fingers.getFinger(0);

	stroke(0xffFFCC00);
	strokeWeight(10);
	line(position.x, position.y, previousPosition.x, previousPosition.y);	
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "KinectTest" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
