class Node {
    public float x, y;
    public int branches;
    Node(float x, float y) {
      this.x = x;
      this.y = y;
      branches = 1;
    }
    Node(float x, float y, int branches) {
      this(x,y);
      this.branches = branches;
    }
      
    public String toString(){
    return "(" + nf(x,0,1) + "," + nf(y,0,1) + ")" + (branches > 1 ? "branches" + branches : "");
  }
}