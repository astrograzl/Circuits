const int PWR = A0;
const int ANG = A1;
const int SHT = 8;
const int BNS = 7;
const int led = 6;
const int LED[led] = {2, 3, 4, 10, 11, 12};

void setup() {
  Serial.begin(9600);
  pinMode(SHT, INPUT);
  pinMode(BNS, OUTPUT);
  for (int l = 0; l < led; l++) {
    pinMode(LED[l], OUTPUT);
  }
}

int xang = -101;
int xpwr = -101;
boolean sht = false;

void loop() {

  // angle
  int ang = analogRead(ANG);
  if (abs(xang - ang) >= 2) {
    xang = ang;
    Serial.write(map(ang, 0, 1023, 0, 180));
  }

  // power
  int pwr = analogRead(PWR);
  if (abs(xpwr - pwr) >= 2) {
    xpwr = pwr;
    Serial.write(map(pwr, 0, 1023, 181, 200));
  }

  // shoot
  if (digitalRead(SHT) == HIGH) {
    if (!sht) {
      sht = true;
      Serial.write(201);
    }
  } else {
    sht = false;
  }

  // incomming commands
  if (Serial.available() > 0) {
    int hit = Serial.read();
    if (hit < led) digitalWrite(LED[hit], HIGH);
    if (hit == led) {  // winner
      for (int i = 0; i < 10; i++) {
        for (int l = 0; l < led; l++) {
          digitalWrite(LED[l], HIGH);
          delay(100);
          digitalWrite(LED[l], LOW);
        }
      }
    }
    if (hit == BNS) digitalWrite(BNS, HIGH);
    if (hit == 10) {  // looser
      for (int i = 0; i < 10; i++) {
        for (int l = led; l > 0; l--) {
          digitalWrite(LED[l - 1], HIGH);
          delay(100);
          digitalWrite(LED[l - 1], LOW);
        }
      }
    }
    if (hit == led || hit == 10) {
      Serial.end();
      Serial.begin(9600);
      Serial.write(255);
      digitalWrite(BNS, LOW);
    }
  }

}

