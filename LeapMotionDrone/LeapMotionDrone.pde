Drone drone;
LeapMotion leapMotion;
ArrayList<ArrayList<PVector>> positionArrays;
ArrayList<PVector> positions;

// Size of the screen in which you're drawing.
int sWidth = 0;
int sHeight = 0;

// Boolean to detect if drawing is on or off.
Boolean isDrawing = false;
Boolean isFlying = true;
Boolean intro = false;
Boolean splash = true;

int posX = 0;
int posY = 0;
int rot = 0;

int gridDelta = 0;
int gridX = 0;
int gridY = 0;
int xLijnen = 0;
int yLijnen = 0;
PImage bg;

/*
** Setup method.
*/
void setup()
{
	// Screen properties.
	sWidth = displayWidth;
	sHeight = displayHeight - 22;
	size(sWidth, sHeight);
	smooth();
	stroke(#266F97);
	background(#222222);
	strokeWeight(1);
	frameRate(30);

	posX = sWidth / 2 - 150;
	posY = sHeight / 2 - 300;
	splash();

	gridDelta = sWidth / 50;
	gridX = gridDelta / 4;
	gridY = gridDelta / 4;

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
	if (splash) {
		posX+=5;
		posY+=5;
		splash();
	}
	else if (!intro) {
		drone.hover();
		detectFingerPosition();
		showBattery();
		drawShape();
	}
	else
	{
		drawBackground();
	}
}

void splash() {
	background(#266F97);
	PShape logo = loadShape("assets/logo.svg");
	shape(logo, sWidth / 2 - 150, sHeight / 2 - 300, 300, 300);

	tint(255, 127);
	PShape hand = loadShape("assets/hand.svg");
	shape(hand, posX, posY, 300, 300);

	if (posX >= sWidth / 2 + 50) {
		intro = true;
		splash = false;
		background(#222222);
	}
	// intro = true;
}

/*
** Method to draw the background color.
*/
void drawBackground()
{
	if (intro) {
		drawGrid();
	}
	else {
		// neem foto als achtergrond
		if(bg != null) {
			image(bg, 0, 0);
		}
	}
}

void drawGrid() 
{
	// println(xLijnen + ";" + yLijnen);
	// per 3 | lijnen moeten er 2 – komen

	// ylijn = |
	// xLijn = –

	if (xLijnen <= 2 && yLijnen <= 3) {
		line(0, gridY, sWidth, gridY);
		line(gridX, 0, gridX, sHeight);

		xLijnen++;
		yLijnen++;

		gridX += gridDelta;
		gridY += gridDelta;
	}

	else {
		line(0, gridY, sWidth, gridY);
		yLijnen = 0;
		xLijnen = 0;
		gridY += gridDelta;
	}

	if(gridX > sWidth) {
		intro = false;
		bg = get(0, 0, width, height);
	}
}

void showBattery()
{
	textFont(createFont("Open Sans", 72));
	text("" + drone.getBattery(), sWidth - 100, 100);
	// text("38", sWidth - 150, 100);

	textFont(createFont("Open Sans", 15));
	text("% battery", sWidth - 150, 130);
}

/*
** Method to detect the position of the finger.
*/
void detectFingerPosition()
{
	if(isDrawing == true)
	{
		stroke(#EEEEEE);
		strokeWeight(7);
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
			leapMotion = new LeapMotion(this);
			leapMotion.startDrawing();
			isDrawing = true;
		}

		else
		{
			leapMotion.stopDrawing();
			leapMotion = null;
			isDrawing = false;
		}
	}

	// Let the drone take off.
	else if(keyCode == CONTROL)
		drone.takeOff();

	// Let the drone land.
	else if(keyCode == ALT) {
		isFlying = false;
		drone.landing();
	}
}

/*
** Method to make the drone fly a line.
*/
void flyLine(ArrayList<PVector> currentPath)
{
	if (isFlying) {
		drone.move(currentPath);
	
		positionArrays.remove(0);
		drawBackground();
		drawPreviousShapes();
	}
	else {
		drone.landing();
	}
}