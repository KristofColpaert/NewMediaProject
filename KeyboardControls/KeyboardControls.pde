Drone drone;

void setup()
{
	frameRate(10);
	drone = new Drone();
}

void draw()
{
	drone.hover();
}

void keyPressed()
{
	if(key == CODED)
	{
		if(keyCode == UP)
		{
			drone.forward();
		}

		else if(keyCode == DOWN)
		{
			drone.backward();
		}

		else if(keyCode == LEFT)
		{
			drone.left();
		}	

		else if(keyCode == RIGHT)
		{
			drone.right();
		}

		else if(keyCode == ALT)
		{
			drone.landing();
		}

		else if(keyCode == CONTROL)
		{
			drone.takeOff();
		}
	}

	// a
	else if(key == 97)
	{
		drone.up();
	}

	// b
	else if(key == 98) 
	{
		drone.down();	
	}
}