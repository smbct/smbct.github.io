---
layout: post
title:  "Présentation du stage"
date:   2018-03-10 10:00:00 +0200
categories: stage bioinfo communication
comments: true
---

Diantre ! Tenir un journal est plus compliqué que je ne le pensais. Avant de rédiger la prochaine entrée, je devais absolument présenter en détails le sujet sur lequel je travaille. C'est maintenant que ça se passe !

## Faire de l'informatique pour la biologie

Pas facile de voir comment l'informatique peut nous aider pour faire de la biologie. Et c'est justement cette première impression qui limite les possibilités de projets scientifiques interdisciplinaires. Il y a une sorte de paradoxe entre le fait que la recherche scientifique concerne toujours un domaine ultra spécifique qui limite notre vision des choses et l'esprit de la science qui pousse à la curiosité et à aller voir ce qui se fait un peu partout. Faire le pas de s'ouvrir permet de découvrir des choses intéressantes. Pour ce qui est de la bioinfo, on peut déjà justifier l'informatique par le fait qu'on accumule de plus en plus de données et qu'il faut des méthodes efficaces pour analyser ces données. Mais ce n'est pas la seule utilisation et on va voir ici qu'un ordinateur et un organisme vivant, bah... c'est pas si différent finalement !


## La biologie des systèmes

J'en parlais précédemment, l'équipe de recherche dans laquelle je travaille s'intéresse au domaine de la biologie des systèmes. La biologie des systèmes est une discipline de la biologie qui étudie l'intéraction entre les différents composants d'un système. On ne s'intéresse donc pas au fonctionnement précis de chaque de composant et de la physique ou de la chimie qui s'y cache. On considère que le composant peut être dans différents *états* et que certains composants lorsqu'ils sont dans des états spécifiques vont forcer d'autres composants à changer leurs états.

