DiabloRL Sound Setup
--------------------
If you have a disc of the original Diablo game, the sounds can be used to enhance
your DiabloRL experience.

A simple command-line utility is provided to extract the sounds from the original
media. Usage:

	mpqx filename
	
where filename is replaced with the full path of the file "diabdat.mpq" from the
Diablo CD-ROM.

This will create several sound and music folders totaling about 250MB of disk
space. 

Now edit diablorl.ini and adjust the following lines to your preference:

[Sound]
MusicVolume=100
SoundVolume=100

Both values may range from 0-100 where 0 means no sound/music and 100 means
full volume.