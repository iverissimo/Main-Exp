#include <Servo.h>
#include <math.h>

Servo servo;

int potPin = 5;    // select the input pin for the potentiometer
int ledPin = 13;   // select the pin for the LED
int val = 0;       // variable to store the value coming from the sensor
int maxi = 15;     //max val, then servo will not go faster than 90-15 = 75
int tot_time = 1.5; //time it takes for full rotation at max speed (seconds)
int max_val = 0;
//int mov = 1; //!!!!!!!!!!!!! Does the whole arduino script run when I call it through MATLAB? Because if not, robot will only move once

void setup() {

  pinMode(ledPin, OUTPUT);  // declare the ledPin as an OUTPUT
  servo.attach(6); // attaches pin 6 to the servo object
  servo.write(90);  // tell servo to not move, before initializing serial port

  // initialize serial port
  Serial.begin(115200);
}

void loop() {

  // put your main code here, to run repeatedly:

  //if (Serial.available() > 0) { // if there is a serial port available

    int option = 2;//Serial.read(); // read data from MATLAB

    if (option == 1) { //calibration phase, to move motor to desired initial position

      val = round((analogRead(potPin) - 98) / 4); //so val is 0 when there is no force input, and has less sensitivity
      if (val < 0) {
        val = 0; //might be jitter in input, this avoids negative values
      }

      servo.write(90 - val); //tell servo to move clockwise at a speed that depends on val (bigger the val, bigger the speed)
      delay(10);                   // waits X miliseconds for the servo to reach the position
    }

    else if (option == 2) {  //rotate clockwise at constant speed, return max value of force
      int mov = 1;
      if (mov = 1) {
        //tot_time = Serial.read(); // read data from MATLAB
        servo.write(90 - maxi); //tell servo to move clockwise at a certain speed
        int time_left = tot_time * 1000;

        while (time_left > 0) {
          delay(10); // needs to be between write and analogRead so it reads correct value
          val = (analogRead(potPin) - 98) / 4; // read analog input
          if (val < 0) {
            val = 0;
          }

          if (val > max_val) {
            max_val = val;
          }
          time_left = time_left - 10; //time left for feedback (miliseconds)
        }

        Serial.println(max_val);
        servo.write(90);  // tell servo to not move
        delay(1500);//(10);
        //Serial.print("\n");              // prints a tab
        max_val = 0;
        mov = 0;
      }
    }
  //}

}
