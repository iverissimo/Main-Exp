#include <Servo.h>

//code to repeat rotation to a certain position and go back to 0, for a certain number of trials

Servo myservo;  // create servo object to control a servo, that goes from 0-180º

int angle;    // variable to store the servo position, value of initial pos
int dur_wait=500; //time to wait between positions (ms)

void setup() {
  // put your setup code here, to run once
  //Initiate Serial communication.
  Serial.begin(9600);
  myservo.attach(8);  // attaches the servo on pin 8 to the servo object
}

void loop() {
  // put your main code here, to run repeatedly:

  if (Serial.available() > 0) // if there is data to read
  {
    angle = Serial.read(); // read data from MATLAB
    
    myservo.write(angle);              // tell servo to go to position in variable 'angle'
    delay(dur_wait);                       // waits X miliseconds for the servo to reach the position
   
  }

}
