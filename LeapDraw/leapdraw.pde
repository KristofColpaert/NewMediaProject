import com.onformative.leap.*;
import com.leapmotion.leap.*;

PVector cPos;
ArrayList<PVector> trail;
int trailSize = 20;

Controller c = new Controller();

Frame f;

LeapMotionP5 leap;

void setup() {
	size(1920, 900, P3D);
	noStroke();
	cPos = new PVector(width*.5, width*.5);
	trail = new ArrayList<PVector>();
	leap = new LeapMotionP5(this);
	smooth();

	fill(#F2DA63);
	stroke(#E85E00);
	strokeWeight(10);

}

void draw() {
	background(#333333);
	Finger f = c.frame().fingers().frontmost();
	println("f: "+f);
	if (f.isValid()) {
		cPos = leap.getTip(f);	
		if (trail.size() < trailSize) {
			trail.add(cPos);
		}
		else {
			trail = new ArrayList<PVector>(trail.subList(1, trailSize - 1));
			trail.add(cPos);
		}
	
		for (int i = trail.size() - 2 ; i > 0; i--) {
			line(trail.get(i).x, trail.get(i).y, trail.get(i - 1).x, trail.get(i - 1).y);
		}	
	}

}