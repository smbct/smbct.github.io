---
layout: post
title:  "Programmation linéaire"
date:   2016-04-16 21:20:33 +0200
categories: optimisation
---

<script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>

Pour un premier article, j'ai choisi de parler d'un sujet que je vais avoir probablement l'occasion d'évoquer à nouveau par la suite : la programmation linéaire.

Pour commencer, clarifions un peu les termes. Le mot programmation ne signifie pas ici écrire des lignes de code, contrairement à ce que l'on pourrait penser. Programmer veut ici dire planifier. La programmation linéaire (ou encore optimisation linéaire) regroupe une classe particulière de problèmes d'optimisation, et un ensemble de méthodes efficaces pour les traiter.

<p class = "question">Mais au fait, c'est quoi l'optimisation finalement ?</p>

Optimiser, c'est quelque chose de naturel. Tout le monde optimise ! Enfin, tout le monde essaie.

Optimiser, c'est essayer de faire mieux. C'est partir d'une façon de faire, d'une procédure, d'un plan, et trouver des moyens de l'améliorer pour traiter au mieux une situation. L'améliorer peut alors vouloir dire gagner du temps, réduire des dépenses, maximiser ses chances, etc...

<h1>Un premier exemple</h1>

Partons d'une situation qui pourrait tous nous concerner. Imaginons que nous voulons préparer un dîner pour des amis, comportant un grand nombre de plat complexes à préparer. Certains voudront alors faire au plus vite et réussir à tout préparer en peu de temps.

![Des cookies !](/assets/cookies.jpg)

Il pourrait ainsi venir à l'idée de réfléchir à la manière de préparer nos plats le plus efficacement possible. Autrement dit, trouver dans quel ordre faire les choses, afin de finir le plus tôt possible. On vaudrait donc minimiser le temps passé en cuisine. Les plus persévérant d'entre nous prendraient alors un bout de papier et se mettraient à griffoner dessus :D 

Maintenant, imaginons que notre dîner se transforme en une grande réception avec plus de 50 invités. Il devient alors inconcevable d'imaginer calculer tout ça à la main. C'est donc à ce moment là qu'interviennent les mathématiques et l'informatique.


<h1>L'optimisation en maths et en info</h1>

En mathématiques, l'optimisation est une notion très précise. Optimiser signifie trouver les valeurs maximale et minimale que peut atteindre une fonction. Les fonctions dont on parle ici ne sont malheureusment pas les fonctions gentilles du lycée, comme $$x²$$ ou encore $$ \frac{1}{x} $$. Ici, on considère plutôt des fonction à plusieurs variables comme $$x² + y²$$. Les variables, en optimisation, représentent les choix que l'on peut faire, face à notre situation (par exemple, choisir de réaliser une certaine action avant une autre). Il est donc naturel de penser qu'une seule action ne définie pas très bien, à elle seule, la situation que l'on veut optimiser. 

