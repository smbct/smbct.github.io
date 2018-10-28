---
layout: post
title:  "Journal d'un thésard : JDT #0 - Intro"
date:   2018-10-28 20:00:00 +0200
categories: these
comments: true
---

ça y est ! me voilà doctorant désormais ! Il y a eu un gros creux entre la fin de mon stage et mon début de thèse, mais voilà un petit résumé de mon boulot.

# Fin de stage et galères

Dans le dernier billet sur le stage, j'évoquais pas mal de travail à venir et des résultats intéressants. Autant dire que ça ne s'est pas tout à fait passé comme on l'espérait :D

Pour resituer le contexte, mon stage consistait à proposer une nouvelle méthode pour résoudre un problème fondamentalement compliqué : comprendre par là qu'aujourd'hui encore on n'est pas capable de résoudre ce problème dans tous les cas, en particulier lorsque les données du problèmes sont très grandes.

à mon arrivée dans l'équipe de recherche, on possédait déjà une méthode de résolution incroyablement rapide. Le soucis : la méthode n'est pas applicable sur n'importe quel modèle. Le but était donc de développer une méthode alternative qui marcherait sur les exemple sur lesquelles l'autre ne fonctionne pas. Pour cela, le thème était de proposer une transformation du problème en un autre problème. C'est l'encodage SAT dont j'ai déjà parlé. Il y a plusieurs transformations possibles et j'en ai rapidement mis en place une assez simple.

Cependant, mon principal soucis était que ma méthode n'est pas complète. J'entends par là qu'elle peut donner une réponse pour certains exemples mais pas pour tous. C'est donc le même problème qu'avec l'autre méthode, à quelques subtilités près. En fait, le problème que nous avons étudié a comme réponse soit oui, soit non. C'est dans le cas où la réponse est non que la méthode que j'ai développé ne permet pas de conclure. C'est donc à partir de ce soucis que je me suis lancé dans la recherche d'une "borne", un indicateur permettant de prouver que la réponse est bien non. Et c'est sur ce point que j'ai passé le plus de temps pendant le stage.

Plusieurs soucis sont apparus pour cette partie. Tout d'abord, il fallait mettre en place une méthode de calcul pour cette borne. Ensuite, il fallait proposer une preuve pour expliquer pourquoi elle fonctionnait (quand on travaille dessus, on utilise l'intuition mais ça ne veut pas dire que le calcul marche tout le temps). J'ai donc réussi à proposer une preuve mais mon soucis a été que le calcul ne fonctionnait pas tout le temps. Pire, dans le plupart des cas, il n'était pas possible. J'ai pendant longtemps cherché une variante, mais rien à faire. Je suis arrivé à la fin du stage avec une méthode inapplicable en pratique et le projet de publication que l'on avait n'a pas pu aboutir. J'ai quand même présenté mes résultats de stages qui ont plu malgré tout. Dans la foulé, nous avons fait une demande de bourse pour que je fasse un doctorat dans la même équipe de recherche. Et puis voilà, 2 mois de vacances plus tard c'est parti !

# Début d'un doctorat

J'ai donc commencé un doctorant en informatique, et plus particulièrement en bio-informatique. Je ferais un billet dessus prochainement mais le thème est toujours en rapport avec ce que fait l'équipe de recherche, à savoir la modélisation en biologie des systèmes. On étudie donc des modèles, de nature logique (les plus simples en un sens) avec un aspect temporel.

Contrairement à mon stage, la thèse se concentre sur la partie apprentissage. Les biologistes sont capables d'obtenir beaucoup de données, mais les méthodes d'analyse ne sont pas toujours efficaces. Notre objectif est donc de proposer des algorithmes et méthodes permettant de reconstruire des modèles logiques à partir de ces données. En particulier, je m'intéresse dans ma thèse à la prise en compte de "meta-propriétés" dans l'apprentissage. Par exemple, nous disposons d'une information supplémentaire sur le système, qui a un impacte sur plusieurs paramètres à la fois. Le challenge consiste à essayer apprendre le modèle tout en considérant cette information.

# Mes occupations actuelles

En ce moment, je fais des milliards de choses ! Le début de thèse est très intense, pour plusieurs raisons. Voilà un petit listing de mes activités.

## Recherche

Côté recherche, c'est assez simple. Le but de ces premiers mois de thèse est de conclure ce que j'ai fait en stage. Pour ça, j'écris actuellement ma première publication scientifique. J'ai également continué à travailler sur ma méthode de borne. J'ai des nouveaux éléments et j'ai des idées pour étendre le calcul au cas général. Je ne pense cependant pas avoir de nouveaux résultats avant la deadline de la publication, mais nous allons soumettre le papier dans tous les cas. On croise les doigts pour qu'ils soit accepté !

## Enseignement

On propose généralement aux doctorants de faire de l'enseignement pendant leur thèse. Il n'y a pas d'exception ici et j'ai tout de suite accepté. Je suis donc chargé de TP dans des cours d'algorithmique et de maths appliqués pour ce semestre. Je ne suis pas tout seul en prof pendant les séances mais ça représente tout de même énormément de travail. En plus de la préparation du TP et des séances, il faut après les corriger et faire des retours aux étudiants. Malgré tout, ça reste super intéressant et j'apprécie beaucoup. Nous songeons d'ailleurs à me faire intervenir, plus tard dans la thèse, dans l'option bio-informatique des étudiants. J'aimerais faire un cours type conférence en présentant des résultats de recherche.

## Médiation scientifique

En parallèle, j'ai toujours pour but de m'investir dans la médiation scientifique. Mes raisons sont encore les même mais je me rend de plus en plus compte de la nécessité d'expliquer comment fonctionne les algorithmes les plus utilisés aujourd'hui, ceux qui sont en général lié à ce qu'on appel l'IA. J'ai eu l'occasion d'animer un atelier pour les portes ouvertes de l'école où je travaille. C'était très intéressant malgré une organisation difficile et un premier essai pour lequel tous n'a pas parfaitement marché. J'ai d'autres idées pour faire de la médiation et je ne compte pas m'arrêter là. Le blog est un autre moyen que je voudrais garder et c'est pour cela que je tente de le maintenir à jour.

# La suite

Les semaines qui viennent seront chargées. Je travaille en ce moment sur la publication et je dois m'occuper de corrections de TP. J'ai également une grosse part d'administratif. Je suis donc assez pressé que cette période se termine. J'ai envie de passer à la partie "apprentissage" de la thèse pour changer de sujet et aussi voir de plus près l'application à la biologie. Ces éléments devront arriver dans les mois qui viennent et j'ai hâte.
