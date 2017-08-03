import processing.serial.*;

Serial port;

void setup() {
  size(960, 960);
  //println((Object) Serial.list());
  port = new Serial(this, Serial.list()[0], 9600);
}

// serial codes for pins
final int left    = 2;
final int right   = 12;
final int red     = 3;
final int yellow  = 4;
final int green   = 5;
final int blue    = 11;
final int buzz    = 8;

final int[] diods = {red, yellow, green, blue};  // le diods colors
final int[] coins = {5, 10, 15, -20};            // le diods prices
final color[] colors = {
  color(255, 000, 000), // red
  color(255, 255, 000), // yellow
  color(000, 255, 000), // green
  color(000, 000, 255), // blue
};

// initial condition
int x0     = 0;
int y0     = 800;
int size   = 60;
int step   = 120;
int score  = 0;

class LED {
  int s = 0;  // speed
  int y = 0;
  int x = step * floor(random(-3, 4));
  int c = int(random(4));  // color

  void step() {
    y += s + 5;
  }

  void show() {
    noStroke();
    fill(colors[c]);
    ellipse(x, y, size, size);
  }
}

ArrayList<LED> leds = new ArrayList<LED>();

void draw() {

  background(192);
  translate(width/2, 0);

  // incoming command
  if (port.available() > 0) {
    int move = port.read();
    if (move == left) {
      if (x0 == -3 * step) {
        port.write(buzz);
      } else {
        x0 -= step;
      }
    }
    if (move == right) {
      if (x0 == 3 * step) {
        port.write(buzz);
      } else {
        x0 += step;
      }
    }
  }

  // add one LED per second
  if (frameCount % 60 == 1) leds.add(new LED());

  // manage LEDs on circuit
  for (int i = 0; i < leds.size(); i++) {
    LED led = leds.get(i);
    led.s = int(score / 100);  // score to speed up
    led.step();
    if (led.y > height) {
      leds.remove(i);
    } else {
      led.show();
    }
    if (led.x == x0 && abs(led.y - y0) < size/2) {
      score += coins[led.c];
      port.write(diods[led.c]);
      leds.remove(i);
    }
  }

  // show player
  stroke(0);
  strokeWeight(2);
  fill(255, 127);
  ellipse(x0, y0, size, size);

  // show score
  fill(255, 96);
  textSize(32);
  text(score, 15-width/2, height-25);
}