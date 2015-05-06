// Main objects
Drone drone;
LeapMotion leapMotion;

// Lists with current and previous positions
ArrayList<PVector> positions;
ArrayList<ArrayList<PVector>> positionArrays;

// Size of the screen which you're drawing
int screenWidth = 0;
int screenHeight = 0;

// Booleans for the different modes of the game
Boolean splash = true;
Boolean splashMove = false;
Boolean intro = false;
Boolean game = false;

// Booleans that marks if the user is drawing or flying
Boolean isDrawing = false;
Boolean isFlying = false;

// Global positions for the splash screen
int posX = 0; 
int posY = 0;

// Grid variables
int gridDelta = 0;
int gridX = 0; 
int gridY = 0;
int xLijnen = 0;
int yLijnen = 0;

// Background image
PImage bg; 

// Global definitions for log messages
Boolean logging = false;
int currentLogTime = 0;

/*
** Setup method
*/ 
void setup() 
{
	// Global properties
	screenWidth = displayWidth;
	screenHeight = displayHeight - 22;
	positions = new ArrayList<PVector>();
	positionArrays = new ArrayList<ArrayList<PVector>>();
	posX = screenWidth / 2 - 150;
	posY = screenHeight / 2 - 300;

	// Grid properties
	gridDelta = screenWidth / 50;
	gridX = gridDelta / 4;
	gridY = gridDelta / 4;

	// Screen properties
	size(screenWidth, screenHeight);
	smooth();
	frameRate(30);

	// Drone
	drone = new Drone();
}

/*
** Draw method
*/
void draw() 
{
	if(splash)
	{
		if(!splashMove)
		{
			posX += 5;
			posY += 5;
		}
		else
		{
			posX -= 5;
		}

		splash();
	}

	else if(intro)
	{
		drawGrid();
	}

	else if(game)
	{
		drone.hover();
		detectFingerPosition();
		showBattery();
		showControls();
		drawShape();
	}

	if(logging && millis() > currentLogTime + 5000)
	{
		logging = false;
		currentLogTime = 0;
		drawBackground();
		drawShape();
		drawPreviousShapes();
	}
}

