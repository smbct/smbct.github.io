---
title:  Modding Jedi Academy with the Kinect&#58 Visual debugging 1
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

As announced in the [preamble]({{site.baseurl}}/series/modding_ja/pt1) of the series, I started fresh on this project with a specific goal in mind: find a way to perform visual debugging 🖼️ in the game from the code source. I will present the coding setup of the mod here and detail how to alter the drawing part of the game. 

The first thing to know (from wikipédia for instance) is that Jedi Academy is based on a custom version of the [id Tech 3](https://en.wikipedia.org/wiki/Id_Tech_3) game engine. id Tech 3 is actually the game engine behind the game [Quake 3](https://en.wikipedia.org/wiki/Quake_III_Arena) 🎮. It has been used repetitively for developing games of the same genre and era such as [Call of Duty](https://en.wikipedia.org/wiki/Call_of_Duty_(video_game)) and [Medal of Honor](https://en.wikipedia.org/wiki/Medal_of_Honor:_Allied_Assault).
The engine is notably known for its very efficient implementation of the [inverse square root function](https://en.wikipedia.org/wiki/Fast_inverse_square_root): `Q_rsqrt(...)`, which code can still be found in Jedi Academy source code 😲! 

# Overview of the game engine code

Although Jedi Academy source code is unsurprisingly not well documented, some useful resources 📚 can still be found about the original id tech 3 sources. Some information can also be found around modding community forums, including on [Jedi Knight Hub](https://jkhub.org/). [This page](https://fabiensanglard.net/quake3/) by Fabien Sanglard gives a good overview of the code architecture.

![The id tech 3 engine architecture.](https://fabiensanglard.net/fd_proxy/quake3/q3_workspace_architecture2.png)
<div class="custom_caption" markdown="1">
\> The id tech 3 game engine architecture. Image from [fabiensanglard.net](https://fabiensanglard.net/quake3/).
</div>

The engine is split into a server side (2) and a client side (3). This separation allows to easily run the server part on an actual server and communicate with multiple clients in a multiplayer configuration 🛜. Hence, these two different part run their own [process virtual machines](https://en.wikipedia.org/wiki/Virtual_machine) and receive commands with the form of events. The two parts have their own directories in the source code: `game` and `cgame` respectively. Similar directories can be found in the [OpenJK](https://github.com/JACoders/OpenJK/tree/master/code) version of JA code.

# Setting up a development environment

The first thing to do is being able to compile ⚙️ and execute the code. A compilation tutorial is given on the [OpenJK repository](https://github.com/JACoders/OpenJK/wiki/Compilation-guide). I personally work on a Linux based OS and [CMake](https://en.wikipedia.org/wiki/CMake) but the port is also compatible with Windows and Visual Studio. It is obviously essential to own a valid copy of the game 💿 for any further action. It can be found today on multiple game platforms.

Compiling and lunching the game is repetitively performed in the development of any mod. I personally rely on CMake environment variables and commands to automatically install the mod after each modification of the code but other options are also possible. Lastly, a code editor adapted for large project is important, more precisely with a decent search functionality 🔍.

# Diving into the renderer code

Our goal in this post is to find a way to draw debugging information on the level. Drawing will only occur on the client side of the game because the server side is only dedicated to game logic 🎴. We can indeed see on the architecture image that the 🖥️ is directly linked to the client. In the original [code](https://code.idtech.space/raven/jediacademy/src/branch/master/code/) directory, it is possible to spot a `renderer` sub-directory, same name as the `.lib` in the figure. The renderer is actually a common name for the part in charge of drawing the scene.

We will now focus on the OpenJK code. The renderer is actually to be found in the `code/rd-vanilla` directory. Some time before 👴, the OpenJK documentation actually announced that several renderers were maintained in parallel. `vanilla` seems to be the only one that is officially conserved these days. In [this directory](https://github.com/JACoders/OpenJK/tree/master/code/rd-vanilla) we see files such as `tr_draw.cpp` and `tr_surface.cpp`. This is definitely the right place for drawing!

It is now time to start exploring ⌚. A good option is to proceed hierarchically 🪜. We first look at file names and then look at function names. Last, but not least, we  may look at the actual code in the functions. When an interesting functions is found, it is also useful to look at what functions call it (hence the search functionality). A good start here is the `tr_main.cpp` file. Let's look at the `R_GenerateDrawSurfs([...])` function for instance. It seems to be responsible for preparing the polygons that will be drawn on the screen. There are several function calls in it, for instance `R_AddEntitySurfaces ();`. What if we try to comment this call and lunch the game ? Note that a command can be passed to the game executable to load a level without going through the menu, for instance with `load jedi_01` to start from a savefile 🗃️.

<div style="display: flex; align-items: center; gap: 1rem; max-width: 100%">
<div style="display flex;"><img src="{{site.baseurl}}/assets/ja_mod/pt1/draw_entity.png" alt="The first Kinect for Windows." /></div>
<div style="display flex;"><img src="{{site.baseurl}}/assets/ja_mod/pt1/draw_no_entity.png" alt="The second Kinect for Windows." /></div>
</div>
<div class="custom_caption" markdown="1">
\> On the left, normal rendering with the OpenJK build. On the right, rendering after commenting the call to `R_AddEntitySurfaces`. 
</div>

We are onto something! Many objects in the level seem to actually be "entities", including the player itself. It is now worth looking at the content of`R_AddEntitySurfaces` to understand more. It is not necessary to understand everything in the function but rather get the general structure.

<div class="code_frame"> R_AddEntitySurfaces([...])</div>
{% highlight c++ linenos %}
// [...]
for ( tr.currentEntityNum = 0; tr.currentEntityNum < tr.refdef.num_entities; tr.currentEntityNum++ ) {
	ent = tr.currentEntity = &tr.refdef.entities[tr.currentEntityNum];
	//	[...]
	switch ( ent->e.reType ) {
		//	[...]
		case RT_MODEL:
			switch ( tr.currentModel->type ) {
				case MOD_MESH:
					R_AddMD3Surfaces( ent );
					break;
				//	[...]
				case MOD_MDXM:
					R_AddGhoulSurfaces( ent);
					break;
				//	[...]
			}
			// [...]
	}
}		
// [...]
{% endhighlight %}

There is a main loop 🔁 that seems to iterate over entities and add their surfaces (probably triangles) individually. We will now try to better understand`trRefEntity_t`. A big part of mastering the code comes from the understanding of data structures: where data is located and how it is stored. We can play a bit with the code by commenting some of the `R_Add[...]Surfaces(ent)` function calls. By doing so, we realize that `R_AddMD3Surfaces` concerns the objects of the level 📦 whereas `R_AddGhoulSurfaces` is for the characters 🧍. From the function, we see that it is possible to know the type of the entity from the well-named field `type`. An interesting thing to notice here as well is that `tr.refdef.entities` seems to be a global variable as it is not defined anywhere else in the code. This is going to be useful if we want to extract information from this structure.

## Looking for the 3D models 🔬

The search functionality is once helpful to find the definition of `refEntity_t`. It leads to the file `tr_local.h`. In the structure, we can find a lot of information such as a position (`origin`), an orientation (`axis`) and so on. The field `hModel` seems to indicate information about the 3D model of the entity but its type is not very helpful to extract information. Back to the function `R_AddEntitySurfaces()`, we can actually see the field being used in a function call:

{% highlight c++ linenos %}
tr.currentModel = R_GetModelByHandle( ent->e.hModel );
{% endhighlight %}

So `hModel` seems to be a sort of identifier a pointer to the actual model data. We can have a look at the function `R_GetModelByHandle()` to discover that the return type is actually `model_t`. The definition of this type is in fact just above the function definition in `tr_local.h` once again. We see fields that seem to be related to the model data and information, notably with a field `name`.

Let's try something: print the name of the current model in the entity loop in `R_AddEntitySurfaces`. We could use the standard C++ printing functions but the game engine actually provide its own function: `Com_Printf` that look alike the [C function](https://cplusplus.com/reference/cstdio/printf/) `printf`. Let's add the following line in the function just after the call to `R_GetModelByHandle()`:

{% highlight c++ linenos %}
// print the model name
Com_Printf("current model: %s\n", (tr.currentModel)->name);
{% endhighlight %}

When testing the game, we can now see in the terminal the name of the models that are being drawn in the scene! The text is also printed in the in-game terminal accessible with the key " ² ".

<div class="code_frame"> Terminal output</div>
{% highlight txt linenos %}
[...]
current model: models/map_objects/imperial/switch.md3
current model: models/map_objects/desert/wall_light.md3
current model: models/map_objects/desert/emitter.md3
current model: models/map_objects/desert/emitter.md3
current model: models/map_objects/desert/emitter.md3
current model: models/map_objects/desert/view_panel_desert.md3
current model: models/map_objects/desert/view_panel_desert.md3
current model: models/map_objects/desert/view_panel_desert.md3
[...]
{% endhighlight %}

# Drawing in the scene

We can now extract model information and print to the terminal. What about actually drawing in the scene ✏️ ?
A natural thing to do is to keep diving in the function calls, in particular with the `Add[...]Surfaces` ones and see how surfaces are actually processed. Unfortunately, the code of these functions is pretty obscure. Drawing pipelines in 3D applications actually process all surfaces as [a single buffer](https://wikis.khronos.org/opengl/Buffer_Object) for efficiency reasons.
Fortunately, this is not the only way to draw information. If we further study the `tr_main.cpp` file, we may find the following function: 

{% highlight c++ linenos %}
void R_DebugPolygon( int color, int numPoints, float *points ) {
	// [...]
	qglColor3f( color&1, (color>>1)&1, (color>>2)&1 );
	qglBegin( GL_POLYGON );
	for ( i = 0 ; i < numPoints ; i++ ) {
		qglVertex3fv( points + i * 3 );
	}
	qglEnd();
	// [...]
}
{% endhighlight %}

We can see wrapper calls around the [OpenGL standard](https://en.wikipedia.org/wiki/OpenGL) for 3D rendering (with the addition of a "q" for quake I suppose). A good thing here is that OpenGL is actually well documented with [many tutorials](https://rogerboesch.medium.com/the-opengl-tutorial-part-ii-28e89600565e) available (it is important to look at version 2 or bellow since more recent versions abandoned this type of simple drawing calls).

## A first drawing call

A natural question here is: where to put the drawing code ? As opposed to a simple print, drawing calls must be written in the right place because several states have to be initialized to prepare the image rendering. The `R_RenderView([...])` seems to be the general drawing function in `tr_main.cpp`. We will try to loop over entities in this one and display some 3D lines 📈. Here is the code to add at the end of the function:

{% highlight c++ linenos %}
R_IssuePendingRenderCommands();
for ( tr.currentEntityNum = 0; tr.currentEntityNum < tr.refdef.num_entities; tr.currentEntityNum++ ) {
	trRefEntity_t* ent = &tr.refdef.entities[tr.currentEntityNum];
	refEntity_t* e = &(ent->e);
	float shifted[3] = {e->origin[0], e->origin[1], e->origin[2]+100};
	GL_Bind( tr.whiteImage);
	qglColor3f(1, 0, 0);
	qglBegin(GL_LINES);
	qglVertex3fv( e->origin );
	qglVertex3fv( shifted );
	qglEnd();
}
{% endhighlight %}

We are looping over all entities and access their position (`origin`). Then, we draw a red line that starts from its origin and goes straight up (third value in `shifted`). Two notable points here: `GL_Bind( tr.whiteImage);` is necessary as the drawing calls seem to be performed in texturing mode. The second thing is a call to `R_IssuePendingRenderCommands()` required to make perform the drawing. I found a similar call in the `R_DebugGraphics()` function with the following comment: "the render thread can't make callbacks to the main thread". I am not able to precisely explain why the call is necessary 🤔 but it seems that because of the command system, some state must be cleared before performing the drawing calls. 

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![We can draw lines in the scene now.]({{ site.baseurl }}/assets/ja_mod/pt1/draw_line.png)
<div class="custom_caption" markdown="1">
\> We can draw lines in the scene now.
</div>
</div>

## Drawing bounding boxes

We will now tackle the actual objective of this post: drawing bounding boxes around entites. Bounding Boxes (bbox) are cubes ([rectangular cuboid](https://en.wikipedia.org/wiki/Rectangular_cuboid)) that completely includes the entity vertices. [Bounding boxes](https://en.wikipedia.org/wiki/Minimum_bounding_box) may be used in games and other 3D applications to perform fast collision tests and prevent from systematically iterate over all vertices of a model. By going through OpenJK renderer code, we can find the following function in `tr_model.h`:

<div class="code_frame"> R_RenderView</div>
{% highlight c++ linenos %}
void R_ModelBounds( qhandle_t handle, vec3_t mins, vec3_t maxs ) {
	// [...]
}
{% endhighlight %}

The function returns the minimum and maximum coordinates of the box for the 3 different axes. We can test this by drawing a line between the two points but the coordinates of the points are actually local to the entity and must be shifted by the entity's  origin (or global position):

<div class="code_frame"> R_RenderView</div>
{% highlight c++ linenos %}
vec3_t mins, maxs;
R_ModelBounds(e->hModel, mins, maxs );
for(int i = 0; i < 3; i ++) {
	mins[i] += e->origin[i];
	maxs[i] += e->origin[i];
}
GL_Bind( tr.whiteImage);
qglColor3f(1, 1, 1);
qglBegin(GL_LINES);
qglVertex3fv( mins );
qglVertex3fv( maxs );
qglEnd();
{% endhighlight %}

Now, to draw the complete bounding box we need to define all vertices and edges of a cube, as represented below.

<div style="display: block; margin-left: auto; margin-right: auto; width: 40%;" markdown="1">
![Vertices and faces of a cube](https://s1.qwant.com/thumbr/353x325/0/4/6b17b783a0ebab5ae065b2525d19f054c388c82bba1a2ecbe4ed7ed60978a4/OIP.tezvr2oDH4_7xBYzkenpYwAAAA.jpg?u=https%3A%2F%2Ftse.mm.bing.net%2Fth%2Fid%2FOIP.tezvr2oDH4_7xBYzkenpYwAAAA%3Fr%3D0%26pid%3DApi&q=0&b=1&p=0&a=0)
<div class="custom_caption" markdown="1">
\> Vertices and faces of a cube. Image from [McLean Quilve](https://mcleanquilve.blogspot.com/2022/05/how-to-draw-xyz-plane.html).
</div>
</div>

The code is long and does not worth a complete explanation. In summary, I separated the upper and lower faces of the cube (last component) and made sure that a line is drawn between two points only of there is exactly one change between these two. 

<div class="code_frame"> R_RenderView</div>
{% highlight c++ linenos %}
vec3_t mins, maxs;
R_ModelBounds(e->hModel, mins, maxs );
for(int i = 0; i < 3; i ++) {
	mins[i] += e->origin[i];
	maxs[i] += e->origin[i];
}
vec3_t vertex[8]; // cube vertex
// upper face
vertex[0][0] = mins[0]; vertex[0][1] = mins[1]; vertex[0][2] = maxs[2];
vertex[1][0] = mins[0]; vertex[1][1] = maxs[1]; vertex[1][2] = maxs[2];
vertex[2][0] = maxs[0]; vertex[2][1] = maxs[1]; vertex[2][2] = maxs[2];
vertex[3][0] = maxs[0]; vertex[3][1] = mins[1]; vertex[3][2] = maxs[2];
// lower face
vertex[4][0] = mins[0]; vertex[4][1] = mins[1]; vertex[4][2] = mins[2];
vertex[5][0] = mins[0]; vertex[5][1] = maxs[1]; vertex[5][2] = mins[2];
vertex[6][0] = maxs[0]; vertex[6][1] = maxs[1]; vertex[6][2] = mins[2];
vertex[7][0] = maxs[0]; vertex[7][1] = mins[1]; vertex[7][2] = mins[2];

GL_Bind( tr.whiteImage);
qglColor3f(1, 1, 1);
qglBegin(GL_LINES);
// lower face
qglVertex3fv( vertex[0] ); qglVertex3fv( vertex[1] );
qglVertex3fv( vertex[1] ); qglVertex3fv( vertex[2] );
qglVertex3fv( vertex[2] ); qglVertex3fv( vertex[3] );
qglVertex3fv( vertex[3] ); qglVertex3fv( vertex[0] );
// upper face
qglVertex3fv( vertex[4] ); qglVertex3fv( vertex[5] );
qglVertex3fv( vertex[5] ); qglVertex3fv( vertex[6] );
qglVertex3fv( vertex[6] ); qglVertex3fv( vertex[7] );
qglVertex3fv( vertex[7] ); qglVertex3fv( vertex[4] );
// connection
qglVertex3fv( vertex[0] ); qglVertex3fv( vertex[4] );
qglVertex3fv( vertex[1] ); qglVertex3fv( vertex[5] );
qglVertex3fv( vertex[2] ); qglVertex3fv( vertex[6] );
qglVertex3fv( vertex[3] ); qglVertex3fv( vertex[7] );
qglEnd();
{% endhighlight %}

Here is the result:

<div style="display: block; margin-left: auto; margin-right: auto; width: 80%;" markdown="1">
![The resulting bounding boxes.]({{site.baseurl}}/assets/ja_mod/pt1/draw_bbox.png)
<div class="custom_caption" markdown="1">
\> The resulting bounding boxes.
</div>
</div>

We are almost done! We can see that the main character does not have its own bounding box. Unfortunately, we cannot do much without a lot of additional effort because the characters are handled differently and the `R_ModelBounds([...])` function does not work here. The second issue is circled in red in the image: some bounding boxes are not well oriented. Actually the orientation is wrong ❌ for all entities as we do not account for their `axis` field. But it turns out that most of them are actually not rotated.

<div class="code_frame"> R_RenderView</div>
{% highlight c++ linenos %}
// draw orientation axis
vec3_t directions[3];
for(int i = 0; i < 3; i ++) {
	for(int j = 0; j < 3; j ++) {
		directions[i][j] = e->origin[j]+e->axis[i][j]*10.;
	}
}
qglDepthRange(0,0);
qglBegin(GL_LINES);
qglColor3f(1, 0, 0);
qglVertex3fv( e->origin ); qglVertex3fv( directions[0] );
qglColor3f(0, 1, 0);
qglVertex3fv( e->origin ); qglVertex3fv( directions[1] );
qglColor3f(0, 0, 1);
qglVertex3fv( e->origin ); qglVertex3fv( directions[2] );
qglEnd();
qglDepthRange(0,1);
{% endhighlight %}

Here I used the function ̀qglDepthRange(0,0);` to temporary disable the depth test, meaning that axis are displayed on top of everything. Otherwise, as they are located at the center of the entity, they would be almost always hidden.

<div style="display: block; margin-left: auto; margin-right: auto; width: 100%;" markdown="1">
![The bounding box is not aligned with the three orientation axis.]({{site.baseurl}}/assets/ja_mod/pt1/draw_bbox_axis.png)
<div class="custom_caption" markdown="1">
\> The bounding box is not aligned with the three orientation axis.
</div>

We need to *rotate* the bounding box vertices to correct the orientation. The `axis` field of the entity can actually be seen as a 3D [**rotation** matrix](https://en.wikipedia.org/wiki/Rotation_matrix). 3D transformations can actually be represented by matrices, *i.e.*, 2D arrays of numbers. Transforming a point is done by [multiplying its coordinates by the matrix](https://en.wikipedia.org/wiki/Matrix_multiplication). The code bellow achieves it:  


<div class="code_frame"> R_RenderView</div>
{% highlight c++ linenos %}
// rotate the vertices
for(int vert_ind = 0; vert_ind < 8; vert_ind ++) {
	vec3_t temp = {0,0,0};
	for(int i = 0; i < 3; i ++) { // rows
		for(int j = 0; j < 3; j ++) { // cols
			temp[i] += vertex[vert_ind][j]*e->axis[j][i];
		}
	}
	for(int i = 0; i < 3; i ++) {
		vertex[vert_ind][i] = temp[i]+e->origin[i];
	}
}
{% endhighlight %}

Note that vertices are actually rotated with respect to the local origin, at coordinates `(0,0,0)`. This is why we add the entity position (absolute origin) only after the orientation is computed, at the end of the loop. We now have the correct orientation of the bounding boxes:

<div style="display: block; margin-left: auto; margin-right: auto; width: 100%;" markdown="1">
![The bounding box are now correctly oriented.]({{site.baseurl}}/assets/ja_mod/pt1/draw_bbox_axis_orientation.png)
<div class="custom_caption" markdown="1">
\> The bounding box are now correctly oriented.
</div>

# Conclusion

This post gives an overview of what can be done with the code (basically everything). It is really about intensive trial and errors and educated guesses about the engine or the game. It is hard to directly make the correct guess but failed attempts ⛔ are also informative and help to make some progress about the code 🧑‍💻.

The next post will be about drawing the skeletons of the characters 🧍 in order to understand how they are animated 🤸. The current post has the form of a tutorial 🧑‍🎓 but it will progressively migrate toward a devblog format, where I will focus on covering ideas, the difficulties and solutions that helped me along the way. 
