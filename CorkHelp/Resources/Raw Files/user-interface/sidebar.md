# Sidebar

The Sidebar lets you quickly navigate through your installed [packages](../getting-started/main.md#basic-terms) and added [taps](../getting-started/main.md#basic-terms). 

![Sidebar](/Users/david/Documents/xCode Projekty/macOS/Cork/CorkHelp/Resources/Raw Files/user-interface/Assets/Sidebar.png)

When you click one of the packages or taps in the list, it will open in the Detail Area and show you more information about the selected item.

At the top of the package list, you can see the search field user for filtering out packages.

Above the search field, you can see the `Home` button, which you can use to go back to the start page when you have a package or tap opened in the Detail Area.

## Search Field

Not only can you use the search field to filter out packages by name, you can also use search filters to only look for packages that meet certain criteria. 

To show a list of available filters, write # into an **empty** search field. You can then select one from the list. You can choose any of these filters:

- **Formula**: Show only Formulae.
- **Cask**: Show only Casks.
- **Tap**: Show only Taps.
- **Manually Installed**: Show only packages that you have installed manually, and leave out all packages installed only as dependencies.

For example, you might have the package `wireguard` installed. This package is available as both a formula and a cask. To show only the Formula, apply the **Formula** filter, and then search for `wireguard`. You will only see the formula.

Another example is looking up formulae that were manually installed. To do this, apply the **Formula** filter, and then apply the **Manually Installed** filter.

## Quick Actions

When you right-click or Control-click a package or tap in the list, you will see some quick actions, depending on how you have configured Cork.

### Package Actions

For more info on the following actions, see the page [Package Operations](../package-operations/main.md).

- **Tag [package name]**: Mark a package of interest.
- **Untag [package name]**: Remove the tagged status from a package.
- **Uninstall [package name]**: Uninstall a package.
- **Purge [package name]**: Purge a package. See [Package Purging](../package-operations/advanced/purging.md) for more information

### Tap Actions

For more info on the following actions, see the page [Tap Operations](../tap-operations/main.md).

- **Remove [tap name]**: Remove a tap.