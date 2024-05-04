---
title:  SAT, un problème de logique
author: smbct
date:   2018-03-04 18:00:00 +0200
categories: stage logique SAT sudoku
comments: true
layout: post
---

<script src="https://cdn.mathjax.org/mathjax/latest/MathJax.js?config=TeX-AMS-MML_HTMLorMML" type="text/javascript"></script>

Afin de pouvoir parler un peu plus en détails de mon stage, je voulais aujourd'hui présenter un problème très connu en info. Ce problème, SAT de son petit nom, tente de répondre à la question suivante : pour une formule logique donnée, existe-il une affectation des variables de cette formule permettant de la rendre vraie ?

Quelques explications s'imposent...

# Logique, Maths et Info

Il peut paraître un peu bizarre de parler de logique sur un blog d'informatique. En info, on essaie de résoudre des problèmes de calculs divers, allant du calcul de plus courts chemins à l'analyse d'avis clients sur les réseaux sociaux.

Seulement, les problèmes de logiques sont également des problèmes calculatoires. La logique à laquelle on s'intéresse ici est la logique propositionnelle. Elle comprend un ensemble de règles qui nous permettent de définir ces problèmes de calcul.

> L'intérêt dans tout ça ?
{: .prompt-info }

L'intérêt d'étudier ce genre de problème est multiple. Tout d'abord, d'un point de vue théorique, ce sont les premiers problèmes que l'on a démontré comme étant "difficiles". Cela signifie qu'on sait ces problèmes particulièrement compliqués à résoudre. Tellement compliqués que si quelqu'un trouvait une méthode extrêmement rapide pour y arriver, cela aurait un impacte majeur dans le monde, mais ça c'est un autre sujet.

Cela rejoint le côté pratique de la chose. On est capable de montrer que SAT est équivalent à beaucoup d'autres problèmes, il s'agit juste d'une histoire de transformation. Le problème à beau être difficile à résoudre, des chercheurs ont tout de même créé des méthodes **très** efficaces pour les résoudre. Tellement efficaces qu'il peut être intéressant de les utiliser afin de résoudre ces autres problèmes. Et c'est justement **ça** qui nous intéresse ici !

# SAT : mode d'emplois

Entrons dans le vif de sujet. SAT s'intéresse à ce qu'on appelle la logique propositionnelle, une des formes de logique les plus simples et brutes. J'ai parlé plus haut de formule et il faut bien comprendre par là formule au sens mathématique. Voici donc les différents ingrédients de ces formules.

## Les variables

Qui dit formule dit variable, et on va commencer par ça. Une variable logique est donc une variable au sens mathématique. Sa particularité est qu'elle peut prendre deux valeurs : *Vrai* ou *Faux*. Une variable logique représente donc un fait, dont on ne sait pas encore si il est avéré ou non. Par exemple, on pourrait définir une variable **sport** qui vaudrait *vraie* si on a prévu une séance de sport, et *faux* sinon. On peut de la même manière avoir une variable **restau** qui vaudrait *vraie* si on a prévu d'aller manger dans un restaurant.

## Les opérateurs

La deuxième chose que l'on trouve dans une formule, ce sont les opérateurs, qui vont entre autre lier les variables entre elles. Des opérateurs logiques, il en existe énormément. Cependant, pour la logique propositionnelle, on va se limiter à 3 : le **non**, le **et** et le **ou**.

Les résultat de l'application d'un opérateur logique peut être représenté par une **table de vérité**. Cette table indique les valeurs possibles pour les variables et le résultat de l'opération correspondant aux variables. Ces ce que l'on va utiliser pour expliquer la sémantique des opérateurs.

- ### Le **non**

L'opérateur **non** (noté $$\neg$$) est l'opérateur de négation. Cet opérateur s'applique a une seule variable (il est unaire). Il a pour but d'exprimer la négation de la variable. La formule logique sera donc vrai uniquement si la variable est fausse. La table de vérité de cet opérateur est donc :

$$a$$ | $$\neg a$$
$$0$$ | $$1$$
$$1$$ | $$0$$

- ### Le **et**

L'opérateur **et** (noté $$\land$$) indique une conjonction entre deux variable. Il exprime le fait que les deux variables doivent avoir la valeur *vraie*. La formule $$ sport \land restau $$ modélise le fait d'aller à la fois au sport et au restau. La table de vérité est alors :

$$sport$$ | $$restau$$ | $$sport \land restau$$
0 | 0 | 0
0 | 1 | 0
1 | 0 | 0
1 | 1 | 1

- ### Le **ou**

L'opérateur **ou** (noté $$\lor$$) modélise une disjonction. Il représente le fait que l'une des deux variables peut être vraie pas pas nécessairement les deux en même temps. Cela donne :

