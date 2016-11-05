/* Utorak 25. Oktobar 2016 //<>//
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

import javax.swing.*;
import javax.swing.filechooser.*;
import java.io.*;

boolean saveMode;
boolean pmousePressed; // Prethodno stanje mousePressed promenljive
boolean pkeyPressed; // Prethodno stanje keyPressed promenljive
boolean circleMode; // Flag za crtanje krugova
float circleRadius = 1; // Poluprecnik kruga
float mX, mY;
int Width;
int Height;
int ButtonNo;

final float VoltScale = 0.005;
final float e0 = 8.8542e-12; // Permitivnost vakuma/vazduha [F/m]
final float scale = 100; // Odnos metara i piksela 
final float dmin = 1e-2; // najmanja duzina (u metrima) dela puta
final float dmax = 1e-1; // najveca duzina (u metrima) dela puta
final int ekviDist = 1000; // Broj tacaka koji se koriste za iscrtavanje ekvipotencijale i linije polja

System S;

void init() {
  S.reset();
}

void setup() {
  size(900, 600); // Podesava velicinu ekrana
  Width = 800;
  Height = 600;
  S = new System();
  init();
}

void draw() {
  if (keyPressed && key == CODED && keyCode == CONTROL) {
    mX = 50*int(mouseX/50.0 + 0.5);
    mY = 50*int(mouseY/50.0 + 0.5);
  } else {
    mX = mouseX;
    mY = mouseY;
  }

  if (mousePressed && mouseX < Width) {
    if (mouseButton == LEFT) { // Produzivanje putanje pri pritisku na dugme
      if (circleMode) {
        if (!pmousePressed) {
          S.addNewLine();
          float dfi = TWO_PI*0.01;
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

void optimizeL(ArrayList<PVector> L) { // Izbacuje previse kratke delove niti, a previse dugacke deli na manje.
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
        b = PVector.add(a, b).mult(0.5);
        L.add(i + 1, b);
      }
      println();
      i++;
    }
      println();
  }
}

void keyPressed() {
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

void mouseWheel(MouseEvent event) {
  if (circleMode) { 
    circleRadius -= 10*event.getCount()/scale;
    if (circleRadius > 3) circleRadius = 3;
    if (circleRadius < 0.1) circleRadius = 0.1;
  }
}