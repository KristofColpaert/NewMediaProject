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
public void setup()
{
	// Screen properties.
	size(sWidth, sHeight);
	smooth();
	stroke(0xffFFCC00);
	strokeWeight(10);
	drawBackground();
	frameRate(30);

	// Make new instance of Drone class.
	drone = new Drone();

	// Initialisation of lists.
	positions = new ArrayList<PVector>();
	positionArrays = new ArrayList<ArrayList<PVector>>();
}

/*
** Method which should run 30 times every second.
*/
public void draw()
{
	drone.hover();
	detectFingerPosition();
	drawShape();
}

/*
** Method to draw the background color.
*/
public void drawBackground()
{
	background(0xff333333);
}

/*
** Method to detect the position of the mouse when clicking.
*/
public void detectFingerPosition()
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
public void drawShape()
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
public void drawPreviousShapes()
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
public void keyPressed()
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
	else if(keyCode == ALT)
		drone.landing();
}

/*
** Method to make the drone fly a line.
*/
public void flyLine(ArrayList<PVector> currentPath)
{
	drone.move(currentPath);
	
	positionArrays.remove(0);
	drawBackground();
	drawPreviousShapes();
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
	CommandManager commandManager;

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
				int timespan = 1000;
				float xSpeed = map(xDifference, 0, sWidth, 10, 40);
				float ySpeed = map(yDifference, 0, sHeight, 40, 100);

				int intXSpeed = Math.round(xSpeed);
				int intYSpeed = Math.round(ySpeed);

				int currentTime = millis();
				while(millis() < currentTime + timespan)
				{
					this.left(intXSpeed, 1);
					this.up(intYSpeed, 1);
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
					this.left(intXSpeed, 1);
					this.down(intYSpeed, 1);
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
					this.right(intXSpeed, 1);
					this.up(intYSpeed, 1);
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