/*
** Method to detect key presses
*/
void keyPressed() 
{
	// SPACE BAR: skip splash and start or stop drawing
	if(keyCode == 32)
	{
		if(!intro && !game && !splash)
		{
			background(#222222);
			intro = true;
		}

		else if(!isDrawing && game && leapMotion == null)
		{
			leapMotion = new LeapMotion(this);
			leapMotion.startDrawing();
			isDrawing = true;
		}

		else if(isDrawing && game && leapMotion != null)
		{
			leapMotion.stopDrawing();
			leapMotion = null;
			isDrawing = false;
		}
	}

	// DOWN: reset drawing
	else if(keyCode == DOWN)
	{
		positions = new ArrayList<PVector>();
		positionArrays = new ArrayList<ArrayList<PVector>>();
		drawBackground();
	}

	// UP: make the drone execute a flight
	else if(keyCode == UP)
	{
		if(!positionArrays.isEmpty())
		{
			ArrayList<PVector> currentPath = positionArrays.get(0);
			flyLine(currentPath);
		}

		else
		{
			logMessage("No drawings were detected");
		}
	}

	// LEFT: make the drone take off
	else if(keyCode == LEFT)
	{
		logMessage("Drone taking off");
		drone.executePath = true;
		drone.takeOff();
		isFlying = true;
	}

	else if(keyCode == RIGHT)
	{
		logMessage("Drone landing");
		drone.executePath = false;
		drone.landing();
		isFlying = false;
	}
}

/*
** Method to show the splash screen
*/
void splash() 
{
	background(#266F97);

	PShape logo = loadShape("assets/logo.svg");
	shape(logo, screenWidth / 2 - 150, screenHeight / 2 - 300, 300, 300);
	PShape hand = loadShape("assets/hand.svg");
	shape(hand, posX, posY, 300, 300);

	// Check if hand reaches first or second position
	if(posX == screenWidth / 2 + 65)
	{
		splashMove = true;
	}

	else if(splashMove == true && posX <= screenWidth / 2 - 25)
	{
		splash = false;

		int time = millis();
		while(millis() < time + 500);

		textAlign(CENTER, CENTER);
		textFont(createFont("Open Sans", 56, true));
		text("Leap Motion Drone", screenWidth / 2, screenHeight / 2 + 225);
	}
}

/*
** Method to draw an on screen grid
*/ 
void drawGrid()
{
	stroke(#266F97);
	if (xLijnen <= 2 && yLijnen <= 3) 
	{
		line(0, gridY, screenWidth, gridY);
		line(gridX, 0, gridX, screenHeight);

		xLijnen++;
		yLijnen++;

		gridX += gridDelta;
		gridY += gridDelta;
	}

	else 
	{
		line(gridX, 0, gridX, screenHeight);
		gridX += gridDelta;
		line(gridX, 0, gridX, screenHeight);
		gridX += gridDelta;

		yLijnen = 0;
		xLijnen = 0;
	}

	if(gridX > screenWidth) 
	{
		intro = false;
		game = true;
		bg = get(0, 0, width, height);
	}
}

/*
** Draw the background grid as an image
*/
void drawBackground() 
{
	if(bg != null)
	{
		image(bg, 0, 0);
	}
}

/*
** Show the battery percentage on the screen
*/
void showBattery() 
{
	textFont(createFont("Open Sans", 72, true));
	text("" + drone.getBattery(), screenWidth - 100, 100);

	textFont(createFont("Open Sans", 15, true));
	text("% battery", screenWidth - 100, 150);
}

/*
** Show the controls on the screen
*/
void showControls()
{
	PShape logo1 = loadShape("assets/buttonUp.svg");
	shape(logo1, 100, screenHeight - 250, 100, 100);

	PShape logo2 = loadShape("assets/buttonUp.svg");
	shape(logo2, 200, screenHeight - 250, 100, 100);

	PShape logo3 = loadShape("assets/buttonUp.svg");
	shape(logo3, 150, screenHeight - 150, 100, 100);

	PShape logo4 = loadShape("assets/buttonUp.svg");
	shape(logo4, 250, screenHeight - 150, 100, 100);
}


/*
** Method to detect the position of the finger
*/
void detectFingerPosition() 
{
	if(isDrawing == true)
	{
		stroke(#EEEEEE);
		strokeWeight(7);
		PVector newPosition = leapMotion.getCurrentFingerPosition();
		if(newPosition != null)
		{
			positions.add(newPosition);
		}
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
** Method to draw the current shape on the screen
*/
void drawShape() {
	if(positions.size() > 1)
	{
		for(int i = 0; i < positions.size() - 1; i++)
		{
			PVector currentPosition = positions.get(i);
			PVector previousPosition = positions.get(i + 1);
			line(currentPosition.x, currentPosition.y, previousPosition.x, previousPosition.y);
		}
	}
}

/*
** Method to draw the previously saved shapes on the screen
*/
void drawPreviousShapes() 
{
	for(ArrayList<PVector> positionArray : positionArrays)
	{
		if(positionArray.size() > 2)
		{
			for(int i = 0; i < positionArray.size() - 1; i++)
			{
				PVector currentPosition = positionArray.get(i);
				PVector previousPosition = positionArray.get(i + 1);
				line(currentPosition.x, currentPosition.y, previousPosition.x, previousPosition.y);
			}
		}
	}
}

/*
** Method to make the drone fly a line
*/
void flyLine(ArrayList<PVector> currentPath) 
{
	if (isFlying) 
	{
		drone.move(currentPath);

		positionArrays.remove(0);
		drawBackground();
		drawPreviousShapes();
	}

	else 
	{
		logMessage("Drone should be flying before you can execute a path");	
	}
}

/*
** Method to log messages to the user
*/
void logMessage(String message)
{
	currentLogTime = millis();
	logging = true;
	textFont(createFont("Open Sans", 24));
	text(message, screenWidth / 2, screenHeight - 100);
}