$$sport$$ | $$restau$$ | $$sport \lor restau$$
0 | 0 | 0
0 | 1 | 1
1 | 0 | 1
1 | 1 | 1

> Notez bien que le ou que l'on décrit ici n'a pas le même sens que celui que l'on utilise quotidiennement. En effet, si je pose la question : "tu vas au sport ou au resto ?" on ne s'attend pas à ce que les deux faits soit avérés, mais seulement un des deux. Il s'agit d'un ou "exclusif".
{: .prompt-info }

- ### L'implication

L'implication ($$\rightarrow$$) est un opérateur également très utile qui permet de modéliser une conéquence. Il signifie que si la fait correspondant à la cause est *vrai*, alors celui correspondant à la conséquence est *vrai* aussi. Par exemple, si je veux représenter le fait que je ne veuille pas aller au restau après le sport, je peux utiliser la formule : $$sport \rightarrow \neg restau$$. Pour que la formule soit *vraie* dans le cas ou sport est *vrai*, il faudra donc que $$\neg restau$$ soit *vrai*, ce qui revient à $$restau$$ *faux*. La table de cette opérateur donne :

$$a$$ | $$b$$ | $$a \rightarrow b$$
0 | 0 | 1
0 | 1 | 1
1 | 0 | 0
1 | 1 | 1

L'implication peut ne pas être considérée comme un ingrédient de base du calcul propositionnel. En effet, il s'exprime très simplement à l'aide des autres opérations. Par exemple, $$a \rightarrow b$$ peut être réécrit en $$\neg a \lor b$$ (on peut le vérifier facilement avec une table de vérité). De la même manière, on peut se passer de **et** en utilisant uniquement des **ou** et des **non** et inversement pour les **ou**. Cependant, considérer touts ces opérateurs à la fois facilite les modélisation.

# Ecrire et manipuler des formules SAT

Maintenant que nous savons de quoi est constituée une formule SAT, on va pouvoir regarder comment faire des calculs dessus en pratique.

Pour les exemples suivants, on peut définir les variables logiques $a$, $b$, $c$, $d$ et $e$.

## Vérifier la validité d'une formule

Une première chose que l'on peut faire est vérifiée si une formule est vraie étant donné une affectation pour ses variables. Partons par exemple de la formule : $$((a \land \neg b) \rightarrow c) \lor d$$

Si je fixe $$a = Faux$$, $$b = Vrai$$, $$c = Vrai$$ et $$d = Vrai$$, qu'obtient-on ?

Pour répondre à cette question on peut procéder par étape. Tout d'abord, on peut remplacer les variables par leurs valeurs dans la formule : $$((F \land \neg V) \rightarrow V) \lor V$$

Ensuite, on va évaluer chacune des opérations en partant des opérations les plus *à l'intérieur* de la formule, c'est à dire celles dont les opérandes ne sont pas composées de sous-opérations. Pour savoir comment évaluer, il suffit de regarder les tables de vérité. La première chose à évaluer est donc $$\neg V$$ qui est égale à $$F$$. On se retrouver ensuite avec $$F \land F$$ que l'on peut replacer par $$F$$.

A ce stade, la formule a la forme : $$(F \rightarrow V) \lor V$$. On poursuit donc en évaluant $$F \rightarrow V$$ qui est vrai. Il reste enfin la dernière opération à évaluer : $$V \lor V$$ qui est Vraie. On a donc montré que la formule était vraie pour cette affectation de variable.

Vous pouvez noter que cette vérification est très simple à faire. Elle peut aisément être implémentée dans une programme et ce n'est pas cet aspect qui rend le problème difficile.

## Trouver des affectations satisfaisantes

Une autre chose que l'on cherche souvent à faire est trouver les affectations de variables pour lesquelles la formule est vraie.

Vous avez peut-être remarqué dans la vérification précédente qu'on aurait pu répondre Vrai directement en regardant simplement la valeur de $$d$$ dès le début. On va se servir de ça ici pour trouver déjà affirmer que peu importe la valeur des autres variables, à partir du moment où $$d$$ est vraie, la formule sera vraie.

> Et si d est faux, ça donne quoi ?
{: .prompt-info }

Venons-en justement. Il lorsque $$d$$ est faux, la partie droite de a formule : $$(a \land \neg b) \rightarrow c$$ doit être vraie. On peut reprendre la table de vérité de l'implication pour se rendre compte que lorsque la partie gauche est fausse, la formule est vraie. La formule sera donc vérifiée lorsque $$a \land \neg b$$ est faux, c'est à dire lorsque $$a$$ est faux ou $$b$$ est vrai (vous pouvez vérifier par vous-même !).

Enfin, si la partie gauche de la dernière implication est vraie, alors $c$ doit être vraie, ce qui nous donne la dernière affectation : $$a = V$$, $$b = F$$, $$c = V$$ et $$d = F$$. Et c'est tout, on a énuméré de manière implicite chaque affectation permettant de rendre la formule vraie.

