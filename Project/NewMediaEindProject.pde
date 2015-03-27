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
			println("1forward");
		}

		else if(keyCode == DOWN)
		{
			drone.backward();
			println("1backward");
		}

		else if(keyCode == LEFT)
		{
			drone.left();
			println("1left");
		}	

		else if(keyCode == RIGHT)
		{
			drone.right();
			println("1right");
		}

		else if(keyCode == ALT)
		{
			drone.takeOff();
			println("1take off");
		}

		else if(keyCode == CONTROL)
		{
			drone.landing();
			println("1landing");
		}
	}
}