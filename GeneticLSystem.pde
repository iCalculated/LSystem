class GeneticLSystem implements Comparable<GeneticLSystem> {
    static final int   LENGTH = 10,   
                       ITERATIONS = 3;
    static final float ANGLE = 0.436332;

    String axiom, rule, state;
    String[] chromosomes;
    
    Status status;
    float fitness;

    ArrayList<Node> nodes = new ArrayList<Node>();


    GeneticLSystem() {
        axiom = "F";
        status = Status.NEED_RULE;
        chromosomes = new String[2 * int(random(1,4)) + 1];
        for(int i = 0; i < chromosomes.length; i++) {
            chromosomes[i] = randomGene();
        }
    }

    GeneticLSystem(String data) {
        axiom = "F";
        String[] pieces = split(data, " ");
        rule = pieces[1];
        chromosomes = splitRule(rule);
        fitness = float(pieces[0]);
        status = Status.NEED_STATE;
    }

    GeneticLSystem(GeneticLSystem a, GeneticLSystem b) {
        axiom = "F";
        status = Status.NEED_RULE;
        chromosomes = a.chromosomes;
        int shorter = min(chromosomes.length, b.chromosomes.length);
        int quantity = int(random(1,4));
        int index;
        for(int i = 0; i < quantity; i++) {
            index = int(random(0,shorter));
            chromosomes[index] = b.chromosomes[index];
        }
    }

    String[] splitRule(String rule) {
        ArrayList<String> chromosomes = new ArrayList<String>();
        int right = rule.indexOf(']');
        int left = rule.indexOf('[');
        while(rule.indexOf(']') > 0 ) {
            //println(rule);
            left = rule.indexOf('[');
            chromosomes.add(rule.substring(0,left));
            rule = rule.substring(left+1); 
            //println(rule);
            right = rule.indexOf(']');
            chromosomes.add(rule.substring(0,right));
            rule = rule.substring(right+1); 
        }
        chromosomes.add(rule);
        //println("rule: " + rule); 
        //for(String gene : chromosomes) { println("\t" + gene); }
        return chromosomes.toArray(new String[chromosomes.size()]);
    }

    void mutate() {
        int target_chromosome = int(random(chromosomes.length));
        String chromosome = chromosomes[target_chromosome];
        char[] validCharacters = { 'F', '-', '+'};
        if(chromosome.length() == 0) {
            chromosomes[target_chromosome] += validCharacters[int(random(validCharacters.length))];
        }
        else {
            float rand = random(1);
            int target_gene = int(random(chromosome.length()));
            if (rand < 0.4) {
                char gene = chromosome.charAt(target_gene);
                char new_gene = validCharacters[int(random(validCharacters.length))];
                while(new_gene == gene) {
                    new_gene = validCharacters[int(random(validCharacters.length))];
                }
                chromosomes[target_chromosome] = chromosome.substring(0,target_gene) + new_gene + chromosome.substring(target_gene + 1);
            }
            else if (rand < 0.7) {
                chromosomes[target_chromosome] = chromosome.substring(0,target_gene) + chromosome.substring(target_gene + 1);
            }
            else {
                chromosomes[target_chromosome] = chromosome.substring(0,target_gene) + validCharacters[int(random(validCharacters.length))] + chromosome.substring(target_gene);
            }
        }
        //println("Original: " + chromosome + ", Radiated: " + chromosomes[target_chromosome]);

        status = Status.NEED_RULE;
        fitness = 0;
    }

    void calculateFitness() {
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
            if(n.x > 300 || n.x < -300 || n.y < -100 || n.y > 900) { fitness = -1; return; }
        }
        height = height / nodes.size();
        float balance = 1000*(right_skew > left_skew ? left_skew / right_skew : right_skew / left_skew);
        float spread = max_left + max_right;
        fitness = (100 * height + 90*balance + 40*spread)/(100 + 90 + 40);
        status = Status.DONE;
    }

    float getFitness() {
        if(status == Status.NEED_EVAL) { calculateFitness(); }
        if(status != Status.DONE) { throw new Error("Requested fitness from status " + status); }
        return fitness;
    }

    String randomGene() {
        int length = int(random(0,6));
        char[] validCharacters = { 'F', '-', '+'};
        String gene = "";
        while(gene.length() < length) {
            gene += validCharacters[(int)random(validCharacters.length)];
        }
        return gene;
    }

    void generateRule() {
        rule = "";
        for(int i = 0; i < chromosomes.length-1; i++) {
            rule += chromosomes[i];
            rule += i % 2 == 0 ? "[" : "]";
        }
        rule+=chromosomes[chromosomes.length-1];
        status = Status.NEED_STATE;
    }

    void generateState() {
        if(status != Status.NEED_STATE) { throw new Error("State requested with state " + status); }
        state = axiom;
        for(int iteration = 0; iteration < ITERATIONS; iteration++) {
            String temp = "";
            for(int i = 0; i < state.length(); i++) {
                Character current = state.charAt(i);
                if(current == 'F') {
                    temp += rule;
                }
                else {
                    temp += current;
                }
            }
            state = temp;
        }
        status = Status.NEED_EVAL;
    }

    //TODO: count branches
    void draw() {
        int stack = 0;
        resetMatrix();
        background(0);
        translate(width/2, height-100);
        if(status != Status.NEED_EVAL && status != Status.DONE) { throw new Error("Requesting draw with status " + status); }

        PMatrix2D current = new PMatrix2D();
        for(int index = 0; index < state.length(); index++) {
            Character c = state.charAt(index);
            switch (c) {
                case 'G':
                case 'F':
                    line(0,0,0,-LENGTH);
                    translate(0,-LENGTH);
                    getMatrix(current);
                    nodes.add(new Node(500-current.m02, 900-current.m12));
                    break;
                case '-':
                    rotate(-ANGLE);
                    break;
                case '+':
                    rotate(ANGLE);
                    break;
                case '[':
                    pushMatrix();
                    //stack++;
                    //println("stack error: " + stack);
                    //println(rule);
                    //for(String g : chromosomes) {
                    //    println("\t" + g);
                    //}
                    //if(stack > 30) { 
                    //    delay(160000);
                    //    print(state);
                    //}
                    break;
                case ']':
                    popMatrix();
                    //stack -= 1;
                    break;
                default:
                    //println("Illegal character");
            }
        }
        if (status == Status.NEED_EVAL) { calculateFitness(); }
    }

    String toString() {
        return rule + ": " + fitness;
    }

    @Override
    int compareTo(GeneticLSystem s) {
        return fitness - s.fitness > 0 ? 1 : s.fitness - fitness > 0 ? -1 : 0;
    }
}

enum Status
{
    DONE, NEED_EVAL, NEED_STATE, NEED_RULE;
}