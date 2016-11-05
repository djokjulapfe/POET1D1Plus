void sv() {
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

void ld() {
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
          S.addNewSegment(new PVector(float(pieces[0]), float(pieces[1])));
        }
      }
    } while (line != null);
  }
}