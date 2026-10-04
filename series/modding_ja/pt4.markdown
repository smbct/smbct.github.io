---
title:  Modding Jedi Academy with the Kinect&#58 Understanding skeleton positioning
author: smbct
date:   2026-09-20 10:00:00 +0200
categories: modding 
tags: programming modding video-games virtual-reality
comments: true
layout: series_article
series: modding_ja
back_page: headline.md
lang: en
---

In the [last post]({{site.baseurl}}/series/modding_ja/pt3) of the series, we have implemented a visual debugging feature to display the character's skeletons 🩻. This will help us in this post to understand how body positioning is performed and how we can interact with it. We will try to control the orientations of the body limbs to facilitate the integration of a Kinect 📷.

## Looking for Ghoul2 controls

We start once again from our previous code in the `tr_main.cpp` file. We have been previously able to display rotation matrices of the different bones 🦴. We are now looking for some functions that will help us actually rotate these bones. 

We have seen the Ghoul2 functions start with `G2_[...]` so we can first search 🔍 for the place where they are defined.
This lead us to `ghoul2/G2.h` with many defined function.

We eventually find these three *setter* functions related to bone angles:

<div class="code_frame"> ghoul2/G2.h</div>
{% highlight c++ linenos %}
qboolean G2_Set_Bone_Angles_Matrix(CGhoul2Info *ghlInfo, boneInfo_v &blist, const char *boneName, const mdxaBone_t &matrix,
			const int flags, const int blendTime, const int currentTime);

qboolean G2_Set_Bone_Angles_Index(CGhoul2Info *ghlInfo, boneInfo_v &blist, const int index,
			const float *angles, const int flags, const Eorientations yaw,
			const Eorientations pitch, const Eorientations roll,
			const int blendTime, const int currentTime);

qboolean G2_Set_Bone_Angles_Matrix_Index(boneInfo_v &blist, const int index,
			const mdxaBone_t &matrix, const int flags,
			const int blendTime, const int currentTime);
            
{% endhighlight %}

These functions propose two modes for controlling the bones: using matrices or angles.
We will first focus on the matrices functions.
The two functions mainly differ in their second parameters: the "Index" prefixed function seem to identify the bone using an index whereas the other one directly take a string of character as input ⛓️.

For ease, we will use the function `G2_Set_Bone_Angles_Matrix`.
The first 4 parameters of the functions are associated to types we already encountered in the previous post. Then, the user should provide some flags and the two last parameters are related to time ⏲️.

Regarding the `flags` parameter, we need to investigate more to guess the possible values.
Going through the definition of the function, we can spot one value for this flag: `BONE_ANGLES_TOTAL`.

<div class="code_frame"> G2_bones.cpp </div>
{% highlight c++ linenos %}
G2_Set_Bone_Angles_Matrix(/* [..] */) {
    // [...]
    blist[index].flags &= ~(BONE_ANGLES_TOTAL);
    blist[index].flags |= flags;
    // [...]
}
{% endhighlight %}

We can find other values for the flags by following the definition of `BONE_ANGLES_TOTAL`.
The definition is in `game/ghoul2_shared.h`:

<div class="code_frame"> ghoul2_shared.h </div>
{% highlight c++ linenos %}
#define BONE_ANGLES_PREMULT			0x0001
#define BONE_ANGLES_POSTMULT		0x0002
#define BONE_ANGLES_REPLACE			0x0004
//rww - RAGDOLL_BEGIN
#define BONE_ANGLES_RAGDOLL			0x2000  // the rag flags give more details
#define BONE_ANGLES_IK				0x4000  // the rag flags give more details
//rww - RAGDOLL_END
#define BONE_ANGLES_TOTAL			( BONE_ANGLES_PREMULT | BONE_ANGLES_POSTMULT | BONE_ANGLES_REPLACE )
{% endhighlight %}

