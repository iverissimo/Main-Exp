//libraries
#include <Servo.h>
#include <math.h>

Servo servo;

int potPin = 5;    // select the input pin for the potentiometer
int ledPin = 13;   // select the pin for the LED
int val = 0;       // variable to store the value coming from the sensor
int maxi = 15;     //max val, then servo will not go faster than 90-15 = 75
int tot_time = 1.5; //time it takes for full rotation at max speed (seconds)
int max_val = 0;
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
  
  if (Serial.available() > 0) { // send data only when you receive data:
    servo.write(89);  // tell servo to not move
    delay(10); // needs to be between write and analogRead so it reads correct value
    val = (analogRead(potPin) - 100) / 6; // read analog input
    if (val < 0) {
      val = 0;
    }
    Serial.println(val);

  }

}
