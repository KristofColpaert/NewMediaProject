Drone drone;
LeapMotion leapMotion;
ArrayList<ArrayList<PVector>> positionArrays;
ArrayList<PVector> positions;

// Size of the screen in which you're drawing.
int sWidth = 1200;
int sHeight = 800;

// Boolean to detect if drawing is on or off.
Boolean isDrawing = false;

/*
** Setup method.
*/
void setup()
{
	// Screen properties.
	size(sWidth, sHeight);
	smooth();
	stroke(#FFCC00);
	strokeWeight(10);
	drawBackground();
	frameRate(30);

	// Make new instance of Drone class.
	drone = new Drone();

	//Make new instance of LeapMotion class.
	leapMotion = new LeapMotion(this);

	// Initialisation of lists.
	positions = new ArrayList<PVector>();
	positionArrays = new ArrayList<ArrayList<PVector>>();
}

/*
** Method which should run 30 times every second.
*/
void draw()
{
	drone.hover();
	detectFingerPosition();
	drawShape();
}

/*
** Method to draw the background color.
*/
void drawBackground()
{
	background(#333333);
}

/*
** Method to detect the position of the mouse when clicking.
*/
void detectFingerPosition()
{
	if(isDrawing == true)
	{
		PVector newPosition = leapMotion.getCurrentFingerPosition();
		if(newPosition != null)
			positions.add(newPosition);
	}

	else
	{
		if(!positions.isEmpty())
		{
			positionArrays.add(positions);
			positions = new ArrayList<PVector>();
		}
	}
}
/*
** Method to draw the current shape on the screen.
*/
void drawShape()
{
	if(positions.size() > 1)
	{
		for(int i = 0, l = positions.size() - 1; i < l; i++)
		{
			PVector currentPosition = positions.get(i);
			PVector previousPosition = positions.get(i + 1);
			line(currentPosition.x, currentPosition.y, previousPosition.x, previousPosition.y);
		}
	}
}

/*
** Method to draw the saved shapes on the screen.
*/
void drawPreviousShapes()
{
	for(ArrayList<PVector> positionArray : positionArrays)
	{
		if(positionArray.size() == 2)
		{
			for(int i = 0, l = positionArray.size() - 1; i < l; i++)
			{
				PVector currentPosition = positionArray.get(i);
				PVector previousPosition = positionArray.get(i + 1);
				line(currentPosition.x, currentPosition.y, previousPosition.x, previousPosition.y);
			}
		}

		else if(positionArray.size() == 3)
		{
			PVector center = positionArray.get(0);
			PVector positionTop = positionArray.get(1);
			PVector positionLeft = positionArray.get(2);

			float ellipseWidth = (Math.abs(positionLeft.x - center.x)) * 2;
			float ellipseHeight = (Math.abs(positionTop.y - center.y)) * 2;

			ellipse(center.x, center.y, ellipseWidth, ellipseHeight);
		}
	}
}

/*
** Method to make the drone fly the pattern.
*/
void keyPressed()
{
	// Execute flight.
	if(key == 'A' || key == 'a')
	{
		if(!positionArrays.isEmpty())
		{
			ArrayList<PVector> currentPath = positionArrays.get(0);
			println("positionArrays: " + positionArrays);
			flyLine(currentPath);
		}
	}

	// Reset drawing.
	if(key == 'R' || key == 'r')
	{
		positions = new ArrayList<PVector>();
		positionArrays = new ArrayList<ArrayList<PVector>>();
		drawBackground();
	}

	// Start or stop drawing.
	if(key == 'S' || key == 's')
	{
		if(isDrawing == false)
		{
			leapMotion.startDrawing();
			isDrawing = true;
		}

		else
		{
			leapMotion.stopDrawing();
			isDrawing = false;
		}
	}

	// Let the drone take off.
	else if(keyCode == CONTROL)
		drone.takeOff();

	// Let the drone land.
	else if(keyCode == ALT)
		drone.landing();
}

/*
** Method to make the drone fly a line.
*/
void flyLine(ArrayList<PVector> currentPath)
{
	drone.move(currentPath);
	
	positionArrays.remove(0);
	drawBackground();
	drawPreviousShapes();
}