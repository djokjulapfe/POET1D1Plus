import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import javax.swing.*; 
import javax.swing.filechooser.*; 
import java.io.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class POET1D1Plus extends PApplet {

/* Utorak 25. Oktobar 2016
 * Dodatak za domaci zadatak iz POETa
 * Djordje Marjanovic 120/16
 * Features:
 *  Racunanje potenciala i vektora elektricnog polja u tacki
 *  Menjanje poduznog naelektrisanja
 *  Crtanje vise kriva misem
 *  Mod za crtanje kruga
 *  Generisanje mape zavisnosti potenciala od koordinata
 *  Stap to grid
 *  Crtanje dugackih pravih linija
 *  Dva moda racunanja: automatsk i ne automatski
 *  Brisanje celog ekrana
 *  Crtanje ekvipotencijale i linije elektricnog polja
 *  Crtanje vektorskog elektricnog polja
 *  Cuvanje i ucitavanje slike ili krive
 *  *Help stranica
 *  *Osnovne komande za kontrolu linija (brisanje, pomeranje, dupliranje...)
 * Uputstvo:
 *  Misom se crta
 *  CTRL - Snap to grid
 *  SHIFT - Crtanje pravih linija
 *  ENTER - Oznaka za zavrseno crtanje sa SHIFT-om
 *  C - Menja se mod za crtanje krugova
 *  +/- - Povecavanje/smanjivanje naelektrisanja
 *  A - Menjanje moda za automatsko racunanje.
 *      Kada je ulkjuceno ne automatsko, pritiskom na space (razmak) 
 *      se vrsi vizuelni racun el. polja i potencijala
 *  R - Brisanje ekrana
 *  M - Crtanje skalarnog polja potencijala (sa desne strane je skala)
 *  E - Crtanje vektorskog polja elektricnog polja
 *  W - Menja mod za crtanje elektricnog polja:
 *      Normalizovani - svi vektori su iste duzine
 *      Atan mod - Vektori imaju duzinu k*atan(c*|E|)
 *  *V - Prikazuje jednu ekvipotencijalu ili liniju elektricnog polja
 *      (Pritiskom na dugme B se menja) koja prolazi kroz polozaj kursora
 *  S/L - Cuvanje/Otvaranje slike ili krive (Pritiskom na dugme D se menja)
 *  H - Prikazuje stranicu "Help" (Pritiskom na dugme J se menja jezik)
 *  Q - Prikazuje liniju najblizu misu
 *  *X - brise liniju najblizu misu
 *  *CTRL + Z/X/C/V - UNDO/CUT/COPY/PASTE
 *  *F - Selektuje liniju najblizu misu da bi mogla da se pomera
 *  *ruler
 *
 */





boolean saveMode;
boolean pmousePressed; // Prethodno stanje mousePressed promenljive
boolean pkeyPressed; // Prethodno stanje keyPressed promenljive
boolean circleMode; // Flag za crtanje krugova
float circleRadius = 1; // Poluprecnik kruga
float mX, mY;
int Width;
int Height;
int ButtonNo;

final float VoltScale = 0.005f;
final float e0 = 8.8542e-12f; // Permitivnost vakuma/vazduha [F/m]
final float scale = 100; // Odnos metara i piksela 
final float dmin = 1e-2f; // najmanja duzina (u metrima) dela puta
final float dmax = 1e-1f; // najveca duzina (u metrima) dela puta
final int ekviDist = 1000; // Broj tacaka koji se koriste za iscrtavanje ekvipotencijale i linije polja

System S;

public void init() {
  S.reset();
}

public void setup() {
   // Podesava velicinu ekrana
  Width = 800;
  Height = 600;
  S = new System();
  init();
}

public void draw() {
  if (keyPressed && key == CODED && keyCode == CONTROL) {
    mX = 50*PApplet.parseInt(mouseX/50.0f + 0.5f);
    mY = 50*PApplet.parseInt(mouseY/50.0f + 0.5f);
  } else {
    mX = mouseX;
    mY = mouseY;
  }

  if (mousePressed && mouseX < Width) {
    if (mouseButton == LEFT) { // Produzivanje putanje pri pritisku na dugme
      if (circleMode) {
        if (!pmousePressed) {
          S.addNewLine();
          float dfi = TWO_PI*0.01f;
          for (float fi = 0; fi < TWO_PI + dfi; fi+=dfi) {
            S.addNewSegment(new PVector(mX/scale+circleRadius*cos(fi), mY/scale+circleRadius*sin(fi)));
          }
          S.addNewLine();
        }
      } else {
        if (!pmousePressed && !(keyPressed && key==CODED && (keyCode == SHIFT || keyCode == CONTROL) )) {// Rising edge
          S.addNewLine();
        }
        S.addNewSegment(new PVector(mX/scale, mY/scale));
      }
    } else if (mouseButton == RIGHT) { // Pomeranje tacke M
      S.M.set(mX/scale, mY/scale);
    }
  }

  if (pmousePressed && !mousePressed) {
    S.m.update(S.L);
    S.e.update(S.L);
  }

  S.update();
  S.draw();
  pmousePressed = mousePressed;
  pkeyPressed = keyPressed;
}

public void optimizeL(ArrayList<PVector> L) { // Izbacuje previse kratke delove niti, a previse dugacke deli na manje.
  if (L.size() > 2) {
    int i = 0;
    while (i<L.size()-1) {
      PVector a = L.get(i);
      PVector b = L.get(i+1);
      if (PVector.sub(a, b).mag() < dmin) {
        L.remove(i+1);
        i++;
      }
      while (PVector.sub(a, b).mag() > dmax) {
        b = PVector.add(a, b).mult(0.5f);
        L.add(i + 1, b);
      }
      println();
      i++;
    }
      println();
  }
}

public void keyPressed() {
  if (key == 'c') { 
    circleMode = !circleMode;
  }
  if (key == 'r') {
    init();
  }
  if (key == 'm') {
    S.s.get(0).change();
  }
  if (key == 'f') {
    S.s.get(1).change();
  } 
  if (key == 'g') {
    S.s.get(2).change();
  } 
  if (key == 'e') {
    S.s.get(3).change();
  } 
  if (key == 'h') {
    S.s.get(4).change();
  }
  if (key == 'j') {
    S.s.get(5).change();
  }
  if (key == ' ') {
    S.s.get(6).change();
  }
  if (key == ENTER) {
  }
  if (key == 'l') {
    ld();
  }
  if (key == 's') {
    sv();
  }
  if (keyCode == ENTER) {
    S.L.add(new Line());
  }
}

public void mouseWheel(MouseEvent event) {
  if (circleMode) { 
    circleRadius -= 10*event.getCount()/scale;
    if (circleRadius > 3) circleRadius = 3;
    if (circleRadius < 0.1f) circleRadius = 0.1f;
  }
}
class Map {
  PImage map;
  Switch showMap;

  Map() {
    showMap = new Switch("Show Map [M]");
    map = createImage(Width, Height, RGB);
  }

  public void update(ArrayList<Line> L) {
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

  public void draw() {
    if (showMap.state) {
      image(map, 0, 0);
      fill(0);
      stroke(0);
      rect(Width - 20, Height/2 - 50, 20, 100);
      line(Width - 20, Height/2 - 50, Width - 25, Height/2 - 50);
      line(Width - 20, Height/2, Width - 25, Height/2);
      line(Width - 20, Height/2 + 50, Width - 25, Height/2 + 50);
      for (float i = 0.04f; i < 3.96f; i+= 0.04f) {
        stroke(lerpc(i));
        line(Width - 19, Height/2 + 50 - map(i, 0, 4, 0, 100), Width - 2, Height/2 + 50 - map(i, 0, 4, 0, 100));
      }
      textAlign(RIGHT, BOTTOM);
      text("0V", Width - 25, Height/2 + 50);
      textAlign(RIGHT, CENTER);
      text(PApplet.parseInt(2/VoltScale) + "V", Width - 25, Height/2 );
      textAlign(RIGHT, TOP);
      text(PApplet.parseInt(4/VoltScale) + "V", Width - 25, Height/2 - 50);
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

  public void update(ArrayList<Line> L) {
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
          tE.setMag(atan(tE.mag()*0.005f)/HALF_PI);
        }
        V[y][x] = tE;
      }
    }
  }

  public void draw() {
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
class Line {
  ArrayList<PVector> L;
  float Qp;
  boolean Qs; // Sign of Qp
  boolean selected;

  Line() {
    L = new ArrayList<PVector>();
    Qp = 3e-9f;
    Qs = true;
  }

  public PVector getEV(PVector pos) {
    PVector EV = new PVector();
    for (int dli = 0; dli < L.size() - 1; dli++) { // Prolaz kroz sve clanove liste L
      float dl = PVector.sub(L.get(dli), L.get(dli+1)).mag(); // Duzina delica putanje
      PVector r = PVector.sub(L.get(dli), pos); // Vektor udaljenosti delica putanje i tacke M
      float dV = 1.0f/4/PI/e0 * Qp * dl / r.mag(); // "Diferencijal" napona
      PVector rn = new PVector(r.x, r.y);
      rn.normalize(); // Ort vektor vektora r
      PVector dE = PVector.mult(rn, (!Qs?1:-1) *1.0f/4/PI/e0 * Qp * dl / sq(r.mag())); // "Diferencijal" vektora elektricnog polja
      dE.z = dV;
      // Integraljenje:
      EV.add(dE);
    }
    return EV;
  }

  public PVector getE(PVector pos) {
    PVector EV = new PVector();
    for (int dli = 0; dli < L.size() - 1; dli++) { // Prolaz kroz sve clanove liste L
      float dl = PVector.sub(L.get(dli), L.get(dli+1)).mag(); // Duzina delica putanje
      PVector r = PVector.sub(L.get(dli), pos); // Vektor udaljenosti delica putanje i tacke M
      PVector rn = new PVector(r.x, r.y);
      rn.normalize(); // Ort vektor vektora r
      PVector dE = PVector.mult(rn, (!Qs?1:-1) *1.0f/4/PI/e0 * Qp * dl / sq(r.mag())); // "Diferencijal" vektora elektricnog polja
      // Integraljenje:
      EV.add(dE);
    }
    return EV;
  }

  public float getV(PVector pos) {
    float V = 0;
    for (int dli = 0; dli < L.size() - 1; dli++) { // Prolaz kroz sve clanove liste L
      float dl = PVector.sub(L.get(dli), L.get(dli+1)).mag(); // Duzina delica putanje
      PVector r = PVector.sub(L.get(dli), pos); // Vektor udaljenosti delica putanje i tacke M
      float dV = 1.0f/4/PI/e0 * Qp * dl / r.mag(); // "Diferencijal" napona
      // Integraljenje:
      V += dV;
    }
    return V;
  }

  public float getDist(PVector v) {
    float ret = 1e5f;
    for (PVector l : L) {
      float d = dist(v.x, v.y, l.x, l.y);
      ret = d < ret ? d : ret;
    }
    return ret;
  }

  public void draw(boolean bold) {
    if (bold)strokeWeight(2);
    else strokeWeight(1);
    stroke(0);
    for (int i = 0; i < L.size()-1; i++) {
      PVector a = L.get(i);
      PVector b = L.get(i+1);
      line(a.x*scale, a.y*scale, b.x*scale, b.y*scale);
    }
  }

  public void addNewSegment(PVector v) {
    L.add(v);
    optimizeL(L);
  }

  public void inc() {
    Qp *= 1.1f;
  }

  public void dec() {
    Qp /= 1.1f;
  }

  public void neg() {
    Qs = !Qs;
  }
}

class Ekvi {
  ArrayList<PVector> L;
  ArrayList<PVector> next;
  Switch we;

  Ekvi() {
    L = new ArrayList<PVector>();
    we = new Switch("Ekvi [E]");
  }

  public void calcWE(ArrayList<Line> Lp) {
    if (!we.state) calcEkvi(Lp);
    else calcLin(Lp);
  }

  public void calcLin(ArrayList<Line> Lp) {
    L = new ArrayList<PVector>();
    PVector c = new PVector(mX/scale, mY/scale);
    L.add(c);
    PVector tE;
    for (int i = 0; i < ekviDist; i++) {
      tE = new PVector();
      for (int j = 0; j < Lp.size(); j++) {
        tE.add(Lp.get(j).getE(L.get(L.size()-1)));
      }
      tE.setMag(0.01f);
      L.add(PVector.add(L.get(L.size()-1), tE));
    }
    L.add(c);
    for (int i = 0; i < ekviDist; i++) {
      tE = new PVector();
      for (int j = 0; j < Lp.size(); j++) {
        tE.add(Lp.get(j).getE(L.get(L.size()-1)));
      }
      tE.rotate(-PI);
      tE.setMag(0.01f);
      L.add(PVector.add(L.get(L.size()-1), tE));
    }
  }

  public void calcEkvi(ArrayList<Line> Lp) {
    L = new ArrayList<PVector>();
    /*
     next = new ArrayList<PVector>();
     next.add(new PVector(mX/scale, mY/scale));
     for (int i = 0; i < 2; i++) {
     calcNext(Lp);
     }*/
    PVector c = new PVector(mX/scale, mY/scale);
    L.add(c);
    PVector tE;
    for (int i = 0; i < ekviDist; i++) {
      tE = new PVector();
      for (int j = 0; j < Lp.size(); j++) {
        tE.add(Lp.get(j).getE(L.get(L.size()-1)));
      }
      tE.rotate(HALF_PI);
      tE.setMag(0.01f);
      L.add(PVector.add(L.get(L.size()-1), tE));
    }
    L.add(c);
    for (int i = 0; i < ekviDist; i++) {
      tE = new PVector();
      for (int j = 0; j < Lp.size(); j++) {
        tE.add(Lp.get(j).getE(L.get(L.size()-1)));
      }
      tE.rotate(-HALF_PI);
      tE.setMag(0.01f);
      L.add(PVector.add(L.get(L.size()-1), tE));
    }
  }

  public void calcNext(ArrayList<Line> Lp) { // in progress
    int k = next.size();
    for (int loop = 0; loop < k; loop++) {
      PVector p = next.get(0);
      L.add(p);
      next.remove(0);
      PVector[] t = new PVector[10];
      float c = 0;
      for (int j = 0; j < Lp.size(); j++) {
        c += Lp.get(j).getV(p);
      }
      for (int i = 0; i < 10; i++) {
        t[i] = PVector.add(p, (new PVector(0.01f, 0)).rotate(i*TWO_PI/10));
        for (int j = 0; j < Lp.size(); j++) {
          t[i].z += Lp.get(j).getV(t[i]);
        }
        //println(PVector.sub(p, new PVector(t[i].x, t[i].y, t[i].z-c)));
      }
      //println();
      for (int i = 0; i < 9; i++) {
        if (sgn(t[i].z-c)*sgn(t[i+1].z-c) == -1) {
          boolean toadd = true;
          /*for (PVector pv : L) {
           if (dist(t[i].x, t[i].y, pv.x, pv.y)<0.01)
           toadd = false;
           }*/
          //if (toadd)
          next.add(new PVector(t[i].x, t[i].y));
        }
      }
    }
  }

  public void update(ArrayList<Line> Lp) {
    calcWE(Lp);
  }

  public void draw() {
    PVector a;
    for (int i = 0; i < L.size()-1; i+=5) {
      a = L.get(i);
      stroke(50);
      strokeWeight(3);
      point(a.x*scale, a.y*scale);
      strokeWeight(1);
    }
  }
}

class Calcer {
  int i, Li;
  PVector cur;
  Switch calc;

  Calcer() {
    i = Li = 0;
    cur = new PVector();
    calc = new Switch("Calculate [ ]");
  }

  public void update(ArrayList<Line> L) {
    if (calc.state) {
      if (L == null) return;
      while (L.get(Li).L.size() < 3) {
        Li++;
        if (Li >= L.size()) {
          Li = 0;
          cur = new PVector();
          calc.state = !calc.state;
          return;
        }
      }
      float dl = PVector.sub(L.get(Li).L.get(i), L.get(Li).L.get(i+1)).mag(); // Duzina delica putanje
      PVector r = PVector.sub(L.get(Li).L.get(i), S.M); // Vektor udaljenosti delica putanje i tacke M
      float dV = 1.0f/4/PI/e0 * L.get(Li).Qp * dl / r.mag(); // "Diferencijal" napona
      PVector rn = new PVector(r.x, r.y);
      rn.normalize(); // Ort vektor vektora r
      PVector dE = PVector.mult(rn, 1.0f/4/PI/e0 * L.get(Li).Qp * dl / sq(r.mag())); // "Diferencijal" vektora elektricnog polja
      // Integraljenje:
      cur.add(new PVector(dE.x, dE.y, dV));
      S.EV = cur;
      i++;
      if (i == L.get(Li).L.size() - 2) {
        i = 0;
        Li ++;
        if (Li == L.size()) {
          Li = 1;
          calc.state = !calc.state;
        }
      }
    }
  }

  public void draw(ArrayList<Line> L) {
    if (calc.state) {
      if (L.size() > 1) {
        if (L.get(Li).L.size() > 1) {
          PVector r = PVector.sub(L.get(Li).L.get(i), S.M); // Vektor udaljenosti delica putanje i tacke M
          line(S.M.x * scale, S.M.y * scale, (S.M.x + r.x) * scale, (S.M.y + r.y) * scale); // Iscrtavanje procesa racunanja
        }
      }
    }
  }
}

class System {
  ArrayList<Line> L;
  ArrayList<Switch> s;
  ArrayList<Button> b;
  Map m;
  Vfield e;
  Ekvi ekvi;
  Calcer calc;
  PVector M;
  PVector EV;
  Line sel;
  String HelpEn;
  String HelpRs;

  System() {
    ButtonNo = 1;
    s = new ArrayList<Switch>();
    b = new ArrayList<Button>();
    m = new Map();
    e = new Vfield();
    ekvi = new Ekvi();
    s.add(m.showMap);
    s.add(e.show);
    s.add(e.ef);
    s.add(ekvi.we);
    s.add(new Switch("Help (H)"));
    s.add(new Switch("Language (J)"));
    b.add(new Button("Load (L)"));
    b.add(new Button("Save (S)"));
    calc = new Calcer();
    s.add(calc.calc);

    reset();

    HelpEn = "This is a visualizer for common notions in electrostatics.\n" +
      "For drawing charged lines use the left mouse button.\n" +
      "Optionally use CTRL for snap to grid feature or SHIFT for straight lines.\nPress ENTER when finishing a line drawn with CTRL and SHIFT features\n" +
      "You can enter circle drawing mode by pressing C (use mouse wheel for changing radius).\n" +
      "With the buttons on the right, you can show the map of electric potential, electric vector field,\nthis help page and many more, the letters in braces are keyboard shortcuts.\n" +
      "In the bottom right corner, there is data about the electric potential,\nelectric field vector and the linear charge of the line closest to the cursor.\n" +
      "When the button Calculate is pressed a visual calculation is preformed (shortcut is SPACE)\n" +
      "Using + and - you can increse or decrese the charge on the line closest to the cursor\n(the line that is bolded), linear charge is shown in the bottom right corner.\n" +
      "Using Load and Save you can save a text file containing information about the drawn lines.\nSaving a file with extention .png saves a screenshot.\n" +
      "Show Map shows a heatmap of the electric potential.\n" +
      "Show Field shows a vector field for the electric field vector, and Field mode makes the vectors normalized\n" +
      "Pressing Ekvi will change the mode of the dashed line, ekvipotential or one electric line";

    HelpRs = "Ovo je vizuelizator za \u010deste pojame elektrostatike.\n" +
      "Za crtanje naelektrisanih linija koristite levo dugme mi\u0161a.\n" +
      "Dr\u017eanjem CTRL mo\u017eete uklju\u010diti snap to grid opciju, a sa SHIFT mo\u017eete crtati prave linije.\nPritisnite ENTER da bi ste zavr\u0161ili liniju koju ste crtali kori\u0161\u0107enjem CTRL i SHIFT" +
      "Mo\u017eete uklju\u010diti mod za crtanje krugova pritiskom na C (Koristite kru\u017ei\u0107 na mi\u0161u za menjanje pre\u010dnika).\n" +
      "Pomo\u0107u dugmi\u0107a sa desne strane, mo\u017eete prikazati mapu potencijala,\nvektorsko polje vektora elektri\u010dnog polja, ovu stranicu i jo\u0161 puno toga, slova u zagradama su pre\u010dice za tastaturu.\n" +
      "U donjem desnom uglu, postoje podaci o potencijalu,\nelektri\u010dnom polju i podu\u017enom naelektrisanju linije najbli\u017ee kursoru.\n" + 
      "Pritiskom na dugme Calculate, vr\u0161i se vizuelni ra\u010dun (skra\u0107enica SPACE)" +
      "Kori\u0161\u0107enjem + i -, mo\u017eete pove\u0107ati ili smanjiti naelektrisanje na liniji najbli\u017eoj kursoru\n(podebljana linija), podu\u017eno naelektrisanje je prikazano u donjem desnom uglu.\n" +
      "Mo\u017eete koristiti Load i Save da sa\u010duvate ili otvorite tekstualnu datoteku koja sadr\u017ei podatke o nacrtanim linijama.\nCuvanjem datoteke sa zavrsetkom .png cuva sliku" +
      "Show Map prikazuje mapu potencijala.\n" +
      "Show Field prikazuje vektorsko polje vektora elektricnog polja, a Field mode prikazuje normalizovane vektore\n" +
      "Ekvi menja mod za isprekidanu liniju: Ekvipotencijala ili jedna linija elektri\u010dnog polja\n";
  }


  public void update() {
    for (Switch ss : s) {
      ss.update();
    }
    for (Button ss : b) {
      ss.update();
    }
    if (sel != null && keyPressed && !pkeyPressed) {
      if (key == '+') {
        sel.inc();
        m.update(L);
        e.update(L);
      }
      if (key == '-') {
        sel.dec();
        m.update(L);
        e.update(L);
      }
      if (key == '*') {
        sel.neg();
        m.update(L);
        e.update(L);
      }
    }

    if (b.get(0).state) ld();
    if (b.get(1).state) sv();

    EV = new PVector();
    for (int i = 0; i < L.size(); i++) {
      EV.add(L.get(i).getEV(M));
    }
    ekvi.update(L);
    calc.update(L);
  }

  public void draw() {
    background(255);

    fill(255);
    stroke(0);
    rect(Width, 0, 100-1, Height-1);
    for (Switch ss : s) {
      ss.draw();
    }
    for (Button ss : b) {
      ss.draw();
    }

    m.draw();

    drawAxis();

    float min = 1;
    sel = null;
    for (int i = 0; i < L.size(); i++) {
      L.get(i).draw(false);
      float d = L.get(i).getDist(new PVector(mX/scale, mY/scale));
      if (d < min) {
        sel = L.get(i);
        min = d;
      }
    }
    if (sel != null) sel.draw(true);

    e.draw();

    if (circleMode) {
      stroke(128);
      noFill();
      ellipse(mX, mY, circleRadius*2*scale, circleRadius*2*scale);
    }

    ekvi.draw();
    calc.draw(L);

    strokeWeight(1);
    fill(0);
    stroke(0);
    ellipse(M.x*scale, M.y*scale, 5, 5);
    PVector E = new PVector(EV.x, EV.y);
    drawVector(M, E);
    textAlign(LEFT, BOTTOM);
    text("U = \t" + nfplus(EV.z, 1, 2) + "V\nE = " + nfplus(E.mag(), 1, 2) + "V/m\n" + (sel!=null?("Q\' = " + (sel.Qs?"":"-") + nfplus(sel.Qp, 1, 2) + "C/m"):""), Width + 1, Height-5);

    if (s.get(4).state) {
      fill(255, 200, 200, 200);
      rect(-1, -1, width + 1, height + 1);
      fill(0);
      textSize(15);
      textAlign(CENTER, CENTER);
      text(!s.get(5).state?HelpEn:HelpRs, width/2, height/2);
      textSize(11.5f);
    }
  }

  public void addNewLine() {
    L.add(new Line());
  }

  public void addNewSegment(PVector v) {
    L.get(L.size()-1).addNewSegment(v);
  }

  public void reset() {

    L = new ArrayList<Line>();
    addNewLine();
    M = new PVector(2, 2);
    EV = new PVector();
    m.update(L);
    e.update(L);
  }
}
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

  public void update() {
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

  public void draw() {

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
  
  public void change() {
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

  public void update() {
    state = false;
    if (mousePressed && !pmousePressed) {
      if (mouseX > pos.x-30 && mouseX < pos.x+30 && mouseY > pos.y && mouseY < pos.y + 20) state = !state;
    }
  }

  public void draw() {
    fill(0);
    textAlign(CENTER, BOTTOM);
    text(text, pos.x, pos.y - 5);

    fill(state?255:0);
    rect(pos.x - 30, pos.y, 60, 20);
  }
}

public void drawVector(PVector ss, PVector ee) { // Crta vektor
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
  PVector back = PVector.sub(s, PVector.add(s, e)).mult(0.1f);
  back.rotate(PI/6);
  line(s.x + e.x, s.y + e.y, s.x + e.x + back.x, s.y + e.y + back.y);
  back.rotate(-PI/3);
  line(s.x + e.x, s.y + e.y, s.x + e.x + back.x, s.y + e.y + back.y);
  strokeWeight(1);
}

public String nfplus(float x, int l, int r) { // Lepse pretstavlja vrednosti
  if (x == 0 || x<1e-15f) return "0 ";
  if (x > 1e15f) return "+\u221e ";
  int s = 0;
  while (x < 1) {
    x*=1e3f;
    s++;
  }
  while (x > 1e3f) {
    x/=1e3f;
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

public void drawAxis() {
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

public int lerpc(float p) {
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

public int sgn(float a) {
  return a > 0 ? 1 : -1;
}
public void sv() {
  String save = "Saves/Screenshot from " + year()+"-"+nf(month(), 2, 0)+"-"+nf(day(), 2, 0)+" "+nf(hour(), 2, 0)+"-"+nf(minute(), 2, 0)+"-"+nf(second(), 2, 0);
  if (saveMode) {
    println(save + ".png");
    save(save + ".png");
  } else {
    JFileChooser jfc = new JFileChooser();
    int retrival = jfc.showSaveDialog(null);
    if (retrival == JFileChooser.APPROVE_OPTION) {
      try {
        String file = jfc.getSelectedFile().getAbsolutePath();
        FileWriter fw;
        if (file.charAt(file.length() - 1) == 'g' &&
          file.charAt(file.length() - 2) == 'n' &&
          file.charAt(file.length() - 3) == 'p' &&
          file.charAt(file.length() - 4) == '.') {
          //println(jfc.getSelectedFile() + "");
          save(jfc.getSelectedFile() + "");
        } else {
          if (file.charAt(file.length() - 1) == 't' &&
            file.charAt(file.length() - 2) == 'x' &&
            file.charAt(file.length() - 3) == 't' &&
            file.charAt(file.length() - 4) == '.')
            fw = new FileWriter(jfc.getSelectedFile());
          else fw = new FileWriter(jfc.getSelectedFile()+".txt");
          for (int i = 0; i < S.L.size(); i++) {
            for (int j = 0; j < S.L.get(i).L.size(); j++) {
              //P.println(L.get(i).get(j).x + "\t" + L.get(i).get(j).y);
              fw.write(S.L.get(i).L.get(j).x + "\t" + S.L.get(i).L.get(j).y + "\n");
            }
            fw.write("END\n");
          }
          fw.flush();
          fw.close();
          println(save + ".txt");
        }
      }
      catch (Exception ex) {
        ex.printStackTrace();
      }
    }
  }
}

public void ld() {
  JFileChooser jfc = new JFileChooser();
  FileNameExtensionFilter filter = new FileNameExtensionFilter( "txt files", "txt");
  jfc.setFileFilter(filter);
  int returnVal = jfc.showOpenDialog(null);
  if (returnVal == JFileChooser.APPROVE_OPTION) {
    String file = jfc.getSelectedFile().getAbsolutePath();
    println("The file you have chosen: " + file);
    BufferedReader R = createReader(file);
    String line;
    S.L = new ArrayList<Line>();
    do {
      try {
        line = R.readLine();
      } 
      catch (IOException e) {
        line = null;
      }
      if (line != null) {
        String[] pieces = split(line, TAB);
        if (pieces[0].equals("END")) {
          S.addNewLine();
        } else if (pieces.length == 2) {
          S.addNewSegment(new PVector(PApplet.parseFloat(pieces[0]), PApplet.parseFloat(pieces[1])));
        }
      }
    } while (line != null);
  }
}
  public void settings() {  size(900, 600); }
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "POET1D1Plus" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