## Résolution de SAT

Dans la partie précédente, on a vu comment procéder de manière méthodologique pour satisfaire la formule. C'est justement ce calcul qui nous intéresse en pratique. Cependant, il y a des cas où cette méthodologie se ramène à tester toutes les affectations possibles de variables. C'est particulièrement embêtant car des affectations possibles, il y en a trop. Pour $$n$$ variables, elles sont au nombre de $$2^n$$. Cela signifie qu'a partir de 20 variables, on dépasse déjà le million d'affectation (et je peux vous assurer que 20 variables, c'est très peu !).

Heureusement, les cas problématiques sont très difficiles à rencontrer en pratique. En effet, la modélisation en SAT des problèmes que l'on cherche à résoudre donne à la formule une structure particulière qui est en général plus facile à résoudre. Il faut aussi compte sur le fait que les solveurs SAT ont a la réputation d'être très très efficaces et permettent de résoudre en pratique des formules énormes. C'est d'ailleurs la raison pour laquelle on transforme nos problèmes en problèmes SAT.

# SAT pour résoudre des problèmes

J'en parle depuis le début, ce qui nous intéresse avec SAT, c'est la possibilité de l'utiliser pour résoudre d'autres problèmes. On appel cela un *encodage SAT du problème*. Pour illustrer cela, je vous propose de résoudre la petite énigme [suivante](http://matoumatheux.ac-rennes.fr/tous/qui/possede.htm).

## Les variables

La première étape pour faire un encodage SAT est de déterminer les variables. Il n'y a en général pas qu'une bonne réponse et trouver les bonnes variables est une affaire de savoir faire.

Pour définir les variables ici, on peut étudier les différents *choix* ou *possibilités* de réponse que nous avons face au problème. La difficulté de se problème réside dans sa combinatoire, c'est à dire le nombre de combinaisons d'éléments de réponse. Un élément de réponse dans ce cas-ci est une proposition de la forme : tel objet va avec telle personne. C'est justement ça que l'on va utiliser comme variable.

Les variables que l'on peut définir sont donc :

- $$v_g$$ valant vraie si Valérie possède la guitare
- $$s_g$$ valant vraie si Sylvie possède la guitare
- $$v_l$$ valant vraie si Valérie possède le luth
- $$s_l$$ valant vraie si Sylvie possède le luth
- $$v_f$$ valant vraie si Valérie possède le ballon de foot
- $$s_f$$ valant vraie si Sylvie possède le ballon de foot
- $$v_t$$ valant vraie si Valérie possède la balle de tennis
- $$s_t$$ valant vraie si Sylvie possède la balle de tennis
- $$v_{cn}$$ valant vraie si Valérie possède le chien
- $$s_{cn}$$ valant vraie si Sylvie possède le chien
- $$v_{ct}$$ valant vraie si Valérie possède le chat
- $$s_{ct}$$ valant vraie si Sylvie possède le chat

On pourrait ici se passer de certaines variables (je vous laisse trouver comment) mais les expliciter toutes dans le modèle rend la modélisation plus claire.

## Contraintes du problème

Un peu comme en programmation linéaire, on retrouve une partie que j'appelle *contrainte* dans la modélisation. Ici, ce sont des formules logiques qui vont lier les variables entre elles et faire respecter les conditions du problème.

### Contrainte 1

La première contrainte nous apprend que si Valérie possède la guitare, le chat doit être avec la balle de tennis, c'est à dire qu'ils sont possédés par la même personne. La forme "Si... alors..." est typiquement une implication. En effet, la seule chose qui ne sera pas possible dans cette indication est que Valérie possède la guitare et que le chat ne soit pas avec la balle de tennis (une seule possibilité d'obtenir faux avec l'implication, cf tables de vérités).

Pour représenter cette contrainte avec une formule logique, on peut d'abord voir comment écrire la partie droite : le chat est avec la balle de tennis. Avec nos variables, deux possibilités s'offrent à nous : $$v_{ch}$$ et $$v_t$$ sont vraies en même temps ou bien $$s_{ch}$$ et $$s_t$$ sont vraies en même temps. On va donc modéliser cette partie par : $$(v_{ch} \land v_t) \lor (s_{ch} \land s_t)$$.

Le reste de la formule est facile à modéliser car il s'exprimer facilement à partir des variables définies. On obtient donc :

$$ v_g \rightarrow ((v_{ct} \land v_t) \lor (s_{ct} \land s_t))$$

### Contrainte 2

On remarque que la contraint 2 a la même forme que la première. Cela nous permet d'écrire les formules sans trop de peine. On obtient :

$$ s_{ct} \rightarrow ((v_{cn} \land v_t) \lor (s_{cn} \land s_t))$$

### Contrainte 3

La contrainte 3 est légèrement différente. En effet, la partie gauche de l'implcation est cette fois similaire à la partie droite. Cela tombe bien, on a déjà vu comment la modéliser. On obtient :

$$ ((v_{cn} \land v_f) \lor (s_{cn} \land s_f)) \rightarrow ((v_t \land v_l) \lor (s_t \land s_l))$$

### Contrainte 4

La contrainte 4 reprend le même principe que la précédente :

$$ ((v_{ct} \land v_f) \lor (s_{ct} \land s_f)) \rightarrow ((v_t \land v_g) \lor (s_t \land s_g))$$

### Contrainte 5

La contrainte 5 apporte une petite différence. Cette fois, la partie droite de l'implication signifie qu'un objet ne doit pas être avec un autre. Pour modéliser cela, rien de plus simple, il suffit de rajouter une négation sur une des deux variables ou encore utiliser la variable correspondant à l'autre personne. On obtient par exemple :

$$ ((v_g \land v_f) \lor (s_g \land s_f)) \rightarrow ((v_t \land \neg v_{ct}) \lor (s_t \land \neg s_{ct}))$$

###  Contraintes additionnelles

Il reste encore à ajouter certaines contraintes qui n'apparaissent pas dans l'énoncé. En effet, il  parait évident et ce n'est pas précisé qu'une personne possède un seul des deux objets de chaque type et que les deux personnes ne peuvent pas posséder le même objet. Il n'y a cependant rien qui empêche cela dans les variables. De plus, rien n'oblige les personnes à posséder un des deux objets.

Pour forcer une personne à ne posséder qu'un seul des deux objets, on peut ajouter des contraintes du style :

$$\neg(personne_{objet1} \land personne_{objet2})$$

Pour empêcher un objet d'appartenir à deux personnes, la contrainte est très similaire :

$$\neg(personne1_{objet} \land personne2_{objet})$$

Enfin, pou qu'une personne possède au moins un objet, on ajoute des contraintes du genre :

$$\neg(personne_{objet1} \lor personne_{objet2})$$

> Certaines contraintes sont peut-être redondantes. Cependant, la modélisation n'est pas fait pour être parfait, elle doit seulement décrire de la manière la plus exacte possible le problème.
{: .prompt-info }

## Résolution

Nous avons donc tous les éléments pour résoudre le problème. Cependant, vous vous demander ce que l'on va faire de toutes ces formules, car le problème SAT s'exprime avec une seule formule. Et bien ce que l'on cherche à obtenir c'est des valeurs pour nos variables telles que **toutes** les formules soient satisfaites en même temps. Pour les satisfaire, il suffit de les ajouter à la suite en utiliser des **et** logiques. On obtient donc la formule suivante :

$$
    \begin{align*}
		&v_g \rightarrow ((v_{ct} \land v_t) \lor (s_{ct} \land s_t)) \land \\
        &s_{ct} \rightarrow ((v_{cn} \land v_t) \lor (s_{cn} \land s_t)) \land \\
        &((v_{cn} \land v_f) \lor (s_{cn} \land s_f)) \rightarrow ((v_t \land v_l) \lor (s_t \land s_l)) \land \\
        &((v_{ct} \land v_f) \lor (s_{ct} \land s_f)) \rightarrow ((v_t \land v_g) \lor (s_t \land s_g)) \land \\
        &((v_g \land v_f) \lor (s_g \land s_f)) \rightarrow ((v_t \land \neg v_{ct}) \lor (s_t \land \neg s_{ct})) \land \\
        &\neg(v_{g} \land v_{l}) \land \\
        &\neg(v_{f} \land v_{t}) \land \\
        &... \land \\
        &\neg(v_{g} \land s_{g}) \land \\
        &\neg(v_{l} \land s_{l}) \land \\
        &... \land \\
        &v_g \lor v_l \land \\
        &s_f \lor s_t \land \\
        &...
	\end{align*}
$$


# SAT dans mon stage

Pfiuou ! ça fait beaucoup non ? Il y aurait encore énormément de choses à dire sur SAT mais je voulais présenter le principal pour pouvoir parler de ce que je fais en stage.

Je l'annonçais dès le début, on s'intéresse à SAT car les solvers qui permettent de résoudre les formules sont extrêmement efficaces. L'intuition de mes encadrants, derrière la proposition de stage à laquelle j'ai répondue, est qu'en déterminant un encodage SAT intelligent pour les problèmes sur lesquels ils travaillent, ils allaient pouvoir être plus performants et résoudre plus de problèmes.

Justement, ces problèmes je ne les ai pas encore présentés. J'y viendrais la prochaine fois et cela me donnera l'occasion de présenter un peu les travaux de mon équipe. Et je vous promet, ils font des trucs bien stylés!
