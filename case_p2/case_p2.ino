//libraries
#include <Servo.h>
#include <math.h>

Servo servo;

int potPin = 5;    // select the input pin for the potentiometer
int ledPin = 13;   // select the pin for the LED
int val = 0;       // variable to store the value coming from the sensor
int vel = 70;     //velocity clockwise
int max_val = 0;
int time_left = 720; //time it takes for 180º rotation at vel speed (miliseconds)
char option;

void setup() {
  // put your setup code here, to run once:

  pinMode(ledPin, OUTPUT);  // declare the ledPin as an OUTPUT
  servo.attach(6); // attaches pin 6 to the servo object
  servo.write(89);  // tell servo to not move, before initializing serial port

  // initialize serial port
  Serial.begin(115200);

  //wait for port to open:
  while (!Serial) {
    ; // wait for serial port to connect. Needed for native USB
  }

}

void loop() {
  // put your main code here, to run repeatedly:

  int time_left = 721; //time it takes for 180º rotation at vel speed (miliseconds)
  servo.write(vel); //tell servo to move clockwise at a certain speed

  while (time_left > 0) {
    delay(10); // needs to be between write and analogRead so it reads correct value
    val = (analogRead(potPin) - 100) / 6; // read analog input
    if (val < 0) {
      val = 0;
    }

    if (val > max_val) {
      max_val = val;
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

}


