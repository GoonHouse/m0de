local res = {}
res.image = {
	{'border', 'media/images/border.bmp'},
	{'border-normals', 'media/images/border-normals.png'},
	{'left-hand-climber-hi', 'media/images/left-hand-climber-hi.png' },
	{'left-hand-climber-hi2', 'media/images/left-hand-climber-hi2.png' },
	{'left-hand-climber-hi3', 'media/images/left-hand-climber-hi3.png' },
	{'textureatlas', 'media/images/textureatlas.png',
		quad = {
			['A_left-hand-climber-hi']={ 0, 0, 402, 598, 512, 1024, 0, 0, 402, 598 },
			['A_left-hand-climber-hi2']={ 0, 600, 240, 357, 512, 1024, 0, 0, 240, 357 },
			['A_left-hand-climber-hi3']={ 242, 600, 120, 179, 512, 1024, 0, 0, 120, 179 }
		},
	},
	{'left-hand-climber-hi4', 'media/images/left-hand-climber-hi.png' },
	{'left-hand-climber-hi5', 'media/images/left-hand-climber-hi2.png' },
	{'left-hand-climber-hi6', 'media/images/left-hand-climber-hi3.png' },
	{'left-hand-climber-hi7', 'media/images/left-hand-climber-hi.png' },
	{'left-hand-climber-hi8', 'media/images/left-hand-climber-hi2.png' },
	{'left-hand-climber-hi9', 'media/images/left-hand-climber-hi3.png' },
	{'left-hand-climber-hi10', 'media/images/left-hand-climber-hi.png' },
	{'left-hand-climber-hi11', 'media/images/left-hand-climber-hi2.png' },
	{'left-hand-climber-hi12', 'media/images/left-hand-climber-hi3.png' },
}
res.imagedata = {
}
--Creates a new Source from a filepath, File, Decoder (steam/static) or SoundData.
res.source = {
}
--Contains raw audio samples. You can not play SoundData back directly. You must wrap a 'Source' object around it.
-- Sounddata -> Source -> play() -- soundata is automatically converted into source by TESound (mod. by me)
res.sounddata = {
}

return res
