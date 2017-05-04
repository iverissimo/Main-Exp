#include <Servo.h>

//code to repeat rotation to a certain position and go back to 0, for a certain number of trials
//Afterwards increment and start again

Servo myservo;  // create servo object to control a servo, that goes from 0-180º

int pos = 20;    // variable to store the servo position, value of initial pos
int initpos = 0;
int numtrial = 5; // variable for the number of trials/repetitions
int pause = 1000; //time to wait between positions (ms)

int trial = 1; // variable for the number of trials/repetitions

void setup() {
  // put your setup code here, to run once
  //Initiate Serial communication.
  Serial.begin(9600);
  myservo.attach(8);  // attaches the servo on pin 8 to the servo object
}

void loop() {
  // put your main code here, to run repeatedly:

  for (trial = 1; trial <= numtrial; trial += 1) { // runs until trial = numtrial
    myservo.write(pos);              // tell servo to go to position in variable 'pos'
    Serial.print("Current trial is: ");
    Serial.println(trial);
    Serial.print("\t"); //tab
    Serial.print("Current position in degrees is: ");
    Serial.println(pos);
    delay(pause);                       // waits X seconds for the servo to reach the position
    myservo.write(initpos);              // tell servo to go to initial position (0º)
    Serial.print("\t"); //tab
    Serial.print("Current position in degrees is: ");
    Serial.println(initpos);
    delay(pause);                      //give time to the system to comunicate change of pos
  }


}
