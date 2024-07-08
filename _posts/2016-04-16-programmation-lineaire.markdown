---
title:  Programmation linéaire
author: smbct
date:   2016-04-16 21:20:33 +0200
categories: optimisation IA
categories: vulgarisation IA
comments: true
layout: post
lang: fr
back_page: /fr/index.html
---


Pour un premier article, j'ai choisi de parler d'un sujet que je vais avoir probablement l'occasion d'évoquer à nouveau par la suite : la programmation linéaire.
Pour commencer, clarifions un peu les termes. Le mot programmation ne signifie pas ici écrire des lignes de code, contrairement à ce que l'on pourrait penser. Programmer veut ici dire planifier. La programmation linéaire (ou encore optimisation linéaire) regroupe un ensemble de problèmes d'optimisation, et des méthodes efficaces pour les traiter.

> Mais au fait, c'est quoi l'optimisation finalement ?
{: .prompt-info }

Optimiser, c'est essayer de faire de la meilleure façon possible. Cela peut concerner le fait de partir d'une façon de faire, d'une procédure, d'un plan, et trouver des moyens de l'améliorer pour traiter au mieux une situation. Cela peut aussi concerner le fait de prévoir à l'avance quelle va être la meilleure stratégie pour attaquer un problème. L'améliorer peut alors vouloir dire gagner du temps, réduire des dépenses, maximiser ses chances, etc...

<script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>


## L'optimisation en maths et en info

En mathématiques, l'optimisation est une notion très précise. Optimiser signifie trouver les valeurs maximale et minimale que peut atteindre une fonction.

> Et pourquoi un maximum ou un minimum ?
{: .prompt-info }

Il n'est pas forcément évident aux premiers abords qu'un problème d'optimisation est un problème de recherche de maximum ou de minimum. Cependant, en y réfléchissant, derrière tout problème d'optimisation se cache un min ou un max. Par exemple, dans certaines situations, on veut optimiser le temps mis pour faire une action. Cela veut alors dire prendre le moins de temps possible. On cherche bien un minimum. Dans d'autres contextes, on peut aussi chercher à optimiser un gain. On cherche alors à obtenir le gain maximum.

