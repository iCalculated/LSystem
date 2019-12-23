class GeneticLSystem { //implements Comparable<GeneticLSystem> {
    static final int LENGTH = 3,          // length of segments drawn
                     ITERATIONS = 3,      // iterations when generating state
                     OVERLOAD_COUNT = 5,  // the amount of child-branches a node can have before being penalized
                     BRANCH_COUNT = 1,    // used to determine if a branch has multiple children
                     WEIGHT_HEIGHT = 100, // weight of height versus other factors
                     WEIGHT_BALANCE = 90, // weight of balance (relative to center)
                     WEIGHT_WIDTH = 40,   // weight of width versus other factors
                     WEIGHT_OVERLOAD = 20,// weight of "overload ratio" ([total] - [overloaded branches])/[total]
                     WEIGHT_BRANCH = 30;  // weight of "branch ratio" ([nodes with children]/[total])
    static final float ANGLE = 0.436332;  // angle by which + or - rotates

    String axiom, rule, state, species;
    int generation;
    String[] chromosomes;
    
    Status status;
    float fitness;

    StructNode root = new StructNode(new Node(0,0));
    ArrayList<StructNode> nodes;  

    // constructor from scratch, randomizes system
    GeneticLSystem() {
        axiom = "F";
        status = Status.NEED_RULE;
        chromosomes = new String[2 * int(random(1,5)) + 1];
        for(int i = 0; i < chromosomes.length; i++) {
            // the system rule for F is generated from aa series of shorter chromosomes
            chromosomes[i] = randomChromosome();
        }
        species = chromosomes.length + "-" + generateRandomChars("ABCDEFGHIJKLMNOPQRSTUVWXYZ", 4);
        generation = 1;
    }
    
    // constructor when loading systems from a file, somewhat lossy
    GeneticLSystem(String data) {
        axiom = "F";
        String[] pieces = split(data, " ");
        rule = pieces[1];
        chromosomes = splitRule(rule);
        species = pieces[2];
        fitness = float(pieces[0]);
        // prompting regeneration from bare-bones
        status = Status.NEED_STATE;
        generation = 1;
    }

    // cross-over based constructor, chromosomes taken from two systems to construct one
    GeneticLSystem(GeneticLSystem a, GeneticLSystem b) {
        axiom = "F";
        species = a.species;
        generation = max(a.generation, b.generation)+1;
        status = Status.NEED_RULE;
        chromosomes = a.chromosomes;
        int shorter = min(chromosomes.length, b.chromosomes.length);
        int quantity = int(random(1,5));
        int index;
        for(int i = 0; i < quantity; i++) {
            index = int(random(0,shorter));
            chromosomes[index] = b.chromosomes[index];
        }
    }

    // used to split a rule into chromosomes
    String[] splitRule(String rule) {
        ArrayList<String> chromosomes = new ArrayList<String>();
        int right = rule.indexOf(']');
        int left = rule.indexOf('[');
        while(rule.indexOf(']') > 0 ) {
            left = rule.indexOf('[');
            chromosomes.add(rule.substring(0,left));
            rule = rule.substring(left+1); 
            right = rule.indexOf(']');
            chromosomes.add(rule.substring(0,right));
            rule = rule.substring(right+1); 
        }
        chromosomes.add(rule);
        return chromosomes.toArray(new String[chromosomes.size()]);
    }

    // randomly chooses a chromosome, then either changes a random gene, inserts a random gene, or deletes a gene
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
            // replace
            if (rand < 0.4) {
                char gene = chromosome.charAt(target_gene);
                char new_gene = validCharacters[int(random(validCharacters.length))];
                while(new_gene == gene) {
                    new_gene = validCharacters[int(random(validCharacters.length))];
                }
                chromosomes[target_chromosome] = chromosome.substring(0,target_gene) + new_gene + chromosome.substring(target_gene + 1);
            }
            // delete
            else if (rand < 0.7) {
                chromosomes[target_chromosome] = chromosome.substring(0,target_gene) + chromosome.substring(target_gene + 1);
            }
            // insert
            else {
                chromosomes[target_chromosome] = chromosome.substring(0,target_gene) + validCharacters[int(random(validCharacters.length))] + chromosome.substring(target_gene);
            }
        }
        // updating status to prompt regeneration
        status = Status.NEED_RULE;
    }

    // calculates fitness of a plant based on various factors
    void calculateFitness() {
        // fitness function vaguely based on
        // http://www.cs.stir.ac.uk/~goc/papers/GAsandL-systems.pdf
        fitness = 0;
        float height = 0;
        float width = 0;
        float max_l = 0;
        float max_r = 0;
        float balance = 0;
        float l_skew = 0;
        float r_skew = 0;
        float branch_ratio = 0;
        float overloaded_ratio = 0;
        float x, y;
        for(StructNode node : nodes) {
            y = node.data.y;
            x = node.data.x;
            height += y;
            if(x < 0) { 
                l_skew -= x; 
                if(x < max_l) { max_l = x;}
            }
            else if (x > 0) {
                r_skew += x;
                if(x > max_r) { max_r = x;}
            }
            if(node.countBranches() > BRANCH_COUNT) { branch_ratio++; }
            if(node.countBranches() > OVERLOAD_COUNT) { overloaded_ratio ++; }
        }
        height /= 1000*nodes.size();
        width = max_r - max_l;
        width /= 1000;
        balance = l_skew == 0 ||  r_skew == 0 ? 0 : (l_skew > r_skew) ? r_skew / l_skew : l_skew / r_skew;
        branch_ratio /= nodes.size();
        overloaded_ratio = nodes.size() - overloaded_ratio;
        overloaded_ratio /= nodes.size();
        fitness = (WEIGHT_HEIGHT * height + WEIGHT_BALANCE * balance + WEIGHT_WIDTH * width + 
                   WEIGHT_OVERLOAD * overloaded_ratio + WEIGHT_BRANCH * branch_ratio)
                   /(WEIGHT_HEIGHT + WEIGHT_BALANCE + WEIGHT_WIDTH + WEIGHT_OVERLOAD + WEIGHT_BRANCH);
        fitness *= 100;
        // I felt really smart when I wrote this
        if(fitness!=fitness) { throw new Error("Fitness is NaN! lskew: " +  l_skew + ", rskew: " + r_skew + ", size: " + nodes.size());}
        status = Status.DONE; 
    }               


    // Not just a getter, also recalculates the state
    float getFitness() {
        if(status == Status.NEED_EVAL) { calculateFitness(); }
        if(status != Status.DONE) { throw new Error("Requested fitness from status " + status); }
        return fitness;
    }

    // constructs a chromosome from valid characters
    String randomChromosome() {
        int length = int(random(0,4));
        char[] validCharacters = { 'F', '-', '+'};
        String gene = "";
        while(gene.length() < length) {
            gene += validCharacters[(int)random(validCharacters.length)];
        }
        return gene;
    }

    // deterministically constructs a rule from series of chromosomes
    void generateRule() {
        rule = "";
        for(int i = 0; i < chromosomes.length-1; i++) {
            rule += chromosomes[i];
            rule += i % 2 == 0 ? "[" : "]";
        }
        rule+=chromosomes[chromosomes.length-1];
        status = Status.NEED_STATE;
    }

    // pretty much the starting point of this project
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

    // draws the sytsem, which has the added benefit of creating a data structure with its points, nodes
    void draw() {
        nodes = new ArrayList<StructNode>(); 
        nodes.add(root);
        StructNode current_branch = root;
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
                    current_branch = current_branch.addChild(new Node(1500-current.m02, 2900-current.m12));
                    nodes.add(current_branch);
                    break;
                case '-':
                    rotate(-ANGLE);
                    break;
                case '+':
                    rotate(ANGLE);
                    break;
                case '[':
                    pushMatrix();
                    break;
                case ']':
                    popMatrix();
                    if(current_branch.parent != null) current_branch = current_branch.parent;
                    break;
                default:
                    //println("Illegal character");
            }
        }
        if (status == Status.NEED_EVAL) { calculateFitness(); }
    }

    String toString() {
        return species +  "-" + generation + ": " + rule + ", " + fitness;
    }

    // Comparator has since moved into a separate class
    //@Override
    //int compareTo(GeneticLSystem s) {
    //    //return fitness > s.fitness ? 1 : fitness < s.fitness ? -1 : 0;
    //    if(this.fitness > s.fitness) { return 1; }
    //    else if(this.fitness < s.fitness) { return -1; }
    //    else { return 0; }
    //}
    String generateRandomChars(String candidateChars, int length) {
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < length; i++) {
            sb.append(candidateChars.charAt(int(random(candidateChars .length()))));
        }
        return sb.toString();
    }
}

// status was used to confirm that plants were in expected state
// DONE: all functions have been performed
// NEED_EVAL: plant needs to be drawn and have fitness calculated
// NEED_STATE: plant needs state generated, often after rule update
// NEED_RULE: plant needs rule generated, often after genetic effects
enum Status
{
    DONE,      
    NEED_EVAL,  
    NEED_STATE, 
    NEED_RULE;
}