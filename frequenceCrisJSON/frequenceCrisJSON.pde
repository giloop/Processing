import java.util.Arrays;

// Analyse de la fréquence des cris JSON
String repImg   = "qdb2015"; // "jae2015"; // "FDMTinte2015"; // 
String baseUrl  = "http://gueulomaton.org/";

// Variables globales
JSONArray  jsaListeCris;
String[] listeDate;
float[] dateSecond;
int nbCris;
float xScale, yScale;

void setup() {
  size(1000,400);
  jsaListeCris = loadJSONArray(baseUrl+"listerCrisJSON.php?n="+repImg);
  nbCris = jsaListeCris.size();
  println(nbCris+" cris dans "+repImg);
  listeDate = new String[nbCris];
  dateSecond = new float[nbCris];
  
  for (int i=0; i<nbCris; i++) {
    String[] nomParts = split(jsaListeCris.getJSONObject(i).getString("nom"), '/');
    listeDate[i] = nomParts[nomParts.length-1].substring(10);
    dateSecond[i] = Float.parseFloat(listeDate[i].substring(3,5))*86400 + 
    Float.parseFloat(listeDate[i].substring(6,8))*3600 + 
    Float.parseFloat(listeDate[i].substring(9,11))*60 + 
    Float.parseFloat(listeDate[i].substring(12,14)) + 
    Float.parseFloat(listeDate[i].substring(15,18))/1000 ;
 }
  Arrays.sort(listeDate);
  Arrays.sort(dateSecond);
  
  for (int i=0; i<nbCris; i++) {
     println(listeDate[i]+" : "+dateSecond[i]+"s");  
  }
  
  xScale = width / (nbCris+1);
  yScale = height / (dateSecond[nbCris-1]-dateSecond[0]);
}

void draw() {
  background(0);
  // Draw white points
  stroke(255);
  for (int i=0; i<nbCris; i++) {
     point(xScale*i, yScale*(dateSecond[i]-dateSecond[0]));
  }
  
  stroke(255,0,0);
  for (int i=0; i<nbCris-1; i++) {
     point(xScale*i, yScale*(dateSecond[i+1]-dateSecond[i]));  
  }

}