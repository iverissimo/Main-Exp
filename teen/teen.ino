#include <Servo.h>
#include <math.h>

Servo servo;
int potPin = 5;    // select the input pin for the potentiometer
int ledPin = 13;   // select the pin for the LED
int val = 0;       // variable to store the value coming from the sensor
int maxi = 15;     //max val, then servo will not go faster than 90-15 = 75 

void setup() {
  // initialize serial port

  pinMode(ledPin, OUTPUT);  // declare the ledPin as an OUTPUT
  servo.attach(6); // attaches pin 6 to the servo object
  servo.write(90);  // tell servo to not move
  Serial.begin(115200);

}


void loop() {

  // put your main code here, to run repeatedly:

  //if (Serial.available() > 0) // if there is data to read
  //{

    val = round((analogRead(potPin)-98)/4); //so val is 0 when there is no force input, and has less sensitivity  
    if (val<0){val = 0;}   //might be jitter in input, this avoids negative values
    //if(val>15){val = maxi;}  //
    
    Serial.println(val); //print input value in serial monitor
if (val > 30){
  Serial.println("MOVE");
    servo.write(75); //tell servo to move clockwise at a speed that depends on val (bigger the val, bigger the speed)
    delay(10);                   // waits X miliseconds for the servo to reach the position
}
  //}


  /*while (val > 5){
    val = analogRead(potPin);    // read the value from the sensor
    }
    Serial.print(1);
    delay(1000);
    val = analogRead(potPin);    // read the value from the sensor
    while (val < 5){
    val = analogRead(potPin);    // read the value from the sensor
    }
    Serial.print(0);
    delay(1000);
    val = analogRead(potPin);    // read the value from the sensor
  */
}

