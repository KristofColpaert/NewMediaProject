import fingertracker.*;
import SimpleOpenNI.*;

FingerTracker fingers;
SimpleOpenNI kinect;
int threshold = 625;

PVector position = new PVector(0, 0);
PVector previousPosition = new PVector(0, 0);

void setup()
{
	size(640, 480);

	kinect = new SimpleOpenNI(this);
	kinect.enableDepth();
	kinect.setMirror(true);

	fingers = new FingerTracker(this, 640, 480);
	fingers.setMeltFactor(100);
}

void draw()
{
	kinect.update();

	fingers.setThreshold(threshold);

	int[] depthMap = kinect.depthMap();
	fingers.update(depthMap);

	//Get fingers
	previousPosition = position;
	position = fingers.getFinger(0);

	stroke(#FFCC00);
	strokeWeight(10);
	line(position.x, position.y, previousPosition.x, previousPosition.y);	
}