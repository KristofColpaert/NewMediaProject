import com.onformative.leap.*;
import com.leapmotion.leap.*;

PVector cPos;
ArrayList<PVector> path;
Controller c = new Controller();
Frame f;
LeapMotionP5 leap;

void setup() {
	size(1920, 900, P3D);
	noStroke();
	cPos = new PVector(width*.5, width*.5);
	path = new ArrayList<PVector>();
	leap = new LeapMotionP5(this);
	smooth();

	fill(#F2DA63);
	stroke(#E85E00);
	strokeWeight(10);

	background(#333333);
}

void draw() {
	
	Finger f = c.frame().fingers().frontmost();
	
	if (f.isValid()) {
		cPos = leap.getTip(f);

		path.add(cPos);

		for (int i = path.size() - 2 ; i > 0; i--) {
			line(path.get(i).x, path.get(i).y, path.get(i - 1).x, path.get(i - 1).y);
		}
	}

}