We can exclude the entries between the *ragdoll* section as it probably concerns death animations.
`BONE_ANGLES_TOTAL` seems to be a combination of the first defined values.
It is not clear what their role is but we may guess that this has something to do with the skeleton hierarchy.
The application of rotations in 3D is indeed not commutative: inverting two successive rotations will result in a different orientation.
When some bone 🦴 move, it is then natural to apply the same movement to all the bones that are attached to it in the hierarchy (for instance, moving the humerus causes the motion of all the arm 🦾).
For our concern, it will actually be more convenient to control the bones by setting each matrix independently since the matrices will be obtained externally (from motion capture devices 📷 😇).
We can select the flag value `BONE_ANGLES_REPLACE` for our tests, this mode should not be influenced by parent bones.


## First attempt: a basic rotation 

Let's start by defining the most natural rotation matrix: the [identity](https://en.wikipedia.org/wiki/Identity_matrix), that actually does not apply any rotation 🤷.
We will apply it to the `humerus` bone in out example.
We start by defining the identity matrix (ones on the diagonal) before iterating over the bones:

<div class="code_frame"> tr_main.cpp </div>
{% highlight c++ linenos %}
mdxaBone_t bone_matrix; // 3x4 matrix
for(int i = 0; i < 3; i ++) {
	for(int j = 0; j < 4; j ++) {
		bone_matrix.matrix[i][j] = 0.;
	}
}
bone_matrix.matrix[0][0] = 1.;
bone_matrix.matrix[1][1] = 1.;
bone_matrix.matrix[2][2] = 1.;
{% endhighlight %}

We saw in the previous posts that the `mdxaBone_t` matrices are 3x4 matrices, meaning **three** rows and **four** columns.
We assumed that the rotation part is stored in the first three columns of the matrix.
We also interpreted the first index as the row index and the second one as the column, which is fairly common.

We can now call the ghoul2 set_angle function  with our identity matrix. We need the `CGhoul2Info*` and `boneInfo_v` parameters to call the function so the following line can be placed inside of the first loop that iterates over all entities:

<div class="code_frame"> tr_main.cpp </div>
{% highlight c++ linenos %}
CGhoul2Info_v& ghoul2 = *ent->e.ghoul2;
for(int i = 0; i < ghoul2.size(); i ++) {
  CGhoul2Info &info = ghoul2[i];
  if(!info.mBoneCache) {
    continue;
  }
  G2_Set_Bone_Angles_Matrix(&info, info.mBlist, "rhumerus", bone_matrix, BONE_ANGLES_REPLACE, 0, 0);
  // [...]
}
{% endhighlight %}

