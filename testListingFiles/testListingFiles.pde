String repImg = "/home/gilou/Images/FeteRGC2015/";

void setup() {
  File dir; 
  File [] files;

  dir= new File(repImg);
  files= dir.listFiles();
  println("Nombre de fichiers : "+files.length);
  for (int i = 0; i <= files.length - 1; i++)
  {
    String path = files[i].getAbsolutePath();
    if (path.endsWith("_thumb.jpg"))
    {
      println(path+" -> "+path.replaceFirst("_thumb.jpg", ".jpg"));
    }
  }  
}
 
void draw() { 
  
}