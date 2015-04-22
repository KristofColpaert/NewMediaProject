import com.onformative.leap.*;
import com.leapmotion.leap.*;

PVector cPos = new PVector(width/2, height/2,0);
ArrayList<PVector> path;
Controller c = new Controller();
Frame f;
LeapMotionP5 leap;
Boolean drawing = false;

int timer = 0;

void setup() {
	size(displayWidth, displayHeight - 45, P3D);
	noStroke();
	smooth();
	fill(#F2DA63);
	stroke(#E85E00);
	strokeWeight(11);

	background(#333333);

	cPos = new PVector(width*.5, width*.5);

	path = new ArrayList<PVector>();
	leap = new LeapMotionP5(this);
	drawGrid();
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

void drawGrid() {
	// int row, col = 40;

	// draw horizontal
	for (int i = 0; i < len; i+40) {
		
	}

	// draw vertical
	for (int i = 0; i < len; i+40) {
		
	}
}

void keyPressed() {
	// Reset
	if (key == 'R' || key == 'r') {
		cPos = null;
		path = new ArrayList<PVector>();
		background(#333333);
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