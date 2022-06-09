# Udin
Welcome to **Udin**!

The current version of Udin is `0.6.0`, a major release that fixes a major issue.

**WARNING: UDIN IS EXPERIMENTAL ON WINDOWS AND MAY NOT WORK RELIABLY**

**CONFIRMED WORKING ON WINDOWS. LAST CHECK: VER 0.6.0**

# Fun Stuff

The longest lived series of Udin were 0.1.x and 0.4.x, both going up to 0.1.5 and 0.4.5. Just a little fun fact.

The longest lived bug in Udin was a compilation/scan bug, where nothing would work if you weren't in the same directory as your sources. Started in 0.1.0 and finally ended in 0.6.0. That's 23 releases until it was fixed.

# Usage
`udin [g, r, c] <filename> [o] <output name>`

For reference:

`g` -> output generated py

`r` -> run udin code

`c` -> compile code to a binary

`o` -> output file

Documentation will be written eventually, but for now, check out the example files to learn the language.

# Things to Do
Add __*more*__ custom functionality.

Add better error handling.

# Installation
macOS is not officially supported.

Install `nim`, `nimble`, `python3`, and `pip3`.

You need to have `pyinstaller`, `python3-devel`, and `gcc` (in the case of Windows, you just need `pyinstaller` and `mingw`) installed to compile code to a binary.

Finally, run `nimble build -d:release` to build everything here, and run the generated binary.

# Submitting issues
Please please PLEASE submit the code that you were trying to run when the issue occurred, it REALLY helps me when you take the time to do that. An expected result could be helpful to include as well.

Documentation requests are cool too and are appreciated.

Don't be afraid to also submit feature requests.
