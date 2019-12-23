import java.util.Arrays;   
import java.util.HashMap;   
import java.util.Map.Entry;   
import java.util.Set;   
import java.util.HashSet;   
// woo, data structures

class Population {
    // Hyperparams
    final static int   POPULATION_SIZE  = 10000;       // The size of the population
    final static float GENERATION_DECAY = 0.6,         // The portion of the population that is culled
                       MUTATION_CHANCE = 0.08,         // Chance a given plant mutates
                       FIRST_PARENT_THRESHOLD = 0.6,   // Parent plants are selected from the top portion 
                       SECOND_PARENT_THRESHOLD = 0.6;  

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
            // as noted, this storage loses some information about plants such as generation
            cache.println(plant.fitness + " " + plant.rule + " " + plant.species);
        }
        cache.flush();
        cache.close();
    }

    // fill in a population with random plants
    void randomFill() {
        for(int i=0; i < POPULATION_SIZE; i++) {
            if(plants[i] == null) {
                plants[i] = new GeneticLSystem();
            }
        }
    }

    // checks enum Status to see what actions are recquired for each plant
    void prepare() {
        randomFill();
        for(GeneticLSystem plant : plants) {
            if(plant.status == Status.NEED_RULE) { plant.generateRule(); }
            if(plant.status == Status.NEED_STATE) { plant.generateState(); }
            if(plant.status == Status.NEED_EVAL) { plant.draw(); }
        }
        Arrays.sort(plants, new PlantComparator());
    }

    // chooses plants to radiate 
    void mutate() {
        for(int i=0; i < POPULATION_SIZE; i++) {
            if(random(1) < MUTATION_CHANCE) { plants[i].mutate(); }
        }
    }

    // crosses two parent plants, mechanics are in GeneticLSystem
    GeneticLSystem crossover(GeneticLSystem a, GeneticLSystem b) {
        GeneticLSystem plant = new GeneticLSystem(a, b);
        plant.generateRule();
        return plant;
    }

    // draws the top plants in a population for my amusement
    void drawTop(int num, String stem) {
        GeneticLSystem plant;
        for(int i = 1; i <= num; i++) {
            plant = plants[POPULATION_SIZE - i];
            plant.draw();
            save(stem + "/" + int(plant.fitness) + plant.rule + ".png");
        }
    }

    // fills in the population by choosing parents after the regularly scheduled mass-exinction event.
    void reproduce() {
        for(int i = 0; i < GENERATION_DECAY * POPULATION_SIZE; i++) {
            plants[i] = crossover(plants[int(random(FIRST_PARENT_THRESHOLD*POPULATION_SIZE,POPULATION_SIZE))],
                                  plants[int(random(SECOND_PARENT_THRESHOLD*POPULATION_SIZE,POPULATION_SIZE))]);
        }
    }

    // my pretty-printedish stats, favorite part of the project
    void stats() {
        float average_fitness = 0;
        float[] deciles = new float[11];
        HashMap<String, Integer> uniq_species = new HashMap<String, Integer>();
        String name;
        for(int i = 0; i < POPULATION_SIZE; i++) {
            average_fitness += plants[i].fitness;
            if(i%(POPULATION_SIZE/10)==0) { deciles[i/(POPULATION_SIZE/10)] = plants[i].fitness; }
            name = plants[i].species;
            uniq_species.put(name, uniq_species.getOrDefault(name, 0)+1);
        }
        deciles[10] = plants[POPULATION_SIZE-1].fitness;

        average_fitness /= POPULATION_SIZE;

        println("--------------------------------------------------------------------------------------------------");
        println("Average fitness: " + nf(average_fitness,0,1) + "\n");
        println("Deciles: ");
        for(int i = 0; i < deciles.length; i++) {
            println((10*i) + "th percentile: " + deciles[i]);
        }
        println("\nSpecies distribution: " + uniq_species.size() + " alive."); 
        for (Entry<String, Integer> entry : uniq_species.entrySet()) {  
            if (entry.getValue() >= POPULATION_SIZE / 100) {
                println("\t" + entry.getKey() + ": " + entry.getValue() + " alive");     
            }
        }
        println("\nRandom Sample:");
        int index;
        for(int i = 0; i < 10; i++) {
            index = int(random(0, POPULATION_SIZE));
            println("\t" + index + ": " + plants[index]);
        }
        println("\nTop Plants:");
        for(int i = 1; i <= 10; i++) {
            println("\t" + i + ": " + plants[POPULATION_SIZE-i]);
        }
        println("--------------------------------------------------------------------------------------------------");
    }
}