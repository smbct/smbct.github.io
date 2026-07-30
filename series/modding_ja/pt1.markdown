---
title:  Modding Jedi Academy with the Kinect&#58 Origins of the project
author: smbct
date:   2026-07-25 10:00:00 +0200
categories: modding 
tags: programming modding video-games virtual-reality
comments: true
layout: series_article
series: modding_ja
back_page: headline.md
lang: en
---

[Jedi Knight 2: Jedi Academy](https://en.wikipedia.org/wiki/Star_Wars_Jedi_Knight:_Jedi_Academy) is a Star Wars game released in 2003 by [Raven Software](https://en.wikipedia.org/wiki/Star_Wars_Jedi_Knight:_Jedi_Academy). I am currently modding this game to incorporate [pose tracking](https://en.wikipedia.org/wiki/3D_tracking) capabilities with the Wiimote (or Joy-Con) and the Kinect. For this reason, I am starting this series as a dev blog of the mod 🗒️. In this post, I will explain the origin of the project and why I consider it as still relevant as of today in 2026.


<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![The Jedi Academy game.](https://media.moddb.com/cache/images/games/1/1/71/thumb_620x2000/Star-Wars-Jedi-Acadamy-9.jpg)
<div class="custom_caption" markdown="1">
\> The Jedi Academy game. Image from [moddb](https://www.moddb.com/games/star-wars-jedi-academy).
</div>
</div>

# Preamble

The year is 2006. Nintendo releases its revolutionary game console, the [Wii](https://en.wikipedia.org/wiki/Wii), alongside the [Microsoft Xbox 360](https://en.wikipedia.org/wiki/Xbox_360) and the [Playstation 3](https://en.wikipedia.org/wiki/PlayStation_3). At the center of its gameplay, the Wiimote (or Wii remote controller) invites the player to use their gesture in addition to the buttons to control video games 🕹️.

<div style="display: block; margin-left: auto; margin-right: auto; width: 40%;" markdown="1">
![The wiimote with the nunckuck extension.](https://upload.wikimedia.org/wikipedia/commons/thumb/7/73/Nintendo-Wii-Remote-wNunchuck.jpg/1920px-Nintendo-Wii-Remote-wNunchuck.jpg)
<div class="custom_caption" markdown="1">
\> The wiimote with the nunckuck extension. Image from [wikipedia](https://en.wikipedia.org/wiki/Wii_Remote).
</div>
</div>

The Wiimote may actually not be seen as an actual revolution since pointing devices 🫵 were already used in the so called [light-gun shooter games](https://en.wikipedia.org/wiki/Light-gun_shooter) long before its release. The motion sensing features of the Wiimote however did seem to be a renewal in the game industry at that time. Its success was followed by some efforts from Microsoft and PlayStation to provide a similar experience respectively through their [Kinect](https://en.wikipedia.org/wiki/Kinect) and [PlayStation Move](https://en.wikipedia.org/wiki/PlayStation_Move).

Gesture recognition in video games seems to remain popular in 2026 as some controllers keep integrating motion sensing devices. For instance, the [Joy-Con](https://en.wikipedia.org/wiki/Joy-Con) accompanying the [Nintendo Switch](https://en.wikipedia.org/wiki/Nintendo_Switch) presents capabilities that are similar to the Wiimote and PlayStation's [Dual Sense](https://en.wikipedia.org/wiki/DualShock#DualSense) controller also integrates several motion sensors. As I mentioned in my [Kinect]({{ site.baseurl }}/blog/kinect_tracking/) post, modern [Virtual Reality](https://en.wikipedia.org/wiki/Virtual_reality) devices are also equipped with several sensors for pose tracking.

When the Wii was released, I was as a young nerd inevitably fascinated by the technology 🤩. I was actually rather interested in understanding the technology than I was in playing the associated video games. It became particularly interesting to me when I discovered on the web that the Wiimote could be used on a computer 🖥️! 

# The Wiimote on the pc

Instead of simply owning a Wii console at that time, I would only by a Wiimote for experimenting on a pc and study how it works ⚙️. Connecting the Wiimote is [fairly simple](https://www.digitalcitizen.life/how-to-connect-a-wii-remote-to-a-pc/) as it only requires a [Bluetooth](https://en.wikipedia.org/wiki/Bluetooth) dongle 🛜. The level 0 of using the Wiimote then consisted of a simple mapping between the buttons of the remote and the keyboard ⌨️. This could be performed with softwares such as [GlovePie](https://vrarwiki.com/wiki/GlovePIE) and [HID Wiimote](https://www.julianloehr.de/educational-work/hid-wiimote/) so that the remote could be used as a controller for pc games or even as a mouse pointer. A mapping was also possible between the Wiimote' accelerometers and standard joystick axes 🕹️, enabling the use of the motion sensing capabilities in games supporting joysticks (as a wheel for racing games for instance 🏎️).

Such mapping between the Wiimote and conventional game inputs was good enough for gesture in some applications such as racing games but the integration of the Wiimote remained limited as pc games were not prepared for it 👾. As a cheap device compared to profesionnal equipment, the Wiimote was however a great tool for research and experiments 🧑‍🔬 as it has been demonstrated by [several projects](http://johnnylee.net/projects/wii/) from Johnny Chung Lee and by academics works such as the [Linux Laptop Orchestra](https://www.nime.org/proceedings/2010/nime2010_170.pdf).

Coming back to video games, things become especially interesting if we focus on the world of modding. [Videogame modding](https://en.wikipedia.org/wiki/Video_game_modding) consists in modyfying an existing game to add new features such as maps, levels and so on.. In 2007, a developer named PJG2005 released a [mod](https://www.moddb.com/mods/half-life-2-wiimote-mod) for the game [Half-Life 2](https://en.wikipedia.org/wiki/Half-Life_2) that integrated the Wiimote and the Nunchuck (its main extension) in a native manner. 

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![The configuration menus for the Wiimote in the mod in Half-Life 2.](https://media.moddb.com/cache/images/mods/1/9/8775/thumb_620x2000/57525.jpg)
<div class="custom_caption" markdown="1">
\> The configuration menus for the Wiimote in the mod in Half-Life 2. Image from [moddb](https://www.moddb.com/mods/half-life-2-wiimote-mod).
</div>
</div>

Although the mod was only released in beta version, it really provided the true experience of a [First Person Shooter](https://en.wikipedia.org/wiki/First-person_shooter) game on the Wii. I was fascinated when I discovered this development. The old video bellow (in french) gives a good overview of the various features in the mod.

<div style="padding-bottom: 56.25%; position: relative;"><iframe style="position: absolute; top: 0px; left: 0px; width: 100%; height: 100%; border: 0px;" width="100%" height="100%" src="https://www.dailymotion.com/embed/video/x1nx0g" allow="accelerometer; encrypted-media; gyroscope; picture-in-picture; fullscreen" title="Media Embed"><small>Propulsé par <a href="https://embed.tube/fr/embed-code-generator/dailymotion/">embed dailymotion</a></small></iframe></div>

This very video actually put me on the track of this project. I was impressed by the responsiveness of the Wiimote and its seamless integration into the original game ✨.

# Star Wars games with pose tracking

Like many Star Wars enthusiastic, I was dreaming of the perfect Star Wars gaming experience thanks to the Wiimote. Obviously, the first thing that comes in mind is the possibility to perform lightsaber combats from real gestures 🤺! Wii players became excited when [Star Wars: The Clone Wars – Lightsaber Duels](https://en.wikipedia.org/wiki/Star_Wars:_The_Clone_Wars_%E2%80%93_Lightsaber_Duels) was announced in 2008 as they could hope for the Wii [lightsaber experience](https://www.slashfilm.com/499634/finally-a-lightsaber-wii-video-game/). Unfortunately, the game simply [did not meet the players expectations](https://www.ign.com/articles/2008/11/13/star-wars-the-clone-wars-lightsaber-duels-review) and it was not well received ❌. The developers themselves announced that this was not going to be a real swordplay game but the marketing inevitably made its way into the players' minds...

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![Star Wars: The Clone Wars – Lightsaber Duels was received as a missed opportunity from the fans.](https://www.nintendo.com/eu/media/images/migration/games_7/screenshots/wii_13/starwarsclonewars/TethBridge_OWK_v_AV6.jpg)
<div class="custom_caption" markdown="1">
\> Star Wars: The Clone Wars – Lightsaber Duels was received as a missed opportunity from the fans. Image from [nintendo](https://www.nintendo.com/en-gb/Games/Wii/Star-Wars-The-Clone-Wars-Lightsaber-Duels-283267.html#Overview).
</div>
</div>

[The Force Unleashed](https://en.wikipedia.org/wiki/Star_Wars:_The_Force_Unleashed) and [The Clone Wars: Republic Heroes](https://en.wikipedia.org/wiki/Star_Wars:_The_Clone_Wars_%E2%80%93_Republic_Heroes) games were also good candidates for the Wiimote but its technology was simply not sufficient for providing the experience players were hoping for 🎮 (that I would also discover by myself at some point 😅).

## And outside of the Wii world ?

As I mentioned earlier in this post, Microsoft released the **Kinect** device in response to Nintendo for providing a similar experience in Xbox games. The Kinect was also a good opportunity for Star Wars games. [Kinect Star Wars](https://en.wikipedia.org/wiki/Kinect_Star_Wars) released in 2012 once again provided hope to the players but the result [was still deceiving](https://www.ign.com/articles/2012/04/03/kinect-star-wars-review) 🤷. Pose tracking was however [better achieved](https://www.youtube.com/watch?v=w7tDxiZCfwE) with the Kinect than it was with the Wiimote for reasons that I will detail later in this post. At the end, something was still missing 🗋.

What about now in **2026** ? To my knowledge, there has not been any additional Star Wars game on a console that utilizes motion tracking. However, with the advent of Virtual Reality Devices for gaming in the 2015's, there has been a revival of the Star Wars pose tracking gaming enthusiasm. A [small list](https://starwars.fandom.com/wiki/Category:Virtual_reality_games) of VR games is available but they seem to be only experimental demos or minigames. They still made a [good impression](https://gamesbeat.com/virtual-reality-has-finally-let-me-live-my-star-wars-dream/) around the gaming community

A more concrete line of action has actually been conducted from the modding community. Contributions have been made in two different directions 🔁. Some mods would turn an existing VR game into a Star Wars game. This has been done on [Blade & Sorcery](https://en.wikipedia.org/wiki/Blade_%26_Sorcery) for creating [The Outer Rim](https://www.nexusmods.com/bladeandsorcery/mods/528) mod and in [Skyrim Special Edition](https://en.wikipedia.org/wiki/The_Elder_Scrolls_V:_Skyrim) with the [Star Wars Redux VR](https://www.nexusmods.com/skyrimspecialedition/mods/88569) mod that recreates the [Battlefront](https://en.wikipedia.org/wiki/Star_Wars:_Battlefront) experience in Virtual Reality.

The other way around, *i.e.*, turning an existing star wars game into a VR one, appears more interesting to me as it does not require to re-create the entire universe from scratch 🖼️. This has been achieved for instance on the game [Jedi: fallen order](https://en.wikipedia.org/wiki/Star_Wars_Jedi:_Fallen_Order). The mod from pande4360 is named [UEVR Profile 6DOF Motion Combat](https://www.nexusmods.com/starwarsjedifallenorder/mods/828) and seem to provide a native and complete VR experience of the original game 👍. After digging a little bit to understand how it was done, I found that Jedi: fallen order was actually made in the game engine [Unreal Engine](https://en.wikipedia.org/wiki/Unreal_Engine) and that the mod was made using the [UEVR framework](https://github.com/praydog/UEVR), a general toolkit for converting games based on this engine into VR.

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![The Jedi: fallen order VR mod](https://staticdelivery.nexusmods.com/mods/3061/images/828/828-1754351439-1082356261.png)
<div class="custom_caption" markdown="1">
\> The Jedi: fallen order VR mod. Image from [nexusmods](https://www.nexusmods.com/starwarsjedifallenorder/mods/828).
</div>
</div>

And now that becomes interesting. Another game that has been modded for VR is actually Jedi Academy 😲! Along with Jedi Knight II, its predecessor, [Team Beef](https://www.teambeefvr.com/) released a [complete VR mod](https://sidequestvr.com/app/15472/jk-xr-jedi-knight-in-vr-meta-quest) (rather called a VR port) that is also [open source](https://github.com/Team-Beef-Studios/JKXR)! The team actually released this type of port for dozens of games. However, as close as it may be to my original idea 💡, this did not stop me from experimenting with my own vision for reasons I will also explain. Lastly, although this is not a mod I wanted to mention this ongoing [fan remake](https://x.com/vr_jedi) of Jedi Knight II into a modern VR game. The current result is pretty nice but I am still believing that a complete remake is not reasonable considering the amount of work that is required here 🫠.  

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
<iframe width="600" height="461"
src="https://www.youtube.com/embed/cvpl9I3cDD0">
</iframe>
<div style="margin-top:8px;">
<div class="custom_caption" markdown="1">
\> The Jedi Academy VR mod almost achieves what I had in mind.
</div>
</div>
</div>

To sum up, the VR modding/developing community has been extremely productive and creative in the recent years. Even Half-Life 2 got his own [VR port](https://halflife2vr.com/) for an experience that may not be far from the 2007 Wiimote mod. Drifting off-topic 💨 I must mention here the [VR mod](https://crementif.github.io/BotW-BetterVR/) for [Zelda Breath Of The Wild](https://en.wikipedia.org/wiki/The_Legend_of_Zelda:_Breath_of_the_Wild) that I found while writing this post. The mod is [open-source](https://github.com/Crementif/BotW-BetterVR) and Crementif, its author, gives a fair amount of details about its creation 📝 (I desperately wanted to learn more about it). The mod is actually built upon the Wii U version of the game on a PC emulator. Among other aspects, it uses a manipulation of the PowerPC machine instructions of the game to [hook](https://en.wikipedia.org/wiki/Hooking) C++ functions that alter its behavior and add the VR features. I would not imagine the amount of work and technical skills required to reverse engineer the game engine from assembly instructions. Impressive work 👏!

# My idea with Jedi Academy

Now coming back to my project. When I thought about it in the 2010's, my idea was to create a mod to play Jedia Academy with the Wiimote, similarly to the old Half-Life 2 Wiimote mod experience. Witnessing the unability of editors at that time to release a true lightsaber gaming experience with gesture recognition 🥷, I was willing to solve this disturbance in the force 😎. For me, Jedi Academy is a perfect game for experimenting with this gameplay. I am biased as I was actually playing it but its saber combat already feel smooth and the game in general feel responsive.

Also the game is both a First Person and a Third Person Shooter. I imagined this as integrating a FPS mod similarly to the one of the Half Life 2 mod and adding a Wiimote based lightsaber combat on top of that ⚔️. I started from nothing as I did not know how to program at that time but I was sufficiently motivated to learn along the way 📚. For multiple reasons, this project was unfortunately simply not feasible at this moment 🙅. The idea resurfaced years later for some reasons and I became once again motivated to give it a try. Obviously, I looked at the recent contributions and the existence of a VR mod for Jedi Academy mod did not stop me for two reasons:

- 1) VR games are always played as First Person but the Third Person lightsaber view in JA is really part of the game identity in my opinion. Motion tracking in this perspective still appears to me as an innovation. 

- 2) Despite the rapid progress of the VR market, the technology is still expensive and not well spread. Apparently, the amount of gamers that use VR [is estimated](https://www.demandsage.com/virtual-reality-statistics/) between 5% and 10% only. This is so much an issue that someone even made a [NO-VR mod](https://www.moddb.com/mods/half-life-alyx-novr) for the VR-only game [Half-Life: Alix](https://en.wikipedia.org/wiki/Half-Life:_Alyx). Putting aside the headset feature, motion tracking only can rely on cheap and mass consuming devices such as the Wiimote.

This was enough motivation for me to pursue this modding idea lately. I will now further describe what I learned and the choice I made from the old idea many years ago to an actual development more recently 📅. 

## Focus on the Wiimote technology and its limits

Making a motion tracking based gameplay requires to actually understand the sensing technology. The motion recognition capabilites from the Wiimote can be divided into two parts :

* The **pointing** device: the Wiimote has an infrared camera at its front that detects infrared sources such as the one coming from the Wii [sensor bar](https://wiikipedia.fandom.com/wiki/Wii_Sensor_Bar) (the name was indeed misleading). This feature allows to use the Wiimote as a pointer. It was notably used in [first person](https://en.wikipedia.org/wiki/The_Conduit) [shooter games](https://en.wikipedia.org/wiki/Metroid_Prime_3:_Corruption) where the gun freely moves around the screen before turning the camera as it get close to the borders.

* The **motion** device: the Wiimote is equipped with 3-axis accelerometers. This enables to **partially** detect the orientation of the Wiimote. This feature was used intensively in [Wii Sports](https://en.wikipedia.org/wiki/Wii_Sports) in the form of a precise motion tracking (e.g. golf) or a simple gesture/strength detection (e.g. boxing). 

The Nunchuck, Wiimote's main extension, is also equipped with accelerometers, allowing for the same motion recognition capabilities. A strong limitation of theses devices is the lack of sensors for a full tracking of its orientation 📏. More particularly, it was not possible at that time to track the "yaw" angle of the Wiimote because this one is not subject to gravity (see picture bellow).

<div style="display: block; margin-left: auto; margin-right: auto; width: 60%;" markdown="1">
![The "yaw pitch roll" orientation system illustrated on the Wiimote.](https://reso-nance.org/wiki/_media/projets/smashword/synopsys-android-virtual-prototyping-part-3-fig-12-.jpg)
<div class="custom_caption" markdown="1">
\> The "yaw pitch roll" orientation system illustrated on the Wiimote. Image from [reso-nance.org](https://reso-nance.org/wiki/projets/smashwords/dev/accueil).
</div>
</div>

To counter these limitations, Nintendo released the [Wii Motion Plus](https://en.wikipedia.org/wiki/Wii_MotionPlus) in 2009 as a pass-through extension module for the Wiimote 🥳. The Motion Plus contains a 3-axis gyroscope that completes the information from the accelerometers with angular velocities. This [video](https://www.youtube.com/watch?v=ZirGW_64kzk) shows how angles can be partially extracted from the accelerometers only and this [one](https://www.youtube.com/watch?v=V5p23OTXn7E) illustrates how the combination of accelerometers and gyroscopes achieved "full" orientation tracking (drift remains possible nonetheless).


## Modding Jedi Academy, then and now

Modding can be a very tough experience depending on the game that is tackled 🤔. It can go from modifying a small 3d model or few lines of scripting code to a whole reverse engineering journey the the depth of the game. Fortunately, an official [Software Development Kit (SDK)](https://jkhub.org/files/file/1137-jedi-academy-sdk/?tab=reviews) was released early on for the game. However, the SDK was only released for the multiplayer mode 👥 of the game whereas I was specifically interested in the single-player mod. This original SDK contains a small coding tutorial 📝 to make a simple mod and I remember playing with it a little bit back then 🧙. Not all the code was available at that time so the possible contributions were actually limited 😔. Impressively, someone was however able to implement [rigid body physics](https://jkhub.org/forums/topic/4754-physics-for-openjk/) in the game! 

What happened then? In 2013, as Disney decided to shut down [LucasArts](https://en.wikipedia.org/wiki/Lucasfilm_Games) 📦, Raven Software decided to release [the full source code](code.idtech.space/raven/jediacademy) of the game. [OpenJK](https://github.com/JACoders/OpenJK) then became the main project that maintains the code. The project is still active in 2026 and a large amount of work has been done to modernize and adapt the game for modern hardware and software!

This changed everything as it became really feasible to make the mod 😃! At that time, I had however lost interest in the project and the idea of catching up barely crossed my mind. I regained some interest in the project much more recently and decided to play with the code again. I had switched to Linux long before so the OpenJK port was the perfect occasion to use the tools that I enjoy most in the project 🧑‍💻. At that period, I made significant progresses in implementing the First Person Shooter gun mod 🔫 with the Wiimote but I did not really keep track of my progress and the code was messy. I started thinking about ligthsaber combats ⚔️ but after a while, I realized that this was simply not possible to exclusively rely on the Wiimote. Indeed, even if the Wiimote is able to output its absolute orientation, other skeleton joints such the elbow and the shoulder 💁 cannot be tracked in any manner 🦾.

After reviewing the options, I ended up thinking that including the Kinect in my project was actually the best I could do, which is the reason I wrote a [blog post](({{ site.baseurl }}/blog/kinect_tracking/)) about it. Wiimote+Kinect makes a great duo since the Kinect cannot track the wrist and misses some classical gamepad buttons 🎮. I bought a ridiculously cheap unit of the Kinect v1 and I started experimenting with the code. I made good progresses at understanding the skeletal positioning 🩻 in JA code and how to pass joint information from the Kinect to the game 📡. Unfortunately, I had much trouble figuring out how to correctly position the joints and I ended up stuck again. 


# What about now?

My professional experience made me realize that if I wanted to make progress, I had to create a way to properly debug my code 🛠️. Sadly, debugging 3D geometry code can be tricky as matrices may not seem very explanatory when printed on the terminal... 🧑‍💻 My idea then was to introduce visual debugging features in the game (*i.e.*, drawing 3D shapes to understand my calculations), to help me figuring out the correct positioning procedure ℹ️. After that, I was able to correctly position the arm according to the Kinect tracking ✅. There is still much to do however to make it actually playable. For instance, there is no damage when moving the arm at the moment...

So I decided to create the series to document my progresses 🚧. My goal is to show technical details about the development but also give hints for not being stuck in such projects. The pace is  low but I have a lot of ideas for the following such as integrating the Joy-Con, using gesture for the force and so on... 🚀 Until the next post, the current version of my code is already [hosted on github](https://github.com/smbct/jamod)!


<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![Visual debugging and skeleton tracking in Jedi Academy.]({{ site.baseurl }}/assets/ja_mod/preamble.png)
<div class="custom_caption" markdown="1">
\> Visual debugging and skeleton tracking in Jedi Academy.
</div>
</div>