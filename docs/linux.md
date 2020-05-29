## Intro to Linux

Hopefully you already have been exposed to Linux for a while in the Computer Science department.

However, since there is no real hard requirement for Linux in the department, you might be lacking some experience / exposure, or just need a reference or refresher.

Even for experienced Linux users, hopefully this document can serve as a reference or help accomplish things more easily.

## Terminal
You will spend a lot of time in the terminal, therefore it is good to be aquainted with some basics and helpful hints

### Autocomplete
In the terminal, many people waste a lot of time typing out entire commands.

The first thing to learn is that the terminal can autocomplete commands and directories for you.
All that is needed is to:
* start a command or path
* press `tab`
* Let the terminal complete the command or path
* If it doesn't complete it press `tab` again, it will list the alternatives.
* Type only the next letter that is needed to differentiate between the alternatives
* press `tab` again and repeat the process until you have your command

### Navigation
In the terminal you navigate around directories on your computer using the following commands:
* `cd /path/to/directory` changes directory to the new one
  * In order to navigate to a relative path omit the leading `/`
  * To navigate to a directory relative to your home directory start the path with `~/`
  * To navigate to home directory, you can omit the path entirely e.g. `cd `
  * To navigate up a directory, add two dots `../`
* `ls` to list files and directories in the current directory
* `cwd` to check what the current working directory is

### Manuals
`man command` will give you the manual for the command, and teach you what it can do and what options it has.

To exit the manual press `q`, to scroll press up or down keys or page up/page down.

To search press `/` and then start typing, press `enter` to start the search and `n` to go to the next match

