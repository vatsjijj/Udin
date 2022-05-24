# Udin
This is the repository for the Udin programming language.

Udin is absolutely not production ready as I quickly assembled the entire language in a single day, there is no error checking or anything so you kinda have to know how to use the language internally to have a good time with it.

The current version of Udin is `0.2.0`, a major release that adds the ability to import Udin files.

Some of these changes could be breaking, so don't be afraid to open up an issue.

# Usage
`./udin [t, r, c] <filename> [o] <output name>`

For reference:

`t` -> transpile udin code to py

`r` -> run udin code

`c` -> compile code to a binary

`o` -> output

Documentation will be written eventually, but for now, check out the example files to learn the language.

# Things to Do
Add custom functionality, maybe better pattern matching.

Add actual error handling, it's actually bad right now and I desperately need to fix it.

# Known Issues
You can't run anything if all the files aren't in the same directory as the command is being run.

No error handling when the source file is the same name as an import. When this happens, you just enter an infinite loop.

# Installation
Linux is the only supported system for now.

Install `nim`, `nimble`, `python3`, and `pip3`.

You need to have `nuitka3`, `python3-devel`, and `gcc` installed to compile code to a binary.

Finally, run `nimble build` to build everything here, and run the generated binary.

If you want to run the raylib example you need to have raylib installed.

# Submitting issues
Please please PLEASE submit the code that you were trying to run when the issue occured, it REALLY helps me when you take the time to do that. An expected result could be helpful to include as well.

Documentation requests are cool too and are appreciated.

Don't be afraid to also submit feature requests. I'm running outta ideas here!
