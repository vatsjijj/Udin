## Udin5
The Udin5 programming language is a language that compiles down to Python, for easy use with other Python libraries and such.

Udin's syntax is inspired by Kotlin, Rust, Nim, and a *little bit* of Python.

The current version is 0.4.1.

## Supported Systems
Linux and Windows.

Windows support is highly experimental and may constantly break, proceed with caution.

Linux binaries are built and tested on Fedora 36, and Windows binaries are built and tested on Windows 10.

## Code Samples
Hello World:
```
fun helloFun() {
  put("Hello, world! I'm in a function!")
}

put("Hello, world!")
helloFun()
```

Fib:
```
enableMemo

@cache
fun fib(n: Int) :: Int {
  if n <= 1 {
    ret n
  }
  ret fib(n - 1) + fib(n - 2)
}

fun main() :: None {
  for i in 0..399 {
    put(i, fib(i))
  }
  put("Done")
}

nameMain {
  main()
}
```

Adding Numbers:
```
fun addTwo(a: Int, b: Int) :: Int {
  ret a + b
}

fun addThree(a: Int, b: Int, c: Int) :: Int {
  ret a + b + c
}

x: Int = 7
y: Int = 10
z: Int = 9

put(addTwo(x, y))
put(addThree(x, y, z))
```

Matching and Loops:
```
fun m(arg: Int) :: String {
  match arg {
    0 -> "zero"
    1 -> "one"
    _ -> "none"
  }
}

loop {
  uin: Int = Int(input("> "))
  put(m(uin))
}
```