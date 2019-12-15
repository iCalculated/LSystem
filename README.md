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

(this is actually a model of the classic fibonacci growth, if each 'a' is an adult organism and each 'b' is a developing one and death is entirely ignored the total quantity of organisms is [1] 1 2 3 5 8 ... and so on)

More formally, an L system is defined by a triplet G=<V, w, P> such that V is the alphabet composed of all valid characters, w is the axiom, and P is the set of principles for iteration called productions. 

(On a side note, I just learned that GitHub Markdown does not have LaTeX support and find that disappointing.)

Usually the alphabet can be inferred with an assumption that any character without an explicit rule is subject to the identity production, e.g. a&rarr;a.  

After state generation the fractal drawing fun begins: The state string becomes a series of instructions, for this project F &rarr; move forward, + &rarr; rotate [angle] clockwise, - &rarr; rotate [angle] counterclockwise, [ &rarr; push matrix and ] &rarr; pop matrix. Push and pop matrix are used respectively to add transformations and remove transformations from the matrix stack. 
In addition, various variable character (usually X and Y in my code) are used to create more interesting state strings but the turtle ignores them when drawing.

The plants and several other patterns were borrowed from the [Algorithmic Beauty of Plants](http://algorithmicbotany.org/papers/abop/abop.pdf)
