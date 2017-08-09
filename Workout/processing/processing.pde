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
int sun;
int[] horizon;
final int rand = 8;    // lucky number
final int numb = 10;   // number of bars and balls
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

  // player
  player.show();

  // rocket & tanks on horizon
  for (int t = 0; t < tanks.size(); t++) {
    Tank tank = tanks.get(t);
    if (rocket != null && int(rocket.x / step) == tank.x &&
      rocket.y < tank.y && rocket.y > tank.y - size) {
      if (tank.c == yellow) {
        port.write(7);
        sun = 0;
      } else {
        port.write(hit++);
        sun++;
      }
      tanks.remove(t);
      rocket = null;
    } else {
      tank.show();
    }
  }
  if (rocket != null) {
    for (int h = 0; h < numb; h++) {
      if (int(rocket.x / step) == h && rocket.y > height - horizon[h]) {
        rocket = null;
        sun++;
        break;
      } else {
        rocket.update();
        rocket.show();
      }
    }
  }
  if (tanks.size() == 0) port.write(hit);
  if (sun == numb) port.write(sun);

  // angle meter
  float aw = 420/180.0*player.angle;
  fill(gray); 
  rect(0, 48, aw, -32);
  fill(nogray); 
  rect(0+aw, 48, 420-aw, -32);

  // rocket meter
  fill(nogray); 
  for (int i = 0; i < 10; i++) {
    ellipse(430+i*42+21, 32, 32, 32);
  }
  fill(gray);
  for (int i = 0; i < sun; i++) {
    ellipse(430+i*42+21, 32, 32, 32);
  }

  // power meter
  int pw = 420/20*player.power;
  fill(gray); 
  rect(860, 48, pw, -32);
  fill(nogray); 
  rect(860+pw, 48, 420-pw, -32);
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
  for (int t = 0; t < 7; t++) {
    position.shuffle();
    Tank tank = new Tank();
    tank.x = position.remove(0);
    tank.y = height - horizon[tank.x];
    if (t == 3) tank.c = yellow;
    tanks.add(tank);
  }
  rocket = null;
  port.clear();
  hit = 0;
  sun = 0;
}