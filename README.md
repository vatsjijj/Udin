# Udin
<img src="https://github.com/vatsjijj/Udin/blob/main/udin.png?raw=true" width="25%" height="25%">

Welcome to **Udin**!

The current version of Udin is `0.7.1`, a minor release that fixes some issues.

**WARNING: UDIN IS EXPERIMENTAL ON WINDOWS AND MAY NOT WORK RELIABLY**

**LAST WINDOWS CHECK: VER 0.7.0**

## Usage
`udin [g, r, c] <filename> [o] <output name>`

For reference:

`g` -> output generated py

`r` -> run udin code

`c` -> compile code to a binary

`o` -> output file

Documentation will be written eventually, but for now, check out the example files to learn the language.

## Things to Do
Change output language to take dependencies from six to three.

Change syntax.

Add better error handling.

# Installation
macOS is not officially supported.

Install `nim`, `nimble`, `python3`, and `pip3`.

You need to have `pyinstaller`, `python3-devel`, and `gcc` (in the case of Windows, you just need `pyinstaller` and `mingw`) installed to compile code to a binary.

Finally, run `nimble build -d:release` to build everything here, and run the generated binary.

If you're on Linux, you can copy the binary to `~/.local/bin` or `/usr/bin`, somewhere like that, I trust you.

If you're on Windows, the easiest thing to do would just be to add the build directory to your user PATH.

## Submitting issues
Please please PLEASE submit the code that you were trying to run when the issue occurred, it REALLY helps me when you take the time to do that. An expected result could be helpful to include as well.

Documentation requests are cool too and are appreciated.

Don't be afraid to also submit feature requests.
