# Getting Started

Cork is a graphical user interface for Homebrew. Homebrew is a very powerful package manager for macOS, which is something like the App Store. It allows you to install apps and terminal utilities from a centralized location, without having to go to a developer's website.

You can refer to Homebrew's [website](https://brew.sh) to learn more.

## Relationship Between Cork and Homebrew

Cork serves as a graphical user interface for Homebrew.

The biggest disadvantage of Homebrew is that you have to interact with it through the Terminal, instead of it being a standalone app like Messages or Safari.

You can use Cork to work with Homebrew through a more convenient user interface.

In essence, you can use Homebrew without Cork, but you can't use Cork without Homebrew.

## Cork Terminology

While Cork inherits most terminology from Homebrew, it makes a few changes to be more understandable.

### Basic Terms

| Term    | Example Usage                                                | Explanation                                                  |
| ------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| Package | *Install Packages*<br />*Outdated Packages*                  | App installed through Homebrew / Cork.                       |
| Formula | *Package is a Formula*<br />*Installed Formulae*             | Package that is used through Terminal.                       |
| Cask    | *Package is a Cask*<br />*Installed Casks*                   | Package that has a graphical window.                         |
| Update  | *Update Packages*<br />*Fetching Updates…*                   | Process which check for outdated packages, but does not install any new versions. |
| Upgrade | *Applying Package Upgrades…*<br />*Upgrade All Packages*     | Process which will download and install the latest versions of outdated packages. |
| Tap     | *Tap Includes no Packages*<br />*homebrew/core is an official Tap* | List of packages, which lets you install packages not present in base Homebrew. |