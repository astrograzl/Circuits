// pin connection & serial codes
const int LEFT    = 2;
const int RED     = 3;
const int YELLOW  = 4;
const int GREEN   = 5;
const int BUZZ    = 8;
const int TONE    = 440;
const int BLUE    = 11;
const int RIGHT   = 12;

void setup() {
  Serial.begin(9600);
  pinMode(LEFT,   INPUT);
  pinMode(RIGHT,  INPUT);
  pinMode(RED,    OUTPUT);
  pinMode(YELLOW, OUTPUT);
  pinMode(GREEN,  OUTPUT);
  pinMode(BLUE,   OUTPUT);
  pinMode(BUZZ,   OUTPUT);
}

// hardware status
boolean left    = false;
boolean right   = false;
boolean red     = false;
boolean yellow  = false;
boolean green   = false;
boolean blue    = false;
boolean buzz    = false;
// time event
unsigned long check = 0;

void loop() {

  // incoming command
  if (Serial.available() > 0) {
    check = millis();
    int val = Serial.read();
    switch (val) {
      case RED:
        red = true;
        digitalWrite(RED, HIGH);
        break;
      case YELLOW:
        yellow = true;
        digitalWrite(YELLOW, HIGH);
        break;
      case GREEN:
        green = true;
        digitalWrite(GREEN, HIGH);
        break;
      case BLUE:
        blue = true;
        digitalWrite(BLUE, HIGH);
        break;
      case BUZZ:
        buzz = true;
        tone(BUZZ, TONE);
      default:
        break;
    }
  }

  // hardware indicators reset
  if (millis() - check > 666) {
    if (red) {
      red = false;
      digitalWrite(RED, LOW);
    }
    if (yellow) {
      yellow = false;
      digitalWrite(YELLOW, LOW);
    }
    if (green) {
      green = false;
      digitalWrite(GREEN, LOW);
    }
    if (blue) {
      blue = false;
      digitalWrite(BLUE, LOW);
    }
    if (buzz) {
      buzz = false;
      noTone(BUZZ);
    }
  }

  // move one step to left
  if (digitalRead(LEFT) == HIGH) {
    if (!left) {
      left = true;
      Serial.write(LEFT);
    }
  } else {
    left = false;
  }

  // move one step to right
  if (digitalRead(RIGHT) == HIGH) {
    if (!right) {
      right = true;
      Serial.write(RIGHT);
    }
  } else {
    right = false;
  }

}
