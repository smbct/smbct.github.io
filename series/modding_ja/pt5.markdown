---
title:  Modding Jedi Academy with the Kinect&#58 Integrating the Kinect 🎥
author: smbct
date:   2026-10-04 10:00:00 +0200
categories: modding 
tags: programming modding video-games virtual-reality
comments: true
layout: series_article
series: modding_ja
back_page: headline.md
lang: en
---

In the [last post]({{site.baseurl}}/series/modding_ja/pt4) of the series, I gave an overview of how to interact with Jedi Academy's bone positioning code.
In this new post, I will cover the integration of the Kinect camera in the game to control the characters with our own gesture! 

## The Kinect, why? 

The Kinect is a gaming device 🎮 released by Microsoft for its xbox consoles.
The device allows the user to control games with their own gestures.
The Kinect (more precisely its software) is actually able to predict a simplified 3D skeleton of the player 🩻.

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;">
<img alt="3d pose tracking illustration" src="https://www.researchgate.net/profile/Melvyn-Roerdink/publication/283536111/figure/fig1/AS:339855277084674@1458039220277/Body-points-derived-with-the-human-pose-estimation-software-of-Kinect-v1-A-RGB-image.png">
</div>
<div class="custom_caption" markdown="1">
\> An illustration of 3D pose tracking. Image by [Melvyn Roerdink](https://www.researchgate.net/publication/283536111_Kinematic_Validation_of_a_Multi-Kinect_v2_Instrumented_10-Meter_Walkway_for_Quantitative_Gait_Assessments).
</div>

I have covered the Kinects and other skeleton tracking solutions in [this post]({{site.baseurl}}/blog/kinect_tracking) few times ago.
As I explain in the [preamble]({{site.baseurl}}/series/modding_ja/pt1) of the series, although my initial idea was to use the wiimote only for the mod, I finally decided to integrate the Kinect.
Why? the Wiimote is simply not capable enough for the full tracking of the player's arm.
The Kinect is an old, cheap and functional solution to the skeleton tracking problem 💡 and I think its combination with the Wiimote makes the perfect motion tracking setup 🕺.

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![Skeleton tracking with the Kinect and OpenNI.]({{site.baseurl}}/assets/ja_mod/pt5/kinect_skeleton.png)
</div>
<div class="custom_caption" markdown="1">
\> Skeleton tracking with the Kinect and OpenNI.
</div>

In this post, I will start from the simple example from my [kinect post]({{site.baseurl}}/blog/kinect_tracking) and detail how I integrated the Kinect skeleton as an input to OpenJK's engine and control the player's arm!
Basically, my sample program was already able to extract the information about the skeleton: concretely positions and orientations of several body joints 🦴 (shoulder, elbow, torso, etc..).
I focused solely on the joints orientations that are expressed as rotation matrices (represented with the red-green-blue frames on the figure above).
I had to find a way to feed these matrices to OpenJK directly. 


## More about Jedi Academy's engine

### Engine's main loop

I mentioned in the previous posts that the engine is split between a **server** and a **client** part 🛜.
This separation exists in the single-player mode as well as the multi-player one 🤼🏼.
Having a look at the game's loop is useful to understand the synergy between these two parts.

The **main** function is in the `shared/sys/sys_main.cpp` file. The engine's main loop is clearly identified with a single function call: `Com_Frame();`.
This organization actually seems to be a rework from the OpneJK community as compared to the original [engine's architecture](https://code.idtech.space/raven/jediacademy/src/branch/master/code).
The `Com_Frame()` function contains several additional "frame" functions: `IN_Frame()`, `SV_Frame()` and `CL_Frame()`.
Names are self-explanatory: **in** corresponds to the user inputs events, **sv** is for the server and **cl** for the client.
So game inputs are notably processed in the input frame associated function but few additional steps are performed before these are actually sent to the server game, where the game logic happens.

### Game inputs

Where to start with the Kinect 📸? Integrating a new input device in a game engine is not easy. I needed to find a "suitable place" in the code to insert the new function calls.
I consider the Kinect skeleton data as a game **input** the same way the keyboard and mouse are ⌨️, so I started to look at how the user inputs are passed to the game Engine.
[Openjk](https://github.com/JACoders/OpenJK/)'s code is actually based on the [SDL library](https://www.libsdl.org/) for this aspect (contrary to the [original engine's code](https://code.idtech.space/raven/jediacademy/)). Luckily, I was already familiar with this library which made the understanding of the code easier.

In OpenJK's code, the SDL part is located in the `shared/sdl/sdl_input.cpp` file.
In this file, I found out that the SDL's mouse motion event is turned into a game engine's event through the function `Sys_QueEvent( 0, SE_MOUSE, e.motion.xrel, e.motion.yrel, 0, NULL );`.
Searching for `SE_MOUSE` 🖱️ throughout the code, I ended up finding the function `CL_MouseEvent([..])`, "CL" meaning "client".
This function has two different behaviors: ingame and menu display. I focused on the field `mouseDx` that seemed to refer to the latter case.
I additionally found the `CL_MouseMove(usercmd_t *cmd)` function that put me on the track of the command and message transmission system in the engine.

### Client - Server communication

The split between the client and the server makes things difficult as information does not transit easily between the two 🚝.
The game logic being mainly processed on the server side, the character control would also occur there and communicating the kinect matrices from one to the other is mandatory.
I spotted the `usercmd_t` structure in the `CL_MouseMove(usercmd_t *cmd)` function. It contains information that are sent from the client to the server, including the client inputs (that are transformed from the user input such as keys, mouse, etc..).
`usercmd_s` is defined in `qcommon/q_shared.h`. There I could find information about the direction angles of a player and the buttons that are pressed 🕹️.
By tracing the calls from function `CL_MouesMove`, I was able to find `CL_CreateCmd` and then `CL_CreateNewCommands`.
I ended up at function `CL_SendCmd()` that actually send the data through a call to `CL_WritePacket()`.
The relevant functions for adding information in the command are `MSG_WriteDeltaUsercmd(msg_t *msg, usercmd_t *from, usercmd_t *to)` and `MSG_ReadDeltaUsercmd(msg_t *msg, usercmd_t *from, usercmd_t *to)`.



## Adding the Kinect library

I decided to put all the kinect related code in a single file placed in the `shared` directory because it also contains the SDL code to manage game inputs.
The functions use OpenNI library that I presented in the [Kinect post]({{site.baseurl}}/blog/kinect_tracking).
I mainly re-used the [code sample](https://github.com/smbct/KinectOpenNISetup) that I wrote to perform skeleton tracking (initialization, update and data extraction).
I decided to store the Kinect data into global (static) objects in the file for simplicity (not quite elegant). 
I also placed the kinect update function in a separate thread because this function seemed blocking and caused some ingame framerate issues.

The init function is placed in the main function I mentioned earlier.
The update function is placed in the `Com_Frame()`, just after the input update call.
I also had to modify the `CMakeList` file to link the OpenNI library into the project.
With these elements, I could already setup the camera and extract the information inside the engine.

### From game inputs to the server

I focused on the `usercmd_t` data structure to pass the kinect joint information 🦾 to the game server.
I started by adding the two `3x3=9` float matrices inside the structure: one for the humerus rotation and one for the radius one (I assumed other bones would not be necessary and wanted to start with a single arm!).

I could spot the function `CL_CreateCmd(void)` from `cl_input.cpp` that is called from `CL_MouseMove`, and where I could store joint information from the kinect code to the command.
Then, I had to find and modify the functions `MSG_WriteDeltaUsercmd` and `MSG_ReadDeltaUsercmd` to actually write and read the bytes from the matrices.
These values are encoded in 32 bits as for some of the other fields.

### Actually animating the player

I found a place to receive the matrices information in the function `PM_UpdateViewAngles( playerState_t *ps, usercmd_t *cmd, gentity_t *gent )`, that takes the command as parameter and processes angle information from it.
Although the function takes as input a `playerState_t` structure, I ended up storing the matrices informaiton in class `PlayerStateBase.` And I do not remember exactly why but this was a place where I could recover the information when needed.

I finally found a way to control the player's arm movements in the function `void CG_G2PlayerAngles( centity_t *cent, vec3_t legs[3], vec3_t angles )`.
In this function, I could recover the matrices information from the `centity_t` parameter (`cent->gent->client->ps` 🥵) and call the function `BG_G2SetBoneAngles()` to actually control the arm.
Hence, I used the euler angles representation that I mentioned the [previous post]({{site.baseurl}}/series/modding_ja/pt4). The conversion between the rotation matrix and euler angles is however performed by the [Eigen library](https://libeigen.gitlab.io/) here for simplicity.

A difficult part here was to make sense of Jedia Academy's conventions, i.e., axis orders and signs.
I also had an annoying limitation by noticing that bone indices, required to call the "SetBoneAngles" function, were not all present.
I had to add the additional bones once again by modifying few structures and functions 🦴.
For most of the difficulties, I mainly looked at the engine's code to find hints.

And with all these steps that's it, it is now possible ton control jedi academy's player through the Kinect! 

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;" markdown="1">
![We can naturally control the lightsaber thanks to the Kinect.]({{site.baseurl}}/assets/ja_mod/pt5/kinect_saber.gif)
<div class="custom_caption" markdown="1">
\> We can naturally control the lightsaber thanks to the Kinect.
</div>
</div>

There are still few limitations at this point: we can see that the saber seems rigid. This is because the kinect v1 is not capable of tracking the wrist movement.
The Kinect v2 or other devices such as a Wiimote is required here to do it.
Another limitation comes from the code: in this configuration the saber does not cause any damages because they were accounted for only when the player presses the attack button! 
Last, but not least, the skeleton tracking can be used for weapons others than the lightsabler in the third person view but once again, the projectile trajectory has to be modified to account for the new game mod.

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;" markdown="1">
![We can control blasters as well.]({{site.baseurl}}/assets/ja_mod/pt5/kinect_blaster.gif)
<div class="custom_caption" markdown="1">
\> We can control blasters as well.
</div>
</div>

## Conclusion

I tried to give an overview of the steps needed to perform this modification without giving too much details.
This is probably not the best way to do it (for instance could we use directly rotation matrices? Is the PlayerStateBase the suitable place for the joint information?) but I was still able to produce a working solution on my own.
I will cover the integration of the Wiimote in the next post to address some of the limitations seen here.
By the time, that the source code remains available at [this repository](https://github.com/smbct/jamod).

