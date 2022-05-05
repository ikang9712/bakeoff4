import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;

KetaiSensor sensor;
float light = 0; 
float last_light_value = 0;
float proxSensorThreshold = 20; //you will need to change this per your device.
int choose4target = 0;

private class Target
{
  int target = 0;
  int action = 0;
}

int trialCount = 3; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
int countDownTimerWait = 0;

void setup() {
  size(800, 800); //you should change this to be fullscreen per your phones screen
  frameRate(60);
  orientation(PORTRAIT);
   
  sensor = new KetaiSensor(this);
  sensor.start();
  
  rectMode(CENTER);
  textFont(createFont("Arial", 40)); //sets the font to Arial size 20
  textAlign(CENTER);

  for (int i=0; i<trialCount; i++)  //don't change this random generation code!
  {
    Target t = new Target();
    t.target = ((int)random(1000))%4;
    t.action = ((int)random(1000))%2;
    targets.add(t);
    println("created target with " + t.target + "," + t.action);
  }

  Collections.shuffle(targets); // randomize the order of the button;
}

void draw() {
  int index = trialIndex;

  //uncomment line below to see if sensors are updating
  //println("light val: " + light);
  background(80); //background is light grey

  countDownTimerWait--;

  if (startTime == 0)
    startTime = millis();

  if (index>=targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }

  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount, 2) + " sec per target", width/2, 150);
    return;
  }
  
  strokeWeight(15);
  for (int i=0; i<4; i++)
  {   
    if (i==choose4target)
       stroke(255,0,0);
    else
       noStroke();
        
    if (targets.get(index).target==i)
      fill(0, 255, 0);
    else
      fill(180, 180, 180);
    
    ellipse(200, i*150+100, 100, 100);
  }

  fill(255);//white
  text("Trial " + (index+1) + " of " +trialCount, width/2, 50);
  text("Target #" + (targets.get(index).target)+1, width/2, 100);

  if (targets.get(index).action==0)
    text("UP", width/2, 150);
  else
    text("DOWN", width/2, 150);
    
    
}

void onAccelerometerEvent(float x, float y, float z)
{
  //println(z-9.8); use this to check z output! (-9.8 to remove gravity, which is 9.8m/s)
  
  if (userDone || trialIndex>=targets.size())
    return;

  Target t = targets.get(trialIndex);

  if (t==null)
    return;
 
  if (targets.get(trialIndex).target==choose4target && abs(z-9.8)>4 && countDownTimerWait<0) //possible hit event
  {
      if (((z-9.8)>4 && t.action==0) || ((z-9.8)<-4 && t.action==1))
      {
        println("Right target, RIGHT z direction!");
        trialIndex++; //next trial!
      } else
      {
        if (trialIndex>0)
          trialIndex--; //move back one trial as penalty!
        println("Right target, WRONG z direction!");
      }
      countDownTimerWait=30; //wait a lttile before allowing next trial
  }  
  else if (abs(z-9.8)>4 && targets.get(trialIndex).target!=choose4target && countDownTimerWait<0)
  { 
    println("wrong round 1 action!"); 

    if (trialIndex>0)
      trialIndex--; //move back one trial as penalty!

    countDownTimerWait=30; //wait a little before allowing next trial
  } 
}

void onLightEvent(float v) //this just updates the global light value
{
  last_light_value = light;
  light = v;
  
  if (last_light_value<=proxSensorThreshold && light>proxSensorThreshold)
  {
    choose4target = (choose4target+1)%4;
    println("light event! New target: " + choose4target);
  }
}
