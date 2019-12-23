void setup() {
    smooth();
    stroke(255);
    fill(96);

    Population population = new Population("systems.txt");
    for(int generation = 1; generation <= 50; generation++) {
        population.prepare();
        population.drawTop(10, "a/" + generation);
        population.writeToFile("a/files/systems" + generation + ".txt");
        println("Generation " + generation);
        population.stats();
        population.reproduce();
        population.mutate();
    }
    population.prepare();
    population.drawTop(50, "a/final");

    //GeneticLSystem plant = new GeneticLSystem();
    //plant.generateRule();
    //plant.generateState();
    //plant.draw();
    //print(plant);
    //delay(10000);
    exit();
}

void settings() {
    size(1000, 1000);
}