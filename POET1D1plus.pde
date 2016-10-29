/* Utorak 25. Oktobar 2016 //<>//
 * Dodatak za domaci zadatak iz POETa
 * Djordje Marjanovic 120/16
 * Features:
 *  Racunanje potenciala i vektora elektricnog polja u tacki
 *  Crtanje vise kriva misem
 *  Mod za crtanje kruga
 *  Generisanje mape zavisnosti potenciala od koordinata
 *  Stap to grid
 *  Crtanje dugackih pravih linija
 *  Dva moda racunanja: automatsk i ne automatski
 *  Brisanje celog ekrana
 *  
 *
 *
 *
 *
 *
 *
 */

ArrayList<ArrayList<PVector>> L; // Lista vektora koja pretstavlja nit

float Qp; // Poduzno naelektrisanje niti [C/m]
float V; // Napon izmedju tacke M i tacke u beskonacnosti [V]
float len; // Duzina niti [m]
int dli; // Iterator za listu L[curadd]
int dLi; // Iterator za listu L
PVector M = new PVector(2.5, 2.5); // Vektor polozaja tacke [m]
PVector E; // Vektor elektricnog polja [V/m]
boolean calc = false; // Flag za vizuelizaciju racunanja V i E
boolean auto = true; // Flag za automatsko racunanje
PImage map; // Potencijal u odnosu na koordinate
boolean showMap; // Flag za prikazivanje mape
boolean mapChanged; // Flag za proveru promene
float mapFadeTime; // Sluzi za lepse iskljucivanje mape;
boolean pmousePressed; // Prethodno stanje mousePressed promenljive
boolean circleMode; // Flag za crtanje krugova

final float VoltScale = 0.005;
final float e0 = 8.8542e-12; // Permitivnost vakuma/vazduha [F/m]
final float scale = 100; // Odnos metara i piksela 
final float dmin = 1e-2; // najmanja duzina (u metrima) dela puta
final float dmax = 1e-1; // najveca duzina (u metrima) dela puta

void setup() {
  size(900, 600); // Podesava velicinu ekrana
  Qp = 3e-9; // Pocetno poduzno naelektrisanje niti
  V = 0; // Vrednost napona pre racunanja
  // Inicializacija niti
  dLi = 0;
  L = new ArrayList<ArrayList<PVector>>();
  ArrayList<PVector> curL = new ArrayList<PVector>();
  L.add(curL);
  map = createImage(width, height, RGB);
  showMap = false;
  E = new PVector(); // Vrednost vektora elektricnog polja pre racunanja
}