Une autre chose que l'on doit prendre en compte lorsque l'on optimise est la présence de contraintes. En effet, les variables de notre fonction (que l'on appelle variables de décision) ne peuvent pas prendre n'importe quelles valeurs ! Evidemment, si vous disposiez de ressources infinies comme le temps ou plus de deux mains, l'optimisation serait bien plus efficace ! Mais il faut avouer que les contraintes apparaissent parfois de manière plus subtile. 

Qu'à cela ne tienne, les mathématiciens ont trouvés des méthodes très efficaces pour traiter ce genre de problème.

<p class = "question">Mais alors, pourquoi parler d'informatique ?</p> 

En fait, les mathématiques ne suffisent pas pour optimiser des problèmes réels. Alors bien sûr, il faut des ordinateurs pour calculer les extrema de nos fonctions à optimiser, mais il ne s'agit pas seulement de ça. Le fait est que tout ce que je viens de dire sur l'optimisation en mathématiques est valable pour des fonctions dont les variables prennent des valeurs continues. C'est à dire qu'en oubliant les contraintes, les variables peuvent prendre n'importe quelle valeur, que ça soit $$42$$, $$\pi$$, ou encore $$\sqrt{2}$$. Or, dans une situation réelle, nos décisions ne peuvent pas toujours se traduire par des valeurs quelconques. Par exemple, si notre décision représente le nombre de fois que l'on va réaliser une action, ce nombre ne peut être qu'entier. Voilà donc une des limites aux méthodes que nous apportent les maths. Le défi à relever est donc de trouver des méthodes permettant de résoudre efficacement ce genre de problème. Le soucis étant qu'en général, si l'on se contente de tester toutes les combinaisons de décision possible, il y en a beaucoup, beaucoup, beaucoup, beaucoup trop ! 

<h1>La programmation linéaire dans tout ça</h1>

La programmation linéaire désigne un ensemble de règles que l'on se donne pour représenter sous forme mathématique un problème réel. Le but du jeu est de représenter notre problème concret sous forme d'une fonction et d'un ensemble de contraintes, en respectant toutes ces règles.

En programmation linéaire, on considère donc une fonction de plusieurs variables à optimiser, sous plusieurs contrainte. La limite imposée est le fait que la fonction et les contraintes doivent être linéaires. Cela signifie que, dans l'expression de la fonction et des contraintes, les variables peuvent seulement être multipliées par des valeurs fixées. On ne peut pas multiplier par une variable, diviser une variable, l'élever à une puissance, etc... En bref, on ne touche pas aux variables, on les multiplie seulement par des réels !

Par ailleurs, une précision est rajoutée. En effet, comme je le disais précédemment, on considère parfois des variables dont les valeurs sont des entiers. On précise donc dans notre modèle la nature des variables. Les variables peuvent être continues ($$x_{i} \in \mathbb{R}$$), entières ($$x_{i} \in \mathbb{N}$$) ou encore booléennes ($$x_{i} \in \{0,1\}$$). Dans le premier cas, la précision n'est pas nécessaire. Dans le deuxième et le troisième cas, on parle alors de programmation entière et de programmation entière en variables binaires.

Voici un exemple de programme linéaire :

<p class = "programme-math">
$$

max \,z = x_{1} + 3x_{2}\\
	 \begin{align*} 
		
		s.c.\quad  x_{1} - x_{2} \leq 5\\
			x_{1} + 4 x_{2} \leq 6\\
			-x_{1} + x_{2} \leq 1\\ 
			x_{1}, x_{2} \geq 0
	\end{align*}

$$
</p>

Ces règles peuvent parraître bien contraignantes. En fait, elles permettent tout de même, en rusant un peu, de modéliser beaucoup de situations réelles. Et quel est l'intérêt de se limiter à ça finalement ? L'intérêt c'est que nous disposons d'un algorithme, l'algorithme du simplex, pour résoudre efficacement ces problèmes. Dans le cas de variables entières, c'est tout de même plus compliqué car l'algorithme ne suffit pas pour trouver une solution. De nombreuses méthodes existent toutefois pour résoudre ces problèmes, comme le <em>branch and cut</em>.

Malheureusement, la programmation linéaire n'est pas la solution à tout. En optimisation, généralement on ne trouve pas de méthode globale pour résoudre efficacement n'importe quel problème. L'idée est alors de profiter de toutes les spécificités du problème que l'on traite afin d'en tirer avantage. Par exemple, pour revenir à notre problème de cuisine, qui est en fait un problème <em>d'ordonancement</em>, un modèle linéaire en variable entière existe (vous saurez le trouver ?). Cependant, on décide carément de quitter le formalisme de la programmation linéaire et de le traiter avec un autre outil puissant et mieux adapté ici : la théorie des graphes. Mais ça, ça sera pour une autre fois.

<h1>Crédit</h1>

photo credit: <a href="http://www.flickr.com/photos/7702423@N04/26056556830">297/365/2853 (April 3, 2016) - Chocolate Coconut Cookies</a> via <a href="http://photopin.com">photopin</a> <a href="https://creativecommons.org/licenses/by-nc-sa/2.0/">(license)</a>


