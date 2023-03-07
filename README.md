# Cork
A fast GUI for Homebrew written in SwiftUI

## Special Thanks

I'd like to personally thank [Seb Jachec](https://github.com/sebj) for implementing a system for getting real-time outputs of Brew commands. 

Without his contribution, many of the processes that depend on real-time outputs, such as installation, uninstallation and updating of packages, would be impossible.

## Getting Cork

Pre-compiled, always up-to-date versions are available from my Homebrew tap, which you get access to by donating 5€/month. You can donate through [Ko-Fi](https://ko-fi.com/buresdv) or [GitHub Sponsors](https://github.com/sponsors/buresdv).

However, as Cork is open source, you can always compile it from source for free. See below for instructions.

## Screenshots
### Main Window
![Main Window](https://i.imgur.com/4gEYEuB.jpg)

### Package Info
![Package Info](https://i.imgur.com/L7LyzmS.jpg)
![Package Info](https://i.imgur.com/ZHaEcOA.jpg)

### Install Package
![Install Package](https://i.imgur.com/sWt6xlw.jpg)
![Install Package](https://i.imgur.com/Agc7zxX.jpg)

### Tap Taps
![Tap Taps](https://i.imgur.com/Dya1SkM.jpg)

### Brew Maintenance
![Brew Maintenance](https://i.imgur.com/LGkDErZ.jpg)
![Brew Maintenance Results](https://i.imgur.com/GbTerQX.jpg)

## Compiling Cork

Compiling Cork is simple, as it does not have many dependencies.

Prerequisites:

* Xcode 14.2 or newer
* Git
* An Apple Developer accout. **You don't need a paid one! Even a free one works perfectly**

Instructions:

0. Before you begin, you need to add your Developer account to Xcode. To do so, in the Menu bar, click `Xcode → Settings`, and in the window that opens, click `Accounts`. You can add your account there.
1. Glone this repo using `git clone https://github.com/buresdv/Cork.git && cd Cork && open .`
2. Double-click `Cork.xcodeproj`. Xcode should open the project
3. Wait until all the dependencies are resolved. It should take a couple minutes at most
4. In the Menu Bar, click `Product → Archive` and wait for the building to finish
5. A new window will open. From the list of Cork rows, select the topmost one, and click `Distribute App`
6. Click `Developer ID`, `Export`, choose your account from the *Development Team* dropdown, and select `Automatically manage signing`. After Xcode finishes, click `Export`
7. Open the resulting folder. You'll see a few files, and an app called Cork. Drag Cork to your `/Applications/` folder, and you're done!

