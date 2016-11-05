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

    HelpRs = "Ovo je vizuelizator za česte pojame elektrostatike.\n" +
      "Za crtanje naelektrisanih linija koristite levo dugme miša.\n" +
      "Držanjem CTRL možete uključiti snap to grid opciju, a sa SHIFT možete crtati prave linije.\nPritisnite ENTER da bi ste završili liniju koju ste crtali korišćenjem CTRL i SHIFT" +
      "Možete uključiti mod za crtanje krugova pritiskom na C (Koristite kružić na mišu za menjanje prečnika).\n" +
      "Pomoću dugmića sa desne strane, možete prikazati mapu potencijala,\nvektorsko polje vektora električnog polja, ovu stranicu i još puno toga, slova u zagradama su prečice za tastaturu.\n" +
      "U donjem desnom uglu, postoje podaci o potencijalu,\nelektričnom polju i podužnom naelektrisanju linije najbliže kursoru.\n" + 
      "Pritiskom na dugme Calculate, vrši se vizuelni račun (skraćenica SPACE)" +
      "Korišćenjem + i -, možete povećati ili smanjiti naelektrisanje na liniji najbližoj kursoru\n(podebljana linija), podužno naelektrisanje je prikazano u donjem desnom uglu.\n" +
      "Možete koristiti Load i Save da sačuvate ili otvorite tekstualnu datoteku koja sadrži podatke o nacrtanim linijama.\nCuvanjem datoteke sa zavrsetkom .png cuva sliku" +
      "Show Map prikazuje mapu potencijala.\n" +
      "Show Field prikazuje vektorsko polje vektora elektricnog polja, a Field mode prikazuje normalizovane vektore\n" +
      "Ekvi menja mod za isprekidanu liniju: Ekvipotencijala ili jedna linija električnog polja\n";
  }


  void update() {
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

  void draw() {
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
      textSize(11.5);
    }
  }

  void addNewLine() {
    L.add(new Line());
  }

  void addNewSegment(PVector v) {
    L.get(L.size()-1).addNewSegment(v);
  }

  void reset() {

    L = new ArrayList<Line>();
    addNewLine();
    M = new PVector(2, 2);
    EV = new PVector();
    m.update(L);
    e.update(L);
  }
}