void draw() { // Glavna petlja programa
  if (mousePressed && !calc) {
    if (mouseButton == LEFT) { // Produzivanje putanje pri pritisku na dugme 
      if (circleMode) {
        
      } else {
        if (!pmousePressed && !(keyPressed && key==CODED && (keyCode == SHIFT || keyCode == CONTROL) )) {// Rising edge
          L.add(new ArrayList<PVector>());
          mapChanged = true;
        }
        boolean snap = keyPressed && key == CODED && keyCode == CONTROL;
        if (keyPressed && key == CODED && keyCode == CONTROL) {
          float mX = 50*int(mouseX/50.0 + 0.5);
          float mY = 50*int(mouseY/50.0 + 0.5);
          L.get(L.size()-1).add(new PVector(mX/scale, mY/scale));
        } else L.get(L.size()-1).add(new PVector(mouseX/scale, mouseY/scale));
      }
      optimizeL(L.get(L.size()-1));
    } else if (mouseButton == RIGHT) { // Pomeranje tacke M
      if (keyPressed && key == CODED && keyCode == CONTROL) {
        float mX = 50*int(mouseX/50.0 + 0.5);
        float mY = 50*int(mouseY/50.0 + 0.5);
        M.set(mX/scale, mY/scale);
      } else M.set(mouseX/scale, mouseY/scale);
    }
  }

  background(255); // boja pozadine (belo)
  if (showMap) {
    mapFadeTime += 32;
    if (mapFadeTime > 255) mapFadeTime = 255;
  } else {
    mapFadeTime -= 32;
    if (mapFadeTime < 0) mapFadeTime = 0;
  }
  tint(255, mapFadeTime);
  image(map, 0, 0);

  //Iscrtavanje koordinatne ravni:
  textAlign(LEFT, TOP);
  text("0m", 0, 0);

  stroke(0);
  textAlign(LEFT, BOTTOM);
  for (int y = 100; y < height; y+= 100) {
    line(0, y, 5, y);
    text(" " + y/100 + "m", 3, y);
    stroke(200);
    line(5, y, width, y);
  }

  stroke(0);
  textAlign(LEFT, CENTER);
  for (int x = 100; x < width; x+= 100) {
    line(x, 0, x, 5);
    text(" " + x/100 + "m", x, 5);
    stroke(200);
    line(x, 5, x, height);
  }

  if (showMap) {
    // Crtanje slicice koja se nalazi na desnoj strani
    fill(0);
    stroke(0);
    rect(width - 20, height/2 - 50, 20, 100);
    line(width - 20, height/2 - 50, width - 25, height/2 - 50);
    line(width - 20, height/2, width - 25, height/2);
    line(width - 20, height/2 + 50, width - 25, height/2 + 50);
    for (float i = 0.04; i < 3.96; i+= 0.04) {
      stroke(lerpc(i));
      line(width - 19, height/2 + 50 - map(i, 0, 4, 0, 100), width - 2, height/2 + 50 - map(i, 0, 4, 0, 100));
    }
    textAlign(RIGHT, BOTTOM);
    text("0V", width - 25, height/2 + 50);
    textAlign(RIGHT, CENTER);
    text(int(2/VoltScale) + "V", width - 25, height/2 );
    textAlign(RIGHT, TOP);
    text(int(4/VoltScale) + "V", width - 25, height/2 - 50);
  }

  stroke(0);
  // Kraj iscrtavanja koordinatne ravni

  if (auto) { // Racunanje
    PVector tE = new PVector();
    float tV = 0;
    for (int i = 0; i < L.size(); i++) {
      calcStuff(L.get(i), M);
      tE.add(E);
      tV += V;
    }
    E.set(tE);
    V = tV;
  }

  if (L.get(dLi).size() < 3) {
    dLi ++;
    if (dLi == L.size()) dLi = 0;
  }

  if (calc && L.get(dLi).size() > 2 && !auto) {
    float dl = PVector.sub(L.get(dLi).get(dli), L.get(dLi).get(dli+1)).mag(); // Duzina delica putanje
    PVector r = PVector.sub(L.get(dLi).get(dli), M); // Vektor udaljenosti delica putanje i tacke M
    float dV = 1.0/4/PI/e0 * Qp * dl / r.mag(); // "Diferencijal" napona
    PVector rn = new PVector(r.x, r.y);
    rn.normalize(); // Ort vektor vektora r
    line(M.x * scale, M.y * scale, (M.x + r.x) * scale, (M.y + r.y) * scale); // Iscrtavanje procesa racunanja
    PVector dE = PVector.mult(rn, 1.0/4/PI/e0 * Qp * dl / sq(r.mag())); // "Diferencijal" vektora elektricnog polja
    // Integraljenje:
    V += dV;
    E.add(dE);
    // Iteriranje:
    dli++;
    if (dli == L.get(dLi).size() - 2) {
      dli = 0;
      dLi ++;
      if (dLi == L.size()) {
        dLi = 1;
        calc = false;
      }
    }
  }
  // Crtanje niti i racunanje duzine:
  len = 0;
  for (int Li = 0; Li < L.size(); Li++) {
    for (int i = 0; i < L.get(Li).size()-1; i++) {
      PVector a = L.get(Li).get(i);
      PVector b = L.get(Li).get(i+1);
      line(a.x*scale, a.y*scale, b.x*scale, b.y*scale);
      len += PVector.sub(a, b).mag();
    }
  }

  if (keyPressed && key==CODED && keyCode == SHIFT && L.size()>1 && L.get(L.size()-1).size() > 0) {
    PVector last = L.get(L.size() - 1).get(L.get(L.size()-1).size() - 1);
    stroke(128);
    line(last.x*scale, last.y*scale, mouseX, mouseY);
  }

  //Iscrtavanje:
  fill(0);
  ellipse(M.x*scale, M.y*scale, 5, 5);
  drawVector(M, E);
  textAlign(LEFT, BOTTOM);
  text("U = \t" + nfplus(V, 1, 3) + "V\nE = " + nfplus(E.mag(), 1, 3) + "V/m\nQ\' = " + nfplus(Qp, 1, 3) + "C/m\nAutomatic: " + auto, 5, height-5);
  pmousePressed = mousePressed;
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
      if (PVector.sub(a, b).mag() > dmax) {
        L.add(i + 1, PVector.add(a, b).mult(0.5));
        i++;
      }
      i++;
    }
  }
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

