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

Right now, if you want to import some other Udin source code, you have to transpile the module file first, and then it will be importable.

For example:

```
# test module, named "test.udin"
fun sayHello() {
  put("Hello, world!")
}

# now in the main file, called "module_test.udin"
from test import *

sayHello()

# now after you do this, transpile the
# "test.udin" file into "test.py" with
# './udin t test.udin o test' and then
# run "module_test.udin" with
# './udin r module_test.udin'
# alternatively you can also compile the
# "module_test.udin" file and that should work
# fine too.
# right now it's very annoying and
# clunky, so hopefully i can figure
# something out in the future
```

Documentation will be written eventually, but for now, check out the example files to learn the language.

# Things to Do
Properly handle imports on other Udin files.

Add custom functionality, maybe better pattern matching.

Add actual error handling, it's actually bad right now and I desperately need to fix it.

# Installation
Linux is the only supported system for now.

Install `nim`, `nimble`, `python3`, and `pip3`.

You need to have `nuitka3`, `python3-devel`, and `gcc` installed to compile code to a binary.

Finally, run `nimble build` to build everything here, and run the generated binary.

If you want to run the raylib example you need to have raylib installed.

# Submitting issues
Please please PLEASE submit the code that you were trying to run when the issue occured, it REALLY helps me when you take the time to do that. An expected result could be helpful to include as well.

Don't be afraid to also submit feature requests. I'm running outta ideas here!