Le but est donc d'étudier la dynamique d'un réseau, qui peut être par exemple constitué de gènes ou de protéines. Ce genre de système présente donc un aspet temporel. L'idée est de partir d'un état global donné pour le système, où chaque composant sera dans un état spécifique (par exemple, un niveau d'expression pour un gène). Une fois cette état global initial fixé, on peut analyser l'évolution du système. En fonction des états de certains composants, les autres composants vont pouvoir évoluer dans d'autres états et ainsi de suite. Ce genre de comportement peut voir émerger des propriétés étonnantes qui sont éventuellement à l'origine de comportements non désirés de l'organisme.

![Un exemple de réseau de régulation de gènes](/assets/RRB.png)

## Des problèmes difficiles

Les réseaux sur lesquels nous travaillons sont **discrets**. Cela signifie que les composants biologiques peuvent uniquement se trouver dans des états bien distincts. Autrement dit, n'autorise pas un composant a se trouver dans un *mélange* de deux états.

Cette simplification grossière à première vue est en fait vraiment utile pour décrire certains comportements du système. L'hypothèse assez forte qu'on soutient ici est que différents fonctionnements de l'organisme peuvent s'expliquer uniquement avec les intéractions entre les composants et même sans avoir besoin de décrire avec une extrême précision les comportements de ces composants.

Cette abstraction ne simplifie pas complètement pour autant l'analyse des réseaux. Un premier challenge est la création de ces réseaux. Pour découvrir cette structure, il n'y a pas énormément d'options, il faut utiliser des donneés. Les données en question sont typiquement des séries de données temporelles, qui indiquent le comportement des différents composants de l'organisme au cours du temps (voir l'exemple ci-dessous). Deviner à partir de ces données quels organismes intéregissent entre eux n'est pas quelque chose d'évident. Mon équipe travaille donc sur des techniques d'apprentissages qui discrétisent les niveaux d'expression des composants et qui infèrent automatiquement les règles d'intéractions entre ces composants.

![Exemple de séries de données temporelles](/assets/time_series.png)

La construction des réseaux de régulations biologiques n'est pas la seule problématique étudiée. Les biologistes peuvent ensuite se poser des questions sur le fonctionnement même du système. Par exemple, il est intéressant de savoir si partant d'une configuration initiale, le réseau est capable **d'atteindre** une configuration dans laquelle on retrouve certains composants dans des niveaux d'expressions bien précis. La difficulté de ce problème réside dans le nombre potentiel de fonctionnements possibles du système. En effet, si chaque composent peut être dans deux états, on se retrouve en théorie à explorer un nombre d'état de l'ordre de 2 à la puissance le nombre de composants. L'ordre de grandeur est exponentiel, une analyse exhaustive n'est donc pas envisageable. Un autre problème que les bioinformaticiens essaient de résoudre est la recherche des attracteurs. Ces derniers sont des ensembles d'états à partir desquels il est impossible de s'échapper. Cela signifie qu'une fois que le système arrive dans un mode de fonctionnement correspondant à un de ces états, il ne pourra plus revenir en arrière.

## Des problématiques concrètes

Derrières ces questions assez spécifiques se cachent des problématiques fondamentales en biologie ainsi que des applications pratiques. Par exemple, un des projets de recherche financé qui portait une partie des travaux de l'équipe concernait l'horloge circadienne. Ce projet avait pour but notamment de comprendre les mécanismes d'horloge de certains être vivants.

Pour le côté pratique, étudier les comportements des réseaux biologiques peut avoir des intérêts dans le domaine de la santé. Par exemple, les chercheurs de l'équipe ont essayé d'appliquer leurs résultats aux challenges [DREAM](http://dreamchallenges.org/). Ces challenges proposent de travailler sur des problématiques liées à la biologie et à la santé sous forme de compétitions. L'approche utilisée par l'équipe pour ces challenges se voulait originale puisque les modèles qu'ils utilisent apportent de la connaissance supplémentaire par rapport à des techniques d'analyse de données plus communes.

## Et moi dans tout ça

Venons-en à mon stage. Je travaille sur l'analyse des réseaux de régulation biologiques en utilisant les modèles discrets établies par l'équipe. Mon but est donc de développer des méthodes efficaces permettant de résoudre les problèmes dont je parlais plus haut. Ces méthodes doivent être suffisamment efficaces permettre d'analyser des réseaux de très grande taille.

Je disais au début de l'article qu'un ordinateur et un réseau biologique ne sont pas forcément très différents. Je vous propose de revenir un peu sur cela. Pour commencer, tout un domaine de l'informatique se concentre sur l'étude et la vérification de systèmes informatiques tels que les logiciels embarqués (dans les avions par exemple). On voudrait évidemment éviter qu'un bug provoque un [crash :D](https://www.youtube.com/watch?v=PK_yguLapgA). Or tracker les bugs d'un système est quelque chose de très difficile. Pour cette raison, les chercheurs ont développé des méthodes automatiques pour certifier l'absence de ces bugs. Ces méthodes appartiennent au champ des méthodes formelles et du model checking et les problématiques posées sont parfois exactement les mêmes que celles des biologistes concernant les réseaux décrits dans cet article.

Il faut bien voir que les systèmes étudiés, qu'ils soient informatiques ou biologiques, ont un peu la même nature. A l'instare des composants biologiques qui peuvent être dans différents états, un logiciel utilise une mémoire qui va retenir les états de différents éléments et ce système va également évoluer dans le temps, avec des intéractions entre les différents éléments.

Une des approches qui s'est montrée particulièrement efficace pour résoudre ces problèmes est l'encodage en SAT des problèmes. Cette approche se base sur l'efficacité des solvers SAT, comme j'en parlais dans le dernier article. C'est donc pour cela que je me base sur un encodage en SAT pour traiter les problèmes d'analyse des réseaux biologiques. Pour le moment, je me suis donc concentré sur une première modélisation qui représente en fait sous forme d'une formule logique l'évolution du réseau pour un certain nombre d'étape. Cette modélisation permet déjà de résoudre certains problèmes mais elle est très coûteuse car les formules à résoudre sont très très grandes, y compris pour modéliser un petit nombre d'étapes. La suite de mon travail consiste donc à trouver des méthodes qui permettent de résoudre d'autres problèmes et également traiter les réseaux de grande taille. Et je n'en dis pas plus pour le moment, mais ce n'est pour l'instant pas les idées qui manquent !

### Crédit

- photo credit: <a href="https://figshare.com/articles/_gene_regulatory_network_between_adrb2_and_cancer_specific_genes_/1223385">Gene regulatory network between ADRB2 and cancer-specific genes. by Min Oh Jaegyoon Ahn Youngmi Yoon</a> <a href="https://creativecommons.org/licenses/by/4.0/">(license)</a>

- Jeu de données pour les séries de données temporelles emprunté [ici](https://www.ebi.ac.uk/arrayexpress/experiments/E-GEOD-78215/?query=circadian)
