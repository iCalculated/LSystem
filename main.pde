import java.util.Collections;   

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

    plant.generateState(3);
    translate(width/2, height-100);
    plant.draw(5,25);

    println(plant.fitness);

    save("plant.png");
}

void plant2() {
    LSystem plant2 = new LSystem("F");
    plant2.addRule('F', "FF-[-F+F+F]+[+F-F-F]");
    background(0);


    resetMatrix();
    plant2.generateState(5);
    translate(width/2, height-100);
    plant2.draw(5,22.5);

    print(plant2.fitness);

    save("plant2.png");
}

String insert(String s, String insert, int index) {
    return s.substring(0,index) + insert + s.substring(index);
}

String randomRule() {
    int length = int(random(10,31));
    char[] validCharacters = { 'F', '-', '+'};//, 'A', 'B'};
    String rule = "";
    while(rule.length() < length) {
        rule += validCharacters[(int)random(validCharacters.length)];
    }
    int[] breaks = {int(random(length)), int(random(length)),
                    int(random(length)), int(random(length))};
    breaks = sort(breaks);
    rule = insert(rule, "T[T", breaks[0]);
    rule = insert(rule, "T]T", breaks[1]+3);
    rule = insert(rule, "T[T", breaks[2]+6);
    rule = insert(rule, "T]T", breaks[3]+9);
    return rule;
}
LSystem randomSystem() {
    LSystem system = new LSystem("F");
    system.addRule('F',randomRule());
    return system;

}

ArrayList<LSystem> systemsFromFile(String file) {
    ArrayList<LSystem> systems = new ArrayList<LSystem>();
    String[] lines = loadStrings(file);
    LSystem system;
    for(String line : lines) {
        system = new LSystem("F");
        system.addRule('F', split(line, " ")[1]);
        system.fitness = float(split(line, " ")[0]);
        systems.add(system);
    }
    return systems;
}
void writeToFile(ArrayList<LSystem> systems) {
    PrintWriter cache = createWriter("systems.txt");
    for(LSystem system : systems) 
        cache.println(system.fitness + " " + system.rules.get('F'));
    cache.flush();
    cache.close();
}

LSystem[] crossoverGenerate(LSystem a, LSystem b) {
    //println("Parent " + a);
    //println("Parent " + b);
    String[] a_genes = a.genes('F');
    String[] b_genes = b.genes('F');
    int a_swap = int(random(0,a_genes.length));
    int b_swap = int(random(0,b_genes.length));
    String temp = a_genes[a_swap];
    a_genes[a_swap] = b_genes[b_swap];
    b_genes[b_swap] = temp;
    a.ruleFromGenes('F', a_genes);
    b.ruleFromGenes('F', b_genes);
    a.fitness=0;
    b.fitness=0;
    //println("Child " + a);
    //println("Child " + b);
    return new LSystem[] {a,b};
}
void setup() {
    smooth();
    stroke(255);
    fill(96);
    font = createFont("Hack",16,true);
    textFont(font,20);

    ArrayList<LSystem> systems = new ArrayList<LSystem>();
    systems = systemsFromFile("systems.txt");

    while(systems.size() < 100) {
        systems.add(randomSystem());
    }
    LSystem[] newSystems = new LSystem[2];

    for(int generations = 0; generations < 10; generations++) {
        for(int i = systems.size(); i < 100; i += 2) {
            newSystems = crossoverGenerate(systems.get(int(random(0,70))), systems.get(int(random(0,70))));
            systems.add(newSystems[0]);
            systems.add(newSystems[1]);
        }
        
        for(LSystem system : systems) {
            if(system.fitness == 0) {
                system.generateState(5);
                resetMatrix();
                background(0);
                translate(width/2, height-100);
                system.draw(2, 25);
                println("Generated " + system.rules.get('F') + ": " + system.fitness);
                save("gen8/" + nf(int(system.fitness)) + system.rules.get('F') + ".png");
            }
        }
        Collections.sort(systems);
        systems.subList(70,100).clear();
    }
    writeToFile(systems); 
    exit();
}

void settings() {
    size(1000, 1000);
}