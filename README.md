# Cork
A fast GUI wrapper for Homebrew written in SwiftUI

# WARNING: THIS APP IS STILL EARLY IN DEVELOPMENT
## You will encounter bugs, random crashes and updates that hang. There's minimal error checking for now. Use only at own risk for the time being!

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
