# Udin
Welcome to **Udin**!

Udin used to be called Udin5, since this is the fifth iteration of the language. Now, it is just called Udin.

The current version of Udin is `0.4.5`, a minor release that fixes a major bug with imports and makes the string error less frustrating and vague.

**WARNING: THE 0.4.0 SERIES IS HIGHLY EXPERIMENTAL ON WINDOWS AND MAY NOT WORK**

# Usage
`./udin [g, r, c] <filename> [o] <output name>`

For reference:

`g` -> output generated py

`r` -> run udin code

`c` -> compile code to a binary

`o` -> output file

Documentation will be written eventually, but for now, check out the example files to learn the language.

# Things to Do
Add __*more*__ custom functionality.

Add better error handling.

# Known Issues
- You can't run anything if all the files aren't in the same directory as the command is being run.

# Installation
macOS is not officially supported.

Install `nim`, `nimble`, `python3`, `mypy`, and `pip3`.

You need to have `pyinstaller`, `python3-devel`, and `gcc` (in the case of Windows, you just need `pyinstaller` and `mingw`) installed to compile code to a binary.

Finally, run `nimble build` to build everything here, and run the generated binary.

# Submitting issues
Please please PLEASE submit the code that you were trying to run when the issue occurred, it REALLY helps me when you take the time to do that. An expected result could be helpful to include as well.

Documentation requests are cool too and are appreciated.

Don't be afraid to also submit feature requests.
