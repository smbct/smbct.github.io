---
title:  Kinect pose tracking on Linux in 2025
date:   2025-07-15 10:00:00 +0200
categories: hardware
tags: programming hardware low-level
comments: true
layout: post
lang: en
back_page: /index.html
---

**Full body tracking**, or pose tracking, skeleton tracking, etc.. is a hardware 📷 and software technology used for producing a virtual three dimensional representation of a person's body in real time 🕺.
This technology recently gained my interest for a video game modding project 🎮. 
However, capturing the body movements in real time is not an easy task and a combination of specialized hardware 📷 and software 💾 is necessary to achieve it.

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;">
<img alt="3d pose tracking illustration" src="https://www.researchgate.net/profile/Melvyn-Roerdink/publication/283536111/figure/fig1/AS:339855277084674@1458039220277/Body-points-derived-with-the-human-pose-estimation-software-of-Kinect-v1-A-RGB-image.png">
</div>
<div class="custom_caption" markdown="1">
\> An illustration of 3D pose tracking. Image by [Melvyn Roerdink](https://www.researchgate.net/publication/283536111_Kinematic_Validation_of_a_Multi-Kinect_v2_Instrumented_10-Meter_Walkway_for_Quantitative_Gait_Assessments).
</div>

As I was looking for a cheap and reliable solution, I spent some time reviewing and compare existing methods 👀.
In this blog post 📃, I will expose multiple options that I found to solve this problem.
I will particularly focus on the **Kinect** 🎥, a gaming device developed by [Microsoft](https://fr.wikipedia.org/wiki/Microsoft).
We will explore what the device is actually capable of and we will see how to setup a working environment on Linux to develop for the Kinect and actually perform 3D tracking.
This topic will also give the opportunity to argument about open source, about the usability of consumer products and obsolescence 💬.

## Full body tracking starter guide 


There exist several technologies capable of performing body tracking:

- A first solution can be found around **V**irtual **R**eality devices.
Some allow for [full body tracking](https://pimax.com/blogs/blogs/pose-tracking-methods-outside-in-vs-inside-out-tracking-in-vr) but these devices remain [particularly expensive](https://www.vive.com/fr/product/).

- [Motion capture](https://en.wikipedia.org/wiki/Motion_capture) is another solution, mostly used in the cinema industry 🎬.
This solution may necessitate heavy hardware (multiple cameras) with additional body markers and is more relevant for professional applications.

- [Deep learning](https://en.wikipedia.org/wiki/Deep_learning) technologies may help here as well.
Some models allow for pose estimation from RGB cameras thanks to Convolutional Neural Networks, even in [real time](https://medium.com/augmented-startups/top-9-pose-estimation-models-of-2022-70d00b11db43). These software based solutions would however require high [GPU](https://en.wikipedia.org/wiki/Graphics_processing_unit) compute capabilities to perform fast neural network inference and reach a decent framerate. 

- Depth cameras are the last option that I found, the Kinect being one of them.
These devices use various type of imaging sensors for reconstructing depth images, where each pixel represents a distance to the camera.
Several devices [exist](https://www.intelrealsense.com/depth-camera-d435/) but once again, most of them are rather [expensive](https://store.intelrealsense.com/buy-intel-realsense-depth-camera-d435.html).

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;">
<a title="Marc Auledas, CC BY-SA 4.0 &lt;https://creativecommons.org/licenses/by-sa/4.0&gt;, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Intel_Realsense_depth_camera_D435.jpg"><img alt="Intel Realsense depth camera D435 mounted on a small tripod" src="https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Intel_Realsense_depth_camera_D435.jpg/256px-Intel_Realsense_depth_camera_D435.jpg?20210504180506"></a>
</div>
<div class="custom_caption" markdown="1">
\> The intel RealSense D435 device, another type of Depth camera. Image from [wikimedia](https://commons.wikimedia.org/wiki/File:Intel_Realsense_depth_camera_D435.jpg).
</div>

#### Looking for affordable options 💰

The advent of **VR** technologies has further encouraged the development of cheap and/or open source tracking solutions.
[Various solutions](https://vrheaven.io/full-body-tracking-quest/) have been imagined such as wearing sensors/markers or relying on webcams.
For instance the [kick-started](https://www.crowdsupply.com/slimevr/slimevr-full-body-tracker) open source [SlimeVR](https://slimevr.dev/) device is a camera-free solution based on a set of wearable sensors 👖.
Another example is actually the **Kinect**, considered as an old consumer device used by several [open source solutions](https://kinectvr.com/).

<div style="display: block; margin-left: auto; margin-right: auto; width: 60%;">
<img src="https://docs.slimevr.dev/assets/img/slimeVRTrackers.jpg" alt="SlimeVR wearable devices.">
</div>
<div class="custom_caption" markdown="1">
\> The wearable tracking devices from SlimeVR's solution. Image from [SliveVR](https://slimevr.dev/).
</div>


In the end, the **Kinect** appears to me as one of the most convenient and affordable option.
Indeed, the device can still be found today and have become particularly cheap.
However, a condition for the device to be usable is the availability of **drivers** and **libraries**.
This part is not easy as hardware and software is evolving fast and such devices, produced by profit companies, are mostly closed source and even safe-guarded 🔒!


## But **what** is the Kinect ? 📽️

The [**Kinect**](https://en.wikipedia.org/wiki/Kinect) is a 15 years old 👴 device developed by [Microsoft](https://fr.wikipedia.org/wiki/Microsoft) as a motion game controller for its Xbox 360 console.
More precisely, the Kinect enables the capture of a depth buffer and reconstruction of 3D skeleton of a player, allowing for precise interactions in virtual applications such as [video games](https://fr.wikipedia.org/wiki/Kinect_Sports).

The Kinect device was first presented at the [E3 2009](https://archive.org/details/microsoft-e3-2009) conference (as *Project Natal*) as a motion controller [in response to](https://en.wikipedia.org/wiki/Kinect) Nintendo's Wii Remote and Sony's PlayStation Move.
The device was presented as a webcam and was not intended to be used in combination with another physical device 🎮.
It has a microphone, a set of motors and 2 cameras: a RGB camera and an InfraRed *Depth* camera.

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;">
<a title="Evan-Amos, Public domain, via Wikimedia Commons" href="https://commons.wikimedia.org/wiki/File:Xbox-360-Kinect-Standalone.png"><img width="400" alt="kinect_my_optoin_" src="https://upload.wikimedia.org/wikipedia/commons/thumb/6/67/Xbox-360-Kinect-Standalone.png/512px-Xbox-360-Kinect-Standalone.png?20110811044925"></a>
<div class="custom_caption" markdown="1">
\> The original Kinect for xbox 360, image from [wikimedia](https://commons.wikimedia.org/wiki/File:Xbox-360-Kinect-Standalone.png).
</div>
</div>

One of the main aspect of the device is of course its capability to perform 3D pose tracking in realtime, that is to recover a coarse 3D skeleton of people's body in the camera field.
This feature is of interest in the gaming industry 🎲 but also in other areas such as healthcare 🧑‍⚕️, robotics 🤖, etc..


#### The **Kinect**'s successors 🪦

Despite the limited success of the first Kinect's 💸, Microsoft released a second version of its device together with the Xbox One console in 2013.
The new device, called **Kinect 2** or Kinect One, was originally [controversially bundled with the new console](https://en.wikipedia.org/wiki/Kinect) to favor its adoption.
As we may understand, criticisms were notably raised for privacy concerns 🔒.
This resulted in an updated version of the console that was then sold alone, its Kinect port being removed by Microsoft (an external power adapter was then provided with the device).

<h4 id="SDK"> The <b>Kinect</b> development kits </h4>

In parallel, Microsoft also released alternative versions of the two controllers dedicated to developers and professionals: the [**Kinect** for Windows](https://pcper.com/2012/01/microsoft-releasing-kinect-for-windows-and-sdk-on-february-1st-2012/) and [**Kinect 2** for Windows](https://www.gamesindustry.biz/kinect-2-0-for-windows-coming-in-2014).
These two additional devices had their hardware **slightly modified** compared to the original ones.
Theses releases were accompanied by two respective [**S**oftware **D**evelopment **K**its](https://en.wikipedia.org/wiki/Software_development_kit) (and drivers), allowing developers to write their own applications 🧑‍💻 for the **Kinects**. 
Of course, we were not ready to see any effort from Microsoft to release Linux or Macos versions of the drivers and SDK's 🤷.
Also important to note, these products were sold at a significantly higher price 💵 than their Xbox counterparts 🕹️, and they are rather difficult to find these days. 

<div style="display: flex; align-items: center; gap: 1rem; max-width: 100%">
<div style="display flex;"><img src="https://pcper.com/wp-content/uploads/2012/01/1cca-kinect-for-windows-0.jpg" alt="The first Kinect for Windows." /></div>
<div style="display flex;"><img src="https://www.stuff.tv/wp-content/uploads/sites/2/2021/08/kinect-for-windows-v2.jpg" alt="The second Kinect for Windows." /></div>
</div>
<div class="custom_caption" markdown="1">
\> On the left, the first Kinect for Windows (image from [PC Perspective](https://pcper.com/2012/01/microsoft-releasing-kinect-for-windows-and-sdk-on-february-1st-2012/)).
On the right, the second Kinect for Windows (image from [Stuff.tv](https://www.stuff.tv/news/kinect-windows-v2-now-available-pre-order/)).
</div>

Although Microsoft's SDK had official support only for the **Windows versions** of the two Kinects hardware, [it has been discovered](https://robotics.stackexchange.com/questions/654/what-is-the-difference-between-kinect-for-windows-and-kinect-for-xbox) that the two versions of the devices (Windows vs Xbox) were extremely close, even allowing for SDK compatibility with the Xbox Kinects! 😶
This fact has probably driven the developer community to invest more efforts in using the device!

In 2020, Microsoft persisted with its Kinects by releasing a third model: the [**Azure Kinect**](https://en.wikipedia.org/wiki/Azure_Kinect).
More precise than its predecessors, this product was released as a development device only 📦, with target applications primarily outside of the gaming industry 🏭.
Similarly to the other Kinect's development kits, the Azure Kinect was sold at a much higher price than the consumer level ones 👾.
The device did not last long as Microsoft announced its discontinuation in late 2023 ☠️ (few specimens might still be found at the moment at a high price).


<div style="display: block; margin-left: auto; margin-right: auto; width: 40%;" markdown="1">
![The azure Kinect sensor.](https://cdn-dynmedia-1.microsoft.com/is/image/microsoftcorp/kinect-dk_built-for-developers?resMode=sharp2&op_usm=1.5,0.65,15,0&wid=734&hei=414&qlt=100&fit=constrain)
<div class="custom_caption" markdown="1">
\> The azure Kinect sensor, image by [Microsoft](https://www.microsoft.com).
</div>
</div>



## Kinect hacking and open source drivers

Before diving into body tracking tools for the Kinect, I wanted to cover a bit of history around Kinect's hack.
When the device was released, a [bounty](https://en.wikipedia.org/wiki/Bug_bounty_program) was offered by [Adafruit](https://www.adafruit.com/) to the first people being able to hack the camera: that is developing a custom driver and obtain a depth image.
Although [disapproved by Microsoft](https://linuxdevices.org/bounty-offered-for-hacking-microsofts-kinect-xbox-controller/), this event helped the release of open source 🔓 and multi-platform drivers 🐧 while Microsoft only supported Windows systems 🪟 and Kinect for Windows.
Although hacking may usually be seen as controversial, such a hack would actually have the effect of encouraging the usability of the product.
It appears to me here as an elegant way of encouraging developers to familiarize around a technology ⚙️ and also fight against its obsolescence 🚮. 

Anyway, the bounty was [a success](https://blog.adafruit.com/2010/11/10/we-have-a-winner-open-kinect-drivers-released-winner-will-use-3k-for-more-hacking-plus-an-additional-2k-goes-to-the-eff/) as a [hacking community](https://web.archive.org/web/20230111044143/https://openkinect.org/wiki/Main_Page) was formed around the Kinect.
A tutorial was even made by Adafruit on [how to hack the device](https://learn.adafruit.com/hacking-the-kinect/overview)!
The second Kinect was also [rapidly hacked](https://www.engadget.com/2014-07-18-hackers-make-xbox-ones-kinect-work-on-a-pc.html) and two open source drivers for the two devices have been released as a result: [libfreenect 1 and 2](https://github.com/OpenKinect). 
These actions have probably greatly contributed to increasing the usability of the Kinects despite of its limited success in the gaming world 👾.

## Looking for pose tracking libraries for the Kinect

The **Kinect**'s hardware itself is not capable of directly providing a full body skeleton that can be exploited in applications.
It is instead in charge of re-constructing and sending the monochrome depth image 🖼️ from its [structured light](https://en.wikipedia.org/wiki/Structured_light) IR sensor/projector to a computer (which is already substantial!).

<div style="display: block; margin-left: auto; margin-right: auto; width: 40%;" markdown="1">
![An example of depth image captured by the Kinect.](https://learn.microsoft.com/en-us/archive/msdn-magazine/2012/november/images/jj851072.holmquest_fig03(en-us,msdn.10).jpg)
<div class="custom_caption" markdown="1">
\> An example of depth image captured by the Kinect. Image from [Leland Holmquest](https://learn.microsoft.com/en-us/archive/msdn-magazine/2012/november/kinect-3d-sight-with-kinect).
</div>
</div>

The skeleton reconstruction is rather performed on the software side 🖥️.
Let's face it, this is definitely not an easy problem!
Up to these days, only few libraries/softwares are available to perform this task.
I was surprised to find only few notes on the skeleton tracking problem in the open drivers documentation. 
In my opinion, the Kinect becomes less interesting without this feature and I am surprised that we did not see additional efforts in releasing an open source solution 🤔.
After spending some time digging into the subject, I will review here what I could actually find 🔎. 




#### Microsoft's algorithm and SDK

With the release of the first Kinect in 2010, Microsoft faced the challenge of releasing a fully-working computing library for extracting skeleton information from a depth image, for its in-game applications.
Although Microsoft would obviously not release an open-source solution of its algorithm 🔒, some piece of information is still available online about its technology.
This [conference talk](https://archive.org/details/Microsoft_Research_Video_146550) and the [associated paper](https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/BodyPartRecognition.pdf) explain that [Microsoft Reasearch](https://en.wikipedia.org/wiki/Microsoft_Research) developed an approach based on **machine learning**.
More precisely, the proposed machine learning model is a classification model in charge of associating the depth pixels to body parts.
The model, based on kind of [random forest](https://en.wikipedia.org/wiki/Random_forest) 🌲, was trained (fitted) on a motion captured dataset.
Of course at the time deep learning was not as popular as it is today.
Additional research material on the algorithm may be found online ([here](https://www.microsoft.com/en-us/research/publication/real-time-human-pose-recognition-in-parts-from-a-single-depth-image/?from=https://research.microsoft.com/apps/pubs/?id=145347&type=exact) and [there](https://pages.cs.wisc.edu/~ahmad/kinect.pdf) for instance).

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;">
<div style="display: flex; align-items: center; gap: 3rem; max-width: 100%">
<div style="display flex;"><img src="https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/vrkinect-harlequin_view.jpg
" alt="The first Kinect for Windows." /></div>
<div style="display flex;"><img src="https://www.microsoft.com/en-us/research/wp-content/uploads/2016/02/vrkinect-position_view.jpg" alt="The second Kinect for Windows." /></div>
</div>
</div>
<div class="custom_caption" markdown="1">
\> On the left, result of the random forest classification of body parts from depth pixels. On the right, the resulting skeleton joints estimation. Images from [Microsoft](https://www.microsoft.com/en-us/research/project/human-pose-estimation-for-kinect/).
</div>

When it comes to the implementation, we mentioned earlier the Kinect and Kinect 2 [SDK](#SDK) released by Microsoft together with the release of the Windows versions of the devices.
The SDK came with Kinect's drivers ⚙️ and with an implementation of Microsoft's skeleton algorithms for both the first and second Kinects (the skeleton is more detailed 🔬 with the second Kinect, which may be due to the higher definition of the depth image as well as some improvements on the algorithms).
Athough the original Xbox Kinects were not officially supported by the framework, the SDK **do work** and is a first viable solution for performing skeleton tracking.
Unfortunately, a closed source and Windows only solution was not satisfying to me 😒, which made me keep exploring.

#### OpenNI framework and NITE

The second solution is [OpenNI](https://en.wikipedia.org/wiki/OpenNI), an open source framework developed by the [PrimeSense](https://en.wikipedia.org/wiki/PrimeSense) company.
PrimeSense was actually at the origin of Kinect's hardware and the company was then [bought by Apple](https://www.theverge.com/2013/11/24/5141416/apple-confirms-primesense-acquisition) in 2013.

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;" markdown="1">
![OpenNI framework architecture](https://i0.wp.com/yannickloriot.com/wp-content/uploads/2011/03/OpenNi-Architecture.png?w=460&ssl=1)
<div class="custom_caption" markdown="1">
\> Architecture of the OpenNI framework. Image from [Yannick Loriot](https://yannickloriot.com/2011/03/kinect-how-to-install-and-use-openni-on-windows-part-1/).
</div>
</div>


[OpenNI](https://web.archive.org/web/20110112091914/http://wiki.openni.org/mediawiki/index.php/Main_Page) was developed to mutualize natural interface devices such as depth cameras together with processing algorithms into one API.
[About one year](https://sebastien.warin.fr/2011/01/05/1067-kinect-introduction-openkinect-openni-nite/) after the release of the Kinect, PrimeSense released an open source version of OpenNI.
A library 📚 called **NITE** was also freely released, binary only this time 🔢, to take care of skeleton reconstructions and other complex computations.
From this release, several open source Kinect drivers have been provided such as [this one](https://github.com/avin2/SensorKinect) by github user [avin2](https://github.com/avin2) (I absolutely don't now if it is an open source project, if it comes from the libfreenect project or if it is an official driver... 🤷).

Anyway, these three components : **OpenNI**, a **Kinect driver** and the **NITE** library appeared as a viable multi-platform solution for skeleton tracking with the first Kinect 👨‍💻 and has been easily adopted by the [kinect hobbyists community](https://wiki.ubuntu-fr.org/kinect_openni).
Unfortunately, combining the fact that these libraries are unmaintained, not fully open source and that the official documentation 🗎 is unavailable, the usage has become more difficult today 😬.
We will still see at the end of the post how to set up the Kinect developement environment with tracking through OpenNI ⬇️.


A more recent version, OpenNI2, was also released and can still be found [these days](https://structure.io/openni/).
It seems usable not only with [the first Kinect](https://github.com/OpenKinect/libfreenect/tree/master/OpenNI2-FreenectDriver) but also with [the second one](https://stackoverflow.com/questions/27465516/does-openni-2-2-support-kinect-v2) 📸.
Several pages on the web seems to indicate that this is also a solution to develop with the two Kinects on Linux: for instance see [here](https://www.programmersought.com/article/78274238050/) and [here](https://github.com/carlosoleto/Ubuntu-Kinect2-Vpython) and [here](https://robots.uc3m.es/installation-guides/install-openni-nite.html#install-nite22-ubuntu).
But because there are few resources available on the web, I will keep the focus on the first Kinect in this post.




#### Alternatives

Due to the difficulty of the problem, it is clear that reliable solutions would be primarily brought through commercial products 🛒, which is a shame for the open source world 🌐.
The Kinect SDK's and the OpenNI solution are by far the [most considered ones](https://msr-peng.github.io/portfolio/projects/skeleton_tracking/).
Nevertheless, few alternatives can still be found.

First, [NuiTrack](https://nuitrack.com/) is a commercial software that performs multi-device Skeleton tracking, including support for the three Kinects.
It remains a closed source and expensive solution but it is apparently still maintained 🗓️.
Few information is available about its technology but part of it seems to be powered by deep learning.
This solution may however be usable [on arm64 platforms](https://github.com/3DiVi/nuitrack-sdk/releases/tag/v0.35.7), which includes the [RaspberryPi 4](https://www.raspberrypi.com/products/raspberry-pi-4-model-b/).
This could indicate that the underlying algorithm is not unreasonably intensive ⚡.


<div style="display: block; margin-left: auto; margin-right: auto; width: 40%;" markdown="1">
![NuiTrack solution](https://static.tildacdn.net/tild6236-3061-4739-a333-663731633965/skel-v2.gif)
<div class="custom_caption" markdown="1">
\> The NuiTrack software in action. Image by [NuiTrack](https://nuitrack.com/).
</div>
</div>


By further digging into existing algorithms, I came up onto additional solutions developed by small teams or individuals and that do not rely on machine learning.
These solutions seem to be rather based on mathematical and **physical models** of the body, by minimizing **geodesic distances** for instance 📐.
[Norman0406](https://github.com/Norman0406) on github made available a fully open source solution 🧑‍💻 apparently developed during a research project: [OpenSkeletonFitting](https://github.com/Norman0406/OpenSkeletonFitting).
Kudos to them for achieving and releasing the full code!
More information about the approach is available in the `OpenSkeletonFitting/Doc` directory.
I came across a quite related approach which seems to be a thesis work by Abhishek Kar, available [here](
https://traf-barak.pwr.edu.pl/Others/Literature/2010/Kar%20-%20Skeletal%20Tracking%20using%20Microsoft%20Kinect%20The%20Microsoft%20Kinect%20sensor.pdf) but I was not able to find an open source implementation for this one.

The remaining approaches that I found belong to the research world 🧑‍🔬.
I came through several research articles [here](https://ieeexplore.ieee.org/abstract/document/8337363), [here](https://www.sciencedirect.com/science/article/abs/pii/S026322411830410X
), [there](https://ieeexplore.ieee.org/abstract/document/7467728
) and [there](https://www.sciencedirect.com/science/article/abs/pii/S026288561100134X).
Sadly, it seems that the authors rarely share their source code details... 😢 This is bad!
Overall there is a mix of approaches with machine learning and more explicit modeling of the human body.
I can however surprisingly note this [method](https://github.com/SeyedMuhammadHosseinMousavi/Real-Time-Differential-Evolution-Human-Pose-Estimation) (working on RGB images this time) that rely on [evolutionary computing](https://en.wikipedia.org/wiki/Differential_evolution) 🧬!

At the end, it is clear that once again, the problem is far from being easy! 
Due to the current attention raised by deep learning 🧠, and due to its success on image processing 🖼️ with convolutional architectures, I believe that modern solutions would prioritize this type of approach.
This seems to be the case for instance in a [presentation by RealSense](https://realsenseai.com/skeletal-tracking/skeletal-tracking/) of their own algorithms for depth cameras. 
If we think in terms of open and accessible approaches, the question remains about a frugal and open source solution to keep the Kinect devices alive 🛟.
For now, the OpenNI/NITE couple, although not fully open, seems a reliable one and I decided to go with it.


## Hands on! Setting up a Linux **Kinect** development environment

After covering multiple aspects of the skeleton tracking problem, we will now see how to actually set up the hardware and run a first tracking program.
We will work on the first Kinect in its XBox 360 model (excluding the Kinect for Windows one) and the OpenNI library.



#### Setting up the hardware

The first step to work with the Kinect is to connect it to a computer 🔌!
As straightforward as it seems, this is already the first difficulty since the Xbox 360 Kinect had its own custom plug 😧.
Fortunately, the communication between the Kinect and the console is performed over USB but the Kinect also requires its own 12V power supply ⚡ that cannot be taken from USB (The Xbox was able to provide 12V on its own through the custom cable).
This [nice tutorial](https://www.instructables.com/Wiring-an-Xbox-Kinect-for-USB/) by [squiggy2](https://www.instructables.com/member/squiggy2/) explains how to rewire Kinect's original cable by separating the USB wires from the power ones.

⚠️ Warning, working with electricity always comes at [a risk](https://www.circuitbasics.com/working-with-electronics-safely/).

<div style="display: block; margin-left: auto; margin-right: auto; width: 90%;">
<div style="display: flex; align-items: center; gap: 3rem; max-width: 100%">
<div style="display flex;"><img src="https://content.instructables.com/FR8/X180/HH2VL3PN/FR8X180HH2VL3PN.jpg?auto=webp&frame=1&width=1024&height=1024&fit=bounds&md=MjAxMy0xMi0yMCAyMjo0NDo0Ni4w" /></div>
<div style="display flex; width: 200%;"><img src="https://content.instructables.com/FOA/QBHU/HH2VL3XA/FOAQBHUHH2VL3XA.png?auto=webp&frame=1&fit=bounds&md=MjAxMy0xMi0yMCAyMjo0NTowOC4w
" /></div>
</div>
</div>
<div class="custom_caption" markdown="1">
\> One the left, a classical USB cable. On the right, the Kinect custom cable. Images by [squiggy2](https://www.instructables.com/Wiring-an-Xbox-Kinect-for-USB/).
</div>

To perform the wiring, you need a 12V power supply that would be plugged in addition to the USB cable.
A 12V and 2A (24W) must work fine.
Instead of buying a new one, this type of supply may usually be found from old devices such as laptop charging blocks 🔋. 
At the moment of writing these lines, I also realise that the Kinect could even be plugged to a desktop [computer's power supply](https://electronics.stackexchange.com/questions/63793/where-to-get-12v-from-my-computer) 🖥️.
I also wondered if modern USB-C charging blocks could be used as a power supply since they support multiple output tension but [extra eltronics](https://hackaday.io/project/20424-pd-buddy-sink) would be necessary and it seems that on 12V, the maximum power [might not be enough](https://www.zonsanpower.com/blog/can-i-use-a-usb-charger-as-a-power-supply.html) for the Kinect ❌.

#### Setting up OpenNI and NITE library

We will see now how to install OpenNI on recent Ubuntu distributions 🐧, starting from an empty system.
I tested the scripts inside a [live Ubuntu USB image](https://ubuntu.com/tutorials/try-ubuntu-before-you-install#1-getting-started) 🖫 to ensure that the procedure is reproducible.
We will make sure that at the end of the installation, it is possible to compile and run few program samples to develop with skeleton data 🩻. 

The three piece of softwares will be obtained from these three (non official) git repositories hosted on github:

- OpenNI: `https://github.com/smbct/OpenNI.git`
- SensorKinect: `https://github.com/smbct/SensorKinect.git`
- NITE: `https://github.com/arnaud-ramey/NITE-Bin-Dev-Linux-v1.5.2.23.git`

These repositories have evolved from the original releases in order to maintain compatibility and fix multiple issues.
One recent issue with OpenNI was a compilation error caused by a clash on [C++ **macro**](https://gcc.gnu.org/onlinedocs/cpp/Macros.html) names between the source and recent versions of the [GCC compiler](https://gcc.gnu.org/).
This error almost made me give up on the installation ❌ when I started the project!
Fortunately, several people have been working on a fix 😇.
One of the proposed solution is to downgrade GCC ⤵️ to an older version, as suggested [here](https://github.com/slugspark/KinectSkeletontTracking_18.04/tree/master) and [here](https://github.com/pingarelho/Kinect-Skeleton-Tracking-on-Linux?tab=readme-ov-file).
I am however not a big fan of this as replacing the GCC version (even temporarily) is somehow intrusive 🥷 in the system.
Another solution has been proposed by [roncapat](https://github.com/roncapat) via a [pull request](https://github.com/OpenNI/OpenNI/pull/128/commits) on github: [renaming the macro in question.](https://github.com/OpenNI/OpenNI/pull/128/commits/99e5dcc60860ea065bad3afaefb4c4cf7bc98e18)
I did not see this at the time I tried and I actually came up with the exact same modification [in my fork](https://github.com/OpenNI/OpenNI/commit/75749441887b8ac2a3c6f0557f4baccc737755d9) 🤦
(*Note to self: always check the pull requests, they are particularly informative.*)


To simplify the installation process, I created a *bash* install script in a [github repository](https://github.com/smbct/KinectOpenNISetup/tree/main).
The installation can then be done by cloning the repository and executing the *bash* script with root privileges:

<div class="code_frame"> bash</div>
{% highlight bash linenos %}
git clone https://github.com/smbct/KinectOpenNISetup.git
cd ./KinectOpenNISetup
sudo bash install_openni_kinect.sh
{% endhighlight %}

This should install the dependencies and then download, compile, and install the OpenNI library, the Kinect driver and the NITE binary library.
Once the installation is complete, the Kinect can be connected to the computer 🖥️ and tested via the two C++ examples in the repository.
These examples have been developed to help reproduce the development environment.
Fom these, one may simply copy the source files and the Makefile to setup its own script.
The code source has been made simple to **build upon it**.

The first example, **SimpleSkeletonRevisited**, is a console-only program that prints skeleton information in the terminal.
A **calibration** phase is necessary for OpenNI to compute the skeleton joints: this can be performed simply as standing in front of the Kinect at a reasonable distance.
After that, the program should print the 3D position of one skeleton joint:

<div class="code_frame"> bash</div>
{% highlight bash linenos %}
# from KinectOpenNISetup directory
cd SimpleSkeletonRevisited
make SimpleSkeletonRevisited
./SimpleSkeletonRevisited
{% endhighlight %}

The second example, **SkeletonViewer** is a graphical program that displays a 3D scene with [openGL](https://www.opengl.org/) and the [freeglut](https://freeglut.sourceforge.net/docs/api.php) library.

<div class="code_frame"> bash</div>
{% highlight bash linenos %}
# from KinectOpenNISetup directory
cd SimpleSkeletonRevisited
make SimpleSkeletonRevisited
./SimpleSkeletonRevisited
{% endhighlight %}

<div style="display: block; margin-left: auto; margin-right: auto; width: 60%;" markdown="1">
![The SkeletonViewer program](https://github.com/smbct/KinectOpenNISetup/blob/main/SkeletonViewer.png?raw=true)
</div>
<div class="custom_caption" markdown="1">
\> The small program SkeletonViewer that I wrote for visualizing the skeleton in 3D.
</div>

More examples are available in the OpenNI directory.
They are being compiled with the library when running the install script.
They can be found in the directory `OpenNI/Platform/Linux/Redist/OpenNI*/Samples/Bin/x*-Release` and may serve as tutorials for more advanced features.

⚠️ Note: when I first tried the installation process a few time ago I came across a running issue with the Kinect.
I had to follow the procedure described [here](https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1521245): `sudo -s &&
echo -1 > /sys/module/usbcore/parameters/autosuspend`.
For some reason, I did not have the issue anymore when writing this post 🤷.

#### Runnning the Kinect inside a container

As I was looking for a simpler way of setting up the Kinect/OpenNI/NITE development environment, my idea was to build a **container** with all the tools installed in it.
More precisely, [containerization](https://en.wikipedia.org/wiki/Containerization_(computing)) is a software technology that allows to create an isolated environment in the Operating System to execute a program in a controlled way (in terms of software dependencies and not necessarily in terms of security! ⚠️).

I created a small [Apptainer](https://apptainer.org/) image definition file to create an image with a working development environment.
Unfortunately at first, the Kinect wouldn't be recognised by any test program...
I identified a small missing piece of code in the driver and created [a commit to fix the issue](https://github.com/smbct/OpenNI/commit/47a0815f4362c9682ba8341866d1c0de08a134eb).
I may write a future blog post to add more details of the debugging process which I find interesting (I have almost no knowledge in driver development!).

With Apptainer installed in the system, the following commands allow to create the apptainer image:

<div class="code_frame"> bash</div>
{% highlight bash linenos %}
git clone https://github.com/smbct/KinectOpenNISetup.git
cd ./KinectOpenNISetup
apptainer build openni_kinect.sif openni_kinect.def
{% endhighlight %}

Once the image is created, it is possible to open a shell inside the container with the command:

 ```apptainer shell openni_kinect.sif```

Once inside the container, the examples can be compiled and run:

<div class="code_frame"> bash | openni_kinect.sif </div>
{% highlight bash linenos %}
# from within openni_kinect.sif shell
cd SimpleSkeletonRevisited
make SimpleSkeletonRevisited
./SimpleSkeletonRevisited
{% endhighlight %}

⚠️ Note: graphical programs cannot be run by default on some systems, which prevents from running the `SkeletonViewer` example.
I encountered this issue when working on a gnome+wayland desktop (Debian default).
It is possible to solve the issue with the following command (on the host, outside of the container): `xhost +SI:localuser:$(id -un)`.
See more details on the issue [here](https://unix.stackexchange.com/questions/330366/how-can-i-run-a-graphical-application-in-a-container-under-wayland).


#### What about Windows and MacOS ?

I have only covered Linux systems here for two main reasons 🤔: I am more familiar with them and they are more accessible for experienced users/developers.
However the OpenNI release also contains a Windows and a MacOS version 👍.
I have no idea of what still works and what does not in recent versions of these operating systems though...
Some documentation on the installation for Windows can still be found [here](https://www.codeproject.com/Articles/148251/How-to-Successfully-Install-Kinect-on-Windows-Open
https://yannickloriot.com/2011/03/) and [here](https://lh1075.blogspot.com/2016/10/openninite-installation-on-windows.html).


## Concluding thoughts

I hope that this post gives an interesting overview of what the Kinect is capable of and how to use it in some projects.
A lot of elements were not covered here such as [hardware modes for the Kinect](https://medium.com/robotics-weekends/how-to-turn-old-kinect-into-a-compact-usb-powered-rgbd-sensor-f23d58e10eb0
), variations of the open source drivers for different platforms (for instance I found a version of the [avin2](https://github.com/avin2/SensorKinect) driver specialized [for Debian](https://github.com/jspricke/debian-openni-sensor-avin2-sensorkinect)), about the Kinect audio system 🎤 that was apparently also [reverse engineered](https://salsa.debian.org/debian/kinect-audio-setup), the Kinect 2 drivers, etc...
There is definitely more to be explored.

I do have several ideas yet for further improving the usability, performance and openness of the Kinect software ecosystem.
It is already possible to build 👷 upon existing open source code to improve its maintainability (I am indeed talking about OpenNI...).
The skeleton tracking part is also critical ⚠️ as the NITE library is not open source.
This prevents for instance a port to [arm devices](https://en.wikipedia.org/wiki/ARM_architecture_family) such as the [raspberry pi](https://www.raspberrypi.com/).
There are only few solutions here but I do believe that there is [always a way](https://decompilation.wiki/).


Anyway, for now what started as a hobby to me has also become a source of reflection about aging hardware, obsolescence and open source development 😀.
Helping to keep an old gaming device alive might not be the most useful software contribution 💽 but it is a good opportunity to enjoy "old" technology 🧓 and to learn more about how things work 🤓!

I still believe that keeping things alive has its point though.
This may be a way of opening technology to everyone, which is reflected with the Kinect by numerous hacking/modding [projects](https://kinect.fandom.com/wiki/Hacks) and more recently around [VR](https://k2vr.tech/).
We are definitely far from **high end** devices such as the [Apple Vision Pro](https://en.wikipedia.org/wiki/Apple_Vision_Pro) here 👓, even the name sounds rather *restrictive*...
The Kinect once again did not stop at gaming: I found two more examples in [surgery](https://www.gamesindustry.biz/kinect-trialled-by-surgeons) 🧑‍⚕️ and [therapy](https://www.gamesindustry.biz/microsoft-testing-kinect-therapy-system-for-soldiers) 🪖.
The device is also an interesting tool for [artists](https://www.youtube.com/watch?v=h4VMbeB5Hlk&ab_channel=PBSIdeaChannel), to help questioning our relationship to computers through the lens of [User Interfaces](https://en.wikipedia.org/wiki/User_interface) for example.
To me, all these applications make it worth the time investment ⌚.
And beyond this particular device, I am convinced that we have everything to gain from maintaining old yet operational systems.


