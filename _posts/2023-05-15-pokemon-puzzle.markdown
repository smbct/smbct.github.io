---
title:  Solving a pokemon puzzle with SAT solvers
author: smbct
date:   2023-05-15 10:00:00 +0200
categories: SAT logic puzzle games model-checking
comments: true
layout: post
---

I recently came across an interesting logic puzzle found in a pokemon (unofficial) fangame.
As everyone knows, Pokemon is a famous role playing game license from nintendo where your goal is to train small creatures that fight each other.
While the core of pokemon gameplay is centered toward the training of pokemons, the player would encounter some logic puzzles on his way. For instance, the next image show one of these puzzles taken from pokemon emerald.

![A puzzle from the pokemon game emerald.](https://lparchive.org/Pokemon-Emerald-(by-Crosspeice)/Update%2025/8-e23009.png)

While these puzzles are usually relatively simple and solvable by everyone, it is possible to find much more challenging ones in unofficial games.
The puzzle I am interesting in takes place in [pokemon reborn](https://www.rebornevo.com/pr/index.html/).
This particular puzzle caught my attention as it is similar to constraint problems in computer science.
I decided to apply techniques that I studied during my master degree to solve it. 



---

# The puzzle

## Overview

The puzzle in question is represented by two 3x3 grids of digits, as it is shown below.
The goal of the puzzle is to manipulate the grids throw a set of operations so that you end up with a sum of digits equal to 15 for each rows, each columns and each diagonal of the grids (these grids are called [Magic Squares](https://en.wikipedia.org/wiki/Magic_square)).

![The puzzle ingame.](/assets/pokemon_puzzle.png)


There are two type of operations in the grids.
First, it is possible to move a column down or up.
All the columns can be moved independently and when a digit is on the border of the grid, moving the olumn places it at the other extremity.
Second, it is possible to move the rows left or right.
For this operation, the two grids are connected together and when a digit leaves one grid, it appears on the second one.
This interconnection between the grids make the puzzle challenging as trying to satisfy one of the row or column on one grid may perturb the other one.
Here is one example for each operation:



```
4 9 6  .  1 2 5                                         5 9 6  .  1 2 5
5 8 3  .  7 7 9   Move First Column Left Grid Up ->     2 8 3  .  7 7 9
2 4 1  .  6 3 8                                         4 4 1  .  6 3 8

-----------------------------------------------------------------------

5 9 6  .  1 2 5                                         5 9 6  .  1 2 5
2 8 3  .  7 7 9   Move Second Row Left ->               8 3 7  .  7 9 2
4 4 1  .  6 3 8                                         4 4 1  .  6 3 8

```

## How I solve it

To solve this puzzle, I decided to use a type of program called [SAT Solvers](https://en.wikipedia.org/wiki/SAT_solver).
These programs are made to automatically solve logic formula: they search for **true/false** values for logic variables to make the formula true.
For instance, if the formula is `(a => b) and c`, this formula would be true when `a = false, b = false or true, c = true` or `a = true, b = true, c = true`. 
Finding the right values for the variables so that the formula is true is actually the goal of the so called SAT problem.

For this method, our goal is to create an *encoding* of the puzzle, in this case define a logic formula that is true when a solution of the puzzle is found.


---



# Encoding the puzzle into a logic formula

The encoding of the problem consists in representing the sequence of operations performed on the grids with logic operations on logic variables, and ensuring that after the last operations the sums are verified on the rows and columns.
There are two parts in this step.
The first part is to decide what are the logic variables and how they represent the problem.
Once it is decided, the variables need to be linked between each other through logic operations, which is the second part.

## Encoding the grids

The main variables of the problem will represent its **states**.
In this context, the states of the puzzle are the two grids at different step of evolution.
Indeed, we need to keep track of each evolution of the grid in the formula to make sure that every transformation is valid.

To represent one grid in this problem, we can use 3*3 sets of 9 variables. For each cell of a grid, the 9 variables will represent all the digits, assuming the digit showing up in that cell will have its corresponding variable **true**.
This representation can be used to encode the two grids at each step of the operations.

```

-------------------------------
|         |         |         |
| v_0_0_k | v_0_1_k | v_0_2_k |
|         |         |         |
-------------------------------   k = {1,..,9}
|         |         |         |
| v_1_0_k | v_1_1_k | v_1_2_k |             / true if the cell at row i and column j = k 
|         |         |         |   v_i_j_k =    
-------------------------------             \ false if the cell at row i and column j != k 
|         |         |         |
| v_2_0_k | v_2_1_k | v_2_2_k |
|         |         |         |
-------------------------------

```

In order to represent multiple operations performed on the grids, we will need more than one state.
Thus, we will decide a number **n** of states for our encoding, and create in total **n** group of state variables.
The first state will then represent the initial grids (as seen on the in game picture), and the n-th state will be the two grids verifying the sum constraints.   

We will additionally add variables to represent the different operations performed on the grid.
There will be in total 18 variables for each step (6 * 2 variables for the columns operations (column index, Up Down) and 3*2 variables for the rows (row index and Left/Right)).
Hence, we will have (n-1) group of variables for the operations, one between each consecutive states:

```
 (state_1, operations_1) -> (state_2, operations_2) -> ... -> (state_n, operations_n)
```

## Encoding the operations

Once the variables are decided, we need to link them with logic operations into a formula that would be true only if the values of the variables correspond to a solution of the puzzle.
This step can be interpreted as adding **constraints** to our formula. The different constraints will be linked with a **And** operation so that they will be all satisfied when the formula is true.


One way of looking at it this modeling task is to consider that with an empty formula, the values of the variables can be anything, it will always be true.
However, this will not likely correctly represent the states of our puzzle (for instance we may have two digits true in the same cell).
Hence, the logic operations will make sure that the representation is consistent.
The constraints needed here can be divided into thee parts: 1) setting the initial state of the puzzle, 2) imposing the sum constraints on the last state and 3) creating the transitions between each state.

### 1) First state constraint

The first step is straightforward. Given the initial grids shown in the game (see picture), we will create a **And** operation between the digits that needs to be true and the negation of the digits that need to be false.
For instance, for the upper left corner of the first grid, there is a 4, thus:
 `v_0_0_4 = true and v_0_0_1 = false and v_0_0_2 = false and v_0_0_3 = false and v_0_0_5 = false and .. and v_0_0_9 = false` will be our constraint for this first cell.
Since the variables are joined using a And, it is not necessary to make the true/false appear here, which gives:
`v_0_0_4 and (not v_0_0_1) and (not v_0_0_2) and (not v_0_0_3) and (not v_0_0_5) and .. and (not v_0_0_9)` as a final constraint.
This step can be repeated for all the cells of the initial state. 

### 2) Last state constraints

For this last step, one difficulty is the translation of the numerical sum into a logic constraint. To simplify this step, we can introduce for each row, column and diagonal a set of 9 digit variables that will be independent from their position in the grid.
From this, it is possible to enumerate all the subsets of 3 digits that sum up to 15 and proceed similarly to step 1) to enforce one of this sum to be verified.
The digit variables can be linked to the grids from the last state by adding implications. For example `digit_5_row_0 => v_0_1_5 or v_0_2_5 or v_0_3_5`.  

### 3) Transition constraints

The last step is trickier.
Here, we need to somehow verify through logic constraints that any modification occurring on the grids between two states is consistent regarding the puzzle's rules.
For this step we will once agin use implications, between consecutive states this time.
For instance, taking the upper left corner cell of the first grid, we need to verify that the digit that is true at state i+1 is either the result of an operation or was already true at state i.
In case the digit was true at state i, we also need to check that no operation was performed on the same row or column.

For example, having a 3 in the cell at row 1 and column 0 implies either:

* there was already a 3 and the second row and the first column did not move
* the column moved and there was a 3 below or above
* the row moved and there was a three before or after this position

Encoding the column move would be done as following:

```                                
                           -------------                 
                           | 3 | _ | _ |                                  
                           -------------                                   
                           | _ | _ | _ |   and column operation Down               
                           -------------
-------------              | _ | _ | _ |
| _ | _ | _ |              -------------     
-------------               
| 3 | _ | _ |    Implies        or
-------------               
| _ | _ | _ |              ------------- 
-------------              | _ | _ | _ |
                           -------------                               
                           | _ | _ | _ |   and column operation Up    
                           -------------    
                           | 3 | _ | _ |      
                           -------------    
                               
State n                     State n-1
```

For the operations on the row, we will see something like:

```                                 
                                        -------------   -------------
                                        | _ | _ | _ |   | _ | _ | _ |
                                        -------------   -------------
                                        | _ | 3 | _ |   | _ | _ | _ |  and row operation Left
                                        -------------   -------------
-------------   -------------           | _ | _ | _ |   | _ | _ | _ |
| _ | _ | _ |   | _ | _ | _ |           -------------   -------------
-------------   -------------             
| 3 | _ | _ |   | _ | _ | _ |  Implies                or
-------------   -------------            
| _ | _ | _ |   | _ | _ | _ |           -------------   ------------- 
-------------   -------------           | _ | _ | _ |   | _ | _ | _ |
                                        -------------   -------------
                                        | _ | _ | _ |   | _ | _ | 3 |  and row operation Right
                                        -------------   ------------- 
                                        | _ | _ | _ |   | _ | _ | _ |   
                                        -------------   ------------- 
                               
           State n                                State n-1
```

# Let's code the program

Now that the encoding is ready to be implemented, the last part consists in putting all the pieces together into one final program. 
The program will take as input the digits in the two cells and a number of steps to solve the puzzle.
From these data, it will automatically create the logic formula corresponding to the puzzle and will call a SAT solver to solve the formula.
Once it is done, the program can extract the solution and display it in a human readable form.
Without detailing everything in the implementations, I will still give few precisions.

## Writing the automatic encoding

Usually, the code necessary to implement an encoding is not the easiest to read and interpret.
Nonetheless, having well documented data structure really helps in the process.
The final goal of this task is the creation of the logic formula to be sent to the SAT solver.
One important thing is that SAT solvers usually take as input a specific form of logic formulas called [Conjunctive Normal Form](https://en.wikipedia.org/wiki/Conjunctive_normal_form).
Luckily, it is always possible to introduce new variable to transform any formula into this type.
For this project, I used a piece of code that I wrote during my studies that specifically perform this transformation.
It is based on that (approach)[https://en.wikipedia.org/wiki/Tseytin_transformation].


## Finding a suitable SAT solver

Finding a SAT solver able to solve the formula is not an easy task either.
I first started to experiment with a number of state equals to 20 in the encoding.
The resulting formula ends up having a very large number for logical variables, make it solution difficult to find.
It is although good to know that SAT competitions take place every year to encourage the development of performent SAT solvers.
I started looking at state of the art solvers from [the 2022 edition](https://satcompetition.github.io/2022/) and I ended up selecting a solver called [Kissat](https://github.com/arminbiere/kissat). Kissat was able to solve the puzzle whin few minutes on my laptot.

## Final code and solution

The code that I wrote for this program is available on [github](https://github.com/smbct/blog_code/tree/master/pokemon).
The folder contains a c++ program creating the encoding with a sequence of 20 states and calling the sat solver to solve the formula.
It also contains an installation script which download the SAT solver and compile the program with gcc.


Here is a solution I found with kissat (states only):

```
4 9 6     1 2 5         4 4 6     1 2 5         4 4 1     1 2 5        4 4 1     1 2 5        4 4 1     7 2 5         4 1 7     2 5 4        4 1 6     2 5 4        4 1 6     2 5 4 
5 8 3     7 7 9   ->    5 9 3     7 7 9   ->    5 9 6     7 7 9   ->   5 9 6     7 7 9   ->   5 9 6     3 7 9    ->   5 9 6     3 7 9   ->   5 9 7     3 7 9   ->   9 5 9     7 3 7    ->   
2 4 1     6 3 8         2 8 1     6 3 8         2 8 3     6 3 8        8 3 6     3 8 2        8 3 6     1 8 2         8 3 6     1 8 2        8 3 6     1 8 2        8 3 6     1 8 2 


4 5 6     2 5 4         4 5 6     2 5 4         4 4 5     6 2 5        4 4 9     6 2 5        4 4 9     6 8 5         4 4 9     6 8 5        4 4 9     2 8 5        4 5 9     2 8 5 
9 3 9     7 3 7    ->   9 3 6     7 3 7   ->    9 3 6     7 3 7   ->   9 3 5     7 3 7   ->   9 3 5     7 2 7    ->   3 5 7     2 7 9   ->   3 5 7     1 7 9   ->   3 1 7     1 7 9    ->
8 1 6     1 8 2         8 1 9     1 8 2         8 1 9     1 8 2        8 1 6     1 8 2        8 1 6     1 3 2         8 1 6     1 3 2        8 1 6     6 3 2        8 4 6     6 3 2 


4 4 9     2 8 5         4 9 2     8 5 4         4 9 2     8 3 4 
3 5 7     1 7 9    ->   3 5 7     1 7 9   ->    3 5 7     1 5 9 
8 1 6     6 3 2         8 1 6     6 3 2         8 1 6     6 7 2

```

This solution contains 18 states and has been found in 145 seconds on my laptop by the kissat solver.

# Final word

We can see that tools such as SAT solvers are available for automatic reasoning and hard problem solving.
Although this might not work all the time, having a try may usually be a (relatively fast) solution to obtain first hints into some problem.
In this case, the encoding aspect is not easy as SAT solvers speak a relatively basic language (logic formulas) and are not the most suitable tools for reasoning with numbers and spatial data (such as grids).

By searching on the internet it is possible to find much more elegant [solutions](https://www.rebornevo.com/forums/topic/48625-magic-square-puzzle-guide/) to this problem.
The fact that this problem ends up being quite challenging for SAT solvers is a interesting.
The solving time may be improved by trying to reduce the size of the encoding.
However, using solvers more expressive than SAT (for example linear programming) may help on this puzzle as it is not easy to be expressed in pure logic.
There are also other automatic ways of solving it such as tree search algorithms like A* or Monte Carlo Tree Search.
This type of algorithms was actually historically used for making AI for chess and alike games.

A later interesting aspect of this puzzle is the process of its creation.
Indeed mathematical puzzles can emerge from various ideas and topics and it is not possible to know if there is a solution until either one is found or it is proven impossible.
In this example, it would have been possible to generate the puzzle by starting from the last state and applying reverse operations (as the operations are deterministic).
However, this seems not to be the origin of this puzzle as discussed in the solution link I mentioned above, and the original story seems more engaging.
Let's see what would be my next challenging puzzles!


