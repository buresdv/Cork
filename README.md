# Cork

A fast GUI for Homebrew written in SwiftUI

[![Follow me on Bluesky](https://img.shields.io/badge/Bluesky-0285FF?logo=bluesky&logoColor=fff&label=Follow%20me%20on&color=0285FF)](https://bsky.app/profile/buresdv.eu)
[![Discord Link](https://img.shields.io/discord/1083475351260377119?label=Talk%20to%20me%20on%20Discord&style=flat)](https://discord.gg/kUHg8uGHpG)
[![Mastodon Link](https://img.shields.io/mastodon/follow/108939255808776594?domain=https%3A%2F%2Fmstdn.social&label=Follow%20me%20for%20updates&style=flat)](https://mstdn.social/@davidbures)

# My whole life is falling apart right now, so the development of Cork will be impacted

## Special Thanks

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
- [x] Effortlessly managing Homebrew services with a simple click of a button in a beautiful sub-window.
- [x] And many other features! Just try Cork out and try finding them all 😉

## Getting Cork

Pre-compiled, always up-to-date versions are available from my Homebrew tap. You can get access to it in a few ways:

- Buy Cork for 25€ through the [website](https://corkmac.app). You will get access to all future versions at no additional cost.
- Become a contributor. For example, you can:
  - Translate Cork into your language, and keep your translation updated. I'd recommend joining the [Cork Discord](https://discord.gg/kUHg8uGHpG), as I always ping the translators there when new text is ready for translating.
    If you aren't sure how to go about translating Cork, I'd recommend asking the translation team on Discord. They have the `Linguist` role.
    If you'd prefer to learn on your own, this Apple documentation article is a nice introduction to the process: [Internalization](https://developer.apple.com/documentation/xcode/adding-support-for-languages-and-regions).
  - Implement a feature tagged with `Help Wanted` in the [Issue Tracker](https://github.com/buresdv/Cork/issues?q=is%3Aissue+is%3Aopen+label%3A%22Help+Wanted%22).
    Please respect the coding style. The main deviation from the Swift convention is that [brackets are on their own lines](https://github.com/buresdv/Cork/blob/83e6ac9977d780328d7bfeddaf4df66dc3260521/Cork/Logic/JSON/Parse%20JSON.swift#L16).

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

Compiling Cork is simple, as it does not have many dependencies. It uses Tuist to generate Xcode projects to speed up compilation.

Prerequisites:

* macOS Ventura or newer
* Xcode 16 or newer
* Git
* Homebrew

### Instructions:

#### Before you begin

*Skip if you already have an Apple Developer account*

0. Enroll your account in the developer program at [https://developer.apple.com/](https://developer.apple.com/). You don't need a paid account, a free one works fine
1. Install Xcode
2. Add your Developer account to Xcode. To do so, in the Menu bar, click `Xcode → Settings`, and in the window that opens, click `Accounts`. You can add your account there
3. After you add your account, it will appear in the list of Apple IDs on the left of the screen. Select your account there
4. At the bottom of the screen, click `Manage Certificates...`
5. On the bottom left, click the **+** icon and select `Apple Development`
6. When a new item appears in the list called `Apple Development Certificates`, you can press `Done` to close the account manager

#### Installing Tuist and Its Prerequisites

*Skip if you already have Tuist and Mise installed*

#### Installing Mise

*Cork uses Mise to prevent conflicts arising from mismatched Tuist versions across Macs. Mise is a tool similar to Homebrew, but offers some advantages for Tuist specifically, like the aforementioned version synchronization.*

1. Install Mise using `curl https://mise.run | sh`
2. Initialize Mise using the command you see after the installation finishes. It's located under `mise: run the following to activate mise in your shell:`.\
In my case, it was `echo "eval \"\$(/Users/david/.local/bin/mise activate zsh)\"" >> "/Users/david/.zshrc"`
> [!CAUTION]
> Make sure to copy the command Mise itself gives you, and not the one I used above. This command is only valid for my Mac, and will not work on your machine.

3. Add `mise` to your path using one of the following commands, depending on your shell.
- **zsh**: `echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc`
- **bash**: `echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc`
- **fish**: `echo '~/.local/bin/mise activate fish | source' >> ~/.config/fish/config.fish`
> [!TIP]
> **zsh** is the default macOS shell.

> [!NOTE]
> If you don't know which shell you're running, use the command `echo $SHELL`. The last part of the output after the last slash is the name of your shell
> In my case, the output of the command is `/bin/zsh`. This means my shell is `zsh`

4. Restart your shell. Sometimes, restarting the terminal is required.

#### Installing Tuist

1. Install Tuist using `mise install tuist`

#### Compiling Cork

0. I recommend you pick a version marked by one of the version tags. Those are released versions. If you decide to compile the current state of any of the branches, you might encounter experience-breaking bugs and unfinished features
1. Execute the following commands one after the other:
- `git clone https://github.com/buresdv/Cork.git`
- `cd Cork`
- `mise use tuist@latest`

  > At this point, if you try to use tuist (e.g. `which tuist`), the shell should be able to find it. If not, go back to the Mise installation steps or restart your terminal. Continue only if tuist is recognized as a command.

- `tuist install`
- `tuist generate --no-binary-cache`

  > At this point, Xcode will try to open the project.

<br>
<div style= "margin-left: 1rem">
  <details>
    <summary>What do these commands do?</summary>
    <br>
    <ol>
      <li><code>git clone https://github.com/buresdv/Cork.git</code> downloads the source code</li>
      <li><code>cd Cork</code> opens the folder you downloaded Cork into</li>
      <li><code>mise use</code> tells your system to use version <i>4.25.0</i> of Tuist to build Cork</li>
      <li><code>tuist install</code> downloads all Cork pre-requisites</li>
      <li><code>tuist generate</code> creates the Xcode project and opens it</li>
    </ol>
  </details>
</div>
<br>

2. Wait until all the dependencies are resolved. It should take a couple minutes at most
3. In the file browser on the left, click `Cork` at the very top. It's the icon with the App Store logo
4. In the pane that opens on the right, click `Signing & Capabilities` at the top
5. Under `Signing`, switch the `Team` dropdown to `None`
6. Under `Signing → macOS`, switch the `Signing Certificate` to `Sign to Run Locally`
7. If it isn't already selected, change the Build Scheme to `Self-Compiled` in Xcode's [toolbar](https://developer.apple.com/design/human-interface-guidelines/toolbars#macOS).
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

This means that Cork's source source is available and you can modify it, contribute to it etc., but you can't sell or distribute Cork or modified versions of it.

Moreover, you can’t distribute compiled versions of Cork without consulting me first. Compiling versions for your personal use is fine.