Donc si l'on veut traduire un problème d'optimisation naturel en problème mathématique, cela consiste donc à trouver une fonction qui exprime le mieux possible la quantité à optimiser (que ça soit du temps, de l'argent, etc...)

Passer d'un problème réel à un problème mathématique, c'est l'action de modéliser. Une des première chose à faire pour modéliser un problème, c'est identifier les variables. Les variables sont impliquées de le calcul de la fonction à optimiser. Elles correspondent pour le problème réel aux différentes décisions que l'on peut prendre (par exemple, "combien d'unité produire ?" ou encore "doit-on activer cette option ?").

Une autre chose que l'on doit prendre en compte lorsque l'on optimise est la présence de contraintes. En effet, les variables de notre fonction (que l'on appelle variables de décision) ne peuvent pas prendre n'importe quelles valeurs ! Par exemple, si nos variables concernent un nombre d'unité à produire, on ne peut pas évidemment pas produire en quantité infinie. Les ressources disponibles entre donc en compte dans ce type de problème. Par ailleurs, les contraintes apparaissent parfois de manière plus subtile.


> Mais alors, pourquoi parler d'informatique ?
{: .prompt-info }

Comme on l'a vu précédemment, les mathématiques nous offrent des outils puissants pour traiter les problèmes d'optimisation. En effet, une fois que le problème est modélisé, on peut appliquer des théorèmes pour calculer le maximum ou le minimum de fonctions.

Cependant, les problèmes que l'on veut résoudre peuvent parfois comporter des milliers de variables. On ne peut donc plus espérer résoudre ces problèmes à la main. C'est pourquoi il a fallut mettre en place des algorithmes capable de calculer ce genre de chose le plus rapidement possible.

Implémenter des méthodes de calculs automatiques ne suffit toutefois pas à résoudre tous les problèmes. Certains problèmes sont en effet par nature très difficiles à résoudre et les algorithmes généraux prennent énormément de temps. Les outils mathématiques sont limités pour ces problèmes. Il est donc nécessaire de les étudier en profondeur afin de trouver des techniques algorithmiques adaptées pour la résolution.

> Une des caractéristiques du domaine est qu'il n'existe pas de méthode générale efficace pour traiter n'importe quel problème.
{: .prompt-info }

## La programmation linéaire dans tout ça

La programmation linéaire désigne un ensemble de règles que l'on se donne pour représenter sous forme mathématique un problème réel. Le but du jeu est de représenter notre problème concret sous forme d'une fonction mathématique et d'un ensemble de contraintes, en respectant ces règles.

En programmation linéaire, on considère donc une fonction à optimiser, sous plusieurs contrainte. La limite imposée est le fait que la fonction et les contraintes doivent être linéaires. Cela signifie que, dans l'expression de la fonction et des contraintes a la forme d'une somme de variables multipliées par de coefficients. On ne peut ainsi pas multiplier deux variables, diviser deux variables, appliquer une racine, etc...

Ces limitations peuvent paraître très contraignantes. Cependant, un très grand nombre de problèmes réels peuvent se modéliser de cette façon. Parfois, il faut avoir recours à certains tricks mais ceux-ci sont facilement intégrés par expérience. Il faut enfin retenir que si l'on se contraint, c'est parceque les méthodes algorithmiques disponibles pour ces problèmes sont très efficaces. Il vaut donc mieux se creuser la tête et trouver une bonne modélisation en programmation linéaire plutôt que d'avoir à résoudre un problème non linéaire.

## Un premier exemple de modélisation

Prenons un premier exemple de modélisation.

![Des cookies !](/assets/cookies.jpg)

Partons d'une situation simple : nous allons recevoir des invités et nous voulons leur préparer deux types de petits biscuits. Les deux demandent les mêmes ingrédients : de la farine et du sucre.


Mais voilà, nous disposons de ces deux ingrédients en quantité limité malheureusement. De plus, les convives à qui sont destinés ces biscuits n'ont pas tous les mêmes goûts. Ainsi, il ne faut pas produire les deux types de biscuits en même quantité. La question est alors : combien de biscuit de chaque type produire ? Dans l'exemple présenté, les données sont issues de recettes respectives de madeleines et de biscuits à la cannelle.


### Les variables du problème

La première étape de la modélisation consiste à trouver les variables du problème. Ici, les variables sont faciles à trouver. La question concerne directement le nombre de biscuit à produire. On définit donc deux variables : $$x_1$$ représentant le nombre de biscuit de type 1 que l'on veut créer et $$x_2$$ représentant le nombre de biscuit de type 2.

### Les contraintes

Une fois les variables trouvées, on peut regarder les contraintes. Pour ce problème, il y a deux contraintes liées aux ressources disponible (farine et sucre), une contrainte concernant les convives et enfin des contraintes plus générales, et enfin des contraintes structurelles.

Tout d'abord, on peut définir la contrainte pour la farine. On suppose que l'on dispose d'un kilogramme de farine. La recette nous indique également qu'il faut 4.2 g de farine pour un biscuit de type 1 et 15 g de farine pour les biscuits de type 2. On en déduit donc la contrainte $$4.2 x_1 + 15 x_2 \leq 1000$$.

On procède de manière similaire pour le sucre. On obtient : $$5.8 x_1 + 7.5 x_2 \leq 1000$$.

La contrainte suivante traduit une préférence des convives. On suppose qu'un quart de invités n'aime pas les biscuits du type 1. Par ailleurs, il n'y a pas de préférence pour ceux du type 2. On en déduit : $$x_1 \leq \frac{1}{4} (x_1 + x_2)$$

Enfin, on ne peut pas produire un nombre négatif de biscuit. On a donc $$x_1, x_2 \geq 0$$. De plus, on ne peut pas produire de demi-biscuit. Heureusement, en programmation linéaire, nous pouvons résoudre des problèmes avec des variables dites entières. On a donc comme dernière contrainte : $$x_1, x_2 \in \mathbb{Z}$$.

### La fonction objectif

Il ne reste plus qu'à écrire la fonction à optimiser. Ici, on veut maximiser la nombre de gâteau produit. La fonction est donc $$z = x_1 + x_2$$.

On peut donc récapituler le modèle de notre problème :

$$
\text{max} \,z = x_{1} + x_{2}\\
	 \begin{align*}
		s.c.\quad 4.2 x_1 + 15 x_2 &\leq 1000 \\
			5.8 x_1 + 7.5 x_2 &\leq 1000 \\
			x_1 &\leq \frac{1}{4} (x_1 + x_2) \\
			x_1, x_2 &\in \mathbb{N}
	\end{align*}
$$

Je passe les détails de la résolution de ce problème car cela nécessiterait plusieurs articles. Elle est néanmoins basée sur la méthode du branch and bound et l'algorithme du simplexe. Après résolution, on trouve $$x_1 = 20$$ et $$x_2 = 61$$. Nous allons donc pouvoir confectionner 81 gâteaux pour nos invités.

## Conclusion

La programmation linéaire est donc un outil très intéressant pour l'optimisation. Malheureusement, ce n'est pas un outil infaillible. Même si les algorithmes utilisés pour résoudre ces problèmes sont très efficaces en variable continues (c'est à dire lorsque les variables ne sont pas forcément des entiers), ce n'est pas la même chose pour les variables entières ou binaires. L'idée est alors de profiter de toutes les spécificités du problème que l'on traite afin d'en tirer avantage et de proposer des méthodes de résolution dédiées. Parfois, on décide carrément de quitter le formalisme de la programmation linéaire et de traiter le problème avec un autre outil mieux adapté (ex : les graphes). Les problèmes d'optimisation sont donc loin d'être parfaitement maîtrisés et cet article n'effleure que très légèrement toutes les choses que l'on peut faire en optimisation.

## Crédit

photo credit: <a href="http://www.flickr.com/photos/7702423@N04/26056556830">297/365/2853 (April 3, 2016) - Chocolate Coconut Cookies</a> via <a href="http://photopin.com">photopin</a> <a href="https://creativecommons.org/licenses/by-nc-sa/2.0/">(license)</a>
