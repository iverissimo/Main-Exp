//libraries
#include <Servo.h>
#include <math.h>

Servo servo;

int potPin = 5;    // select the input pin for the potentiometer
int ledPin = 13;   // select the pin for the LED
int val = 0;       // variable to store the value coming from the sensor
int maxi = 15;     //max val, then servo will not go faster than 90-15 = 75
int tot_time = 1.5; //time it takes for full rotation at max speed (seconds)
int time_left;
int max_val = 0;
int vel = 70;     //velocity clockwise
char option;

void setup() {
  // put your setup code here, to run once:

  pinMode(ledPin, OUTPUT);  // declare the ledPin as an OUTPUT
  servo.attach(6); // attaches pin 6 to the servo object
  servo.write(89);//(100);  // tell servo to not move, before initializing serial port

  // initialize serial port
  Serial.begin(115200);

  //wait for port to open:
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB
  }

}

void loop() {
  // put your main code here, to run repeatedly:

  // send data only when you receive data:
  if (Serial.available() > 0) {

    option = Serial.read(); // read the incoming byte
    //Serial.println(option); // say what you got

    switch (option) {

      case 'c': //calibrate, to move motor to desired initial position

        val = round((analogRead(potPin) - 100) / 6); //so val is 0 when there is no force input, and has less sensitivity
        if (val < 0) {
          val = 0; //might be jitter in input, this avoids negative values
        }
        if (val > 25) {
          val = 25; //max velocity will be 89-25 = 64
        }

        Serial.println(val);

        servo.write(89 - val); //tell servo to move clockwise at a speed that depends on val (bigger the val, bigger the speed)
        delay(10);                   // waits X miliseconds for the servo to reach the position

        break;

      case 'p': //pull (move clockwise)

        time_left = 721; //time it takes for 180º rotation at vel speed (miliseconds)
        servo.write(vel); //tell servo to move clockwise at a certain speed

        while (time_left > 0) {
          delay(10); // needs to be between write and analogRead so it reads correct value
          val = (analogRead(potPin) - 100) / 6; // read analog input
          if (val < 0) {
            val = 0;
          }

          if (val > max_val) {
            max_val = val;  //register max value of force, to give as output
          }

          time_left = time_left - 10; //time left for feedback (miliseconds)

          if (time_left <= 0 || val > 50) { //if time to reach 180º over or if too much force is detected (toe pull too big)
            break;  // stop loop
          }
        }

        servo.write(89);  // tell servo to not move
        delay(10);
        Serial.println(max_val);
        max_val = 0;

        break;

      case 'b': //go back (move counter-clockwise)

        time_left = 721; //time it takes for 180º rotation at vel speed (miliseconds)
        servo.write(89 + (89 - vel)); //tell servo to move counter-clockwise at a certain speed

        while (time_left > 0) {
          delay(10); // needs to be between write and analogRead so it reads correct value
          val = (analogRead(potPin) - 100) / 6; // read analog input
          if (val < 0) {
            val = 0;
          }

          if (val > max_val) {
            max_val = val;  //register max value of force, to give as output
          }

          time_left = time_left - 10; //time left for feedback (miliseconds)

          if (time_left <= 0 || val < 6) { //if time to reach 180º over or if no force is detected (no pull on the toe)
            break;  // stop loop
          }
        }

        servo.write(89);  // tell servo to not move
        delay(10);
        Serial.println(max_val);
        max_val = 0;

        break;

      default: // if nothing else matches, do the default

        servo.write(89);  // tell servo to not move
        delay(10); // needs to be between write and analogRead so it reads correct value
        val = (analogRead(potPin) - 100) / 6; // read analog input
        if (val < 0) {
          val = 0;
        }
        Serial.println(val);

        break;
    }
  }
}
