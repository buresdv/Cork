# Cork

A fast GUI for Homebrew written in SwiftUI

[![Mastodon Link](https://img.shields.io/mastodon/follow/108939255808776594?domain=https%3A%2F%2Fmstdn.social&label=Follow%20me%20for%20updates&style=flat)](https://elk.zone/mstdn.social/@davidbures)
[![Mastodon Link](https://img.shields.io/discord/1083475351260377119?label=Talk%20to%20me%20on%20Discord&style=flat)](https://discord.gg/kUHg8uGHpG)

## Special Thanks

I'd like to personally thank [Seb Jachec](https://github.com/sebj) for implementing a system for getting real-time outputs of Brew commands. 

Without his contribution, many of the processes that depend on real-time outputs, such as installation, uninstallation and updating of packages, would be impossible.

## Advantages of Cork

Cork is not just an interface for Homebrew. It has many features that are either very hard to accomplish using Homebrew alone, or straight-up not possible.

**Things that Cork makes easier**

- [x] Listing of installed packages. Cork has its own way of loading packages, which is around 10 times faster than the Homebrew implementation.
- [x] Knowing which packages you installed intentionally, and which packages were installed only as dependencies. While somewhat possible with the `brew leaves` command, it is often unreliable, often not listing packages that should be included.
- [x] Updating of only selected packages. Again, while possible with Homebrew alone, Cork makes it so easy you wouldn't believe it is not this simple in Homebrew itself.
- [x] Showing you exactly which packages a package is a dependency of. Super annoying in Homebrew, effortless with Cork.
- [x] And many other features! Just try Cork out and try finding them all 😉

**Things that are not possible without Cork**

- [x] Clearing of cached downloads.
- [x] Updating packages from the Menu Bar without having Cork open.
- [x] Seeing this much info about a package in one convenient location.
- [x] Tagging packages. This is a Cork-only feature that lets you mark any number of packages you'd like to keep track of.

## Getting Cork

Pre-compiled, always up-to-date versions are available from my Homebrew tap, which you get access to by donating 5€/month. You can donate through [Ko-Fi](https://ko-fi.com/buresdv) or [GitHub Sponsors](https://github.com/sponsors/buresdv).

However, as Cork is open source, you can always compile it from source for free. See below for instructions.

## Screenshots
### Main Window
![Start Page](https://i.imgur.com/N8HQtcL.jpg)

### Package Info
![Package Info](https://i.imgur.com/jQLTlOc.jpg)
![Package Info - Full-size Caveats](https://i.imgur.com/ysoa3Hs.jpg)
![Package Info - Minimized Caveats](https://i.imgur.com/vNwRUng.jpg)

### Tap Info
![Tap Info - Casks Only](https://i.imgur.com/Jn5BpuS.jpg)
![Tap Info - Formulae and Casks](https://i.imgur.com/9FghOAy.jpg)

### Install Package
![Install Package](https://i.imgur.com/CtqSCUu.jpg)
![Install Package - Fetching Dependencies](https://i.imgur.com/GuniTJH.jpg)
![Install Package - Installing Dependencies](https://i.imgur.com/EMmaSLA.jpg)

### Add Taps
![Tap Taps](https://i.imgur.com/bywcxaX.jpg)

### Brew Maintenance
![Brew Maintenance](https://i.imgur.com/TNYXFZQ.jpg)
![Brew Maintenance Results](https://i.imgur.com/UDNMz0i.jpg)

## Compiling Cork

Compiling Cork is simple, as it does not have many dependencies.

Prerequisites:

* macOS Ventura or newer
* Xcode 14.2 or newer
* Git

### Instructions:

**Before you begin**

*Skip if you already have an Apple Developer account*

0. Enroll your account in the developer program at [https://developer.apple.com/](https://developer.apple.com/). You don't need a paid account, a free one works fine
1. Install Xcode
2. Add your Developer account to Xcode. To do so, in the Menu bar, click `Xcode → Settings`, and in the window that opens, click `Accounts`. You can add your account there
3. After you add your account, it will appear in the list of Apple IDs on the left od the screen. Select your account there
4. At the bottom of the screen, click `Manage Certificates...`
5. On the bottom left, click the **+** icon and select `Apple Development`
6. When a new item appears in the list called `Apple Development Certificates`, you can press `Done` to close the account manager

**Compiling Cork**

1. Clone this repo using `git clone https://github.com/buresdv/Cork.git && cd Cork && open .`
2. Double-click `Cork.xcodeproj`. Xcode should open the project
3. Wait until all the dependencies are resolved. It should take a couple minutes at most
4. In the file browser on the left, click `Cork` at the very top. It's the icon with the App Store logo
5. In the pane that opens on the right, click `Signing & Capabilities` at the top
6. Under `Signing`, switch the `Team` dropdown to `None`
7. Under `Signing → macOS`, switch the `Signing Certificate` to `Sign to Run Locally`
8. In the Menu Bar, click `Product → Archive` and wait for the building to finish
9. A new window will open. From the list of Cork rows, select the topmost one, and click `Distribute App`
10. Click `Copy App`
11. Open the resulting folder. You'll see an app called Cork. Drag Cork to your `/Applications/` folder, and you're done!

## License

Cork is licensed under [Commons Clause](https://commonsclause.com).

This means that Cork open-source and you can do whatever you want with Cork's source, like modifying it, contributing to it etc., but you can't sell Cork or modified versions of it.

Moreover, you can’t distribute compiled versions of Cork without consulting me first. Compiling versions for your personal use is fine.
