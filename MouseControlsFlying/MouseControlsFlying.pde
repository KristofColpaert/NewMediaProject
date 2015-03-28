Drone drone;
ArrayList<ArrayList<PVector>> positionArrays;
ArrayList<PVector> positions;

/*
** Setup method.
*/
void setup()
{
	// Screen properties.
	size(1200, 800);
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

	else if(keyPressed == true && mousePressed == false)
	{
		if(keyCode == CONTROL && !positions.isEmpty())
		{
			snapPointsHorizontalVertical();
			positionArrays.add(positions);
			positions = new ArrayList<PVector>();
		}

		else
		{
			if(!positions.isEmpty())
			{
				snapPoints();
				positionArrays.add(positions);
				positions = new ArrayList<PVector>();
			}
		}
	}

	else 
	{
		if(!positions.isEmpty())
		{
			snapPoints();
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
** Method to snap points to one shape.
*/
void snapPoints()
{
	if(positions.size() > 1)
	{
		PVector firstPosition = positions.get(0);
		PVector lastPosition = positions.get(positions.size() - 1);

		float xDifference = Math.abs(firstPosition.x - lastPosition.x);
		float yDifference = Math.abs(firstPosition.y - lastPosition.y);

		if(xDifference < 10 && yDifference < 10)
		{
			snapCircle();
			return;
		}

		positions = new ArrayList<PVector>();
		positions.add(firstPosition);
		positions.add(lastPosition);

		drawBackground();
		drawShape();
		drawPreviousShapes();
	}
}

/*
** Method to snap points to a horizontal or vertical line.
*/
void snapPointsHorizontalVertical()
{
	if(positions.size() > 1)
	{
		PVector firstPosition = positions.get(0);
		PVector lastPosition = positions.get(positions.size() - 1);

		float xDifference = Math.abs(firstPosition.x - lastPosition.x);
		float yDifference = Math.abs(firstPosition.y - lastPosition.y);

		if(xDifference > yDifference)
		{
			lastPosition.y = firstPosition.y;
		}

		else 
		{
			lastPosition.x = firstPosition.x;	
		}

		positions = new ArrayList<PVector>();
		positions.add(firstPosition);
		positions.add(lastPosition);

		drawBackground();
		drawShape();
		drawPreviousShapes();
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
		ArrayList<PVector> currentPath = positionArrays.get(0);
		println(positionArrays);
		if(currentPath.isEmpty())
		{
			currentPath = positions;
		}

		if(currentPath.size() == 2)
		{
			flyLine(currentPath);
		}
	}
}

/*
** Method to make the drone fly a straight line.
*/
void flyLine(ArrayList<PVector> currentPath)
{
	println("hier");
	// Calculate speed en duration of the movement.
	PVector firstPosition = currentPath.get(0);
	PVector lastPosition = currentPath.get(1);

	float xDifference = Math.abs(firstPosition.x - lastPosition.x);
	float yDifference = Math.abs(firstPosition.y - lastPosition.y);

	float xyRelationship = 0;
	if(yDifference != 0)
	{	
		 xyRelationship = xDifference / yDifference;
	}

	int timespan = Math.round(xDifference);
	int xSpeed;
	if(xDifference != 0)
	{
		xSpeed = 20;
	}

	else
	{
		xSpeed = 0;	
	}

	int ySpeed;
	if(yDifference != 0)
	{
		ySpeed = Math.round(xSpeed / xyRelationship);
	}

	else if(xyRelationship == 0)
	{
		ySpeed = 20;
	}

	else 
	{
		ySpeed = 0;
	}

	/*
	** Make the drone move in the right direction.
	*/

	// Left to right && down to up.
	if(firstPosition.x < lastPosition.x && firstPosition.y > lastPosition.y)
	{
		int currentTime = millis();
		while(millis() <= currentTime + timespan)
		{
			drone.right(xSpeed, 1);
			drone.up(ySpeed, 1);
			println(xSpeed);
			println(ySpeed);
		}
	}

	// Left to right && up to down.
	else if(firstPosition.x < lastPosition.x && firstPosition.y < lastPosition.y)
	{
		int currentTime = millis();
		while(millis() <= currentTime + timespan)
		{
			drone.right(xSpeed, 1);
			drone.down(ySpeed, 1);
			println(xSpeed);
			println(ySpeed);
		}
	}

	// Right to left && down to up.
	else if(firstPosition.x > lastPosition.x && firstPosition.y > lastPosition.y)
	{
		int currentTime = millis();
		while(millis() <= currentTime + timespan)
		{
			drone.left(xSpeed, 1);
			drone.down(ySpeed, 1);
			println(xSpeed);
			println(ySpeed);
		}
	}

	// Right to left && up to down.
	else if(firstPosition.x > lastPosition.x && firstPosition.y < lastPosition.y)
	{
		int currentTime = millis();
		while(millis() <= currentTime + timespan)
		{
			drone.left(xSpeed, 1);
			drone.up(ySpeed, 1);
			println(xSpeed);
			println(ySpeed);
		}
	}

	// Left to right && horizontal.
	else if(firstPosition.x < lastPosition.x && firstPosition.y == lastPosition.y)
	{
		int currentTime = millis();
		while(millis() <= currentTime + timespan)
		{
			drone.right(xSpeed, 1);
			println(xSpeed);
		}
	}

	// Right to left && horizontal.
	else if(firstPosition.x > lastPosition.x && firstPosition.y == lastPosition.y)
	{
		int currentTime = millis();
		while(millis() <= currentTime + timespan)
		{
			drone.left(xSpeed, 1);
			println(xSpeed);
		}
	}

	// Up to down && vertical.
	else if(firstPosition.x == lastPosition.x && firstPosition.y < lastPosition.y)
	{
		int currentTime = millis();
		while(millis() <= currentTime + timespan)
		{
			drone.down(ySpeed, 1);
			println(ySpeed);
		}
	}

	// Down to up && vertical.
	else if(firstPosition.x == lastPosition.x && firstPosition.y > lastPosition.y)
	{
		int currentTime = millis();
		while(millis() <= currentTime + timespan)
		{
			drone.up(ySpeed, 1);
			println(ySpeed);
		}
	}

	drone.hover();

	positionArrays.remove(0);
	drawBackground();
	drawPreviousShapes();

}