We simply put 0's for the last two parameters as they seem related to animation control 🕺.
Another useful feature would be the visualization of the matrix before it is sent to ghoul2.
This may help us identify potential issues in the way we interpret or pass data.  
It was not mentioned before but note that matrices are usually called [frames](https://en.wikipedia.org/wiki/Cartesian_coordinate_system) 🖼️ in 3D programming. 

<div class="code_frame"> tr_main.cpp </div>
{% highlight c++ linenos %}
vec3_t origin_shift = {e->origin[0], e->origin[1], e->origin[2]+40};
for(int i = 0; i < 3; i ++) { // row
	for(int j = 0; j < 3; j ++) { // col
		directions[i][j] = origin_shift[j]+bone_transformed.matrix[j][i]*10.;
	}
}
qglLineWidth(2.5);
qglBegin(GL_LINES);
qglColor3f(1, 0, 0);
qglVertex3fv(origin_shift); qglVertex3fv(directions[0]);
qglColor3f(0, 1, 0);
qglVertex3fv(origin_shift); qglVertex3fv(directions[1]);
qglColor3f(0, 0, 1);
qglVertex3fv(origin_shift); qglVertex3fv(directions[2]);
qglEnd();
qglLineWidth(1.);
{% endhighlight %}

Here the user rotation matrix is displayed above the character position (`origin_shift`) for visibility reasons.
The drawing is performed similarly than for bone rotation matrices.
As we previously did, we still assume here that the first index of the matrix corresponds to the row and the second one corresponds to the column.
By extracting the three columns, we expect to display a frame as represented below, with <span style="color:red">the first column being the forward axis</span> in red, <span style="color:green">the second column being the left axis in green</span> and <span style="color:blue">the third one being the up axis in blue</span>. 

<div style="display: block; margin-left: auto; margin-right: auto; width: 30%;" markdown="1">
![The coordinate frame used in Jedi Academy.](https://sislerwebgraphics.wordpress.com/wp-content/uploads/2012/11/71ca3-xyz.gif?w=350&h=271)
<div class="custom_caption" markdown="1">
\> The coordinate frame used in Jedi Academy. Image from [Digital Voices](https://sislerwebgraphics.wordpress.com/animation-unit/adv-animation-unit/activity-10-2-5d-effect/).
</div>
</div>

Let see how this behave in an animation:

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![The matrix sent to ghoul2 is transformed by the current rotation.]({{site.baseurl}}/assets/ja_mod/pt4/identity_1.gif)
<div class="custom_caption" markdown="1">
\> The matrix sent to ghoul2 is transformed by the current entity rotation.
</div>
</div>

## Local versus global transformation

We can see a first mismatch between the bone matrix of the right humerus 🦴 (on the shoulder) and the matrix drawn above the player.
The humerus matrix seems to correctly orient the arm to the forward direction (red forward, green left and blue up).
On the contrary, the red axis of the matrix drawn above does not seem to point in the **forward** direction ⬆️ because its direction changes as the player rotates 🌪️.

It is actually the other way around! Our identity matrix is correctly drawn above the player and the alignment problem is actually expected since the identity matrix is global to the game level: it **should not move** as the player rotates. 
This means that rotation matrices sent to ghoul2 are automatically transformed by the entity's rotation, which is particularly convenient but what we could expect at first 💡. 

We will take advantage on this aspect and transform out matrix prior to displaying it above the character.
First, we need to create an entity orientation matrix based on its `axis` field:

<div class="code_frame"> tr_main.cpp </div>
{% highlight c++ linenos %}
// build entity orientation matrix
mdxaBone_t entity_orientation;
for(int i = 0; i < 3; i ++) {
  for(int j = 0; j < 3; j ++) {
    entity_orientation.matrix[i][j] = e->axis[j][i]; 
  }
  entity_orientation.matrix[i][3] = 0;
}
{% endhighlight %}

This is actually very similar to how we corrected the bounding box orientations in the [second article of the series]({{site.baseurl}}/series/modding_ja/pt2).
The transformation is performed by multiplying this entity orientation matrix by our custom matrix (the identity here, that does nothing for now).
We will directly use existing functions from the code to perform this operation:

<div class="code_frame"> tr_main.cpp </div>
{% highlight c++ linenos %}
mdxaBone_t bone_transformed;
Multiply_3x4Matrix(&bone_transformed, &entity_orientation, &bone_matrix);
{% endhighlight %}

The first argument of the function is the returned matrix.
The multiplication is performed from left (the entity matrix) to right (the bone matrix).
Copies are necessary here, it is probably not possible to reuse the same matrix to store the result.
It is also not always easy to find the right order for the matrix multiplication ✖️.
One intuitive way of considering things is to say that all transformations must be performed once in the local entity frame, so the entity matrix placed first (on the left).

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;" markdown="1">
![The identity matrix drawn above is now transformed by the entity local matrix.]({{site.baseurl}}/assets/ja_mod/pt4/identity_2.gif)
<div class="custom_caption" markdown="1">
\> The identity matrix drawn above is now transformed by the entity local matrix.
</div>
</div>

Our matrix now has the same orientation as the humerus as well as the entity matrix drawn at the center of the player (see the previous posts).
This is expected because again the identity matrix does not perform any transformation, the result of the multiplication is equal to the left matrix.
Yet, this transformation will be useful in the following since working in the local entity frame is much more convenient.
 
## Mastering correct bone orientations

At this point we are able to move the bones 🦴 by giving a rotation matrix to ghoul2.
We can see in the gifs above that the arm (humerus) points toward the direction of the forward axis (in red).
However, the other axis in green and blue have a wrong orientation if we compare to the in-game matrices that was displayed in the previous post. 

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![We can select only the characters and draw their orientation.]({{site.baseurl}}/assets/ja_mod/pt3/bone_orientation.png)
<div class="custom_caption" markdown="1">
\> Bones are oriented so that the first axis is pointing toward the children bone's position.
</div>
</div>

We can see that when the forward axis (in red) is pointing to the ground, the green one is supposed to point to the right and the blue one should point to backward 🔙.
If we mentally 🧠 rotate the matrix so the the red axis points forward (as with the identity matrix), we would rotate around the green axis and the blue one should then points downward.
We can actually see on the second gif that the orientation of the arm 💪 is off: the arm and lightsaber are upside down 🗡️!  

We can simply correct this by replacing the identity matrix in our code:

<div class="code_frame"> tr_main.cpp </div>
{% highlight c++ linenos %}
mdxaBone_t bone_matrix; // 3x4 matrix
for(int i = 0; i < 3; i ++) {
  for(int j = 0; j < 4; j ++) {
    bone_matrix.matrix[i][j] = 0.;
  }
}
bone_matrix.matrix[0][0] = 1.;
bone_matrix.matrix[1][1] = -1.;
bone_matrix.matrix[2][2] = -1.;
{% endhighlight %}

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![The humerus bone has now a more realistic positioning.]({{site.baseurl}}/assets/ja_mod/pt4/correct_orientation.png)
<div class="custom_caption" markdown="1">
\> The humerus bone has now a more realistic positioning.
</div>
</div>

## Rotating the matrix

Geometry coding can be tedious, especially in 3D 😮‍💨.
I can actually relate that positioning the bones in this project has been a struggle for a long time and it took me a while to correctly understand it 🗓️, even with some prior experience in 3D.
We will perform a more rigorous test to see if our positioning is correct by rotating the humerus matrix.

We are going to rotate around the blue (3rd) axis so that only the red and the green one are modified.
We will control the animation with an angle to compute the coordinates of the two first axes.

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;" markdown="1">
![Coordinate of a point in the circles given an angle.](https://thumb.wikimedia.org/wikipedia/commons/thumb/8/8f/Unit_circle.svg/500px-Unit_circle.svg.png?utm_source=commons.wikimedia.org&utm_campaign=index&utm_content=thumbnail)
<div class="custom_caption" markdown="1">
\> Coordinate of a point in the circles given an angle. Image from [wikipedia](https://en.wikipedia.org/wiki/Unit_circle).
</div>
</div>

<div class="code_frame"> tr_main.cpp </div>
{% highlight c++ linenos %}
mdxaBone_t bone_matrix; // 3x4 matrix
for(int i = 0; i < 3; i ++) {
  for(int j = 0; j < 4; j ++) {
    bone_matrix.matrix[i][j] = 0.;
  }
}
static float angle = 0;
angle += 0.004;
bone_matrix.matrix[2][2] = -1.;
bone_matrix.matrix[0][0] = sin(angle+M_PI/2.);
bone_matrix.matrix[1][0] = -cos(angle+M_PI/2.);
bone_matrix.matrix[0][1] = sin(angle);
bone_matrix.matrix[1][1] = -cos(angle);
{% endhighlight %}

The angle is defined as a static variable. This way, the value is never reset and it will increments over time 🕖.
In this example, we increment the angle based on a fix value.
Note 📝 that in practice, this is not ideal because there is no guarantee that the `tr_main` function is called at a fixed frame rate.
This can cause the rotation to speedup or slowdown.

The two first columns of the rotation matrix are then computed using trigonometric operations.
Given the illustration above, we would expect the second axis in green to have as coordinates `(sin(angle), cos(angle))` by interpreting the forward axis as the "y" one in the circle image.
The minus comes from the fact that the y axis points to the left whereas the x axis points to the right on the image.
Finally the coordinates of the red (first) axis are obtained by rotating by 90° or half pi counter clockwise.
The constant `M_PI` is a commonly defined constant in language C.

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;" markdown="1">
![We can correctly rotate the humerus matrix.]({{site.baseurl}}/assets/ja_mod/pt4/rotating.gif)
<div class="custom_caption" markdown="1">
\> We can correctly rotate the humerus matrix.
</div>
</div>

The animation performs as expected 🥳! The matrix displayed above the player and the humerus matrix behaves exactly the same, meaning we are able to confidently manipulate the bone angles.
The bone positioning with this animation seems a little odd however but this is only for testing purpose.
We does not see it on the gif but it is also possible that the saber blade 🤺 intersects with the player.
For now this does not performs any damage but this will be another topic of discussion for future posts.  

## Controlling a second bone

We have been able to control one bone for the moment.
We can see that all other bones of the arm are moved following the humerus position 🦾. 
We will check that we are yet able to position another bone, the radius one, independently from the humerus.

<div class="code_frame"> tr_main.cpp </div>
{% highlight c++ linenos %}
mdxaBone_t bone_matrix_2; // 3x4 matrix
for(int i = 0; i < 3; i ++) {
  for(int j = 0; j < 4; j ++) {
    bone_matrix_2.matrix[i][j] = 0.;
  }
}
bone_matrix_2.matrix[0][0] = 1.;
bone_matrix_2.matrix[1][1] = -1.;
bone_matrix_2.matrix[2][2] = -1.;
G2_Set_Bone_Angles_Matrix(&info, info.mBlist, "rradius", bone_matrix_2, BONE_ANGLES_REPLACE, 0, 0);
{% endhighlight %}

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;" markdown="1">
![We can control multiple bones independently.]({{site.baseurl}}/assets/ja_mod/pt4/two_bones.gif)
<div class="custom_caption" markdown="1">
\> We can control multiple bones independently.
</div>
</div>

The result is as expected. Although the humerus matrix is rotating, the radius one keeps the same orientation all the time, resulting in a weirdly looking motion. 

## What about yaw, pitch, roll ?

So far, we have found a pretty convenient way of manipulating bones by directly overriding the rotation matrix.
However, this is not the only way of controlling the bones as we saw at the beginning of the post.
More precisely, we could spot another function that takes angles as parameters: 

<div class="code_frame"> ghoul2/G2.h </div>
{% highlight c++ linenos %}
qboolean G2_Set_Bone_Angles_Index(CGhoul2Info *ghlInfo, boneInfo_v &blist, const int index,
  const float *angles, const int flags, const Eorientations yaw,
  const Eorientations pitch, const Eorientations roll,
  const int blendTime, const int currentTime);
{% endhighlight %}


We can see that this function takes as parameter an array of angles.
The following parameters give more indications about these angles: yaw, pitch and roll.
These are actually three angles representing a way to describe [a rotation in space](https://en.wikipedia.org/wiki/Euler_angles#Tait%E2%80%93Bryan_angles), similarly to what we did with rotation matrices.

<div style="display: block; margin-left: auto; margin-right: auto; width: 50%;" markdown="1">
![Yaw, pitch, roll angles illustrated as commands of an aircraft.](https://thumb.wikimedia.org/wikipedia/commons/thumb/c/c1/Yaw_Axis_Corrected.svg/960px-Yaw_Axis_Corrected.svg.png?utm_source=en.wikipedia.org&utm_campaign=index&utm_content=thumbnail)
<div class="custom_caption" markdown="1">
\> Yaw, pitch, roll angles illustrated as commands of an aircraft. Image from [wikipedia](https://en.wikipedia.org/wiki/Aircraft_principal_axes).
</div>
</div>

This other way of using Ghoul2 is important because this mode is actually the one used in the JA's code.
You may notice with a simple search command that the functions that we saw up to now are not really used throughout the engine.
We have to search more deeply 🔍 to find functions that are actually used in the code.
For instance, function `BG_G2SetBoneAngles([..])` is called numerous times in file `cg_players.cpp`.
This aspect of function usage over the code is not intuitive and it took me a lot of time personally to find out what was usable 🤔.
For now, we will focus on this alternative way of controlling the bones from the `tr_main` function.

The signature of the function `G2_Set_Bone_Angles_Index` is similar to the one we used already.
It takes however an index as parameter rather than a bone name.
The other difference comes from the array of angles ands the `Eorientations` values, one for each angle apparently.
We can find a definition of `Eorientations` in `qcommon/q_shared.h` and we see that possible values are `POSITIVE_X`, `NEGATIVE_X`, `POSITIVE_Y`, etc.. .

We will make a first attempt at calling this function by sending values 0's for angles so that we expect to see the identity matrix for the humerus bone. 
By default, we can try to send parameters `POSITIVE_X`, `POSITIVE_Y` and `POSITIVE_Z` for the `Eorientations` and see what happens:

<div class="code_frame"> tr_main.cpp </div>
{% highlight c++ linenos %}
int humerus_ind = G2_Get_Bone_Index(&info, "rhumerus", qtrue);
float angles[3] = {0., 0., 0.};
G2_Set_Bone_Angles_Index(&info, info.mBlist, humerus_ind, angles, BONE_ANGLES_REPLACE, POSITIVE_X, POSITIVE_Y, POSITIVE_Z, 0, 0);
{% endhighlight %}


<div style="display: block; margin-left: auto; margin-right: auto; width: 30%;" markdown="1">
![The bone matrix shown (right shoulder) is not the identity.]({{site.baseurl}}/assets/ja_mod/pt4/euler_test1.png)
<div class="custom_caption" markdown="1">
\> The bone matrix shown (right shoulder) is not the identity.
</div>
</div>

We see that the resulting matrix is not the identity one.
We can try to correct this by changing the `Eorientations` parameters.
X (red) and Z (blue) axes seem inverted and with the wrong sign, we will change that:

<div class="code_frame"> tr_main.cpp </div>
{% highlight c++ linenos %}
G2_Set_Bone_Angles_Index(&info, info.mBlist, humerus_ind, angles, BONE_ANGLES_REPLACE, NEGATIVE_Z, POSITIVE_Y, NEGATIVE_X, 0, 0);
{% endhighlight %}

<div style="display: block; margin-left: auto; margin-right: auto; width: 30%;" markdown="1">
![The bone matrix shown is now the identity.]({{site.baseurl}}/assets/ja_mod/pt4/euler_test2.png)
<div class="custom_caption" markdown="1">
\> The bone matrix shown is now the identity.
</div>
</div>

The bone matrix looks like thee identity now ✅.
We will then try to use our animation test with the yaw, pitch, roll angles function.
To do so, we need a way to extract these angles from the animated bone matrix.
I used the answer from [this stackoverflow post](https://stackoverflow.com/questions/11514063/extract-yaw-pitch-and-roll-from-a-rotationmatrix) to compute the angles:

<div class="code_frame"> tr_main.cpp </div>
{% highlight c++ linenos %}
float angles[3];
angles[1]=atan2(bone_matrix.matrix[1][0],bone_matrix.matrix[0][0])*180./M_PI;
angles[0]=atan2(-bone_matrix.matrix[2][0],sqrt(bone_matrix.matrix[2][1]*bone_matrix.matrix[2][1]+bone_matrix.matrix[2][2]*bone_matrix.matrix[2][2]))*180./M_PI;
angles[2]=atan2(bone_matrix.matrix[2][1],bone_matrix.matrix[2][2])*180./M_PI;
G2_Set_Bone_Angles_Index(&info, info.mBlist, humerus_ind, angles, BONE_ANGLES_REPLACE, NEGATIVE_Z, POSITIVE_Y, NEGATIVE_X, 0, 0);
{% endhighlight %}

We can notice in this implementation that the angles are once again converted from radians to degrees because Ghoul2 expects degrees while trigonometric functions usually work with radians.
Then, we need to care about the order of the angles in the array.
It would be natural to send them in the "x,y,z" order but "yaw,pitch,roll" actually usually means: rotation around z first, then y, then x.
I also had to swap the two first angles here. I don't know exactly why 🤷 but it is possible that the convention used in the stackoverflow post is not the same (sometimes the y axis points upward).

<div style="display: block; margin-left: auto; margin-right: auto; width: 30%;" markdown="1">
![Our animation is now performed using yaw,pitch,roll angles.]({{site.baseurl}}/assets/ja_mod/pt4/euler_animation.gif)
<div class="custom_caption" markdown="1">
\> Our animation is now performed using yaw,pitch,roll angles.
</div>
</div>

Note 📝 that as it is mentioned in the original post, this way of extracting angles from the matrix is prone to numerical instabilities.
As suggested in the post, at some point I moved to the C++ libraries [Eigen](https://libeigen.gitlab.io/) for this mod to avoid additional issues.

## Conclusion

This post was an important piece to understand bone positioning in Jedi Academy.
I wanted to share my experience and more importantly give some hints and show how to make progress on technical projects by decomposing complex tasks into simpler ones.
In the next post, I will talk about the integration of the kinect into the game.
I will switch to a different format, closer to a devblog than a tutorial-style. 

