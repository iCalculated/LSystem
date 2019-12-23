import java.util.Comparator;   

// used to compare plants for sorting
// this was giving me issues because I did not realize that an earlier fitness function could return NaN
// which resulted in complaints about failing to uphold search contract
static class PlantComparator implements Comparator<GeneticLSystem> {
    @Override
    public int compare(GeneticLSystem c1, GeneticLSystem c2) {
        //return fitness > s.fitness ? 1 : fitness < s.fitness ? -1 : 0;
        if(c1.fitness > c2.fitness) { return 1; }
        else if(c1.fitness < c2.fitness) { return -1; }
        else { return 0; }
    }
}