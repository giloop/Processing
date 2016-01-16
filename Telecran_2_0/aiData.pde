class Data3D {
  int t;
  int x;
  int y;
  int c;
  // Constructor
  Data3D(int _t, int _x, int _y, int _c) {
    t = _t;
    x = _x;
    y = _y;
    c = _c;
  }
  
  public boolean equals(Data3D obj) 
  {  
    return (this.x==obj.x && this.y==obj.y && this.c==obj.c);
  }
  
}