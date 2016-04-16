---
layout: post
title:  "Programmation linéaire"
date:   2016-04-13 23:09:33 +0200
categories: optimisation
---

Pour un premier article, j'ai choisi de parler d'un sujet que je vais avoir probablement l'occasion d'évoquer par la suite : la programmation linéaire.

Pour commencer, clarifions un peu les termes. Le mot programmation ne signifie pas écrire des lignes de code, contrairement à ce que l'on pourrait penser. Programmer veut ici dire planifier. La programmation linéaire (ou encore optimisation linéaire) regroupe une classe particulière de problème d'optimisation, et un ensemble de méthodes efficaces pour les traiter.

Mais au fait, c'est quoi l'optimisation finalement ?

Optimiser, c'est quelque chose de naturel. Tout le monde optimise ! Enfin, tout le monde essaie... Je suis persuadé que tu essaies toi-même d'optimiser des tas de choses, tous les jours.

Optimiser, c'est essayer de faire mieux. C'est partir d'une façon de faire, d'une procédure, d'un plan, et trouver des moyens de l'améliorer pour traiter au mieux une situation. L'améliorer peut alors vouloir dire gagner du temps, réduire des dépenses, maximiser ses chances, etc...

Un premier exemple :

Partons d'une situation qui pourrait tous nous concerner. Imaginons que nous voulond préparer un imporant dîner pour des amis, comportant un grand nombre de plat complexes à préparer. Certaines étapes de la préparation ne peuvent se faire que pendant le dîner, afin de manger chaud par exemple. Par ailleurs, nous voudrions profiter au mieux de la présence de nos invités.

Il pourrait ainsi venir à l'idée de beaucoup de personne de réfléchir à la manière de préparer nos plats le plus efficacement possible. Autrement dit, faire toutes les choses qui peuvent être faîtes simultanément. On vaudrait donc minimiser le temps passé en cuisine. Les plus persévérant d'entre nous prendraient alors un bout de papier et se mettraient à grifoner dessus.

Maintenant, imaginons que notre dîner se transforme en une grande réception avec plus de 50 invités. Il devient alors inconcevable d'imaginer calculer tout ça à la main. C'est donc à ce moment là qu'intervient les mathématiques et l'informatique.


L'optimisation en maths et en info

En mathématiques, l'optimisation est une notion très précises. Optimiser signifie trouver les valeurs maximales et minimales que peuvent atteindre une fonction. Les fonction dont on parle ici ne sont malheureusment pas les fonctions gentilles du lycée, comme x² ou encore 1/x. Ici, on considère plutôt des fonction à plusieurs variables. Les variables, en optimisation, représentent les choix que l'on peut faire IRL, face à notre situation (par exemple, choisir de réaliser une certaine action avant une autre). Il est donc naturel de penser qu'une seule action ne définit pas très bien la situation que l'on veut optimiser. 

Une autre chose que l'on doit prendre en compte lorsque l'on optimise est la présence de contraintes. En effet, les variables de notre fonction (que l'on appelle variables de décision) ne peuvent pas prendre n'importe quelles valeurs ! Evidemment, si vous disposiez de ressources infines comme le temps ou plus de deux mains, l'optimisation serait bien plus efficaces. Mais il faut avouer que les contraintes sont parfois plus subtiles. 

Qu'à cela ne tienne, les mathématiciens ont trouvés des méthodes très efficaces pour traiter ce genre de problème. On peut parler entre autre du Lagrangien qui sert à optimiser des fonctions quelconques, avec la présence de contraintes.

Mais alors, pourquoi parler d'informatique ? 

En fait, les mathématiques ne suffisent pas en optimisation. Alors bien sûr, il faut des ordinateurs pour calculer les extrema de nos fonctions à optimiser, mais il ne s'agit pas seulement de ça. Le fait est que tout ce que je viens de dire sur l'optimisation en mathématiques est valables pour des fonctions dont les variables prennent des valeurs continues. C'est à dire qu'en oubliant les contraintes, les variables peuvent prendre n'importe quelle valeur, que ça soit 42, pi, ou encore racine(2). Or, dans une situation réelle, nos décisions ne peuvent pas toujours se traduire par des valeurs quelconques. Par exemple, si notre décision représente le nombre de fois que l'on va réaliser une action, ce nombre ne peut être qu'un entier. Voilà donc une des limites aux méthodes que nous apportent les maths. Le défis à relever pour les informaticiens est donc de trouver des méthodes permettant de résoudre efficacement des problèmes d'optimisation. Le problème étant qu'en général, si l'on se contente de tester toutes les combinaisons de décision possible, il y en a beaucoup, beaucoup, beaucoup, beaucoup trop ! 

La programmation linéaire dans tout ça

La programmation linéaire désigne un ensemble de règles que l'on se donne pour représenter sous forme mathématique un problème. Le but du jeu est de représenter notre problème concret sous forme mathématique, en respectant toutes ces règles.

En programmation linéaire, on considère donc une fonction de plusieurs variables à optimiser, sous plusieurs contrainte. La limite imposée est le fait que la fonction et les contraintes doivent être linéaires. Cela signifie que dans l'expression de la fonction et des contraintes, les variables peuvent seulement être multipliées par des entiers. On ne peut pas multiplier par une variable, diviser une variable, l'élever à une puissance... En bref, on ne touche pas aux variables, on les multiplies seulement !

Par ailleurs, une précision est rajoutée. En effet, comme je le disais précédemment, on considère parfois des variables dont les valeurs sont des entiers. On précise donc dans notre modèle que la nature des variables. Les variables peuvent être continues (xi appartient à R), entières (xi appartient à N) ou encore booléennes (xi appartient à {0,1}). Dans le deuxième et le troisième cas, on parle alors de programmation entière.


