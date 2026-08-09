---
title:  Modding Jedi Academy with the Kinect&#58 Visual debugging 2
author: smbct
date:   2026-07-30 10:00:00 +0200
categories: modding 
tags: programming modding video-games virtual-reality
comments: true
layout: series_article
series: modding_ja
back_page: headline.md
lang: en
---

In the [last post]({{site.baseurl}}/series/modding_ja/pt2) of the series, we have been able to hook into OpenJK's code and insert some new lines to draw bounding boxes 📦 around the entities.
We will now try to draw [the skeletons](https://en.wikipedia.org/wiki/Skeletal_animation) 🩻 that are used for the the characters animations.

The animation system used in Jedi Outcast and Jedi Academy does not actually originate from id tech 3 original engine. The system has been developed by Raven Software themselves under the name [GHOUL 2](https://en.wikipedia.org/wiki/Star_Wars_Jedi_Knight_II:_Jedi_Outcast) for the needs of their Star Wars games 🤺. This component provide a [ragdoll system](https://en.wikipedia.org/wiki/Ragdoll_physics) for the game: character's death animations are generated on the fly in reaction to their environment. 

## Drawing character orientations

We saw in the previous post that our bounding box code was not working with animated entities 🤸‍♂️ as opposed to static ones. We were still able to display the entities origin and axes (or orientation). This means that animated characters are part of the entities list. Let's start from our entity loop from the [previous part]({{site.baseurl}}/series/modding_ja/pt2) in the function `R_RenderView([...])`. By playing with the field `reType` of `refEntity_t` and the field `type` of the `model_t` struct, we can select only entities that corresponds to characters and draw their orientation (see function `R_AddEntitySurfaces (void)`): 

<div class="code_frame"> R_RenderView([...])</div>
{% highlight c++ linenos %}
for ( tr.currentEntityNum = 0; tr.currentEntityNum < tr.refdef.num_entities; tr.currentEntityNum++ ) {
	trRefEntity_t* ent = &tr.refdef.entities[tr.currentEntityNum];
	refEntity_t* e = &(ent->e);
	if(ent->e.reType != RT_MODEL) {
		continue;
	}
	model_t* currentModel = R_GetModelByHandle( ent->e.hModel );
	if(currentModel->type != MOD_BAD) {
		continue;
	}
	// [...]
	// drawing code
}
{% endhighlight %}

The reason why the type of the model corresponds to `MOD_BAD` is troubling but recall that it is not necessary to understand *everything* in the code at this point as we can rely on our tests.

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![We can select the characters and draw their orientation.]({{site.baseurl}}/assets/ja_mod/pt2/entity_axis.png)
<div class="custom_caption" markdown="1">
\> We can select the characters and draw their orientation.
</div>
</div>

## Looking for skeletal information

Let's start from the `refEntity_t` type that we are referencing in the code. In the definition 🔍 (`tr_types.h`), we can spot a field `CGhoul2Info_v *ghoul2;` that should be related to the Ghoul 2 animation engine . By searching the definition of `CGhoul2Info_v`, we can find that it is actually a class defined in `ghoul2_shared.h`. The class seems to be a container for objects of the type `CGhoul2Info`. Jumping once again, we end up in another class definition in the same file.

This is now interesting. In `CGhoul2Info`, we can see datatypes such as `boneInfo_v` and `boltInfo_v` and fields like `mSkelFrameNum`. This should be the correct place to find information ℹ️ about model animations since the skeleton should be defined from a list of bones 🦴. My first idea was to focus on `boneInfo_v`, which appears to be an alias for `std::vector<boneInfo_t>`. Following the definitions ➡️, we find that `boneInfo_t` is another struct that seem to contain positional information such as the field `lastPosition`.

Let's try to write a loop that extracts this specific field, try to draw it and print the coordinates in the terminal:
<div class="code_frame"> R_AddEntitySurfaces([...])</div>
{% highlight c++ linenos %}
R_IssuePendingRenderCommands();
GL_Bind( tr.whiteImage);
qglLineWidth(1);
for ( tr.currentEntityNum = 0; tr.currentEntityNum < tr.refdef.num_entities; tr.currentEntityNum++ ) {
	trRefEntity_t* ent = &tr.refdef.entities[tr.currentEntityNum];
	refEntity_t* e = &(ent->e);
	if(ent->e.reType != RT_MODEL) {
		continue;
	}
	model_t* currentModel = R_GetModelByHandle( ent->e.hModel );
	if(currentModel->type != MOD_BAD) {
		continue;
	}
	if(!ent->e.ghoul2) {
		continue;
	}
	CGhoul2Info_v& ghoul2 = *ent->e.ghoul2;
	for(int i = 0; i < ghoul2.size(); i ++) {
		CGhoul2Info &info = ghoul2[i];
		for(size_t bone_ind = 0; bone_ind < info.mBlist.size(); bone_ind ++) {
			boneInfo_t& bone_info = info.mBlist[bone_ind];
			Com_Printf("%f %f %f\n", bone_info.lastPosition[0], bone_info.lastPosition[1], bone_info.lastPosition[2]);
			vec3_t temp = {e->origin[0]+bone_info.lastPosition[0], e->origin[1]+bone_info.lastPosition[1], e->origin[2]+bone_info.lastPosition[2]};
			vec3_t temp2 = {e->origin[0]+bone_info.lastPosition[0], e->origin[1]+bone_info.lastPosition[1], e->origin[2]+bone_info.lastPosition[2]+100};
			qglDepthRange(0,0);
			qglBegin(GL_LINES);
			qglColor3f(1, 1, 1);
			qglVertex3fv(temp);
			qglVertex3fv(temp2);
			qglEnd();
			qglDepthRange(0,1);
		}
	}
}
{% endhighlight %}

The code is more complex, with 3 nested loops 🔁: one for the entity index, one for the model index in the entity? and one for the bone index. We then try to display the `lastPosition` of the bone as if it was local regarding the entity, shifting by its origin as we did before.

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![A first attempt to display bone information from the characters.]({{site.baseurl}}/assets/ja_mod/pt2/bone_attempt1.png)
<div class="custom_caption" markdown="1">
\> A first attempt to display bone information from the characters.
</div>
</div>
		
Obviously the result is not what we were hopping for. We can see in the terminal output that the `lastPosition` field is always null:

{% highlight bash linenos %}
[...]
0.000000 0.000000 0.000000
0.000000 0.000000 0.000000
0.000000 0.000000 0.000000
[...]
{% endhighlight %}

We can look further 👀 in the `boneInfo_t` struct in `ghoul2_shared.h` and test other fields. I spent some time exploring many of them but unfortunately, I was not able to find any relevant information. It was a dead end and we need a new idea. 

## Second attempt

We were previously exploring the renderer code 🖼️. It is clear that the renderer has access to the bone information since it is in charge of drawing the characters 🧍.
To find more information, we can have a look at the renderer function `R_AddGhoulSurfaces( trRefEntity_t *ent )` in `tr_ghoul2.cpp`. We already encountered a call to this function in `R_AddEntitySurfaces([...])`. In this function, we can spot calls to Ghoul 2 functions such as `G2_GetBoltMatrixLow([...])` and `G2_TransformGhoulBones([...])`. Aside from these calls, it is hard to get anything more instructive 🧑‍🎓.

We can now look at the `G2_TransformGhoulBones([...])` function in `tr_ghoul2.cpp` and try to get more details. This function takes a `CGhoul2Info` object as input and it seems to mainly process its member field `mBoneCache` 🦴. We can then see in the `CGhoul2Info` class definition that `mBoneCache` has type `CBoneCache` which is defined in `tr_ghoul2.cpp` once again.
Despite its name, `G2_TransformGhoulBones([...])` is probably not what we are looking for since it does not perform any complex computation (no function call, no complex operations, ...).

`G2_GetBoltMatrixLow([...])` might be more interesting 🤔. We see some matrix multiplication being performed with dedicated functions. More importantly, we see additional data types `mdxaSkel_t *skel;` and `mdxaSkelOffsets_t *offsets;` that seem to be related to the skeleton 🦿:

<div class="code_frame"> void G2_GetBoltMatrixLow([...])</div>
{% highlight c++ linenos %}
// [...]
mdxaSkel_t		*skel;
mdxaSkelOffsets_t *offsets;
offsets = (mdxaSkelOffsets_t *)((byte *)boneCache.header + sizeof(mdxaHeader_t));
skel = (mdxaSkel_t *)((byte *)boneCache.header + sizeof(mdxaHeader_t) + offsets->offsets[boneNum]);
Multiply_3x4Matrix(&bolt, &boneCache.Eval(boneNum), &skel->BasePoseMat); // DEST FIRST ARG
// [...]
{% endhighlight %}

These types also appear in the definition of `CBoneCache`: `int mNumBones;`, `mdxaSkel_t **mSkels;` and `CTransformBone *mFinalBones;`. 

What to do with all that information ? For now, we are not able to extract bone positions and or orientations from the *potentially-skeleton-related* data structures but we can spot some functions that could to do the computation for us.
However, we were initially looking for **bones** 🦴 and all we can get is something about **bolts** 🔩. There is a mention to both of these throughout the code.
At this point, it is possible to review the function definitions and spot an alternative function: `void G2_GetBoneMatrixLow(CGhoul2Info &ghoul2,int boneNum,const vec3_t scale,mdxaBone_t &retMatrix,mdxaBone_t *&retBasepose,mdxaBone_t *&retBaseposeInv)` that seem to perform the calculation for bones. Its content is similar to the one from `G2_GetBoltMatrixLow([...])`:

<div class="code_frame"> G2_GetBoneMatrixLow([...])</div>
{% highlight c++ linenos %}
// [...]
mdxaSkel_t		*skel;
mdxaSkelOffsets_t *offsets;
offsets = (mdxaSkelOffsets_t *)((byte *)boneCache.header + sizeof(mdxaHeader_t));
skel = (mdxaSkel_t *)((byte *)boneCache.header + sizeof(mdxaHeader_t) + offsets->offsets[boneNum]);
Multiply_3x4Matrix(&bolt, &boneCache.Eval(boneNum), &skel->BasePoseMat); // DEST FIRST ARG
retBasepose=&skel->BasePoseMat;
retBaseposeInv=&skel->BasePoseMatInv;
// [...]
{% endhighlight %}

Given the prefix **re** of its parameter's names, we can guess that these parameters actually contain the result of the computation ➗. The return type of these parameters is `mdxaBone_t`, a struct that contains a unique field `float matrix[3][4];` (`mdx_format.h`).

### Affine transformations in 3D

Apparently, 3D transformations in Ghoul2 and Jedi Academy (rotation, translation, ..) are performed using 3 rows and 4 columns matrices (the first index usually corresponds to the rows). We saw in the previous post that matrices are commonly used for computing 3D transformations 🦿. *3x4* matrices are one way of expressing [Affine transformations](https://www.brainvoyager.com/bv/doc/UsersGuide/CoordsAndTransforms/SpatialTransformationMatrices.html) by possibly combining translations, rotations and scaling. The matrix elements correspond to the blue part in the following illustration:

<div style="display: flex; align-items: center; gap: 0.5em; max-width: 100%">
<div style="display flex;"><img src="https://www.brainvoyager.com/bv/doc/UsersGuide/CoordsAndTransforms/Images/TransformationMatrix1.png" alt="Affine 3D transformations can be represented through 3x4 matrices." /></div>
<div style="display flex;"><img src="https://www.brainvoyager.com/bv/doc/UsersGuide/CoordsAndTransforms/Images/Translation-Matrix2.png" alt="A translation is a simple addition to the 4th column." /></div>
</div>
<div class="custom_caption" markdown="1">
\> Affine 3D transformations can be represented through 3x4 matrices. A translation is a simple addition to the 4th column. 
</div>

Let us assume that the bone orientation (position and translation) is returned in the 4th parameter: `retMatrix`. We can try to loop over the bones 🦴 of the entity model and call `G2_GetBoneMatrixLow([...])` with a given bone index to obtain information about its position. We then show the bone by drawing a line between the entity origin and its position. 

We previously spotted that the field `mBlist` of `CGhoul2Info_v` is actually a `std::vector<boneInfo_v>`, so basically a list of bones. Let's try to use its size for our bone loop 🔁. We locally define the matrices (of type `mdxaBone_t`) that are returned by the function to extract its result. The function actually takes pointers 👇 as parameters so these pointers need to be defined likewise. Then, we extract the third column of `retMatrix` to extract the assumed position of the bone 🦾 (see in the right picture above, the translation part of the matrix corresponds to the fourth column):

<div class="code_frame"> R_RenderView([...])</div>
{% highlight c++ linenos %}
// [...]
trRefEntity_t* ent = &tr.refdef.entities[tr.currentEntityNum];
// [...]
CGhoul2Info_v& ghoul2 = *ent->e.ghoul2;
for(int i = 0; i < ghoul2.size(); i ++) {
	CGhoul2Info &info = ghoul2[i];
	if(!info.mBoneCache) {
		continue;
	}
	for(int bone_ind = 0; bone_ind < info.mBlist.size(); bone_ind ++) {
		const vec3_t scale = {1, 1, 1};
		mdxaBone_t retMatrix, retBasepose, retBaseposeInv, retMatrix2;
		mdxaBone_t *ptr_retBasepose = &retBasepose, *ptr_retBaseposeInv = &retBaseposeInv;
		G2_GetBoneMatrixLow(info, bone_ind, scale, retMatrix, ptr_retBasepose, ptr_retBaseposeInv);
		vec3_t pos = {ent->e.origin[0], ent->e.origin[1], ent->e.origin[2]};
		vec3_t pos2 = {retMatrix.matrix[0][3], retMatrix.matrix[1][3], retMatrix.matrix[2][3]};
		qglBegin(GL_LINES);
		qglColor3f(1, 1, 1);
		qglVertex3fv( pos ); qglVertex3fv( pos2 );
		qglEnd();
	}
	// [...]
}
// [...]
{% endhighlight %}

Unfortunately, the above code does not compile yet ⚙️ because the function `G2_GetBoneMatrixLow([...])` is not defined in the file `tr_main.cpp`. A quick search indicates that this function is actually not defined in any header *.h* file. A simple solution to that problem is to re-define the function by adding a simple line of code above our loop, *outside* of any function: 

<div class="code_frame"> tr_main.cpp</div>
{% highlight c++ linenos %}
// [...]
void G2_GetBoneMatrixLow(CGhoul2Info &ghoul2,int boneNum,const vec3_t scale,mdxaBone_t &retMatrix,mdxaBone_t *&retBasepose,mdxaBone_t *&retBaseposeInv);
// [...]
void R_RenderView (viewParms_t *parms) {
// [...]
}
// [...]
{% endhighlight %}

As we see now in the screenshot bellow, the extracted position seem consistent with the body positions. However, we see lines going from one entity to another, suggesting a mismatch between the entity origin and the bone position.

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![We can select only the characters and draw their orientation.]({{site.baseurl}}/assets/ja_mod/pt2/bone_attempt2.png)
<div class="custom_caption" markdown="1">
\> We can select only the characters and draw their orientation.
</div>
</div>

An explanation to this issue can be found in the `G2_GetBoneMatrixLow([...])` function with the following line: `Multiply_3x4Matrix(&retMatrix,&worldMatrix, &bolt);`. The output matrix `retMatrix` is multiplied by a matrix `worldMatrix`. We can look further and see that this matrix is initialized in the function `G2_GenerateWorldMatrix(angles,position);` (for instance, in `G2_RagDollCurrentPosition([...])`). This matrix seems to be actually local to an entity? Let's try to add its initialization it in our bone drawing code:

<div class="code_frame"> tr_main.cpp</div>
{% highlight c++ linenos %}
for ( tr.currentEntityNum = 0; tr.currentEntityNum < tr.refdef.num_entities; tr.currentEntityNum++ ) {
	trRefEntity_t* ent = &tr.refdef.entities[tr.currentEntityNum];
	refEntity_t* e = &(ent->e);
	// [...]
	G2_GenerateWorldMatrix(e->angles,e->origin);
	// [...]
}
{% endhighlight %}

Once again, the definition of `G2_GenerateWorldMatrix([...])` needs to be added in the file `tr_main.cpp` to compile. With this additional initialization, the entity mismatch issue ↔️ is solved:

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![We can now successfully extract positions of the bones.]({{site.baseurl}}/assets/ja_mod/pt2/bone_attempt3.png)
<div class="custom_caption" markdown="1">
\> We can now successfully extract positions of the bones.
</div>
</div>


## Drawing the actual bones 🦴

Having access to the bone positions is good enough but now we want to actually draw the bones. We can expect the skeleton 🩻 to be defined hierarchically: every bone being linked to a *parent* one. For instance, the radius is likely to be linked 🔗 to the humerus 🦾. The hierarchy 🌲 means that if the parent bone moves, the children bone will be move the same.

At this stage, I tried to find such information in the `CGhoul2Info` data structure but I was not able to find anything about the hierarchy 📝. My second attempt was to look at the other function's names in the file `G2_bones.cppp`. Bingo 💯, we can find there a function `G2_GetParentBoneMatrixLow` with the same parameters than `G2_GetBoneMatrixLow` ✅. Let's try extract a second position from this assumed parent bone and draw a line between the two:

<div class="code_frame"> R_RenderView(viewParms_t *parms)</div>
{% highlight c++ linenos %}
qglDepthRange(0.,0.);
G2_GenerateWorldMatrix( ent->e.angles,ent->e.origin);
for(int bone_ind = 1; bone_ind < info.mBlist.size(); bone_ind ++) {
	const vec3_t scale = {1, 1, 1};
	mdxaBone_t retMatrix, retBasepose, retBaseposeInv, retMatrix2;
	mdxaBone_t *ptr_retBasepose = &retBasepose, *ptr_retBaseposeInv = &retBaseposeInv;
	G2_GetBoneMatrixLow(info, bone_ind, scale, retMatrix, ptr_retBasepose, ptr_retBaseposeInv);
	vec3_t pos = {retMatrix.matrix[0][3], retMatrix.matrix[1][3], retMatrix.matrix[2][3]};
	G2_GetParentBoneMatrixLow(info, bone_ind, scale, retMatrix2, ptr_retBasepose, ptr_retBaseposeInv);
	vec3_t pos2 = {retMatrix2.matrix[0][3], retMatrix2.matrix[1][3], retMatrix2.matrix[2][3]};
	qglBegin(GL_LINES);
	qglColor3f(1, 1, 1);
	qglVertex3fv( pos ); qglVertex3fv( pos2 );
	qglEnd();
}
qglDepthRange(0.,1.);
{% endhighlight %}

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![We start to see some bones but the skeleton is incomplete.]({{site.baseurl}}/assets/ja_mod/pt2/bone_attempt4.png)
<div class="custom_caption" markdown="1">
\> We start to see some bones but the skeleton is incomplete.
</div>
</div>

We are almost there the but skeleton is not complete yet. We need to find the correct number of bones in the skeleton related data structures. There is a `mNumBones` field in `mBoneCache` class (we saw it before). Let's try this one:

<div class="code_frame"> R_RenderView(viewParms_t *parms)</div>
{% highlight c++ linenos %}
// [...]
G2_GenerateWorldMatrix( ent->e.angles,ent->e.origin);
for(int bone_ind = 1; bone_ind < info.mBoneCache->mNumBones; bone_ind ++) {
	// [...]
}
// [...]
{% endhighlight %}

There is now a new definition issue because of `mBoneCache`. The class `CBoneCache` is only defined in `tr_ghoul2.cpp`.  A [forward declaration](https://en.cppreference.com/cpp/language/class) of it in `tr_main.cpp` would not work here because the access to one of its member is required. A simple fix consists in pasting the entire definition of the class in `tr_main.cpp`. This also requires to add the two following forward declaration: `struct SBoneCalc;` and `class CTransformBone;`:

<div class="code_frame"> tr_main.cpp</div>
{% highlight c++ linenos %}
// [...]
struct SBoneCalc;
class CTransformBone;
class CBoneCache
{
	// [...]
	// the class declaration goes here
};

{% endhighlight %}

We now have a complete skeleton 🥳:

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![The skeleton is now complete.]({{site.baseurl}}/assets/ja_mod/pt2/bone_attempt5.png)
<div class="custom_caption" markdown="1">
\> The skeleton is now complete.
</div>
</div>

## Few adjustments

Several improvements can be made. First, the skeleton actually contains a lot of bones, some of them not particularly useful (fingers for instance). It would be nice to filter the bones based on their names. There is actually a function  `char *G2_GetBoneNameFromSkel(CGhoul2Info &ghoul2, int boneNum);` that we can test in `tr_ghoul2.cpp`. Let's try to print the bone names in the terminal 🧑‍💻:

{% highlight c++ linenos %}
// [...]
Com_Printf("n bones: %d\n", info.mBoneCache->mNumBones);
for(int bone_ind = 0; bone_ind < info.mBoneCache->mNumBones; bone_ind ++) {
	const vec3_t scale = {1, 1, 1};
	char* bone_name = G2_GetBoneNameFromSkel(info, bone_ind);
	Com_Printf("Current bone: %d %s\n", bone_ind, bone_name);
}
// [...]
{% endhighlight %}

We find several entities with 53 bones, where names are self explanatory 🩻:

<div class="collapse-panel"><div>
<label for="code_1">Expand</label>
<input type="checkbox" name="" id="code_1"><span class="collapse-label"></span>
<div class="extensible-content">
<div class="code_frame"> Terminal output</div>
{% highlight bash linenos %}
n bones: 53
Current bone: 0 model_root
Current bone: 1 pelvis
Current bone: 2 Motion
Current bone: 3 lfemurYZ
Current bone: 4 lfemurX
Current bone: 5 ltibia
Current bone: 6 ltalus
Current bone: 7 rfemurYZ
Current bone: 8 rfemurX
Current bone: 9 rtibia
Current bone: 10 rtalus
Current bone: 11 lower_lumbar
Current bone: 12 upper_lumbar
Current bone: 13 thoracic
Current bone: 14 cervical
Current bone: 15 cranium
Current bone: 16 ceyebrow
Current bone: 17 jaw
Current bone: 18 lblip2
Current bone: 19 leye
Current bone: 20 rblip2
Current bone: 21 ltlip2
Current bone: 22 rtlip2
Current bone: 23 reye
Current bone: 24 rclavical
Current bone: 25 rhumerus
Current bone: 26 rhumerusX
Current bone: 27 rradius
Current bone: 28 rradiusX
Current bone: 29 rhand
Current bone: 30 r_d1_j1
Current bone: 31 r_d1_j2
Current bone: 32 r_d2_j1
Current bone: 33 r_d2_j2
Current bone: 34 r_d4_j1
Current bone: 35 r_d4_j2
Current bone: 36 rhang_tag_bone
Current bone: 37 lclavical
Current bone: 38 lhumerus
Current bone: 39 lhumerusX
Current bone: 40 lradius
Current bone: 41 lradiusX
Current bone: 42 lhand
Current bone: 43 l_d4_j1
Current bone: 44 l_d4_j2
Current bone: 45 l_d2_j1
Current bone: 46 l_d2_j2
Current bone: 47 l_d1_j1
Current bone: 48 l_d1_j2
Current bone: 49 ltail
Current bone: 50 rtail
Current bone: 51 lhang_tag_bone
Current bone: 52 face
{% endhighlight %}
</div></div></div>

We can see a symmetry in the bone's names with a *r* or *l* prefix, meaning left 👈 or right 👉. There are also *bones* that are not actual bones such as `reye`, `rblip2`, etc...  Based on this extraction  and some trials and errors, I defined a small list of bones 🦴 that is enough to draw a simple and complete skeleton:


<div class="code_frame"> R_RenderView(viewParms_t *parms)</div>
{% highlight c++ linenos %}
// [...]
std::vector<std::string> bone_draw = {"rclavical", "rhumerus", "rradius", "rhand", "lclavical", "lhumerus", "lradius", "lhand", "thoracic", "upper_lumbar", "lower_lumbar", "ltibia", "lfemurYZ", "ltalus", "rtibia", "rfemurYZ", "rtalus"};
for ( tr.currentEntityNum = 0; tr.currentEntityNum < tr.refdef.num_entities; tr.currentEntityNum++ ) {
	// [...]
	qglDepthRange(0.,0.);
	G2_GenerateWorldMatrix( ent->e.angles,ent->e.origin);
	Com_Printf("n bones: %d\n", info.mBoneCache->mNumBones);
	for(int bone_ind = 0; bone_ind < info.mBoneCache->mNumBones; bone_ind ++) {
		const vec3_t scale = {1, 1, 1};
		char* bone_name = G2_GetBoneNameFromSkel(info, bone_ind);
		if(std::find(bone_draw.begin(), bone_draw.end(), std::string(bone_name)) == bone_draw.end()) {
			continue;
		}
		// [...]
		// draw the bones
	}
	// [...]
}
{% endhighlight %}

The result is satisfying but there is still one drawing issue to solve. We can see that the skeleton is actually not well adjusted with the 3D character model. The offset seems bigger when the player is looking up:

<div style="display: flex; align-items: center; gap: 0.5em; max-width: 100%">
<div style="display flex;"><img src="{{site.baseurl}}/assets/ja_mod/pt2/bone_attempt6.png" alt="Debug rendering of a limited set of bones." /></div>
<div style="display flex;"><img src="{{site.baseurl}}/assets/ja_mod/pt2/bone_attempt7.png" alt="The skeleton is not well superposed with the character model." /></div>
</div>
<div class="custom_caption" markdown="1">
\> Debug rendering of a limited set of bones. The skeleton is not well superposed with the character model. 
</div>

The correction here is a bit tricky. The entity position and orientation is provided to the skeleton engine 🩻 through `G2_GenerateWorldMatrix( ent->e.angles,ent->e.origin);`. This function manipulates the `worldMatrix` global variable. The field `angles` of the entity is actually not what we previously used to display their orientation. We can try to remove this call and manually initialize the `worldMatrix` with the`axis` field this time. The first three columns of the matrix correspond to the orientation axes and the fourth one corresponds to the entity origin:

<div class="code_frame"> R_RenderView(viewParms_t *parms)</div>
{% highlight c++ linenos %}
// the static world matrix variable is referenced in this file
extern mdxaBone_t worldMatrix;
// [...]
// this loop replaces a call to G2_GenerateWorldMatrix( ent->e.angles,ent->e.origin)
for(int j = 0; j < 3; j ++) {
	for(int i = 0; i < 3; i ++) {
		worldMatrix.matrix[i][j] = ent->e.axis[j][i];
	}
	worldMatrix.matrix[0][0] = 1;
	worldMatrix.matrix[1][1] = 1;
	worldMatrix.matrix[2][2] = 1;
	worldMatrix.matrix[j][3] = ent->e.origin[j];
}
// skeleton drawing function
// [...]
{% endhighlight %}

The bone placement is now correct. It is hard to explain the difference between the fields `angles` and `axis` but once again, a complete understanding of the code is not required at this stage.

<div style="display: flex; align-items: center; gap: 0.5em; max-width: 100%">
<div style="display flex;"><img src="{{site.baseurl}}/assets/ja_mod/pt2/bone_attempt9.png" alt="The skeleton is not well superposed with the character model." /></div>
<div style="display flex;"><img src="{{site.baseurl}}/assets/ja_mod/pt2/bone_attempt8.png" alt="Debug rendering of a limited set of bones." /></div>
</div>
<div class="custom_caption" markdown="1">
\> The bone placement is now perfect. 
</div>

## Final touch

Only the bone positions are currently displayed but visualizing their orientation can also be useful for debugging their placement.
Instead of overloading the screen with superfluous information, we can select an additional subset of bones, the arms for instance 💪, to draw their orientation. The orientation is extracted as the first three columns of the matrix:

<div class="code_frame"> R_RenderView(viewParms_t *parms)</div>
{% highlight c++ linenos %}
// draw the bone matrix
std::vector<std::string> bone_matrix_draw = {"rhumerus", "rradius", "rhand", "lhumerus", "lradius", "lhand"};
if(std::find(bone_matrix_draw.begin(), bone_matrix_draw.end(), std::string(bone_name)) == bone_matrix_draw.end()) {
	continue;
}
float romat_scale = 3.;
qglLineWidth(2.5);
qglBegin(GL_LINES);
qglColor3f(1, 0, 0);
pos2[0] = pos[0]+retMatrix.matrix[0][0]*romat_scale; pos2[1] = pos[1]+retMatrix.matrix[1][0]*romat_scale; pos2[2] = pos[2]+retMatrix.matrix[2][0]*romat_scale;
qglVertex3fv( pos ); qglVertex3fv( pos2 );
qglColor3f(0, 1, 0);
pos2[0] = pos[0]+retMatrix.matrix[0][1]*romat_scale; pos2[1] = pos[1]+retMatrix.matrix[1][1]*romat_scale; pos2[2] = pos[2]+retMatrix.matrix[2][1]*romat_scale;
qglVertex3fv( pos ); qglVertex3fv( pos2 );
qglBegin(GL_LINES);
qglColor3f(0, 0, 1);
pos2[0] = pos[0]+retMatrix.matrix[0][2]*romat_scale; pos2[1] = pos[1]+retMatrix.matrix[1][2]*romat_scale; pos2[2] = pos[2]+retMatrix.matrix[2][2]*romat_scale;
qglVertex3fv( pos ); qglVertex3fv( pos2 );
qglEnd();
qglLineWidth(1.);
// [...]
{% endhighlight %}


This helps to understand the bone placement. We can see that the first axis in red is always oriented in the direction of the children bone.

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![We can select only the characters and draw their orientation.]({{site.baseurl}}/assets/ja_mod/pt2/bone_orientation.png)
<div class="custom_caption" markdown="1">
\> Bones are oriented so that the first axis is pointing toward the children bone's position.
</div>
</div>

Lastly, drawing all the skeletons makes the scene slightly confusing  😵‍💫 because skeletons are displayed on top of everything. For this reason, we can additionally limit the drawing 🖼️ to the player's skeleton only. It is however hard to find a field in `trRefEntity_t` or `refEntity_t` that indicates that an entity corresponds to the actual player 🎮. This is not surprising since this information is not really useful for drawing the scene. Luckily enough, we can however realize that the player is always the first animated entity, at index 0! We can now remove the entity loop to only process the player. Here is the final code:

<div class="collapse-panel"><div>
<label for="code_2">Expand</label>
<input type="checkbox" name="" id="code_2"><span class="collapse-label"></span>
<div class="extensible-content">
<div class="code_frame"> R_RenderView(viewParms_t *parms)</div>
{% highlight c++ linenos %}
// skeleton debug drawing
std::vector<std::string> bone_draw = {"rclavical", "rhumerus", "rradius", "rhand", "lclavical", "lhumerus", "lradius", "lhand", "thoracic", "upper_lumbar", "lower_lumbar", "ltibia", "lfemurYZ", "ltalus", "rtibia", "rfemurYZ", "rtalus"};
std::vector<std::string> bone_matrix_draw = {"rhumerus", "rradius", "rhand", "lhumerus", "lradius", "lhand"};

R_IssuePendingRenderCommands();
GL_Bind( tr.whiteImage);
qglDepthRange(0.,0.);
// select the first entity (player)
trRefEntity_t* ent = &tr.refdef.entities[0];
refEntity_t* e = &(ent->e);
if(ent->e.reType != RT_MODEL) {
	return;
}
model_t* currentModel = R_GetModelByHandle( ent->e.hModel );
if(currentModel->type != MOD_BAD) {
	return;
}
if(!ent->e.ghoul2) {
	return;
}

// setup "word" matrix			
for(int j = 0; j < 3; j ++) {
	for(int i = 0; i < 3; i ++) {
		worldMatrix.matrix[i][j] = ent->e.axis[j][i];
	}
	worldMatrix.matrix[j][3] = ent->e.origin[j];
}

CGhoul2Info_v& ghoul2 = *ent->e.ghoul2;
for(int i = 0; i < ghoul2.size(); i ++) {
	CGhoul2Info &info = ghoul2[i];
	if(!info.mBoneCache) {
		continue;
	}

	qglLineWidth(1);
	Com_Printf("n bones: %d\n", info.mBoneCache->mNumBones);
	for(int bone_ind = 0; bone_ind < info.mBoneCache->mNumBones; bone_ind ++) {
		const vec3_t scale = {1, 1, 1};
		char* bone_name = G2_GetBoneNameFromSkel(info, bone_ind);
		if(std::find(bone_draw.begin(), bone_draw.end(), std::string(bone_name)) == bone_draw.end()) {
			continue;
		}

		// compute the bone position
		mdxaBone_t retMatrix, retBasepose, retBaseposeInv, retMatrix2;
		mdxaBone_t *ptr_retBasepose = &retBasepose, *ptr_retBaseposeInv = &retBaseposeInv;
		G2_GetBoneMatrixLow(info, bone_ind, scale, retMatrix, ptr_retBasepose, ptr_retBaseposeInv);
		vec3_t pos = {retMatrix.matrix[0][3], retMatrix.matrix[1][3], retMatrix.matrix[2][3]};
		G2_GetParentBoneMatrixLow(info, bone_ind, scale, retMatrix2, ptr_retBasepose, ptr_retBaseposeInv);
		vec3_t pos2 = {retMatrix2.matrix[0][3], retMatrix2.matrix[1][3], retMatrix2.matrix[2][3]};

		// draw the bone
		qglBegin(GL_LINES);
		qglColor3f(1, 1, 1);
		qglVertex3fv( pos ); qglVertex3fv( pos2 );
		qglEnd();

		// draw the bone orientation
		if(std::find(bone_matrix_draw.begin(), bone_matrix_draw.end(), std::string(bone_name)) == bone_matrix_draw.end()) {
			continue;
		}
		float romat_scale = 3.;
		qglLineWidth(2.5);
		qglBegin(GL_LINES);
		qglColor3f(1, 0, 0);
		pos2[0] = pos[0]+retMatrix.matrix[0][0]*romat_scale; pos2[1] = pos[1]+retMatrix.matrix[1][0]*romat_scale; pos2[2] = pos[2]+retMatrix.matrix[2][0]*romat_scale;
		qglVertex3fv( pos ); qglVertex3fv( pos2 );
		qglColor3f(0, 1, 0);
		pos2[0] = pos[0]+retMatrix.matrix[0][1]*romat_scale; pos2[1] = pos[1]+retMatrix.matrix[1][1]*romat_scale; pos2[2] = pos[2]+retMatrix.matrix[2][1]*romat_scale;
		qglVertex3fv( pos ); qglVertex3fv( pos2 );
		qglBegin(GL_LINES);
		qglColor3f(0, 0, 1);
		pos2[0] = pos[0]+retMatrix.matrix[0][2]*romat_scale; pos2[1] = pos[1]+retMatrix.matrix[1][2]*romat_scale; pos2[2] = pos[2]+retMatrix.matrix[2][2]*romat_scale;
		qglVertex3fv( pos ); qglVertex3fv( pos2 );
		qglEnd();
		qglLineWidth(1.);
	}
	qglDepthRange(0.,1.);

}
{% endhighlight %}
</div></div></div>

And we have the final result for this skeleton drawing phase:

<div style="display: block; margin-left: auto; margin-right: auto; width: 70%;" markdown="1">
![We are finally able to draw the player's skeleton.]({{site.baseurl}}/assets/ja_mod/pt2/skeleton_final.png)
<div class="custom_caption" markdown="1">
\> We are finally able to draw the player's skeleton.
</div>
</div>

# Conclusion

This part was notably more difficult than the previous one due to the complexity of Ghoul2's code. Here I tried to re-create the thinking process 🤔 that I used when solving this task. However, remember that this is not the only solution 💡 and that multiple path may lead to the same solution anyway. It is clear that all the experience with game engine ⚙️ and 3D graphical coding is helpful here but the result remains achievable with less knowledge if one is investing a sufficient amount of time 🕣.

The ending result is useful enough but the process itself is also very helpful to understand how 3D orientation works and how it is implemented in Jedi Academy. The process of modding is greatly simplified as soon as one start to play and experiment with the code 🧑‍💻.