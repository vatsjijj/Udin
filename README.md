# Udin
This is the repository for the Udin programming language.

Udin is absolutely not production ready as I quickly assembled the entire language in a single day, there is no error checking or anything so you kinda have to know how to use the language internally to have a good time with it.

# Usage
`./udin [t, r, c] <filename> [o] <output name>`

For reference:

`t` -> transpile udin code to py

`r` -> run udin code

`c` -> compile code to a binary

`o` -> output

# Things to Do
Properly handle imports on other Udin files.

Add custom functionality, maybe better pattern matching.

# Installation
Linux is the only supported system for now.

Install `nim`, `nimble`, `python3`, and `pip3`.

You need to have `nuitka3`, `python3-devel`, and `gcc` installed to compile code to a binary.

Finally, run `nimble build` to build everything here, and run the generated binary.
