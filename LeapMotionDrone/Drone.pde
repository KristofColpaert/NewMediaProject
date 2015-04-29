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
	int battery;

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
	void logException(Exception ex)
	{
		println("An error occured while running the program: " + ex.getMessage());
	}

	/*
	** Method to log battery status to the command line console.
	*/
	void logBattery(int percentage)
	{	
		println("Current battery status: " + percentage + "%");
	}

	/*
	** Method to return the battery percentage.
	*/
	int getBattery()
	{
		return battery;
	}

	/*
	** Method to let the drone takeoff.
	*/
	void takeOff()
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
	void landing()
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
	void hover()
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
	void up(int speed, int timespan)
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
	void down(int speed, int timespan)
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
	void forward(int speed, int timespan)
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
	void backward(int speed, int timespan)
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
	void left(int speed, int timespan)
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
	void right(int speed, int timespan)
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
	void move(ArrayList<PVector> currentPath)
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
				while(millis() < currentTime + timespan)
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
				while(millis() < currentTime + timespan)
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
				while(millis() < currentTime + timespan)
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