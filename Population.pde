import java.util.Arrays;   
import java.util.Set;   
import java.util.HashSet;   

class Population {
    final static int   POPULATION_SIZE  = 10000;
    final static float GENERATION_DECAY = 0.4,
                       FIRST_PARENT_THRESHOLD = 0.9,
                       SECOND_PARENT_THRESHOLD = 0.8;

    GeneticLSystem[] plants;

    Population(String file) {
        println("System initialized");
        plants = new GeneticLSystem[POPULATION_SIZE];
        println("Acquiring plants from " + file);
        systemsFromFile(file);
        println(file + " loaded");
    }

    void systemsFromFile(String file) {
        String[] lines = loadStrings(file);
        Set<String> uniq = new HashSet<String>();

        for(int i = 0; i < lines.length; i++){
            uniq.add(lines[i]);
        }

        int i = 0;
        for(String data : uniq){
            plants[i] = new GeneticLSystem(data);
            i++;
        }
        println("Loaded " + i  + " systems from " + file);
    }

    void writeToFile(String file) {
        PrintWriter cache = createWriter(file);
        for(GeneticLSystem plant : plants) {
            cache.println(plant.fitness + " " + plant.rule);
        }
        cache.flush();
        cache.close();
    }

    void randomFill() {
        for(int i=0; i < POPULATION_SIZE; i++) {
            if(plants[i] == null) {
                plants[i] = new GeneticLSystem();
            }
        }
    }

    void prepare() {
        randomFill();
        for(GeneticLSystem plant : plants) {
            if(plant.status == Status.NEED_RULE) { plant.generateRule(); }
            if(plant.status == Status.NEED_STATE) { plant.generateState(); }
            if(plant.status == Status.NEED_EVAL) { plant.draw(); }
        }
        Arrays.sort(plants);
    }

    void mutate() {
        for(int i=0; i < POPULATION_SIZE; i++) {
            plants[i].mutate();
        }
    }

    GeneticLSystem crossover(GeneticLSystem a, GeneticLSystem b) {
        GeneticLSystem plant = new GeneticLSystem(a, b);
        plant.generateRule();
        //println("Parent: " + a + ", Parent: " + b + " -> Child: " + plant);
        return plant;
    }

    void drawTop(int num, String stem) {
        GeneticLSystem plant;
        for(int i = 1; i <= num; i++) {
            plant = plants[POPULATION_SIZE - i];
            plant.draw();
            save(stem + "/" + int(plant.fitness) + plant.rule + ".png");
        }
    }

    void reproduce() {
        assert(plants[99].fitness >= plants[98].fitness);
        for(int i = 0; i < GENERATION_DECAY * POPULATION_SIZE; i++) {
            plants[i] = crossover(plants[int(random(FIRST_PARENT_THRESHOLD*POPULATION_SIZE,POPULATION_SIZE))],
                                  plants[int(random(SECOND_PARENT_THRESHOLD*POPULATION_SIZE,POPULATION_SIZE))]);
        }
    }

    void stats() {
        float average_fitness = 0;
        float[] deciles = new float[11];
        for(int i = 0; i < POPULATION_SIZE; i++) {
            average_fitness += plants[i].fitness;
            if(i%(POPULATION_SIZE/10)==0) { deciles[i/(POPULATION_SIZE/10)] = plants[i].fitness; }
        }
        deciles[10] = plants[POPULATION_SIZE-1].fitness;

        average_fitness /= POPULATION_SIZE;

        println("--------------------------------------------------------------------------------------------------");

        println("Average fitness: " + nf(average_fitness,0,1) + "\n");
        println("Deciles: ");
        for(int i = 0; i < deciles.length; i++) {
            println((10*i) + "th percentile:" + deciles[i]);
        }
        println("\nRandom Sample:");
        int index;
        for(int i = 0; i < 10; i++) {
            index = int(random(0, POPULATION_SIZE));
            println("\t" + index + ": " + plants[index]);
        }
        println("\n\nTop Plants:");
        for(int i = 1; i <= 10; i++) {
            println("\t" + i + ": " + plants[POPULATION_SIZE-i]);
        }
        println("--------------------------------------------------------------------------------------------------");
    }
}