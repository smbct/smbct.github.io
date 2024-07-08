---
title:  Soutenir sa thèse en comodal en 2022
author: smbct
date:   2022-04-26 18:00:00 +0200
categories: astuces
tags: these doctorat covid comodal
comments: true
layout: post
lang: fr
---

Une soutenance de thèse est un évènement particulier que l'on ne veut absolument pas louper en tant que doctorant/futur docteur. Il s'agit en effet de convaincre le jury de thèse de la qualité de ses contributions scientifiques, mais également de faire bonne figure devant sa famille et ses amis ! Des répétitions sont évidemment au programme afin de proposer la présentation de ses travaux la plus claire et fluide possible, tout en respectant les 45 minutes qui nous sont accordées pour la présentation.

Cependant, covid oblige, les soutenances ont quelque peu évolué depuis 2020. Par chance, ma soutenance ayant eu lieu en mars 2022, j'ai eu la possibilité de la réaliser dans un amphithéâtre contrairement à d'autres qui ont été contraint de la faire depuis leur maison... Celle-ci était ouverte au public, à l'instar de la quasi totalité des soutenances. Par ailleurs, comme presque tous les doctorants qui soutiennent désormais, j'ai dû  m'adapter à la présence de 2 membres de mon jury (sur 6) en distanciel. Cela m'a donné l'occasion de réfléchir avec plusieurs amis à une installation garantissant la meilleure expérience possible. Voici donc quelques pistes pour soutenir sa thèse à l'ère covid.

# Organisation de la soutenance

Les soutenance de thèse suivent généralement la même organisation. Le doctorant défend son travail devant un public composé du jury, dans les premiers rangs, et de personnes extérieures. La soutenance se déroule en deux parties. La première partie consiste en une présentation de 45 minutes sur les travaux réalisés et la deuxième partie, qui enchaîne directement et pouvant durer plusieurs heures, consiste en une série de questions posées par chacun des membres du jury. Suite à ces questions a lieu la délibération du jury. Dans mon cas, la délibération a eu lieu dans l'amphithéâtre ce qui a contraint toutes les personnes extérieures au jury à le quitter. Enfin, lorsque la délibération est terminée, toutes les personnes retournent dans l'amphithéâtre pour l'annonce des résultats.

Au niveau du co-modal, il y a donc plusieurs précautions à prendre. Dans un premier temps pour la présentation, il faut un moyen de filmer le doctorant et d'en capter le son pour les personnes à distance. Mais ce n'est pas tout. Puisque le jury participe également à la soutenance, il est nécessaire de capter le son et la vidéo des membres du jury en présentiel pour les personnes à distance. Enfin, il est nécessaire de retransmettre dans l'amphithéâtre le son et la vidéo des membres du jury en distanciel. Pour l'annonce des résultats à la fin de la délibération, il peut également être intéressant de filmer le jury et le doctorant en même temps. De manière générale, l'organisation entre le jury et le doctorant demande ainsi d'être capable de filmer et capter le son à deux endroits différents dans l'amphithéâtre, et à retransmettre dans tout l'amphithéâtre le son et la vidéo des membres à distance.

# Matériel disponible et installation générale

Ma soutenance de thèse s'est déroulée dans un amphithéâtre dans lequel il y avait un peu de matériel à disposition. Au niveau du matériel, l'amphithéâtre était équipé avec un vidéoprojecteur, des enceintes et plusieurs micros. Il était possible d'utiliser les enceintes et le vidéoprojecteur à partir d'un pc via un câble HDMI. Par ailleurs, il n'y avait pas la possibilité de récupérer le signal des micros en entrée dans un ordinateur car celui-ci était simplement envoyé dans les enceintes de l'amphi. Enfin, il y avait également un système de vidéo-conférence nomade avec un écran, une caméra, un micro et une enceinte.


# Solution mise en place

La solution mise en place a le défaut d'être complexe mais celle-ci a relativement bien fonctionné le jour de la soutenance. Je vais découper les différents aspects en plusieurs parties, et j'ai ajouté un schéma récapitulatif de l'installation à la fin du billet. Pour commencer, j'ai effectué ma présentation de soutenance sur un pc portable équipé d'ubuntu, avec un support de présentation pdf généré par beamer (powerpoint version LaTex). Pour la partie distanciel, j'ai créé une réunion Zoom gérée sur mon ordinateur de présentation.

## Privilèges Zoom

Premier détail important, il a fallu trouver un moyen d'empêcher les personnes extérieures au jury d'activer micro ou caméra pendant la présentation. Par chance, une option permettait de le faire dans la réunion Zoom avec le compte Zoom utilisé (option sécurité). Malheureusement cette option empêche tout le monde d'activer son son/image, y compris le jury. Pour y remédier, nous avons fait passé les 2 membres à distance en co-hôtes afin qu'ils soient les seuls à pouvoir communiquer. Par sécurité, une personne supplémentaire m'avait aidé en gardant un œil sur le Zoom durant toute la soutenance.