void keyPressed() { // Pri pritisku na dugme na tastaturi
  if (key == ' ' && !auto) { // space zapocinje racun
    calc = !calc;
    if (calc == true) {
      dli = 0;
      dLi = 0;
      V = 0;
      E = new PVector();
    }
  }
  if (key == 'r' || key == 'R') { // Restartuje simulaciju
    setup();
  }
  if (key == '+') { 
    Qp *= 1.1; // Povecava Qp
    if (showMap) updateMap();
  }
  if (key == '-') {
    Qp *= 0.9; // Smanjuje Qp
    if (showMap) updateMap();
  }
  if (key == 'a') { // Menja stanje automatskog racuna
    auto = !auto;
  }
  if (key == 'c') { // Postavi sistem kao sto je zadat za domaci
    setup();
    M = new PVector(2.5, 2.5);
    float dfi = PI*0.01;
    for (float fi = 0; fi <= TWO_PI; fi += dfi ) {
      L.get(L.size()-1).add(new PVector(2+cos(fi), 2.5+sin(fi)));
      optimizeL(L.get(L.size()-1));
    }
  }
  if (key == 'm') {
    if (showMap && !mapChanged) showMap = false;
    else {
      updateMap();
    }
  }
  if (key == ENTER) {
    L.add(new ArrayList<PVector>());
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

void calcV(ArrayList<PVector> L, PVector pos) {
  //pocetna vrednost
  V = 0;
  for (int dli = 0; dli < L.size() - 1; dli++) { // Prolaz kroz sve clanove liste L
    float dl = PVector.sub(L.get(dli), L.get(dli+1)).mag(); // Duzina delica putanje
    PVector r = PVector.sub(L.get(dli), new PVector(pos.x, pos.y)); // Vektor udaljenosti delica putanje i tacke M
    float dV = 1.0/4/PI/e0 * Qp * dl / r.mag(); // "Diferencijal" napona
    // Integraljenje:
    V += dV;
  }
}

void calcE(ArrayList<PVector> L, PVector pos) {
  //pocetna vrednost
  E = new PVector();
  for (int dli = 0; dli < L.size() - 1; dli++) { // Prolaz kroz sve clanove liste L
    float dl = PVector.sub(L.get(dli), L.get(dli+1)).mag(); // Duzina delica putanje
    PVector r = PVector.sub(L.get(dli), pos); // Vektor udaljenosti delica putanje i tacke M
    PVector rn = new PVector(r.x, r.y);
    rn.normalize(); // Ort vektor vektora r
    PVector dE = PVector.mult(rn, 1.0/4/PI/e0 * Qp * dl / sq(r.mag())); // "Diferencijal" vektora elektricnog polja
    // Integraljenje:
    E.add(dE);
  }
}

void calcStuff(ArrayList<PVector> L, PVector pos) {
  //pocetne vrednosti
  E = new PVector();
  V = 0;
  for (int dli = 0; dli < L.size() - 1; dli++) { // Prolaz kroz sve clanove liste L
    float dl = PVector.sub(L.get(dli), L.get(dli+1)).mag(); // Duzina delica putanje
    PVector r = PVector.sub(L.get(dli), pos); // Vektor udaljenosti delica putanje i tacke M
    float dV = 1.0/4/PI/e0 * Qp * dl / r.mag(); // "Diferencijal" napona
    PVector rn = new PVector(r.x, r.y);
    rn.normalize(); // Ort vektor vektora r
    PVector dE = PVector.mult(rn, 1.0/4/PI/e0 * Qp * dl / sq(r.mag())); // "Diferencijal" vektora elektricnog polja
    // Integraljenje:
    V += dV;
    E.add(dE);
  }
}

void updateMap() {
  showMap = true;
  map = createImage(width, height, RGB);
  map.loadPixels();
  for (int x = 2; x < width; x += 5) {
    for (int y = 2; y < height; y += 5) {
      float tV = 0;
      for (int i = 0; i < L.size(); i++) {
        calcV(L.get(i), new PVector(x/scale, y/scale));
        tV += V;
      }
      V = tV;
      for (int xp = x-2; xp < x+3; xp++) {
        for (int yp = y-2; yp < y+3; yp++) {
          map.pixels[yp*width + xp] = lerpc(VoltScale*V);
        }
      }
    }
  }
  map.updatePixels();
  map.filter(BLUR, 3);
  mapChanged = false;
}