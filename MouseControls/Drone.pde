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
			newDrone.setMaxAltitude(3000);

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
	void up()
	{
		try 
		{
			commandManager.up(20).doFor(1);
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone descend.
	*/
	void down()
	{
		try 
		{
			commandManager.down(20).doFor(1);
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone move forward.
	*/
	void forward()
	{
		try 
		{
			commandManager.forward(20).doFor(1);	
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone move backward.
	*/
	void backward()
	{
		try
		{
			commandManager.backward(20).doFor(1);
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone move left.
	*/
	void left()
	{
		try 
		{
			commandManager.goLeft(20).doFor(1);	
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}

	/*
	** Method to let the drone move right.
	*/
	void right()
	{
		try
		{
			commandManager.goRight(20).doFor(1);
		}

		catch(Exception ex)
		{
			logException(ex);
		}
	}
}