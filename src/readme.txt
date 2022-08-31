DiabloRL source readme
----------------------
This project is built using Lazarus IDE for FreePascal, and the Valkyrie library:

	https://sourceforge.net/projects/lazarus/files/
	http://www.freepascal.org/download.var
	https://fpcvalkyrie.svn.sourceforge.net/svnroot/fpcvalkyrie (trunk)

A full build for redistribution also requires a LUA compiler:

	http://luabinaries.sourceforge.net/

Relative paths are used and source files are expected to be arranged like so:

	/
		diablorl/
			bin/
			src/
		fpcvalkyrie
			lua/
			libs/
			src/

There are two Lazarus project files:

	rl.lpi  - main project
	mpq.lpi - compiled LUA generator

The LUA files are compiled for distribution of DiabloRL into a file diablorl.mpq. 
This is not necessary for development. Running the game with -god command line 
argument loads these LUA files at runtime instead.