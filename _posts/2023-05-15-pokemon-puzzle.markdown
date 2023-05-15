---
title:  Solving pokemon puzzle with SAT solvers
author: samuel
date:   2023-05-15 10:00:00 +0200
categories: SAT logic puzzle games model-checking
comments: true
---

I recently came across an interesting logic puzzle found in a pokemon (unofficial) fangame.
As everyone knows, Pokemon is a famous role playing game license from nintendo where your goal is to train small creatures that fight each other.
While the core of pokemon gameplay is centered toward the training of pokemons, the player would encounter some logic puzzles on his way. For instance, the next image show one of these puzzles taken from pokemon emerald.

![A puzzle from the pokemon game emerald.](https://lparchive.org/Pokemon-Emerald-(by-Crosspeice)/Update%2025/8-e23009.png)

While these puzzles are usually relatively simple and solvable by everyone, it is possible to find much more challenging ones in unofficial games.
The puzzle I am interesting in takes place in [pokemon reborn](https://www.rebornevo.com/pr/index.html/).
This particular puzzle caught my attention as it is similar constraint problems in computer science.
I decided to appply techniques that I studied during my master degree to solve it. 



---

# Introduction

## The puzzle

The puzzle in question is represented by two 3x3 grids of digits, as it is shown below.
The goal of the puzzle is to manipulate the grids throw a set of operations so that you end up with a sum of digits equal to 15 for each rows, each columns and each diagonal of the grids.

![The puzzle ingame.](/assets/pokemon_puzzle.png)


There are two type of operations in this grid.
First, it is possible to move a column down or up. All the rows can be moved independently and when a digit is on the border of the grid, moving the row places it at the other extremity.
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

The encoding of the problem consists in representing the sequence of operations performed on the grids with logic operations on logic constraints, and ensuring that after the last operations the sums are verified on the row and columns.
There are two parts in this step.
The first part is to decide what are the logic variables and how they represent the problem.
Once it is decided, the variables need to be linked between each other through logic operations.

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
Hence, we will have (n-1) group of variables for the operations, one between each consecutive states.

```
 (state_1, operations_1) -> (state_2, operations_2) -> ... -> (state_n, operations_n)
```

## Encoding the operations

Once the variables are decided, we need to link them with logic operations into a formula that would be true only if the values of the variables correspond to a solution of the puzzle.
This step can be interpreted as adding **constraints** to our formula.
One way of looking at it is to consider that with an empty formula, the values of the variables can be anything, it will always be true.
However, this will not likely correctly represent the states of our puzzle (for instance we may have two digits as true in the same cell).
Hence, the logic operations will make sure that the representation is consistent.

This task can be divided into thee parts: 1) setting the initial state, 2) imposing the sum constraints on the last state and 3) creating the transitions between each state.

### 1) First state constraint

The first step is straightforward. Given the initial grids shown in the game (see picture), we will create a conjunction between the digits that needs to be true and the negation of the digits that need to be false.
For instance, for the upper left corner of the first grid, there is a 4, thus:
 `v_0_0_4 and not v_0_0_1 and not v_0_0_2 and not v_0_0_3 and not v_0_0_5 and .. and not v_0_0_9`

### 2) Last state constraints

For this last step, one difficulty is the translation of the numerical sum into a logic constraint. To simplify this step, we can introduce for each row, column and diagonal a set of 9 digit variables that will be independent from there position in the row, column, diagonal.
From this, it is possible to enumerate all the subsets of 3 digits that sum to 15 and proceed similarly to step 1) to enforce one of this sum to be verified.
The digit variables can be linked to the grids from the last state by adding implications. For example `digit_5_row_0 => v_0_1_5 or v_0_2_5 or v_0_3_5`.  

### 3) Transition constraints

The last step is trickier. Here, we need to somehow verify through logic constraints that any modification occurring on the grids between two states is consistent regarding the rules.
For this step we will once agin use implications, between consecutive states this time.
For instance, taking the upper left corner cell of the first grid, we need to verify that the digit that is true at state i+1 is either the result of an operation or was already true at state i.
In case the digit was true at state i, we also need to check that no operation was performed on the same row or column.

Having a 3 in the upper left grid implies:
* there was already a 3 and the first row and the first column did not move
* the row moved and we had a 3 
* column moved

```
-------------               -------------                               -------------
| _ | _ | _ |               | 3 | _ | _ |                               | _ | _ | _ |           
-------------               -------------                               -------------
| 3 | _ | _ |    =>   (     | _ | _ | _ |  and row operation up ) or   | _ | _ | _ |
-------------               -------------                               -------------
| _ | _ | _ |               | _ | _ | _ |                               | 3 | _ | _ |
-------------               -------------                               -------------

State n                     State n-1

```


# Let's code the program

In the case of SAT solvers, the formula taken as input is given in its [Conjunctive Normal Form](https://en.wikipedia.org/wiki/Conjunctive_normal_form).
Second, the transform the formula into a conjunctive normal form formula.
This latter step can be done automatically by introducing new variables.
In fact, I wrote a piece of program during my studies to perform this task automatically.
My idea was to re-use the code and create an encoding of the problem for finding a solution.


# Conclusion