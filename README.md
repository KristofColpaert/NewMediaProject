# NewMediaProject

Een overzicht van de applicaties
- Keyboarcontrols: applicatie waarmee je de drone met behulp van het keyboard van een computer kan besturen. 
  -   CTRL: take off.
  -   ALT: landing.
  -   LEFT: links.
  -   RIGHT: rechts.
  -   UP: vooruit.
  -   DOWN: achteruit.
  -   A: stijgen.
  -   B: dalen.

- MouseControls: applicatie waarmee je op het canvas tekeningen kan maken. Om het eenvoudig te houden, worden alle lijnen automatisch gesnapt naar rechten in X en Y. Ronde patronen worden automatisch gesnapt naar een overeenkomstige cirkel.
  -   CTRL: laat toe om rechten evenwijdig met de x-as en de y-as te tekenen. Zie analogie met Photoshop.

- MouseControlsFlying: applicatie die vormen op het canvas omzet in daadwerkelijke dronebewegingen.
  -   Bouwt verder op bovenstaande applicatie. De controls zijn dus dezelfde.

- MouseControlsFlying2: verbeterde versie van de MouseControlsFlying-applicatie. Het lukt om met de muis vormen op het scherm te tekenen die dan later uitgevoerd worden met een drone.
  -   CTRL: take off.
  -   ALT: landing. 
  -   A: zet tekeningen die gemaakt zijn met de muis om in dronebewegingen.
  
- KinectTest: test waarbij we de functionaliteit voor de Leap Motion (zie LeapDraw) herschreven hebben naar een Microsoft Kinect. Het resultaat was onvoldoende accuraat.

- LeapDraw: applicatie die vingerbewegingen boven de Leap Motion omzet naar tekeningen op het scherm.

- LeapMotionDrone: het eindresultaat van dit project. Met de Leap Motion worden tekeningen op het scherm gemaakt. Die tekeningen worden vervolgens omgezet in bewegingen van de drone.
  -   SPACE: start/stop het tekenen met de Leap Motion.
  -   LEFT: take off.
  -   RIGHT: landing.
  -   UP: zet tekeningen met de Leap Motion om in dronebewegingen.
  -   DOWN: maak het scherm leeg. Start opnieuw met tekenen.
