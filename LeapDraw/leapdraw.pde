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
	strokeWeight(11);

	background(#333333);

	cPos = new PVector(width*.5, width*.5);

	path = new ArrayList<PVector>();
	leap = new LeapMotionP5(this);
}

void draw() {

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

void keyPressed() {
	if (key == 'R' || key == 'r') {
		cPos = null;
		path = new ArrayList<PVector>();
		background(#333333);
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