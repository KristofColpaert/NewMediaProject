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

	// Make new instance of Drone class.
	//drone = new Drone();

	// Initialisation of lists.
	positions = new ArrayList<PVector>();
	positionArrays = new ArrayList<ArrayList<PVector>>();
}

/*
** Method which should run 30 times every second.
*/
void draw()
{
	//drone.hover();
	detectMousePoints();
	drawLine();
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

	else if(keyPressed == true)
	{
		if(keyCode == CONTROL)
		{
			snapPointsHorizontalVertical();
			positionArrays.add(positions);
			positions = new ArrayList<PVector>();
		}

		else
		{
			snapPoints();
			positionArrays.add(positions);
			positions = new ArrayList<PVector>();
		}
	}

	else 
	{
		snapPoints();
		positionArrays.add(positions);
		positions = new ArrayList<PVector>();
	}
}
/*
** Method to draw the current line on the screen.
*/
void drawLine()
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
** Method to draw the saved lines on the screen.
*/
void drawPreviousLines()
{
	for(ArrayList<PVector> positionArray : positionArrays)
	{
		for(int i = 0, l = positionArray.size() - 1; i < l; i++)
		{
			PVector currentPosition = positionArray.get(i);
			PVector previousPosition = positionArray.get(i + 1);
			line(currentPosition.x, currentPosition.y, previousPosition.x, previousPosition.y);
		}
	}
}


/*
** Method to snap points to one line.
*/
void snapPoints()
{
	if(positions.size() > 1)
	{
		PVector firstPosition = positions.get(0);
		PVector lastPosition = positions.get(positions.size() - 1);

		positions = new ArrayList<PVector>();
		positions.add(firstPosition);
		positions.add(lastPosition);

		drawBackground();
		drawLine();
		drawPreviousLines();
	}
}

/*
** Method to snap point to a horizontal or vertical line.
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
		drawLine();
		drawPreviousLines();
	}
}