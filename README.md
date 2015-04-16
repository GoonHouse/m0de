m0de
====

Rev up those fryers!

screenshots
===========

![example-image](http://i.imgur.com/gn8KT54.png)

note
====

Everything below this line is verbatim from the [love2d_gametemplate](https://github.com/SiENcE/love2d_gametemplate) repo, so shouts to [@SiENcE](https://github.com/SiENcE)

love2d_gametemplate
===================

This is a gametemplate for LÖVE engine using middleclass, stateful, love-loader, TESound and cron libraries.

The base of this template is copied from kikito.

Features
==========
- The aim of this template is to seperate ressource loading from scenes.
- You can easily develop with seperate Image-Files and later merge them into an Texture-Atlas, without changing your code :-) !

Template description
==========
- A ressource reference is submitted to a Loading State and the ressources are loaded via 'love-loader' library.
- Loading of ressources is visualised via 'love-loader' library.
- After all ressources are loaded, the Loading-State switches to the Menu-Sate.
- All ressources are accessed via the global variable 'media'.
- All ressources share the same naming ... so you can overwrite existing ones using the same name.
- You can add additional ressources during any state switch.
- 'TESound' library is enhanced to also play sounddata.
- Tweening library 'flux' is included.

Sample
==========
definition of ressources using single image files:
```
local res = {}
res.images = {
	{'left-hand-climber-hi', 'media/images/left-hand-climber-hi.png' },
	{'left-hand-climber-hi2', 'media/images/left-hand-climber-hi2.png' },
	{'left-hand-climber-hi3', 'media/images/left-hand-climber-hi3.png' },
	{'textureatlas', 'media/images/textureatlas.png',
		quads = {
				['A_left-hand-climber-hi'] = { 2, 2, 402, 598, 406, 961 },
				['A_left-hand-climber-hi2'] = { 2, 602, 240, 357, 406, 961 },
				['A_left-hand-climber-hi3'] = { 244, 602, 120, 179, 406, 961 },
		}
	},
```

or using a Texture-Atlas:
```
local res = {}
res.images = {
	{'textureatlas', 'media/images/textureatlas.png',
		quads = {
				['left-hand-climber-hi'] = { 2, 2, 402, 598, 406, 961 },
				['left-hand-climber-hi2'] = { 2, 602, 240, 357, 406, 961 },
				['left-hand-climber-hi3'] = { 244, 602, 120, 179, 406, 961 },
		}
	},
```

same code using it:
```
media.quads['left-hand-climber-hi']:draw(0,0)
media.quads['left-hand-climber-hi3']:draw(love.mouse.getX(), love.mouse.getY())
```

References
==========
Script for TexturePacker (http://www.codeandweb.com/texturepacker) included!
or use https://github.com/Bradshaw/Fudge

more Infos here: http://love2d.org/forums/viewtopic.php?f=5&t=77918

License
==========
This gametemplate is distributed under the zlib/libpng License (http://opensource.org/licenses/Zlib)

All libraries used by this game_template are licensed under thier own licenses! 
