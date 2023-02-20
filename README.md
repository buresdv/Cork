# Cork
A fast GUI wrapper for Homebrew written in SwiftUI

# WARNING: THIS APP IS STILL EARLY IN DEVELOPMENT
## You will encounter bugs, random crashes and updates that hang. There's minimal error checking for now. Use only at own risk for the time being!

# Special Thanks

I'd like to personally thank [Seb Jachec](https://github.com/sebj) for implementing a system for getting real-time outputs of Brew commands. 

Without his contribution, many of the processes that depend on real-time outputs, such as installation, uninstallation and updating of packages, would be impossible.

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
