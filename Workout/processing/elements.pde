class Player {
  int x, y;
  int angle, power;

  void show() {
    pushMatrix();
    translate(x*step+step/2, y);
    fill(white);
    triangle(-size, 0, size, 0, 0, -size);
    popMatrix();
  }
}


class Tank {
  int x, y;
  color c =  red;

  void show() {
    fill(c);
    rect(x*step, y, step, -size);
  }
}


class Rocket {
  float t = 0;
  int x0, y0;
  int a, p;
  int x, y;

  void show() {
    fill(yellow);
    ellipse(x, y, 24, 24);
  }

  void update() {
    y = int(y0 - 10*p * t * sin(radians(a)) + 5 * t*t);
    x = int(x0 - 10*p * t * cos(radians(a)));
    if (x > width) {
      x -= width;
    } else if (x < 0) {
      x += width;
    }
    t += .007;
  }
}