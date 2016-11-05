class Line {
  ArrayList<PVector> L;
  float Qp;
  boolean Qs; // Sign of Qp
  boolean selected;

  Line() {
    L = new ArrayList<PVector>();
    Qp = 3e-9;
    Qs = true;
  }

  PVector getEV(PVector pos) {
    PVector EV = new PVector();
    for (int dli = 0; dli < L.size() - 1; dli++) { // Prolaz kroz sve clanove liste L
      float dl = PVector.sub(L.get(dli), L.get(dli+1)).mag(); // Duzina delica putanje
      PVector r = PVector.sub(L.get(dli), pos); // Vektor udaljenosti delica putanje i tacke M
      float dV = 1.0/4/PI/e0 * Qp * dl / r.mag(); // "Diferencijal" napona
      PVector rn = new PVector(r.x, r.y);
      rn.normalize(); // Ort vektor vektora r
      PVector dE = PVector.mult(rn, (!Qs?1:-1) *1.0/4/PI/e0 * Qp * dl / sq(r.mag())); // "Diferencijal" vektora elektricnog polja
      dE.z = dV;
      // Integraljenje:
      EV.add(dE);
    }
    return EV;
  }

  PVector getE(PVector pos) {
    PVector EV = new PVector();
    for (int dli = 0; dli < L.size() - 1; dli++) { // Prolaz kroz sve clanove liste L
      float dl = PVector.sub(L.get(dli), L.get(dli+1)).mag(); // Duzina delica putanje
      PVector r = PVector.sub(L.get(dli), pos); // Vektor udaljenosti delica putanje i tacke M
      PVector rn = new PVector(r.x, r.y);
      rn.normalize(); // Ort vektor vektora r
      PVector dE = PVector.mult(rn, (!Qs?1:-1) *1.0/4/PI/e0 * Qp * dl / sq(r.mag())); // "Diferencijal" vektora elektricnog polja
      // Integraljenje:
      EV.add(dE);
    }
    return EV;
  }

  float getV(PVector pos) {
    float V = 0;
    for (int dli = 0; dli < L.size() - 1; dli++) { // Prolaz kroz sve clanove liste L
      float dl = PVector.sub(L.get(dli), L.get(dli+1)).mag(); // Duzina delica putanje
      PVector r = PVector.sub(L.get(dli), pos); // Vektor udaljenosti delica putanje i tacke M
      float dV = 1.0/4/PI/e0 * Qp * dl / r.mag(); // "Diferencijal" napona
      // Integraljenje:
      V += dV;
    }
    return V;
  }

  float getDist(PVector v) {
    float ret = 1e5;
    for (PVector l : L) {
      float d = dist(v.x, v.y, l.x, l.y);
      ret = d < ret ? d : ret;
    }
    return ret;
  }

  void draw(boolean bold) {
    if (bold)strokeWeight(2);
    else strokeWeight(1);
    stroke(0);
    for (int i = 0; i < L.size()-1; i++) {
      PVector a = L.get(i);
      PVector b = L.get(i+1);
      line(a.x*scale, a.y*scale, b.x*scale, b.y*scale);
    }
  }

  void addNewSegment(PVector v) {
    L.add(v);
    optimizeL(L);
  }

  void inc() {
    Qp *= 1.1;
  }

  void dec() {
    Qp /= 1.1;
  }

  void neg() {
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

  void calcWE(ArrayList<Line> Lp) {
    if (!we.state) calcEkvi(Lp);
    else calcLin(Lp);
  }

  void calcLin(ArrayList<Line> Lp) {
    L = new ArrayList<PVector>();
    PVector c = new PVector(mX/scale, mY/scale);
    L.add(c);
    PVector tE;
    for (int i = 0; i < ekviDist; i++) {
      tE = new PVector();
      for (int j = 0; j < Lp.size(); j++) {
        tE.add(Lp.get(j).getE(L.get(L.size()-1)));
      }
      tE.setMag(0.01);
      L.add(PVector.add(L.get(L.size()-1), tE));
    }
    L.add(c);
    for (int i = 0; i < ekviDist; i++) {
      tE = new PVector();
      for (int j = 0; j < Lp.size(); j++) {
        tE.add(Lp.get(j).getE(L.get(L.size()-1)));
      }
      tE.rotate(-PI);
      tE.setMag(0.01);
      L.add(PVector.add(L.get(L.size()-1), tE));
    }
  }

  void calcEkvi(ArrayList<Line> Lp) {
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
      tE.setMag(0.01);
      L.add(PVector.add(L.get(L.size()-1), tE));
    }
    L.add(c);
    for (int i = 0; i < ekviDist; i++) {
      tE = new PVector();
      for (int j = 0; j < Lp.size(); j++) {
        tE.add(Lp.get(j).getE(L.get(L.size()-1)));
      }
      tE.rotate(-HALF_PI);
      tE.setMag(0.01);
      L.add(PVector.add(L.get(L.size()-1), tE));
    }
  }

  void calcNext(ArrayList<Line> Lp) { // in progress
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
        t[i] = PVector.add(p, (new PVector(0.01, 0)).rotate(i*TWO_PI/10));
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

  void update(ArrayList<Line> Lp) {
    calcWE(Lp);
  }

  void draw() {
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

  void update(ArrayList<Line> L) {
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
      float dV = 1.0/4/PI/e0 * L.get(Li).Qp * dl / r.mag(); // "Diferencijal" napona
      PVector rn = new PVector(r.x, r.y);
      rn.normalize(); // Ort vektor vektora r
      PVector dE = PVector.mult(rn, 1.0/4/PI/e0 * L.get(Li).Qp * dl / sq(r.mag())); // "Diferencijal" vektora elektricnog polja
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

  void draw(ArrayList<Line> L) {
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