## Le son

Concernant le son, je n'ai pas eu besoin de micro pour amplifier la voix. La difficulté principale consistait par ailleurs à capter à la fois mon son et celui du jury à l'intérieur de l'amphi. Le plus simple est d'utiliser deux micros via deux ordinateurs connectés à la même réunion Zoom (ou en utilisant le système de vidéoconférence nomade disponible dans l'amphhi), mais lors des tests, cette solution conduisait à un echo et un effet larsen très nuisible. Pour y remédier, j'ai décidé d'utiliser deux micros usb connectés sur mon pc, et mixés au niveau logiciel. Pour la partie logiciel, j'ai trouvé la solution [ici](https://askubuntu.com/questions/868817/collecting-and-mixing-sound-input-from-different-microphones). Par contre, cette solution est valable uniquement si le jury n'est pas trop éloigné, car les câbles usb sont limités à 5m (on pourrait aussi utiliser un micro sans fil ceci dit). Au niveau de la retransmission dans l’amphithéâtre, le son du Zoom était directement envoyé par mon pc dans les enceintes en HDMI.

## L'image

Concernant la retransmission de l'image, j'ai utilisé deux caméras : une pour moi et une pour le jury. Me concernant, j'avais prévu d'utiliser un appareil photo réflexe en tant que webcam pour la présentation (car la batterie ne tient pas beaucoup plus de 45 minutes), et de switcher sur la webcam du pc ensuite. La solution logicielle est [ici](https://maximevaillancourt.com/blog/canon-dslr-webcam-debian-ubuntu). Pour le jury, c'est la webcam du système Zoom nomade qui a été utilisée (le système était donc connecté à la réunion Zoom de la soutenance). Cette caméra s'est révélée pratique car elle se contrôlait via une télécommande gérée par la personne qui s'occupait également du Zoom. Concernant les membres à distance, l'image était envoyée sur le système Zoom nomade. Les personnes à distance n'étaient donc pas visibles pour tout le monde dans l'amphi mais nous avions considéré que ce n'était pas essentiel car ils étaient entendus à partir des enceintes.

Enfin, ma présentation pdf était projetée via le vidéoprojecteur et partagée via le partage d'écran Zoom. J'ai utilisé le super programme [pympress](https://github.com/Cimbali/pympress) afin de dupliquer les slides sur mon écran de pc, pour ne pas avoir à me retourner. Ce programme permet notamment d'avoir un timer, de visualiser les slides suivantes et d'utiliser un pointeur virtuel. Au niveau du pointeur, c'est justement celui de pympress que j'ai utilisé car un pointeur laser physique n'aurait pas été visible pour les personnes à distance. Pour ce faire, j'ai utilisé un clavier et une souris posés sur une table haute juste devant moi, ce qui me permettait de rester un minimum mobile (contrairement à si j'avais été assis). J'ai par ailleurs également réalisé un petit [fork](https://github.com/smbct/pympress.git) de pympress après coup afin de rajouter une fonctionnalité intéressante pour les animations beamer.


![Schéma de la soutenance](/assets/schema_soutenance.png)
Schéma de l'installation de ma soutenance.

# Bilan et améliorations possibles

De manière général, j'ai été très content de cette installation, et la soutenance s'est très bien déroulée. J'ai seulement eu quelque soucis au début car je n'arrivais pas réaliser le mixage des deux micros (un reboot a résolu le problème), et l'appareil photo réflexe n'a pas fonctionné (j'ignore pourquoi et je suis donc passé à la webcam du pc directement). Ces désagréments m'ont malheureusement fait oublier d'activer le partage d'écran via Zoom au début de la soutenance, ce qui a vite été corrigé grâce à la manifestation d'une personne du jury à distance. J'avais par ailleurs prévu d'enregistrer la présentation en utilisant la fonction de Zoom mais ces soucis techniques m'ont également fait oublier de lancer l'enregistrement.

Au niveau des améliorations, je pense que la partie logicielle est trop sensible car le moindre soucis technique peut rendre la soutenance infaisable. Le plus intéressant me semble l'utilisation des deux micros, même si nous avons également testé la soutenance à un seul micro qui pouvait fonctionner également. Pour améliorer l'installation, on peut imaginer utiliser une table de mixage à laquelle serait relié les différents micros, et même avoir un micro cravate pour gagner en mobilité, mais cela demande plus de matériel. Il serait également intéressant d'avoir un pointeur laser à la fois physique et numérique mais cela semble compliqué à mettre en place en pratique.

Évidemment, une soutenance plus simple aurait largement été possible mais je dois avouer que nous avons été pris au jeu de proposer le mise en place la plus intéressante possible. Dans tous les cas, pensez à privilégier la simplicité afin d'éviter les pannes de dernière minute. La répétition de son installation permet également de ne pas avoir à réfléchir aux aspects techniques le jour de la soutenance, afin de se concentrer sur le contenu de la présentation.
