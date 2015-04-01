import com.onformative.leap.*;
import com.leapmotion.leap.*;
import com.leapmotion.leap.Gesture.*;

PVector cPos = new PVector(width/2, height/2,0);
ArrayList<PVector> path;
Controller c = new Controller();
Frame f;
LeapMotionP5 leap;
Boolean drawing = true;

void setup() {
	size(1920, 900, P3D);
	noStroke();
	smooth();
	fill(#F2DA63);
	stroke(#E85E00);
	strokeWeight(10);

	background(#333333);

	cPos = new PVector(width*.5, width*.5);

	path = new ArrayList<PVector>();
	leap = new LeapMotionP5(this);
}

void draw() {

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