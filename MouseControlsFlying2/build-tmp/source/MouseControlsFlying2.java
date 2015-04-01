import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

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

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class MouseControlsFlying2 extends PApplet {

Drone drone;
ArrayList<ArrayList<PVector>> positionArrays;
ArrayList<PVector> positions;

/*
** Setup method.
*/
public void setup()
{
	// Screen properties.
	size(1200, 800);
	smooth();
	stroke(0xffFFCC00);
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
public void draw()
{
	drone.hover();
	detectMousePoints();
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
public void detectMousePoints()
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
** Method to snap points to an ellipse.
*/
public void snapCircle()
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
public void keyPressed()
{
	if(key == 'a')
	{
		if(!positionArrays.isEmpty())
		{
			ArrayList<PVector> currentPath = positionArrays.get(0);
			flyLine(currentPath);
		}
	}

	else if(keyCode == CONTROL)
	{
		println("hier");
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
public void flyLine(ArrayList<PVector> currentPath)
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
			float xSpeed = map(xDifference, 0, 1200, 0, 100);
			float ySpeed = map(yDifference, 0, 1200, 0, 100);

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
			float xSpeed = map(xDifference, 0, 1200, 0, 100);
			float ySpeed = map(yDifference, 0, 1200, 0, 100);

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
			float xSpeed = map(xDifference, 0, 1200, 0, 100);
			float ySpeed = map(yDifference, 0, 1200, 0, 100);

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
			float xSpeed = map(xDifference, 0, 1200, 0, 100);
			float ySpeed = map(yDifference, 0, 1200, 0, 100);

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
/*
** Class in which we provide access to the Parrot AR Drone 2.0.
** ARDrone library: YaDrone.
*/

ARDrone newDrone = null;
CommandManager commandManager;

class Drone
{
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
			newDrone.setMaxAltitude(2000);

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
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "MouseControlsFlying2" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
