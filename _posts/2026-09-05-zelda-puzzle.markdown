---
title:  Solving a zelda puzzle with constraint programming
date:   2026-09-05 10:00:00 +0200
categories: AI puzzle
tags: video-game puzzle contraint-programming
comments: true
layout: post
lang: en
back_page: /index.html
---

Three years ago, I wrote an article on [solving a puzzle from a Pokemon fanmade video-game]({{ site.baseurl }}/blog/pokemon-puzzle/).
In this post, I highlighted how to formalize the problem into a formal verification task expressed through propositional logic and I demonstrated how to use SAT solvers ⚙️ to solve this problem ✅.

I recently came across another logic puzzle in an official zelda game 👾 this time: [Breath Of the Wild](https://en.wikipedia.org/wiki/The_Legend_of_Zelda:_Breath_of_the_Wild).
As I was lazy enough 🥱 to avoid solving it by trials and errors, I decided to use the [Constraint Programming](https://en.wikipedia.org/wiki/Constraint_programming) paradigm this time to **automatically** find a solution.
I will describe the problem in this post and show how to rapidly come out with a solution using modern and handy tools, much more comfortably than what I did in the Pokemon puzzle.

## The puzzle

In Zelda Breath Of the Wild, the player faces many different puzzles located in shrines. Most of them are based on physics (e.g. moving objects and balancing them to unlock pathways), some are based on the Switch console's gyroscopes! and few others are based and logical thinking, what we will be looking at here 👀.

<div style="display: block; margin-left: auto; margin-right: auto; width: 100%;" markdown="1">
![Akh Va'quot shrine in Zelda Breath of the Wild.](https://static0.polygonimages.com/wordpress/wp-content/uploads/chorus/uploads/chorus_asset/file/8129801/Akh_Va_quot_shrine_0005_1.jpg?q=50&fit=crop&w=825&dpr=1.5)
<div class="custom_caption" markdown="1">
\> **Akh Va'quot** shrine in Zelda Breath of the Wild. Image from [polygon.com](https://www.polygon.com/zelda-breath-of-the-wild-guide-walkthrough/2017/3/9/14877630/akh-vaquot-shrine-puzzle-solutions/).
</div>
</div>


The puzzle we will study here is called the **Akh Va'quot** shrine. The player faces a grid 🧇 made of fans 🪭 and weathercocks. The goal, although not clearly explained, consists in putting into rotation 💨 all weathercocks. To do so, the player can rotate the fans into the Up, Down, Left or Right direction. The difficulty resides in finding suitable directions for all of the six fans, making it a relatively tedious **combinatorial** problem. 

<div style="display: block; margin-left: auto; margin-right: auto; width: 100%;" markdown="1">
<iframe width="600" height="461"
src="https://www.youtube.com/embed/C5UjeSNQp4o">
</iframe>
<div style="margin-top:8px;">
<div class="custom_caption" markdown="1">
\> The puzzle and how it can be solved (spoiler).
</div>
</div>
</div>

Considering the 4 possible directions for each of the 6 fans, there are indeed `4^6=4096` combinations of directions if one is to try all the possible choices. 
This remain a small number for modern computers 💻 and programming an exhaustive search is doable here. It is also possible to refine this number by removing useless directions for fans at the extremities of the grid.
Nonetheless Constraint Programming is a powerful tool, able to solve combinatorial problems far beyond the capabilities of naive [brute force search methods](https://en.wikipedia.org/wiki/Brute-force_search).

## Solving it with constraint programming

In the spirit of Constraint Programming, the user 🧘 is invited to state their problem with the help of a formal constraint language and the machine 🖥️ is in charge of looking for a solution.
Modeling and Solving (finding a solutions) are two different areas, each requiring its own expertise. In an ideal world, the user would be able to easily express all sort of problems and will never care about the way it is solved. In practice, things are obviously not that simple but this vision still applies here.  

We will focus on the modeling side in this post. We will use the Python package [CPMPY](cpmpy.readthedocs.io/en/latest/index.html) to model and solve the problem.
CPMPY is a great open source Constraint Programming package developed by a team of researchers 🧑‍🔬 from the university of [KU Leuven](https://www.kuleuven.be/english/kuleuven/) in Belgium. The package itself does not contain solving algorithms but rather acts as wrapper to a wide range of state of the art solvers ⚙️ such as OR-Tools, SCIP, etc... Its modeling language is expressive enough to conveniently express various real world 🌎 problems.
The package can be easily installed (in a virtual environment) from [PyPi](https://pypi.org/): `pip install cpmpy`. This will also install [ortools](https://developers.google.com/optimization/introduction/python) as the default solver.

We will formalize the problem using propositional logic: the decision variables are represented by boolean or multi-valued discrete variables and we will use logic operators (or, and, implies) to express the constraints of the problem.
We can base our model on the following sketch of this puzzle: 

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![A schematic representation of the puzzle.]({{site.baseurl}}/assets/zelda_puzzle.png)
<div class="custom_caption" markdown="1">
\> A schematic representation of the puzzle.
</div>
</div>

The first step consists in defining the variables. We will use two sets of variables:

- Fans variables ("f", in blue) are our decision variables, with values between 1 and 4. They will represent the orientation of the fans, each value associated to one direction ↗️: Up=1, Down=2, Left=3 and Right=4.

- Weathercocks variables ("w", in red) with values 0 and 1 (boolean) will represent the fact that a weathercock is rotating 🌪️ or not. These are are modeling variables instead of decision variables: the player does not directly decide their value but they will be useful for expressing the constraints of the model.

Variables are identified with an index starting from 0 and following an "Up-Down, Left-Right" order on the grid 🧇. We can start our model in CPMPY by defining them. Values 1,2,3 and 4 are not particularly explanatory for representing the fan's directions so we will define Python variables with these values to write a more interpretable code. Initially, I actually wanted to use Python's `Enum` system but it was in the end less practical than using simple variables.

On a side note, modelers tend to use abstract mathematical symbols such as `x` and `y` to write formal models but one benefit of using high level modeling and prgramming languages is in fact the possibility to to produce a model that is much easier to read.

Here is our initial code:

<div class="code_frame">zelda_puzzle.py</div>
{% highlight python linenos %}
import cpmpy as cp

UP=1
DOWN=2
LEFT=3
RIGHT=4
Dir = {1:'UP', 2:'DOWN', 3:'LEFT', 4:'RIGHT'}

m = cp.Model()
# fans variables, 1 value for each direction N,S,W,E
fan = cp.intvar(1,4, shape=(6), name="fan")
# weathercock variables, 1 if rotating, 0 otherwise
weathercock = cp.boolvar(shape=14, name="weathercock")
{% endhighlight %}

For now, variables can take any values but in our problem, a weathercock would not be rotating if no fan is oriented in their direction 🌪️.
Our goal with the constraints is to express these **impossibilities**.
We will take as example the weathercock indexed by 7: `C_7` on the figure.
This weathercock can be activated by fan `f_2` if it is oriented downward or by fan `f_4` if it is oriented leftward.

A weathercock requires at least one fan in its direction. We will express the fact that if this is not the case, the corresponding variable cannot have the value 1 ❌.
This can be logically expressed as: "if the weathercock 7 is a activated, then the fan 2 is in the Down direction or the fan 4 is in the left orientation".
We can translate it into the logic expression: `(c_7 == 1) => (f_2 == DOWN or f_4 == LEFT)`.  
A quick look at the cpmpy documentation and we can translate it in our code: `m.add(weathercock[7].implies(((fan[2]==DOWN)|(fan[4]==LEFT))))
`.

Two details here:

- `c_7 == 1` in the logic expression has been replaced by `weathercock[7]` directly. We could write `weathercock[7]==1` in the code but this is not necessary since, for boolean variables, the two expressions are equivalent.

- Propositional logic does not allow multi-valued variables such as `fan` in our situation. Indeed, multi-valued variables implicitly represents the fact that a fan cannot have two directions. It would be possible to model this problem only with boolean variables but this enrichment in the modeling language actually helps to simplify the translation of our problem.

The next step consists in writing the constraints for all of the 14 weathercocks ⌨️. This could be further automatized but this may not be necessary for a problem of this size. At the end, we obtain a list of 14 constraints:


<div class="code_frame"> zelda_puzzle.py </div>
{% highlight python linenos %}
m.add(weathercock[0].implies((fan[0]==DOWN)|(fan[1]==UP)|(fan[2]==LEFT)))
m.add(weathercock[1].implies((fan[0]==DOWN)|(fan[1]==UP)|(fan[4]==LEFT)))
m.add(weathercock[2].implies((fan[0]==RIGHT)|(fan[3]==LEFT)))
m.add(weathercock[3].implies(fan[2]==LEFT))
m.add(weathercock[4].implies(fan[4]==LEFT))
m.add(weathercock[5].implies((fan[1]==RIGHT)|(fan[5]==LEFT)))
m.add(weathercock[6].implies(((fan[0]==RIGHT)|(fan[2]==UP)|(fan[3]==LEFT))))
m.add(weathercock[7].implies(((fan[2]==DOWN)|(fan[4]==LEFT))))
m.add(weathercock[8].implies(((fan[1]==RIGHT)|(fan[2]==DOWN)|(fan[5]==LEFT))))
m.add(weathercock[9].implies(((fan[3]==DOWN)|(fan[2]==RIGHT)|(fan[4]==UP))))
m.add(weathercock[10].implies(((fan[3]==DOWN)|(fan[4]==DOWN)|(fan[5]==LEFT)|(fan[1]==RIGHT))))
m.add(weathercock[11].implies((fan[0]==RIGHT)|(fan[3]==RIGHT)|(fan[5]==UP)))
m.add(weathercock[12].implies(((fan[2]==RIGHT)|(fan[5]==UP))))
m.add(weathercock[13].implies(((fan[4]==RIGHT)|(fan[5]==UP))))
{% endhighlight %}

One last constraint, the most important one, is still missing: we want all the weathercock to be activated ✅, so value 1 for all corresponding variables. This can be expressed with a logical **and** operator, i.e. `m.add( weathercock[0] & weathercock[1] & [...] & weathercock[13] )`.
However, CPMPY provides a *global constraint* for us, making the model even more compact: `m.add(cp.all(weathercock))`.
We can then solve the problem with `m.solve()`.
Our final code is:

<div class="collapse-panel"><div>
<label for="code_2">Expand</label>
<input type="checkbox" name="" id="code_2"><span class="collapse-label"></span>
<div class="extensible-content">
<div class="code_frame"> zelda_puzzle.py</div>
{% highlight python linenos %}
import cpmpy as cp

UP=1
DOWN=2
LEFT=3
RIGHT=4
Dir = {1:'UP', 2:'DOWN', 3:'LEFT', 4:'RIGHT'}

m = cp.Model()
# fans variables, 1 value for each direction: Up,Down,Left,Right
fan = cp.intvar(1,4, shape=(6), name="fan")
# weathercock variables, 1 if rotating, 0 otherwise
weathercock = cp.boolvar(shape=14, name="weathercock")

m.add(weathercock[0].implies((fan[0]==DOWN)|(fan[1]==UP)|(fan[2]==LEFT)))
m.add(weathercock[1].implies((fan[0]==DOWN)|(fan[1]==UP)|(fan[4]==LEFT)))
m.add(weathercock[2].implies((fan[0]==RIGHT)|(fan[3]==LEFT)))
m.add(weathercock[3].implies(fan[2]==LEFT))
m.add(weathercock[4].implies(fan[4]==LEFT))
m.add(weathercock[5].implies((fan[1]==RIGHT)|(fan[5]==LEFT)))
m.add(weathercock[6].implies(((fan[0]==RIGHT)|(fan[2]==UP)|(fan[3]==LEFT))))
m.add(weathercock[7].implies(((fan[2]==DOWN)|(fan[4]==LEFT))))
m.add(weathercock[8].implies(((fan[1]==RIGHT)|(fan[2]==DOWN)|(fan[5]==LEFT))))
m.add(weathercock[9].implies(((fan[3]==DOWN)|(fan[2]==RIGHT)|(fan[4]==UP))))
m.add(weathercock[10].implies(((fan[3]==DOWN)|(fan[4]==DOWN)|(fan[5]==LEFT)|(fan[1]==RIGHT))))
m.add(weathercock[11].implies((fan[0]==RIGHT)|(fan[3]==RIGHT)|(fan[5]==UP)))
m.add(weathercock[12].implies(((fan[2]==RIGHT)|(fan[5]==UP))))
m.add(weathercock[13].implies(((fan[4]==RIGHT)|(fan[5]==UP))))

# m.add( weathercock[0] & weathercock[1] & [...] & weathercock[13] ) alternatively
m.add(cp.all(weathercock))

hassol = m.solve()
print("Status:", m.status())
if hassol:
    for ind, elt in enumerate(fan.value()):
        print('fan_' + str(ind) + '=' + Dir[elt])
else:
    print("No solution found.")
{% endhighlight %}
</div></div></div>

And the program output is:

<div class="code_frame"> Output</div>
{% highlight bash linenos %}
Status: ExitStatus.FEASIBLE (0.010329815000000001 seconds)
fan_0=RIGHT
fan_1=RIGHT
fan_2=LEFT
fan_3=DOWN
fan_4=LEFT
fan_5=UP
{% endhighlight %}

CPMPY is able to find a solution in 10 milliseconds 💡. I wonder if the brute force would be slower or faster but I did not try it. On such small problem, it remains possible that a simpler and more naive search is actually faster but our interest here was the ability of easily modeling/programming the problem 🧑‍💻.

CPMPY offers many capabilities that are covered in the documentation. Notably, it is possible to [look for all solutions](https://cpmpy.readthedocs.io/en/latest/modeling.html#finding-all-solutions) to the problem instead of returning a single one (although this would rather work on small problems).
I tested the function `n = m.solveAll()` and the output told me that there is actually only one solution to the problem!

## Discussion

Constraint Programming is one way of expressing and finding solutions for combinatorial problems. We saw in the pokemon puzzle post how to used SAT solvers instead and many other formalisms exist such as [Linear and Integer Programming](https://en.wikipedia.org/wiki/Integer_programming), [Sat Modulo Theory](https://en.wikipedia.org/wiki/Satisfiability_modulo_theories), [Pseudo Boolean](https://en.wikipedia.org/wiki/Quadratic_pseudo-Boolean_optimization), [Quadratic Programming](https://en.wikipedia.org/wiki/Quadratic_programming), [Answer Set Programming](https://en.wikipedia.org/wiki/Answer_set_programming), etc.. It is often possible to translate a problem from one formalism to another one 🔄 and solving performances may depend on the type of problem, the technology, the model, and so on. 

On the problem side, we can go further in its understanding 📚 by considering larger grids and various fans placements for instance.
A classical question is about the hardness of the problem, in other terms we are interested in its [computational complexity](https://en.wikipedia.org/wiki/Computational_complexity_theory).
An easy way to characterize it is actually to look at the scientific literature and find out if this exact problem (or a more general version) as already been studied 🎓.

This problem looks a bit like [Set Covering](https://en.wikipedia.org/wiki/Set_cover_problem), that can be spotted [here](https://en.wikipedia.org/wiki/Karp%27s_21_NP-complete_problems) or [there](https://en.wikipedia.org/wiki/List_of_NP-complete_problems).
We would group the weathercocks into sets that are "covered" by a single fan in a given direction but there is still an additional disjunctive constraint here to avoid selecting two directions from the same fan.
I would bet that this problem is [NP-complete](https://en.wikipedia.org/wiki/NP-completeness), implying that we cannot write a polynomial-time algorithm to solve it. 
Showing it requires to perform a **reduction**, i.e. showing that the problem is "at least a hard as a known hard problem".
This is beyond the scope of this post but the discussion gives and idea of what one would to further study the problem.

