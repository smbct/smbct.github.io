---
layout: post
title:  "Plus court chemin et graphe"
date:   2016-09-03 18:00:00 +0200
categories: optimisation graphe
---

Visualisation : http://www.graphviz.org/

Encore graphe : http://veniceatlas.epfl.ch/atlas/gis-and-databases/named-entities/network-analysis-of-the-social-graph-of-venetian-citizens/

Trouver un chemin, ou même le plus court chemin, est un problème que l'on peut rencontrer assez souvent en informatique.
Parmis les applications concrètes de ce problème, on peut tout d'abord penser à l'itinéraire le plus court, donné par un dispositif gps par exemple.
Ce n'est cependant pas la seule application réelle de ce problème.
On peut par expemple chercher un plus court chemin pour une IA dans un jeu.

## Un problème facile ?

Le problème du plus court chemin est un problème très connu et très étudié.
En réalité, il y a pleins de problèmes différents de problèmes différents.
Certains peuvent être faciles à résoudre, comme le fait de trouver le meilleur itinéraire pour aller d'un endroit à un autre en voiture.
D'autres au contraire peuvent être extrêmement difficiles à résoudre, comme trouver le chemin le plus court passant par un ensemble de villes, pour effectuer des livraisons par exemple (problème du voyageur de commerce).
Nous allons voir ici un algorithme simple et efficace pour résoudre un problème similaire à celui de l'itinéraire.

## Présentation du problème

En informatique, lorsqu'on essaie de résoudre un problème, on se rend parfois compte qu'il est équivalent à un autre problème, plus connu mais qui ne semble rien n'avoir en commun aux premiers abords.
C'est le cas dans l'exmple montré ici. En effet, le problème initial ne ressemble à prioris pas à celui de la recherche de chemin.

Voici donc le contexte :

Imaginons que nous connaissons certaines personnes qui détiennent une même information cruciale que nous voulons récupérer. Le soucis est que ces personnes ne nous donneront pas ce message directement. En effet, elle ne font confience qu'à leurs amis et le confieront seulement à eux.

Si on considère notre cercle d'amis, nous sommes connectés à un certains nombre de personnes qui sont elles-même connectés à d'autres personnes par des relations d'amitié.
Notre défi est de récupérer cette information le plus rapidement possible.
Pour ce faire, nous allons donc demander à nos amis proches de demander a leurs amis de demander à leurs amis etc... jusqu'à ce qu'un personne lache l'information et la diffuse dans le sens inverse jusqu'à ce qu'elle revienne vers nous.

L'objectif est donc de trouver le lien le plus court entre nous et l'information, c'est à dire de trouver une suite de personne A - B - C - ... la plus courte telle que deux personnes successives sont amies, la première personne étant nous et la dernière étant une personne qui détient l'info.

## Détour par les graphes

Les données de notre problèmes constituent un réseau d'amis. Nous avons les noms des personnes, ainsi que leur relations, c'est à dire avec quelles autres personnes elle sont amies.
Une bonne façon de manipuler nos donnés est de les représenter sous forme d'un graphe.

Un graphe est un objet mathématique qui peut être utilisé pour manipuler des données comportant une relation.
Un graphe est constitué de sommets (ici les différentes personnes) et d'arêtes, qui représentent les liens entre les différents sommets (ici ce sont les liens d'amitié).

Pour manipuler le graphe dans notre algorithme, on peut définir un objet de type sommet. Cet objet contient le nom de la personne ainsi que la liste des sommets (personnes) auquel il est connecté. On lui ajoute également une variable booléenne indiquant si la personne détient ou non l'information.

## Algorithme de résolution

# Déroulement de l'algorithme

L'algorithme consiste à partir du sommet qui nous correspond dans le graphe.
A partir de ce sommet, on va demander à tous nos amis d'essayer de récupérer l'information. Ceux-ci vont alors demander à leurs amis de le faire et ainsi de suite.
Une seule règle doit être respectée : on ne demandera pas l'information à quelqu'un à qui on l'a déjà demandé (le on peut désigner n'importe qui).

L'algorithme va donc parcourir progressivement le graphe en partant d'un sommet et en s'éloignant de ce sommet d'une distance de 1 ami à la fois. En effet, la notion de distance est ici le nombre d'ami intermédiaire pour lier deux personnes dans le graphe.

# Dexu mots sur les files

L'algorihme que je propose pour résoudre ce problème utilise une structure de donnée appelée file. En quelque mots, une file est une liste d'élements. Elle contient un premier élément : la tête et un dernier élément : la queue.
Elle respecte également deux conditions : - lorsqu'un élément est ajouté à la file, il est ajouté à la fin et il devient ainsi la queue
                                            - le seul élément qui peut être consulté et retiré est le premier élément, c'est à dire la tête.

Cette structure de donnée est généralement appelée FIFO (First In First Out). En effet, dans une telle structure, c'est le premier élément ajouté dans la file qui sera retiré en premier.
Pensez donc à la file d'attente de la caisse d'un magasin. On ne peut s'insérer qu'à la fin de la file (en général!) et c'est personne arrivée la première qui est servie la première.

# Implémentation de l'algorithme

Comme dit plus haut, nous disposons dans notre algorithme d'un objet de type sommet qui représente une personne du réseau et qui contient l'information de ses amis.
L'algorithme débute donc avec l'insertion d'un premier sommet dans la file. C'est le sommet qui nous représente.

Ensuite, l'algorithme entre dans une boucle. Cette boucle est exécutée tant que la file n'est pas vide et que l'information n'a pas été atteinte.
à chaque itération, le sommet en tête de la file est retiré.
Suite à cela, les sommets qui lui sont connectés sont ajoutés à la fin de la file. On n'ajoute cependent parmis ces sommets seulement ceux qui n'ont pas déjà été étudiés (il faut donc garder l'information des sommets qui ont été étudiés, avec un tableau de booléen par exemple).
Ce processus est répété jusqu'à ce que l'info soit trouvée dans un noeud étudié, ou bien jusqu'à ce que la file soit vide. Dans ce dernier cas, cela signifie que l'information n'est tout simplement pas présente dans le réseau d'amis, ou bien pas atteignable.

# Exemple pas à pas

# Optimalité du résultat

Il n'est pas forcément évident au premier abord que l'algorithme donné résoud bien le problème.
Cet algorithme est en fait une algorithme de parcours en largeur de graphe.
Il consiste à visiter dans l'ordre les sommets de distance croissant au sommet d'origine. Cela signifie donc qu'au début de l'algorithme on viste tous nos amis directs. Ensuite, on visite tous les amis de nos amis et ainsi de suite. En faisant cela, on tombera bien sur la personne la plus proche pour récupérer l'info.

Maintenant, cela ce traduit dans l'implémentation par l'utilisation de la file. En effet, l'idée de la file est que les sommets insérés à la fin seront traités en dernier. Au début de l'algorithme, en insérant tous nos amis, on s'assure que nos amis directs seront étudiés avant tous les autres. Lorsque ces amis là sont étudiées, on va commencer à ajouter des amis d'amis, donc des personnes à une distance de 2 amis de nous. Ceux-ci étant insérés à la fin de la file, il seront donc étudiés qu'une fois que tous les amis directs l'auront été. Une fois que tous les amis directs ont été étudiés, tous les amis d'amis auront été ajouté à la file et donc on est assuré que les personnes à une distance de deux amis seront étudiés avant ceux à une distance de 3.

# Code
