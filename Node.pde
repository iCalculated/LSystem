class Node {
    public float x, y;
    Node(float x, float y) {
      this.x = x;
      this.y = y;
    }
      
    public String toString(){
    return "(" + nf(x,0,1) + "," + nf(y,0,1) + ")";
  }
}