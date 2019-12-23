# LSystem
A first foray into processing, constructing fractalesque figures from L-systems.

L-systems, short for Lindemayer systems, were originally created by Aristid Lindenmayer, a Hungarian biologist, to formlize the development of simple organisms such as algae. 

The principle of an L-system is that there is an initial state, known as an axiom, and then rules to iteratively change the current state. With each iteration the rules of the system are applied to every character.

For example, given a system with axiom 'a' and the following rules 

- a &rarr; ab
- b &rarr; a

then the first four iterations would be

0. a
1. ab
2. aba
3. abaab
4. abaababa.

(this is actually a model of classic Fibonacci growth, if each 'a' is an adult organism and each 'b' is a developing one and death is entirely ignored the total quantity of organisms is [1] 1 2 3 5 8 ... and so on)

More formally, an L system is defined by a triplet G=<V, w, P> such that V is the alphabet composed of all valid characters, w is the axiom, and P is the set of principles for iteration called productions. 

(On a side note, I just learned that GitHub Markdown does not have LaTeX support and find that disappointing.)

Usually the alphabet can be inferred with an assumption that any character without an explicit rule is subject to the identity production, e.g. a&rarr;a.  

After state generation the fractal drawing fun begins: The state string becomes a series of instructions, for this project F &rarr; move forward, + &rarr; rotate [angle] clockwise, - &rarr; rotate [angle] counterclockwise, [ &rarr; push matrix and ] &rarr; pop matrix. Push and pop matrix are used respectively to add transformations and remove transformations from the matrix stack. 
In addition, various variable character (usually X and Y in my code) are used to create more interesting state strings but the turtle ignores them when drawing.

The plants and several other patterns were borrowed from the [Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf)

# Genetic Algorithm

The second phase of this project was generating compelling-looking plants using a genetic algorithm. Plants are defined by a series of chromosomes which can then be mutated and exchanged with other plants through reproduction. If for whatever reason you want to use this repository yourself I greatly recommend using a fitness function from a previous commit because the most recent one removed limitations that forced the plants to look decent.

The genetic algorithm starts by generating a pool of plants, usually 10 000, and then evaluating them, which provides an attribute called "fitness." Considering that the fitness function here is quite fuzzy in the sense that I'm trying to determine how much a combination of random lines looks like a plant some creativity was needed. Currently the implemented fitness function follows suggestions from [this](http://www.cs.stir.ac.uk/~goc/papers/GAsandL-systems.pdf) paper. The five attributes are as follows, I'll use the paper's titles since they are more fun than my own:

- **Positive phototropism:** Literally how tall the plant is, with the idea that taller plants receive more sunlight.
- **Bilateral symmetry:** "Calculating torque on the stem of the plant" would not be far from the truth, but it's also overly-dramatized. Sums how far nodes are from the stem on each side and then compares the values, if they are fairly close it's a good, well-balanced plant.
- **Light gathering ability:** The horizontal distance between the rightmost and leftmost points.
- **Structural stability:** Determines what fraction of nodes have too many branches coming from them.
- **Proportion of branching points:** The portion of nodes with multiple branches coming from them.

Once each member of the population has had its fitness calculated the bottom *x*% can be eliminated. I personally used 60% in my final extreme test (one of the many numbers that needs to be changed, 20% had good results). The population is then replenished by reproducing more fit plants, I just cloned one and then exchanged about half of its chromosomes in a *very* crude approximation of sexual reproduction. Throw in some random mutations every so often and your ecosystem is complete!
