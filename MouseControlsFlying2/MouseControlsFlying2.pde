Drone drone;
ArrayList<ArrayList<PVector>> positionArrays;
ArrayList<PVector> positions;

// Size of the screen in which you're drawing.
int sWidth = 1200;
int sHeight = 800;

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
	ellipseMode(CENTER);
	noFill();

	// Make new instance of Drone class.
	drone = new Drone();

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
	detectMousePoints();
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
void detectMousePoints()
{
	if(mousePressed == true)
	{
		PVector newPVector = new PVector(mouseX, mouseY);
		positions.add(newPVector);
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
** Method to snap points to an ellipse.
*/
void snapCircle()
{
	PVector positionLeft = positions.get(0);
	PVector positionTop = positions.get(0);
	PVector positionRight = positions.get(0);
	PVector positionBottom = positions.get(0);

	for(PVector position : positions)
	{
		if(position.x < positionLeft.x)
		{
			positionLeft = position;
		}

		else if(position.x > positionRight.x)
		{
			positionRight = position;
		}

		else if(position.y < positionTop.y)
		{
			positionTop = position;
		}

		else if(position.y > positionBottom.y)
		{
			positionBottom = position;
		}
	}

	positionRight.y = positionLeft.y;
	positionBottom.x = positionTop.x;

	float xDifference = Math.abs(positionLeft.x - positionRight.x);
	float yDifference = Math.abs(positionTop.y - positionBottom.y);

	PVector center = new PVector(positionLeft.x + (xDifference / 2), positionTop.y + (yDifference / 2));

	drawBackground();
	ellipse(center.x, center.y, xDifference, yDifference);

	positions = new ArrayList<PVector>();
	positions.add(center);
	positions.add(positionTop);
	positions.add(positionLeft);
	drawPreviousShapes();
}

/*
** Method to make the drone fly the pattern.
*/
void keyPressed()
{
	if(key == 'a')
	{
		if(!positionArrays.isEmpty())
		{
			ArrayList<PVector> currentPath = positionArrays.get(0);
			println("positionArrays: " + positionArrays);
			flyLine(currentPath);
		}
	}

	else if(keyCode == CONTROL)
	{
		drone.takeOff();
	}

	else if(keyCode == ALT)
	{
		drone.landing();
	}
}

/*
** Method to make the drone fly a line.
*/
void flyLine(ArrayList<PVector> currentPath)
{
	for(int i = 0, j = currentPath.size() - 5; i < j; i += 5)
	{
		PVector currentVector = currentPath.get(i);
		PVector nextVector = currentPath.get(i + 5);

		float xDifference = currentVector.x - nextVector.x;
		float yDifference = currentVector.y - nextVector.y;

		if(xDifference > 0 && yDifference > 0)
		{
			int timespan = 1000;
			float xSpeed = map(xDifference, 0, sWidth, 10, 40);
			float ySpeed = map(yDifference, 0, sHeight, 40, 100);

			int intXSpeed = Math.round(xSpeed);
			int intYSpeed = Math.round(ySpeed);

			int currentTime = millis();
			while(millis() < currentTime + timespan)
			{
				drone.left(intXSpeed, 1);
				drone.up(intYSpeed, 1);
			}
		}

		else if(xDifference > 0 && yDifference < 0)
		{
			int timespan = 1000;
			float xSpeed = map(xDifference, 0, sWidth, 10, 40);
			float ySpeed = map(yDifference, 0, sHeight, 40, 100);

			int intXSpeed = Math.round(xSpeed);
			int intYSpeed = Math.round(ySpeed);

			int currentTime = millis();
			while(millis() < currentTime + timespan)
			{
				drone.left(intXSpeed, 1);
				drone.down(intYSpeed, 1);
			}
		}

		else if(xDifference < 0 && yDifference > 0)
		{
			int timespan = 1000;
			float xSpeed = map(xDifference, 0, sWidth, 10, 40);
			float ySpeed = map(yDifference, 0, sHeight, 40, 100);

			int intXSpeed = Math.round(xSpeed);
			int intYSpeed = Math.round(ySpeed);

			int currentTime = millis();
			while(millis() < currentTime + timespan)
			{
				drone.right(intXSpeed, 1);
				drone.up(intYSpeed, 1);
			}
		}

		else if(xDifference < 0 && yDifference < 0)
		{
			int timespan = 1000;
			float xSpeed = map(xDifference, 0, sWidth, 10, 40);
			float ySpeed = map(yDifference, 0, sHeight, 40, 100);

			int intXSpeed = Math.round(xSpeed);
			int intYSpeed = Math.round(ySpeed);

			int currentTime = millis();
			while(millis() < currentTime + timespan)
			{
				drone.right(intXSpeed, 1);
				drone.down(intYSpeed, 1);
			}
		}
	}

	drone.hover();

	positionArrays.remove(0);
	drawBackground();
	drawPreviousShapes();

}