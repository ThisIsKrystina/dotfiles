What the CLI gives you (requires Snippety Pro + the app running):
Command	Use in Alfred workflow
snippety list "{query}" --json	Script Filter to search & present results
snippety expand <name> --in-app	Paste expanded snippet into the frontmost app
snippety add / edit / delete	Manage snippets from Alfred
snippety app-show / app-edit	Open specific snippets in the Snippety UI

How to build the workflow:
Script Filter – Run snippety list "{query}" --json and parse the JSON into Alfred's Script Filter format to show matching snippets as results.
Run Script / Copy to Clipboard – On selection, run snippety expand <selected> --in-app to paste the resolved snippet directly into whatever app is focused.
Optional: Open URL action – Use snippety://edit-snippet?id=... deeplinks to jump into the Snippety editor for a specific snippet.
