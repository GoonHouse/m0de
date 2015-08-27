# m0de
This thing is a mess meant to replace [Marin0SE](https://github.com/GoonHouse/Marin0SE) and all that fancy jazz. It's supposed to right the wrongs of man and solve original sin. Or at least not be a complete failed rewrite if Mari0. Who knows.

# todo
Sometimes I forget what I'm doing, this is here to compensate for that.
* get object serialization up and going with [lady](https://github.com/gvx/Lady) if it isn't merged into binser first.
* maybe use meshes for box2d debug drawing? lines are crazy, yo.
* make the networking model update its own system
* make the networking components entities like the rest of them
* anything that contains __index__.lua gets mounted to root
* main menu routing? who knows

# very done
* get rid of tserial and throw it in the lake, probably use [binser](https://github.com/bakpakin/binser)
	* used binser in hopes that the promise of per-class object serialization will kick ass

# screenshots
![example-image](http://i.imgur.com/gn8KT54.png)

# note
This was based on the [love2d_gametemplate](https://github.com/SiENcE/love2d_gametemplate) repo, so shouts to [@SiENcE](https://github.com/SiENcE).
I also BORROWED some stuffs from [CommandoKibbles](https://github.com/bakpakin/CommandoKibbles) to get my bearings with [tiny-ecs](https://github.com/bakpakin/tiny-ecs)

# dev notes
some things to keep me sane

## properties to expect from tiled:
```lua
{
	name = "",
	id = 9,
	
	properties = {
		propertyname = "every property value is a string",
	},
	
	shape = "rectangle",
	rectangle = {
		{x=1200,y=1008},
		{x=1264,y=1264},
		...
	},
	
	x = 1200,
	y = 1008,
	rotation = 0,
	height = 64,
	width = 64,
}
```