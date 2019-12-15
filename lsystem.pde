class LSystem {
    String axiom;
    String state;

    HashMap<Character, String> rules = new HashMap<Character, String>();

    LSystem(String axiom) {
        this.axiom = axiom;
    }

    void addRule(Character id, String rule) {
        rules.put(id, rule);
    }

    void generateState(int iterations) {
        state = axiom;
        for(int i = 1; i <= iterations; i++) {
            String temp = "";
            for(int charIndex = 0; charIndex < state.length(); charIndex++) {
                Character currentChar = state.charAt(charIndex);
                if(rules.containsKey(currentChar)) {
                    temp += rules.get(currentChar);
                }
                else {
                    temp += currentChar;
                }
            }
            state = temp;
        }
    }

    void draw(float length, float angleInDegrees) {
        float angle = radians(angleInDegrees);
        for (int i = 0; i < state.length(); i++) {
            Character currentChar = state.charAt(i);
            switch (currentChar) {
                case 'G':
                case 'F':
                    line(0,0,0,-length);
                    translate(0,-length);
                    break;
                case '-':
                    rotate(-angle);
                    break;
                case '+':
                    rotate(angle);
                    break;
                case '[':
                    pushMatrix();
                    break;
                case ']':
                    popMatrix();
                    break;
                default:
                    //println("Illegal character");
            }
        }
    }
}

PFont font; 

void tree()
{  
  LSystem lSystem = new LSystem("X");
  lSystem.addRule('X',"F[+X][-X]FX");
  lSystem.addRule('F',"FF");
  
  resetMatrix();
  background(0);  
   
  lSystem.generateState(7); 
  
  translate(width/2,height-150);
  lSystem.draw(2,25.7);
  
  save("tree.png");
}

void hilbert() {
    LSystem hilbert = new LSystem("X");
    hilbert.addRule('X',"+YF-XFX-FY+");
    hilbert.addRule('Y',"-XF+YFY+FX-");

    resetMatrix();
    background(0);

    hilbert.generateState(7);

    translate(0,height);
    hilbert.draw(10, 90);

    save("hilbert.png");
}

void sierpinski() {
    LSystem sierpinski = new LSystem("F");
    sierpinski.addRule('F',"G-F-G");
    sierpinski.addRule('G',"F+G+F");

    resetMatrix();
    background(0);

    sierpinski.generateState(10);
    translate(width/2-128, height/2+256);
    sierpinski.draw(2,60);

    save("sierpinski.png");
}

void quadraticKoch() {
    LSystem quadraticKoch = new LSystem("F-F-F-F");
    quadraticKoch.addRule('F',"F-F+F+FF-F-F+F");

    resetMatrix();
    background(0);

    quadraticKoch.generateState(4);
    translate(width-250, height-250);
    quadraticKoch.draw(2,90);

    save("quadraticKoch.png");

}

void dragon() {
    LSystem dragon = new LSystem("FX");
    dragon.addRule('X',"X+YF+");
    dragon.addRule('Y',"-FX-Y");

    resetMatrix();
    background(0);

    dragon.generateState(13);
    translate(width/2, height/2);
    dragon.draw(5, 90);

    save("dragon.png");
}

void plant() {
    LSystem plant = new LSystem("X");
    plant.addRule('F', "FF");
    plant.addRule('X', "F+[[X]-X]-F[-FX]+X");

    resetMatrix();
    background(0);

    plant.generateState(8);
    translate(width/2, height-100);
    plant.draw(2,25);

    save("plant.png");
}

void plant2() {
    LSystem plant2 = new LSystem("F");
    plant2.addRule('F', "FF-[-F+F+F]+[+F-F-F]");

    resetMatrix();
    background(0);

    plant2.generateState(8);
    translate(width/2, height-100);
    plant2.draw(2,22.5);

    save("plant2.png");
}

void setup() {
    size(1024, 1600);
    smooth();
    stroke(255);
    fill(96);
    font = createFont("Hack",16,true);
    textFont(font,20);

    plant2();
}