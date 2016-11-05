class Switch {
  Boolean state;
  float dist;
  String text;
  PVector pos;

  Switch(String text) {
    state = false;
    pos = new PVector(Width + 50, ButtonNo * 60 - 30);
    ButtonNo++;
    this.text = text;
  }

  void update() {
    if (mousePressed && !pmousePressed) {
      if (mouseX > pos.x-30 && mouseX < pos.x+30 && mouseY > pos.y && mouseY < pos.y + 20) state = !state;
    }
    if (state) {
      dist+=5;
      dist = dist>30?30:dist;
    } else {
      dist-=5;
      dist = dist<0?0:dist;
    }
  }

  void draw() {

    strokeWeight(1);
    fill(0);
    textAlign(CENTER, BOTTOM);
    text(text, pos.x, pos.y - 5);

    fill(255, 0, 0);
    rect(pos.x - 30, pos.y, 30, 20);
    fill(0, 255, 0);
    rect(pos.x, pos.y, 30, 20);

    fill(255);
    rect(pos.x - dist, pos.y, 30, 20);
  }
  
  void change() {
    state = !state;
  }
}

class Button {
  boolean state;
  String text;
  PVector pos;

  Button(String text) {
    state = false;
    pos = new PVector(Width + 50, ButtonNo * 60 - 30);
    ButtonNo++;
    this.text = text;
  }

  void update() {
    state = false;
    if (mousePressed && !pmousePressed) {
      if (mouseX > pos.x-30 && mouseX < pos.x+30 && mouseY > pos.y && mouseY < pos.y + 20) state = !state;
    }
  }

  void draw() {
    fill(0);
    textAlign(CENTER, BOTTOM);
    text(text, pos.x, pos.y - 5);

    fill(state?255:0);
    rect(pos.x - 30, pos.y, 60, 20);
  }
}

void drawVector(PVector ss, PVector ee) { // Crta vektor
  PVector s = new PVector(ss.x, ss.y);
  PVector e = new PVector(ee.x, ee.y);
  s.mult(scale);
  float limit = 200;
  if (e.mag() > limit) { 
    stroke(255, 0, 0);
    strokeWeight(2);
  }
  e.limit(limit);
  line(s.x, s.y, s.x + e.x, s.y + e.y);
  PVector back = PVector.sub(s, PVector.add(s, e)).mult(0.1);
  back.rotate(PI/6);
  line(s.x + e.x, s.y + e.y, s.x + e.x + back.x, s.y + e.y + back.y);
  back.rotate(-PI/3);
  line(s.x + e.x, s.y + e.y, s.x + e.x + back.x, s.y + e.y + back.y);
  strokeWeight(1);
}

String nfplus(float x, int l, int r) { // Lepse pretstavlja vrednosti
  if (x == 0 || x<1e-15) return "0 ";
  if (x > 1e15) return "+∞ ";
  int s = 0;
  while (x < 1) {
    x*=1e3;
    s++;
  }
  while (x > 1e3) {
    x/=1e3;
    s--;
  }
  switch(s) {
  case -4:
    return nf(x, l, r) + " T";
  case -3:
    return nf(x, l, r) + " G";
  case -2:
    return nf(x, l, r) + " M";
  case -1:
    return nf(x, l, r) + " K";
  case 1:
    return nf(x, l, r) + " m";
  case 2:
    return nf(x, l, r) + " u";
  case 3:
    return nf(x, l, r) + " n";
  case 4:
    return nf(x, l, r) + " p";
  case 5:
    return nf(x, l, r) + " f";
  default:
    return nf(x, l, r) + " ";
  }
}

void drawAxis() {
  textAlign(LEFT, TOP);
  fill(0);
  text("0m", 0, 0);

  textAlign(LEFT, BOTTOM);
  for (int y = 100; y < Height; y+= 100) {
    stroke(0);
    line(0, y, 5, y);
    text(" " + y/100 + "m", 3, y);
    stroke(200);
    line(5, y, Width, y);
  }

  textAlign(LEFT, CENTER);
  for (int x = 100; x < Width; x+= 100) {
    stroke(0);
    line(x, 0, x, 5);
    text(" " + x/100 + "m", x, 5);
    stroke(200);
    line(x, 5, x, Height);
  }
}

color lerpc(float p) {
  if ( p < 1 ) {
    return lerpColor(color(0, 0, 255), color(0, 255, 255), p);
  }
  if ( p < 2 ) {
    return lerpColor(color(0, 255, 255), color(0, 255, 0), p - 1);
  }
  if ( p < 3 ) {
    return lerpColor(color(0, 255, 0), color(255, 255, 0), p - 2);
  }
  if ( p < 4 ) {
    return lerpColor(color(255, 255, 0), color(255, 0, 0), p - 3);
  }
  return color(255, 0, 0);
}

int sgn(float a) {
  return a > 0 ? 1 : -1;
}