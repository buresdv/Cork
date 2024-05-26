# Cork

A fast GUI for Homebrew written in SwiftUI

[![Mastodon Link](https://img.shields.io/mastodon/follow/108939255808776594?domain=https%3A%2F%2Fmstdn.social&label=Follow%20me%20for%20updates&style=flat)](https://mstdn.social/@davidbures)
[![Discord Link](https://img.shields.io/discord/1083475351260377119?label=Talk%20to%20me%20on%20Discord&style=flat)](https://discord.gg/kUHg8uGHpG)

## Special Thanks

I'd like to personally thank [Seb Jachec](https://github.com/sebj) for implementing a system for getting real-time outputs of Brew commands. 

Without his contribution, many of the processes that depend on real-time outputs, such as installation, uninstallation and updating of packages, would be impossible.

I'd like to personally thank [Dmitri Bouniol](https://github.com/dimitribouniol) and [Ben Carlsson](https://twos.dev) for coming up with a way for self-compiled builds to bypass the license check.

Without them, it would be impossible to have a free self-compiled version of the app.

## Advantages of Cork

Cork is not just an interface for Homebrew. It has many features that are either very hard to accomplish using Homebrew alone, or straight-up not possible.

**Things that are not possible without Cork**

- [x] Automatically respecting system proxy.
- [x] Clearing of cached downloads.
- [x] Updating packages from the Menu Bar without having Cork open.
- [x] Seeing this much info about a package in one convenient location.
- [x] Tagging packages. This is a Cork-only feature that lets you mark any number of packages you'd like to keep track of.

**Things that Cork makes easier**

- [x] Listing of installed packages. Cork has its own way of loading packages, which is around 10 times faster than the Homebrew implementation.
- [x] Knowing which packages you installed intentionally, and which packages were installed only as dependencies. While somewhat possible with the `brew leaves` command, it is often unreliable, often not listing packages that should be included.
- [x] Updating of only selected packages. Again, while possible with Homebrew alone, Cork makes it so easy you wouldn't believe it is not this simple in Homebrew itself.
- [x] Showing you exactly which packages a package is a dependency of. Super annoying in Homebrew, effortless with Cork.
- [x] Effortlessly managing Homebrew services with a simple click of a button in a beutiful sub-window.
- [x] And many other features! Just try Cork out and try finding them all 😉

## Getting Cork

Pre-compiled, always up-to-date versions are available from my Homebrew tap. You can get access to it in a few ways:

- Buy Cork for 25€ through the [website](https://corkmac.app). You will get access to all future versions at no additional cost.
- Become a contributor. For example, you can:
  - Translate Cork into your language, and keep your translation updated. I'd recommend joining the [Cork Discord](https://discord.gg/kUHg8uGHpG), as I always ping the translators there when new text is ready for translating.
    If you aren't sure how to go about translating Cork, I'd recommend asking the translation team on Discord. They have the `Linguist` role.
    If you'd prefer to learn on your own, this Apple documentation article is a nice introduction to the process: [Internalization](https://developer.apple.com/documentation/xcode/adding-support-for-languages-and-regions).
  - Implement a feature tagged with `Help Wanted` in the [Issue Tracker](https://github.com/buresdv/Cork/issues?q=is%3Aissue+is%3Aopen+label%3A%22Help+Wanted%22).
    Please espect the coding style. The main deviation from the Swift convention is that [brackets are on their own lines](https://github.com/buresdv/Cork/blob/83e6ac9977d780328d7bfeddaf4df66dc3260521/Cork/Logic/JSON/Parse%20JSON.swift#L16).

However, if you don't want to do any of the above, you can always compile Cork yourself. See below for instructions.

## Screenshots
### Main Window
![Start Page](https://i.imgur.com/DNCsucp.png)

### Package Info
<p align="center">
  <img alt="Package Info" src="https://i.imgur.com/U8nCdlc.png" width="28%">
&nbsp; &nbsp; &nbsp; &nbsp;
  <img alt="Package Info - Full-size Caveats" src="https://i.imgur.com/lm2AhnX.png" width="28%">
  &nbsp; &nbsp; &nbsp; &nbsp;
  <img alt="Package Info - Minimized Caveats" src="https://i.imgur.com/KFonAHx.png" width="28%">
</p>

### Tap Info
<p align="center">
  <img alt="Tap Info - Formulae Only" src="https://i.imgur.com/VZi6jKK.png" width="47%">
&nbsp; &nbsp; &nbsp; &nbsp;
  <img alt="Tap Info - Formulae and Casks" src="https://i.imgur.com/ZCDlel6.png" width="47%">
</p>

### Install Package
<p align="center">
  <img alt="Install Package" src="https://i.imgur.com/c5BNkl3.png" width="28%">
&nbsp; &nbsp; &nbsp; &nbsp;
  <img alt="Install Package - Fetching Dependencies" src="https://i.imgur.com/x8qWBMO.png" width="28%">
  &nbsp; &nbsp; &nbsp; &nbsp;
  <img alt="Install Package - Installing Dependencies" src="https://i.imgur.com/dIgYKoj.png" width="28%">
</p>

### Add Taps
![Tap Taps](https://i.imgur.com/RKMUgM8.png)

### Brew Maintenance
<p align="center">
  <img alt="Brew Maintenance" src="https://i.imgur.com/Ky9kjPo.png" width="47%">
&nbsp; &nbsp; &nbsp; &nbsp;
  <img alt="Brew Maintenance Results" src="https://i.imgur.com/sxjbRg2.png" width="47%">
</p>

## Media
Do you run a blog, a magazine, make videos, or just make content about apps for fun? Get in touch at dev@corkmac.app!

I will provide you with the newest release and development version, answer any questions you have, and introduce you to Cork personally (and for free, or course), so you can focus on creating.

## Compiling Cork

Compiling Cork is simple, as it does not have many dependencies.

Prerequisites:

* macOS Ventura or newer
* Xcode 15 or newer
* Git

### Instructions:

**Before you begin**

*Skip if you already have an Apple Developer account*

0. Enroll your account in the developer program at [https://developer.apple.com/](https://developer.apple.com/). You don't need a paid account, a free one works fine
1. Install Xcode
2. Add your Developer account to Xcode. To do so, in the Menu bar, click `Xcode → Settings`, and in the window that opens, click `Accounts`. You can add your account there
3. After you add your account, it will appear in the list of Apple IDs on the left of the screen. Select your account there
4. At the bottom of the screen, click `Manage Certificates...`
5. On the bottom left, click the **+** icon and select `Apple Development`
6. When a new item appears in the list called `Apple Development Certificates`, you can press `Done` to close the account manager

**Compiling Cork**

0. I recommend you pick a version marked by one of the version tags. Those are released versions. If you decide to compile the current state of any of the branches, you might encounter experience-breaking bugs and unfinished features
1. Clone this repo using `git clone https://github.com/buresdv/Cork.git && cd Cork && open Cork.xcodeproj`. Xcode will open the project
2. Wait until all the dependencies are resolved. It should take a couple minutes at most
3. In the file browser on the left, click `Cork` at the very top. It's the icon with the App Store logo
4. In the pane that opens on the right, click `Signing & Capabilities` at the top
5. Under `Signing`, switch the `Team` dropdown to `None`
6. Under `Signing → macOS`, switch the `Signing Certificate` to `Sign to Run Locally`
7. If it isn't already selected, change the Build Scheme to `Self-Compiled` in Xcode's toolbar.
![Build Scheme Selector](https://files.catbox.moe/ofufd1.jpg)
> [!WARNING]  
> If you don't select the correct Build Scheme, Cork will require you to put in a license.
8. In the Menu Bar, click `Product → Archive` and wait for the building to finish
9. A new window will open. From the list of Cork rows, select the topmost one, and click `Distribute App`
10. In the popup that appears, click `Custom`, then click `Next` in the bottom right of the popup
11. Click `Copy App`
12. Open the resulting folder. You'll see an app called Cork. Drag Cork to your `/Applications/` folder, and you're done!

## License

Cork is licensed under [Commons Clause](https://commonsclause.com).

This means that Cork open-source and you can do whatever you want with Cork's source, like modifying it, contributing to it etc., but you can't sell or distribute Cork or modified versions of it.

Moreover, you can’t distribute compiled versions of Cork without consulting me first. Compiling versions for your personal use is fine.

[![Mutable.ai Auto Wiki](https://img.shields.io/badge/Auto_Wiki-Mutable.ai-blue)](https://wiki.mutable.ai/buresdv/Cork)