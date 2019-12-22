class LSystem implements Comparable<LSystem> {
    String axiom;
    String state;
    float fitness = 0;
    ArrayList<Node> nodes = new ArrayList<Node>();
    nodes.add(new Node(0,0));

    HashMap<Character, String> rules = new HashMap<Character, String>();

    LSystem(String axiom) {
        this.axiom = axiom;
    }

    float calculateFitness() {
        fitness = 0;
        float height = 0;
        float left_skew = 0;
        float right_skew = 0;
        float max_right = 0;
        float max_left = 0;
        for(Node n : nodes) {
            height += n.y;
            if(n.x > 500) {
                left_skew += (n.x - 500); 
                if (n.x > max_left) max_left = n.x - 500;
            }
            else if(n.x < 500) {
                right_skew += (500 - n.x);
                if (n.x < max_right) max_right = 500-n.x;
            }
        }
        height = height / nodes.size();
        float balance = 1000*(right_skew > left_skew ? left_skew / right_skew : right_skew / left_skew);
        float spread = max_left + max_right;
        fitness = height * (90*balance + 40*spread)/(90 + 90);
        return fitness;
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

    String[] genes(char id) {
        return(splitTokens(rules.get(id)," []"));
    }

    void crossover(LSystem other, char id) {
        String[] other_genes = other.genes('F');
        String[] own_genes = genes('F');
        int swap = int(random(0,5));
        String temp = other_genes[swap];
        other_genes[swap] = own_genes[swap];
        own_genes[swap] = temp;
    }

    @Override
    int compareTo(LSystem l) {
        return l.fitness > this.fitness ? 1 : l.fitness < this.fitness ? -1 : 0;
    }

    void ruleFromGenes(char id, String[] g) {
        String rule = g[0] + "[" + g[1] + "]" + g[2] + "[" + g[3] + "]" + g[4];
        rules.replace(id, rule);
    }

    void draw(float length, float angleInDegrees) {
        PMatrix2D current = new PMatrix2D();
        float angle = radians(angleInDegrees);
        boolean tooLarge = false;
        Node node;
        for (int i = 0; i < state.length(); i++) {
            Character currentChar = state.charAt(i);
            switch (currentChar) {
                case 'G':
                case 'F':
                    line(0,0,0,-length);
                    translate(0,-length);
                    getMatrix(current);
                    node = new Node(500-current.m02, 900-current.m12);
                    //if(node.x > 400 || node.x < -400 || node.y > 800 || node.y < -100) { tooLarge = true; }
                    //else{
                           nodes.add(node);
                    //}
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
            if(tooLarge) { break; }
        }
        calculateFitness();
    }

    public String toString() {
        return rules.get('F') + ": " + fitness; 
    }
}

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