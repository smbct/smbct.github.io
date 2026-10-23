---
title:  Modding Jedi Academy with the Kinect&#58 Integrating the Wiimote 🎮
author: smbct
date:   2026-10-20 10:00:00 +0200
categories: modding 
tags: programming modding video-games virtual-reality
comments: true
layout: series_article
series: modding_ja
back_page: headline.md
lang: en
---

In the [last post]({{site.baseurl}}/series/modding_ja/pt5) of the series, I explained how I integrated the Kinect skeleton tracking in the game engine.
Playing with the Kinect only as the game controller is rather limited even if several star wars games already proposed the experience.
The Wiimote brings fills missing pieces of the mod for the best experience: buttons and additional motion tracking.
I will detail here how I integrated this device 🎮 in OpenJK.

## What is the Wiimote?

The Wiimote is Nintendo Wii's official controller, released in 2005 together with the console.
It has a remote shape and contains several buttons, including a trigger.
It also supports several extensions, the nunchuck being the main one with its joystick 🕹️. 

<div style="display: block; margin-left: auto; margin-right: auto; width: 40%;" markdown="1">
![The wiimote with the nunckuck extension.](https://upload.wikimedia.org/wikipedia/commons/0/07/Nintendo-Wii-Remote-wNunchuk.jpg?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=original)
<div class="custom_caption" markdown="1">
\> The wiimote with the nunckuck extension. Image from [wikipedia](https://en.wikipedia.org/wiki/Wii_Remote).
</div>
</div>

Most importantly, the Wiimote has several motion control sensors in order to bring a new gaming experience.
I already [covered the different sensors]({{site.baseurl}}/series/modding_ja/pt5) (accelerometers and IR camera) in the preamble of the series as well as the gyroscope introduced by the [Wii motion](https://en.wikipedia.org/wiki/Wii_MotionPlus) plus (Wm+) extension.

<div style="display: block; margin-left: auto; margin-right: auto; width: 40%;" markdown="1">
![On the right: a classical Wiimote with the Wm+ passthrough extension. On the left: the newer Wiimote with the integrated Wm+.](https://upload.wikimedia.org/wikipedia/commons/f/f6/Wii_Remote_Motion_Plus_comparison.jpg?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=original)
<div class="custom_caption" markdown="1">
\> On the right: a classical Wiimote with the Wm+ passthrough extension. On the left: the newer Wiimote with the integrated Wm+. Image from [Wikipedia](https://en.wikipedia.org/wiki/Wii_MotionPlus).
</div>
</div>

I explained in the last post that despite having the Kinect integrated, the orientation of the wrist ✊ is still missing for this new gaming experience.
For this reason, I focused on exploiting the accelerometers and gyroscopes data to compute a global orientation of the Wiimote.

Regarding the IR camera, I decided to not use it at all ⛔. Although this sensor is interesting in the first person shooter view that Jedi Academy also offers, the setup will probably not work out with the Kinect and Wiimote simultaneously because the Kinect already emits an infrared source 🤷.

<div style="display: block; margin-left: auto; margin-right: auto; width: 40%;" markdown="1">
![The "yaw pitch roll" orientation system illustrated on the Wiimote.](https://reso-nance.org/wiki/_media/projets/smashword/synopsys-android-virtual-prototyping-part-3-fig-12-.jpg)
<div class="custom_caption" markdown="1">
\> The "yaw pitch roll" orientation system illustrated on the Wiimote. Image from [reso-nance.org](https://reso-nance.org/wiki/projets/smashwords/dev/accueil).
</div>
</div>

So the main task here was to find a way to exploit the Wiimote information (sent over Bluetooth) through a C++ library.
One difficulty is that the Wiimote does not directly outputs its orientation to a program.
It rather send raw or preprocessed accelerometers data (relatively to gravity) and gyroscope data (angular speed on the 3 yaw-pitch-roll directions).


## The Wiimote on linux, how to ?

Using the Wiimote on linux (and other OS) has been intensively documented soon after the release of the device.
Several libraries appeared for all platforms but I only focus on Linux here.
Many of them are actually [listed on wiibrew](https://wiibrew.org/wiki/Wiimote/Library).
I decided to use [Wiiuse](https://github.com/rpavlik/wiiuse), a C library that basically gives access to all the Wiimote functionalities ⚙️, including its Wm+ extension that I needed in the project.

It is also worth mentioning [XWiimote](https://xwiimote.github.io/xwiimote/), a younger alternative that is actually implemented in the Linux kernel!
It may seem surprising but drivers are now also available for the switch's Joycon!
Using XWiimote could be more interesting in the mod since the Wiimote can be connected outside of the game process, a much more comfortable mode when developing the mod.
It also has a better design principle that I will mention hereafter, but I decided to stick to wiiuse for now.

I additionally wanted to mention [Dolphin's emulator](https://fr.dolphin-emu.org/) work around the Wiimote.
Their emulated driver actually contains the code needed to exploit the motion sensors in almost every possible way 🫨.
They also wrote an interesting article about [the Wii motion +](nb.dolphin-emu.org/blog/2019/04/26/mastering-motion/).
This piece of information is valuable because exploiting the raw motion data is not easy.

### Estimating the Wiimote angles

Having access to the Wiimote's button is trivial but exploiting its sensor information poses a serious challenge.
Libraries such as Wiiuse actually gives access to either raw sensor values or to a simple and imperfect [processed model](https://www.youtube.com/watch?v=ZirGW_64kzk). 
For this project, I needed to obtain a full orientation of the wiimote, as a rotation matrix or even 3 angles (the representation does not matter).
I understood after some research 📚 that I needed both the gyroscope (wm+) and the accelerometers data to obtain an orientation of the Wiimote.
However, the combination is not trivial.
The web is full of [threads about this problem](https://stackoverflow.com/questions/1586658/combine-gyroscope-and-accelerometer-data) and I could see complicated notions such as [Kalman](https://en.wikipedia.org/wiki/Kalman_filter) or [Complementary](https://ahrs.readthedocs.io/en/latest/filters/complementary.html) filters 🧑‍🔬.
The system that combines both sensors actually has its own name: [Inertial Measurement Unit](https://en.wikipedia.org/wiki/Inertial_measurement_unit).

Unfortunately, despite seeing plenty of documentation about the problem, I could not find an easy-to-use-implementation that could be applied to the Wiimote.
Code samples were often too simple, too complex or would not contain enough details so that I could adapt them 🧑‍💻.
Even searching specifically for samples for the Wiimote did not help me find a suitable solution.
[This video](https://www.youtube.com/watch?v=V5p23OTXn7E) that I mentioned in the [preamble]({{site.baseurl}}/series/modding_ja/pt1) is actually one of the only example that I could find and the code seems not available anymore 😭.
One library that appeared several time though was [Fusion](https://github.com/xioTechnologies/Fusion).
It seemed a good option at first: an open source code that is well documented and widely used.
However, I have never been able to make it work correctly the the Wiimote in my tests. 
I made another attempt by exploiting the code from [JoyconLib](https://github.com/Looking-Glass/JoyconLib) a library to use the Joycon library in Unity (joycons have a similar pair of accelerometers/gyroscope sensors).
I thought I had the solution but the it was still imperfect.
The prediction would not follow the real orientation in some of the rotations, and it was once again unsatisfying and not suitable 😰.

<div style="display: block; margin-left: auto; margin-right: auto; width: 40%;" markdown="1">
![JoyconLib was almost the solution](https://camo.githubusercontent.com/49b547707bf36f902ce0e23460a06953919044aa6d5926b6bb74ffb6fbf68c64/68747470733a2f2f692e696d6775722e636f6d2f426256365372672e676966)
<div class="custom_caption" markdown="1">
\> JoyconLib was almost the solution. Image from [github](https://github.com/Looking-Glass/JoyconLib).
</div>
</div>

The solution finally came out of LLM's. 
It is still important for me in 2026 to produce the code of this mod by myself but AI 🤖 remains very good sometimes to put in the right direction.
Although I believe that this technology is mainly not beneficial for humans (because of its energetic and social implications), I was desperate enough to give it a try for the mod.
My initial goal was to correct the Joyconlib's code to obtain a more realistic orientation.

So I described my problem in ChatGPT. My initial attempt was to produce an orientation from the gyroscope only, just to see if I could get rid of the odd behavior that I observed before.
It produced a simple solution with Eigen, as I asked, that integrates the angular speed values from the gyroscope into an `angleAxis` object.
I missed that the gyroscope offset values could be directly interpreted as a vector around which the rotation is performed, definitly not intuitive! 

The second part of the solution came from Gemini. I was still not able to use the accelerometer data to correct the pitch and roll drift from the gyroscope with chatGPT.
My initial idea then was to "correct" the gyroscope-estimated orientation from the yaw angle so that the resulting orientation is directly comparable to the acceleration vector. 
Gemini produced a simple solution once again.
It turned out that a simple cross product was sufficient to compute a correction that is independant of the yaw rotation. Once again, not intuitive 🤷!
These two solutions, gyroscope integration and accelerometer correction, resulted as the perfect compute routine for the Wiimote rotation estimation code in the mod.
I released a [sample code](https://github.com/smbct/wiimote_IMU/tree/main) in github with opengl so that it is available to anyone that encounters this problem in the future.

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;" markdown="1">
![We can control blasters as well.](https://github.com/smbct/wiimote_IMU/blob/main/output.gif?raw=true)
<div class="custom_caption" markdown="1">
\> The Wiimote/wm+ orientation estimation algorithm in action.
</div>
</div>

At this point, the solution is already viable but things does not stop here because the Wiimote solution suffers from one issue: the Wiimote is not capable of keeping an absolute reference its yaw orientation. This results in an inevitable drift over this angle after some use time 🕙, as a consequence of accumulating small errors each time a new angular speed data is processed from the gyroscope.
I potentially identified a more annoying issue from Wiiuse itself that I mention in the code sample [README](https://github.com/smbct/wiimote_IMU/blob/main/README.md).
The Wiimote data is received through bluetooth as packets but the gyroscope data in Wiiuse are read asynchronously by the user.
This may cause issues because the time is measured between two accesses but the same values may be accounted for several time.
Apparently, the **XWiimote** library does not have this issue (gyroscope data is accessed in an event based manner).
It would probably be better to migrate to this library in the future but the current code is still functional enough for the development.

The good thing is that the method is also compatible with the Joycons as they rely on accelerometers and gyroscopes as well.
This may also be usable with the new version of the joycons, the [Joycon2](https://en.wikipedia.org/wiki/Joy-Con#Joy-Con_2), that additionally contains [a megnotometer](https://www.reddit.com/r/GyroGaming/comments/1td86u3/switch_2_controllers_now_have_9axis_support_on_pc/).
The magnetometer could be used to correct the drift on the yaw angle and I bet that a simple additional cross-product like correction would be possible to do it here.



## The Wiimote and nunchuck in OpenJK



### Wiimote code and initialization

Having integrated the Kinect [in the previous post]({{site.baseurl}}/series/modding_ja/pt5) makes the Wiimote integration quite simple.
I started the same way by adding a source file dedicated to the Wiimote in the "shared" directory.
The file contains functions to initialize the Wiimote through the wiiuse library, access its input data and compute its orientation.
The wiiuse object is stored as a static object like the kinect one.

<div style="display: block; margin-left: auto; margin-right: auto; width: 90%;" markdown="1">
![The custom menu for the wiimote connection.]({{site.baseurl}}/assets/ja_mod/pt6/wiimote_menu.png)
<div class="custom_caption" markdown="1">
\> The custom menu for the wiimote connection.
</div>
</div>

I placed the wiimote initialization code in the same place as the Kinect one in `sys_main.cpp`, easy!.
The same was done for the update function that checks the buttons status and process the motion tracking data. 

The wiiuse library also requires to connect to the Wiimote using a blocking function with a timeout parameter.
I added a custom menu in the game specifically to add a `connect` button for the wiimote.
The wimmote connection function is called from `ui_main.cpp`, where I can test if the button is clicked.
The function runs once again in a separate thread so that the blocking behavior does not disturb the game display. 
I then use a **Cvar** (client variable): `cl_wiimotestatus` to updatz the UI when the wiimote status changes.

### Adding the buttons

For the integration of the wiimote buttons, I manly read the SDL code of OpenJK where keys and mouse buttons are handled.
I was able to find the `Sys_QueEvent` function that is called to notify the game that a given key is pressed.
I modified the `fakeAscii_t` structure in `client/keycode.h` to add entries for the wiimote and nunchuck buttons.
I could also specify an ascii name of the button in the `keyname_t` data structure, in `cl_keys.cpp`.

<div style="display: block; margin-left: auto; margin-right: auto; width: 90%;" markdown="1">
![The input menu gives access almost natively to the new input buttons.]({{site.baseurl}}/assets/ja_mod/pt6/buttons_menu.png)
<div class="custom_caption" markdown="1">
\> The input menu gives access almost natively to the new input buttons. 
</div>
</div>

And that's it! The integration is performed on top of the input event system and all of its machinery is already compatible with these additional buttons.
Even the input menu is able to update and display correctly the wiimote buttons! If only this could be always as easy!

### Adding the orientation

Passing the wiimote orientation matrix mentioned above to OpenJK may seem to be a significantly harder task than handling the buttons but most of the work was actually already done in the Kinect case.
The rotation matrix is computed in the wiimote update function the same way that it is described above.
The matrix is retrieved and sent to the game server side in `CL_CreateCmd()` and it is received in `PM_UpdateViewAngles()` similarly than the kinect matrices.

The rotation finally occurs in `PM_UpdateViewAngles()`.
It was however hard to find the relevant skeleton bone to control the saber (or any other weapon 🔫).
After several trial-and-errors, I was however able to identify `rhang_tag_bone` that works for the saber as well as other weapons.

⚠️ An important thing to note about the Wiimote orientation: additionaly to the possible drift, the wiimote has no absolute reference about the yaw angle.
This means that we need to decide where it points in the first place in the game.
I assumed that the pointing direction would be the direction of the player view, assuming the player points the Wiimote in the direction of its screen in it is initialized.

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;" markdown="1">
![Kinect+Wiimote control of the lightsaber.]({{site.baseurl}}/assets/ja_mod/pt6/kinect_wiimote.gif)
<div class="custom_caption" markdown="1">
\> Kinect+Wiimote control of the lightsaber.
</div>
</div>


<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;" markdown="1">
![Kinect+Wiimote control of a blaster.]({{site.baseurl}}/assets/ja_mod/pt6/wiimote_kinect_weapon.gif)
<div class="custom_caption" markdown="1">
\> Kinect+Wiimote control of a blaster.
</div>
</div>

## Conclusion

With the Wiimote control and the wrist movement, the mod is now almost playable.
There are still several limitations: additional modifications are required to account for the saber damages.
Apparently, the game engine dose not keep track of the damages when the saber is not in an attack (which seems reasonable actually).

Another issue is the lack of movement of the hand when the saber moves.
This is purely cosmetic but achieving this turns out to be difficult.
The hand is composed of several bones but they are not connected to a single "wrist" anchor.
As a result, it does not seem to be possible to simply orient the hand with a rotation matrix 😥.
For now I don't see any solution to improve that point.

I have not mentioned the other weapons here but the rotation of the wiimote is still relevant.
However, with these modifications, it becomes necessary to change the trajectory of the shots. By default, the shot is always performed in the direction of the screen center.
I also plan to make a first person version of the control, at least for the other weapons.
With these elements, the mod should be already playable.
