/*
** Class in which we provide access to the Leap Motion device.
** Leap Motion library: LeapMotionP5.
*/
import com.onformative.leap.*;
import com.leapmotion.leap.*;

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
	void setFirstFinger()
	{
		finger = controller.frame().fingers().frontmost();
	}

	/*
	** Method to get the current position of the drawing finger.
	*/
	PVector getCurrentFingerPosition()
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
	void startDrawing()
	{
		setFirstFinger();
		isDrawing = true;
	}

	/*
	** Method to stop the drawing.
	*/
	void stopDrawing()
	{
		finger = null;
		isDrawing = false;
	}

	/*
	** Method to log errors to the command line console.
	*/ 
	void logError(String message)
	{
		println("An error ocurred while running the program: " + message);
	}
}