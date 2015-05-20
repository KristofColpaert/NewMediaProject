import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import com.onformative.leap.*; 
import com.leapmotion.leap.*; 

import de.yadrone.base.exception.*; 
import de.yadrone.apps.controlcenter.plugins.connection.*; 
import de.yadrone.apps.tutorial.*; 
import de.yadrone.apps.controlcenter.plugins.console.*; 
import de.yadrone.apps.controlcenter.plugins.state.*; 
import de.yadrone.base.navdata.*; 
import de.yadrone.apps.paperchase.*; 
import de.yadrone.apps.controlcenter.plugins.keyboard.*; 
import de.yadrone.apps.controlcenter.plugins.battery.*; 
import de.yadrone.apps.controlcenter.plugins.qrcode.*; 
import de.yadrone.apps.controlcenter.plugins.statistics.*; 
import de.yadrone.base.command.*; 
import de.yadrone.base.configuration.*; 
import de.yadrone.base.*; 
import de.yadrone.apps.controlcenter.plugins.qrcode.generator.*; 
import de.yadrone.apps.controlcenter.plugins.pluginmanager.*; 
import de.yadrone.apps.controlcenter.plugins.attitudechart.*; 
import de.yadrone.base.video.*; 
import de.yadrone.apps.controlcenter.plugins.configuration.*; 
import de.yadrone.apps.controlcenter.plugins.speed.*; 
import de.yadrone.base.utils.*; 
import de.yadrone.apps.controlcenter.plugins.video.*; 
import de.yadrone.base.video.xuggler.*; 
import de.yadrone.base.manager.*; 
import de.yadrone.apps.paperchase.controller.*; 
import de.yadrone.apps.controlcenter.*; 
import de.yadrone.apps.controlcenter.plugins.altitude.*; 
import com.onformative.leap.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class LeapMotionDrone extends PApplet {

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
public void setup() 
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
public void draw() 
{
	if(splash)
	{
		if(splashMove)
		{
			posX -= 8;
		}
		else
		{
			posX += 8;
			posY += 8;
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

	if(logging && millis() > currentLogTime + 1500)
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
public void keyPressed() 
{
	// SPACE BAR: skip splash and start or stop drawing
	if(keyCode == 32)
	{         
		if(!intro && !game && !splash)
		{
			background(0xff222222);
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
			if(currentLogTime == 0)
			{
				logMessage("No drawings were detected");
			}
		}
	}

	// LEFT: make the drone take off
	else if(keyCode == LEFT)
	{
		if(currentLogTime == 0)
		{
			logMessage("Drone taking off");
		}
		
		drone.executePath = true;
		drone.takeOff();
		isFlying = true;
	}
	else if(keyCode == RIGHT)
	{
		if(currentLogTime == 0)
		{
			logMessage("Drone landing");
		}
		
		drone.executePath = false;
		drone.landing();
		isFlying = false;
	}
}

/*
** Method to show the splash screen
*/
public void splash() 
{
	background(0xff266F97);

	PShape logo = loadShape("assets/logo.svg");
	shape(logo, screenWidth / 2 - 150, screenHeight / 2 - 300, 300, 300);
	PShape hand = loadShape("assets/hand.svg");
	shape(hand, posX, posY, 300, 300);

	// Check if hand reaches first or second position
	if(posX >= screenWidth / 2 + 65) 
	{
		splashMove = true;
	}

	if(splashMove && posX <= screenWidth / 2 - 25) 
	{
		splash = false;
		int time = millis();
		while(millis() < time + 500);

		splashMove = false;
		textAlign(CENTER, CENTER);
		textFont(createFont("Open Sans", 56, true));
		text("Press forward to start", screenWidth / 2, screenHeight / 2 + 225);
	}
}

/*
** Method to draw an on screen grid
*/ 
public void drawGrid() 
{
	stroke(0xff266F97);
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
public void drawBackground() 
{
	if(bg != null)
	{
		image(bg, 0, 0);
	}
}

/*
** Show the battery percentage on the screen
*/
public void showBattery() 
{
	textAlign(CENTER, CENTER);
	textFont(createFont("Open Sans", 72, true));
	text("" + drone.getBattery(), screenWidth - 100, 100);

	textFont(createFont("Open Sans", 15, true));
	text("% battery", screenWidth - 100, 150);
}

/*
** Show the controls on the screen
*/
public void showControls() 
{
	textAlign(LEFT, CENTER);
	textFont(createFont("Open Sans", 32, true));
	text("Controls", 100, screenHeight -300);

	PImage logo1 = loadImage("assets/buttonUp.png");
	image(logo1, 100, screenHeight - 250, 80, 80);

	PImage logo2 = loadImage("assets/buttonFlyLine.png");
	image(logo2, 200, screenHeight - 250, 80, 80);

	PImage logo3 = loadImage("assets/buttonDown.png");
	image(logo3, 150, screenHeight - 150, 80, 80);

	PImage logo4 = loadImage("assets/buttonErase.png");
	image(logo4, 250, screenHeight - 150, 80, 80);

	PImage logo5 = loadImage("assets/buttonDraw.png");
	image(logo5, 400, screenHeight - 250, 180, 180);
}


/*
** Method to detect the position of the finger
*/
public void detectFingerPosition() 
{
	if(isDrawing == true)
	{
		stroke(0xffEEEEEE);
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
public void drawShape() 
{
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
public void drawPreviousShapes() 
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
public void flyLine(ArrayList<PVector> currentPath) 
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
public void logMessage(String message) 
{
	currentLogTime = millis();
	logging = true;
	textFont(createFont("Open Sans", 24));
	text(message, screenWidth / 2, screenHeight - 100);
}
/*
** Class in which we provide access to the Parrot AR Drone 2.0.
** ARDrone library: YaDrone.
*/
class Drone
{
	/*
	** Fields
	*/
	ARDrone newDrone = null;
	CommandManager commandManager = null;
	int battery = 0;
	Boolean executePath = true;

	/*
	** Constructor trying to set up the drone and its listeners.
	*/
	Drone()
	{
		// Set up new drone object.
		try 
		{
			newDrone = new ARDrone();
			newDrone.start();
			newDrone.setMaxAltitude(5000);

			commandManager = newDrone.getCommandManager();
		}
		
		catch(Exception ex)
		{
			logException(ex);
		}

		// Battery status listener.
		newDrone.getNavDataManager().addBatteryListener(new BatteryListener()
		{
			public void batteryLevelChanged(int percentage)
			{
				battery = percentage;
				logBattery(percentage);
			}

			public void voltageChanged(int vbat_raw)
			{ }
		});
	}

	/*
	** Method to log exceptions to the command line console.
	*/
	public void logException(Exception ex)
	{
		println("An error occured while running the program: " + ex.getMessage());
	}

	/*
	** Method to log battery status to the command line console.
	*/
	public void logBattery(int percentage)
	{	
		println("Current battery status: " + percentage + "%");
	}

	/*
	** Method to return the battery percentage.
	*/
	public int getBattery()
	{
		return battery;
	}

	/*
	** Method to let the drone takeoff.
	*/
	public void takeOff()
	{
		try 
		{
			commandManager.takeOff().doFor(2000);
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone land.
	*/
	public void landing()
	{
		try
		{
			commandManager.landing(); 
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone hover for a certain time.
	*/
	public void hover()
	{
		try 
		{
			commandManager.hover();
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone ascend.
	*/
	public void up(int speed, int timespan)
	{
		try 
		{
			commandManager.up(speed).doFor(timespan);
			println("up");
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone descend.
	*/
	public void down(int speed, int timespan)
	{
		try 
		{
			commandManager.down(speed).doFor(timespan);
			println("down");
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone move forward.
	*/
	public void forward(int speed, int timespan)
	{
		try 
		{
			commandManager.forward(speed).doFor(timespan);	
			println("forward");
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone move backward.
	*/
	public void backward(int speed, int timespan)
	{
		try
		{
			commandManager.backward(speed).doFor(timespan);
			println("backward");
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone move left.
	*/
	public void left(int speed, int timespan)
	{
		try 
		{
			commandManager.goLeft(speed).doFor(timespan);
			println("left");	
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone move right.
	*/
	public void right(int speed, int timespan)
	{
		try
		{
			commandManager.goRight(speed).doFor(timespan);
			println("right");
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to make the drone fly a line.
	*/
	public void move(ArrayList<PVector> currentPath)
	{
		for(int i = 0, j = currentPath.size() - 5; i < j; i += 5)
		{
			PVector currentVector = currentPath.get(i);
			PVector nextVector = currentPath.get(i + 5);

			float xDifference = currentVector.x - nextVector.x;
			float yDifference = currentVector.y - nextVector.y;

			if(xDifference > 0 && yDifference > 0)
			{
				int timespan = 500;
				float xSpeed = map(xDifference, 0, screenWidth, 10, 40);
				float ySpeed = map(yDifference, 0, screenHeight, 40, 100);

				int intXSpeed = Math.round(xSpeed);
				int intYSpeed = Math.round(ySpeed);

				int currentTime = millis();
				while(executePath && millis() < currentTime + timespan)
				{
					this.left(intXSpeed, 1);
					this.up(intYSpeed, 1);
				}
			}

			else if(xDifference > 0 && yDifference < 0)
			{
				int timespan = 500;
				float xSpeed = map(xDifference, 0, screenWidth, 10, 40);
				float ySpeed = map(yDifference, 0, screenHeight, 40, 100);

				int intXSpeed = Math.round(xSpeed);
				int intYSpeed = Math.round(ySpeed);

				int currentTime = millis();
				while(executePath && millis() < currentTime + timespan)
				{
					this.left(intXSpeed, 1);
					this.down(intYSpeed, 1);
				}
			}

			else if(xDifference < 0 && yDifference > 0)
			{
				int timespan = 500;
				float xSpeed = map(xDifference, 0, screenWidth, 10, 40);
				float ySpeed = map(yDifference, 0, screenHeight, 40, 100);

				int intXSpeed = Math.round(xSpeed);
				int intYSpeed = Math.round(ySpeed);

				int currentTime = millis();
				while(executePath && millis() < currentTime + timespan)
				{
					this.right(intXSpeed, 1);
					this.up(intYSpeed, 1);
				}
			}

			else if(xDifference < 0 && yDifference < 0)
			{
				int timespan = 500;
				float xSpeed = map(xDifference, 0, screenWidth, 10, 40);
				float ySpeed = map(yDifference, 0, screenHeight, 40, 100);

				int intXSpeed = Math.round(xSpeed);
				int intYSpeed = Math.round(ySpeed);

				int currentTime = millis();
				while(executePath && millis() < currentTime + timespan)
				{
					this.right(intXSpeed, 1);
					this.down(intYSpeed, 1);
				}
			}
		}
		this.hover();
	}
}
/*
** Class in which we provide access to the Leap Motion device.
** Leap Motion library: LeapMotionP5.
*/



class LeapMotion
{
	/*
	** Fields
	*/
	Controller controller;
	LeapMotionP5 leapMotion;
	Finger finger;
	Boolean isDrawing = false;

	int timer = 0;

	/*
	** Constructor trying to set up the Leap Motion.
	*/
	LeapMotion(PApplet context)
	{
		controller = new Controller();
		leapMotion = new LeapMotionP5(context);
	}

	/*
	** Method to set the drawing finger.
	*/ 
	public void setFirstFinger()
	{
		finger = controller.frame().fingers().frontmost();
	}

	/*
	** Method to get the current position of the drawing finger.
	*/
	public PVector getCurrentFingerPosition()
	{
		setFirstFinger();
		if(finger.isValid() && isDrawing)
			return leapMotion.getTip(finger);

		else 
			logError("invalid finger or drawing not started");

		return null;
	}

	/*
	** Method to start the drawing.
	*/
	public void startDrawing()
	{
		setFirstFinger();
		isDrawing = true;
	}

	/*
	** Method to stop the drawing.
	*/
	public void stopDrawing()
	{
		finger = null;
		isDrawing = false;
	}

	/*
	** Method to log errors to the command line console.
	*/ 
	public void logError(String message)
	{
		println("An error ocurred while running the program: " + message);
	}
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "LeapMotionDrone" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
