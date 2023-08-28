# Detail Page

## Package Details

The contents of detail pages vary between packages. Nevertheless, each package will have at least this following information shown:

- **Name** in bold at the top of the screen.
- **Description** under the name.
- **Tap** the package was installed from.
- **Type**, whether it is a formula or a cask.
- **Homepage** of the project or developer.
- The date the package was installed on.
- The size of the package.

Under the package's name is an area where package status items might be displayed. However, not all packages have status items. These statuses might be:

- A list of packages that depend on this package, shown as **Dependency of [packages]**.
- Whether the package is **Outdated**.
- If you set Cork to show Package caveats as Minified, optional caveats will be displayed under **Has Caveats**. Click on the status item to reveal the caveats.

If a packages has dependencies, an additional item will be shown between **Homepage** and **Installed on**:

- **Dependencies** dropdown, which will show all package dependencies.
  - **Direct** dependencies are packages that are needed by the package itself.
  - **Indirect** dependencies are dependencies of direct dependencies.

There are two additional buttons at the bottom of the page:

- **Pin to version [package version]**: [Pin](../../package-operations/advanced/pin.md) the package to the currently-installed version.
- **Uninstall [package]**: [Uninstall]() the package.
  - If you enabled [Purging](../../package-operations/advanced/pin.md), the button will have the additional option of purging the package instead.

## Tap Details

Tap details pages show you basic info about the selected tap. Each details page contains the following items:

- **Name** in bold at the top of the screen.
- **Contents** of the tap; this specifies whether the tap has formulae or casks.
- **Homepage** of the tap, where the tap is configured.
- A list of included packages

Additionally, taps maintained by Homebrew developers have an icon next to the tap name to indicate that they are vetted for harmful packages.