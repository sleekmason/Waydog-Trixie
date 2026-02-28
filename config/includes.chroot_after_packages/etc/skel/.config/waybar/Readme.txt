This Readme is specifically for the 'Waybar Main Size' setup. (Modules)

Though most of the options in the dialog are fairly self-explanatory,
the one option that is more involved is "Waybar Main Size". This button
changes the size of the Waybar modules and can allow for easy
customization.

Upon first press in a new setup, Waybar Main Size will create two files.
The first file is simply a state file telling us it has been run once.
The second file is module_defaults.ini.

The module_defaults.ini file contains the size values for all of the
modules and tasktray in Waybar. This can allow for easy size changes
when needed.

The values are taken from the style.css file on initial button press.
This means if you have an adjusted style.css, the correct size values
will be copied to module_defaults.ini, and whenever you press the
'Reset All' button, those copied values will be used.

The module_defaults.ini can then be used to change the module sizes on
the fly, by simply adjusting those values for your future reset use.

Questions:

* Okay, How do I set it to use system defaults instead of what I have?

Simply remove module_defaults.ini, and a new file will be created with
the current distro defaults as if just installed fresh.

* What if I've changed fonts/icons and have changed the sizes to match,
and now want it set as default so as not to overwrite my settings?

This is where that first_run state file comes in. Simply remove that
file as well as the module_defaults.ini, and on first press of
'Waybar Main Size' a new modules_default.ini will be created using the
current values in style.css.

Attention:

Be aware that if the state file exists, the values are copied from the
script.

If it doesn't exist, the values are copied from:
~/.config/waybar/style.css
