# Cork
A fast GUI wrapper for Homebrew written in SwiftUI

# WARNING: THIS APP IS STILL EARLY IN DEVELOPMENT
## You will encounter bugs, random crashes and updates that hang. There's minimal error checking for now. Use only at own risk for the time being!

# What can I do?
If you'd like to help develop Cork, there's one thing that is holding the app back: the shell interface.

In short, it's the system by which Cork issues terminal commands and receives their outputs. As it is now, it has to wait for the entire command to finish and return an output. I cannot figure out how to get real-time output from a running command.

If you'd like to have a crack at it, see the file `Logic -> Shell -> Shell Inteface.swift`. The function that issues terminal commands and receives their outputs is there.

**The requirements for an improved shell interface are:**
- It has to be somewhat integratable with the existing codebase. I'm not against changing the code a bit, but I will not be rewriting the app's entire logic to make a new interface work.
- It has to have two modes: one that returns real-time output, and one that waits for the command to finish and only then returns its output.
- It has to support getting outputs both from *standard output* and *standard error*.
- It does not have to be written strictly in Swift, as long as it works with Swift. If you can somehow make this work in Objective C or C, more power to you. I just need the function to be able to issue commands from Swift, and to receive the outputs in Swift.

If you think you have what it takes, feel free to try this challenge out. If you figure out, you will get my gratitude, along with a top stop in the contributors list and a special shoutout in the README.

# Contributing Protips
If you want to make your commit messages stand out, you can use my syntax for marking additions/removals/adjustments/etc.
- **+** for **additions**. When you add a new feature or function, mark it with +
- **-** for **removals**. When you remove something, mark it with -
- **^** for **fixes**. When you fix a bug, mark what the bug was with ^
- **~** for **adjustments**. When you change somethingm but it still works the same, mark it with ~

When you're using this system, you no longer have to say *Removed old parsing function*, you can just write *- Old parsing function*. Or instead of *Fixed infinite loading bug*, you can say *^ Infinite loading bug*.

Of course, you don't have to use this system, but I use it with my commits to reduce their length, so you're welcome to do so, too.

## Screenshots
### Main Window
![Main Window](https://i.imgur.com/4gEYEuB.jpg)

### Package Info
![Package Info](https://i.imgur.com/KX7D0Ny.jpg)

### Install Package
![Install Package](https://i.imgur.com/izo0E3X.jpg)

### Tap Taps
![Tap Taps](https://i.imgur.com/119KoKV.jpg)

## Current Limitations
### Minimal error checking
As it is now, none of the operations have error checking implemented. This means that if a Brew operation fails on something or Brew hangs, the entire app will also hang. I will address this soon.

### Convoluted logic
This was one of my first projects almost a year ago that I have resurrected recently. This means that in some places, the old logic from times when I wasn't that good of a programmer is still present. I am continuously refactoring and updating old code to make it work better, but it takes time, especially because I am focused on adding new core features to achieve a minimum viable product.

### Tapping a tap doesn't actually tap the tap due to a debug process
While the logic to tap taps is implemented and working, the app will immediately remove the tap after it successfuly finishes tapping it. This is because I'm hunting down a bug that only happens when a tap is tapped, so to save myself the trouble of constantly untapping a tap manually to re-tap it again, the app instead untaps it for me.
**If you want to disable this behavior:**
- Open the file Views/Taps/Add Tap.swift
- Remove variable "untapResult" and all of its uses
- The tapping will now work properly
