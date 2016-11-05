class Map {
  PImage map;
  Switch showMap;

  Map() {
    showMap = new Switch("Show Map [M]");
    map = createImage(Width, Height, RGB);
  }

  void update(ArrayList<Line> L) {
    map = createImage(Width, Height, RGB);
    map.loadPixels();
    for (int x = 2; x < Width; x += 5) {
      for (int y = 2; y < Height; y += 5) {
        float tV = 0;
        for (int i = 0; i < L.size(); i++) {
          tV += L.get(i).getV(new PVector(x/scale, y/scale));
        }
        for (int xp = x-2; xp < x+3; xp++) {
          for (int yp = y-2; yp < y+3; yp++) {
            map.pixels[yp*Width + xp] = lerpc(VoltScale*tV);
          }
        }
      }
    }
    map.updatePixels();
  }

  void draw() {
    if (showMap.state) {
      image(map, 0, 0);
      fill(0);
      stroke(0);
      rect(Width - 20, Height/2 - 50, 20, 100);
      line(Width - 20, Height/2 - 50, Width - 25, Height/2 - 50);
      line(Width - 20, Height/2, Width - 25, Height/2);
      line(Width - 20, Height/2 + 50, Width - 25, Height/2 + 50);
      for (float i = 0.04; i < 3.96; i+= 0.04) {
        stroke(lerpc(i));
        line(Width - 19, Height/2 + 50 - map(i, 0, 4, 0, 100), Width - 2, Height/2 + 50 - map(i, 0, 4, 0, 100));
      }
      textAlign(RIGHT, BOTTOM);
      text("0V", Width - 25, Height/2 + 50);
      textAlign(RIGHT, CENTER);
      text(int(2/VoltScale) + "V", Width - 25, Height/2 );
      textAlign(RIGHT, TOP);
      text(int(4/VoltScale) + "V", Width - 25, Height/2 - 50);
    }
  }
}

class Vfield {
  PVector[][] V;
  int w, h;
  Switch ef;
  Switch show;

  Vfield() {
    w = Width / 20;
    h = Height / 20;
    V = new PVector[h][w];
    show = new Switch("Show field [F]");
    ef = new Switch("Field mode [G]");
  }

  void update(ArrayList<Line> L) {
    V = new PVector[h][w];
    for (int x = 0; x < Width/20; x++) {
      for (int y = 0; y < Height/20; y++) {
        float tx = 20*x/scale;
        float ty = 20*y/scale;
        PVector tE = new PVector();
        for (int i = 0; i < L.size(); i++) {
          tE.add(L.get(i).getE(new PVector(tx, ty)));
        }
        if (ef.state) tE.normalize();
        else {
          tE.setMag(atan(tE.mag()*0.005)/HALF_PI);
        }
        V[y][x] = tE;
      }
    }
  }

  void draw() {
    if (show.state) {
      for (int x = 0; x < w; x++) {
        for (int y = 0; y < h; y++) {
          float tx = 20*x/scale;
          float ty = 20*y/scale;
          stroke(0);
          drawVector(new PVector(tx, ty), PVector.mult(V[y][x], 10));
        }
      }
    }
  }
}