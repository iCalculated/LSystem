void setup() {
    smooth();
    stroke(255);
    fill(96);

    Population population = new Population("systems.txt");
    for(int generation = 1; generation <= 500; generation++) {
        population.prepare();
        population.drawTop(10, "nolimits/" + generation);
        population.writeToFile("nolimits/files/systems" + generation + ".txt");
        println("Generation " + generation);
        population.stats();
        population.reproduce();
        population.mutate();
    }
    population.prepare();
    population.drawTop(50, "nolimits/final");

    // This code constructs a single system for testing purposes
    //GeneticLSystem plant = new GeneticLSystem();
    //plant.generateRule();
    //plant.generateState();
    //plant.draw();
    //print(plant);
    exit();
}

void settings() {
    size(3000, 3000);
}