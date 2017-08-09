import processing.serial.*;

Serial port;

void setup() {
  size(1280, 960);
  textSize(32);
  noStroke();
  //println((Object) Serial.list());
  port = new Serial(this, Serial.list()[0], 9600);
  init();
}


int hit;
int[] horizon;
final int rand = 8;    // lucky number
final int numb = 10;   // number of bars
final int size = 64;   // increment size
final int step = 128;  // width of bars


color red    = color(204, 0, 0);
color gray   = color(85, 87, 83);
color blue   = color(114, 159, 207);
color white  = color(238, 238, 236);
color green  = color(78, 154, 6);
color yellow = color(252, 234, 79);
color nogray = color(186, 189, 182);


Rocket rocket = null;
Player player = new Player();
ArrayList<Tank> tanks = new ArrayList<Tank>();


void draw() {
  background(blue);

  // incomming commands
  if (port.available() > 0 && rocket == null) {
    int cmd = port.read();
    if (cmd == 255) {
      init();
    } else if (cmd == 201) {
      rocket = new Rocket();
      rocket.x0 = player.x*step + size;
      rocket.y0 = player.y - size;
      rocket.a = player.angle;
      rocket.p = player.power;
    } else if (cmd <= 180) {
      player.angle = cmd;
    } else if (cmd > 180 && cmd <= 200) {
      player.power = cmd - 180;
    }
  }

  // horizon
  fill(green);
  for (int h = 0; h < numb; h++) {
    rect(h*step, height, step, -horizon[h]);
  }

  // tanks
  for (int t = 0; t < tanks.size(); t++) {
    Tank tank = tanks.get(t);
    if (rocket != null && int(rocket.x / step) == tank.x &&
      rocket.y < tank.y && rocket.y > tank.y - size) {
      port.write(hit++);
      tanks.remove(t);
      rocket = null;
    } else {
      tank.show();
    }
  }
  if (tanks.size() == 0) {
    port.write(hit);
  }

  // player
  player.show();

  // rocket
  if (rocket != null) {
    for (int h = 0; h < numb; h++) {
      if (int(rocket.x / step) == h && rocket.y > height - horizon[h]) {
        rocket = null;
        break;
      } else {
        rocket.update();
        rocket.show();
      }
    }
  }

  fill(gray);
  text("Angle", 24, 48);
  float aw = 500/180.0*player.angle;
  rect(128, 48, aw, -32);
  fill(nogray);
  rect(128+aw, 48, 500-aw, -32);
  // status bars
  fill(gray);
  text("Power", 664, 48);
  int pw = 500/20*player.power;
  rect(768, 48, pw, -32);
  fill(nogray);
  rect(768+pw, 48, 500-pw, -32);
}


void init() {
  // initialize battlefield
  horizon = new int[numb];
  IntList position = new IntList();
  for (int h = 0; h < numb; h++) {
    position.append(h);
    horizon[h] = size + size * int(random(rand));
  }
  player.x = floor(random(numb));
  player.y = height - horizon[player.x];
  position.remove(player.x);
  tanks.clear();
  for (int t = 0; t < 6; t++) {
    position.shuffle();
    Tank tank = new Tank();
    tank.x = position.remove(0);
    tank.y = height - horizon[tank.x];
    tanks.add(tank);
  }
  rocket = null;
  hit = 0;
}