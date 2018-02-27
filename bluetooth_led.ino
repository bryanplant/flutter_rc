#include <SoftwareSerial.h>

String inputString = "";
bool toggle = false;
bool done = false;
bool reading = false;
int frontLed = 9;
int backLed = 10;
int leftLed = 11;
int rightLed = 6;

int motor;

SoftwareSerial mySerial (2, 3);

void setup() {
  pinMode(frontLed, OUTPUT);
  pinMode(backLed, OUTPUT);
  pinMode(leftLed, OUTPUT);
  pinMode(rightLed, OUTPUT);

  mySerial.begin(9600);
  Serial.begin(19200);
}

void loop() {
  if (mySerial.available()) {
    inputString = "";
    while (!done) {
      while (mySerial.available())
      {
        char inChar = (char)mySerial.read(); //read the input

        if (inChar == '>') {
          reading = false;
          done = true;
        }

        if (reading) {
          inputString += inChar;
        }

        if (inChar == '<') {
          reading = true;
          motor = 0;
        }
        else if (inChar == '{') {
          reading = true;
          motor = 1;
        }
      }
    }

    
    Serial.println(inputString);
    done = false;

    int value = inputString.toInt();

    /*if (inputString == "a") {
      if (!toggle) {
        digitalWrite(led, HIGH);
      }
      else {
        digitalWrite(led, LOW);
      }
      toggle = !toggle;
      }*/
    if(motor == 0) {
      if (value > 0) {
        analogWrite (frontLed, value * 2.55);
        analogWrite (backLed, 0);
      }
      else if (value < 0) {
        analogWrite (backLed, abs(value * 2.55));
        analogWrite (frontLed, 0);
      }
      else if (value == 0) {
        analogWrite (frontLed, 0);
        analogWrite (backLed, 0);
      }
    }
    else if(motor == 1) {
      if (value > 0) {
        analogWrite (rightLed, value * 2.55);
        analogWrite (leftLed, 0);
      }
      else if (value < 0) {
        analogWrite (leftLed, abs(value * 2.55));
        analogWrite (rightLed, 0);
      }
      else if (value == 0) {
        analogWrite (rightLed, 0);
        analogWrite (leftLed, 0);
      }
    }
  }
}
