## Using Git

Some basic git commands:
These all have to happen within the repository folder on the command line
* `git pull` -- pulls the latest updates from the remote server
* `git push` -- pushes your local commits to the remote server
* `git commit -am "my message"` -- adds a local commit with all the local changes you have made with the commit message "my message"
* `git add .` -- adds all of the files that are not currently being tracked in this directory to git
  * Warning: This will include files that we don't care about unless you add them to the .gitignore of the repository
* `git checkout branch_name` -- checks out a pre-existing branch named "branch_name" for you to work on
* `git checkout -b branch_name` -- creates and checks out a branch named "branch_name" for you to work on
* `git push -u origin branch_name` -- adds the local branch named "branch_name" to the remote server and calls the remote branch "branch_name"
* `git status` -- shows you the status of a specific repository such as what files are and aren't committed and what branch you are on
* `git stash` -- stashes the changes you have made, so that you can pull down updates without committing your changes, you can 'unstash' them to try to apply your changes on top of the new stuff you pulled down, but generally I only stash stuff to get rid of changes that were not important (such as a generated file or other unimportant file). If you want to save your changes it would be better to commit them before pulling.

### Git Extras
There is a handy set of git extensions that you can install on your machine to help with a few git tasks:
* Install `sudo apt install git-extras`

Commands (that I use):
* `git ignore path/to/file ` -- adds a file/directory to the gitignore in the repository

## Multi-Repository git assistance
Managing multiple git repositories can get tedious and annoying, there are a few tools that help with repository management, that we will mention here.

### The rosinstall file

There is a .rosinstall file in the root of the sawyer_ws repository. This file specifies all of the repositories that we use, and their directories for organization. It also specifies which branch to download / use, for those repositories. It is heavily used by the wstool tool to manage all of the repositories, but has the side effect of checking out different branches than you might have been working on. Unless you updated the .rosinstall to pull your new branch. VCS tool doesn't depend on the file except to setup / clone / pull all of your repositories in the first place. They both have their advantages, but we are slowly moving towards using vcstool more.

### Using vcstool
VCS tool is a tool for managing multiple repositories: [link to github](https://github.com/dirk-thomas/vcstool)

#### To Install

`sudo sh -c 'echo "deb http://packages.ros.org/ros/ubuntu $(lsb_release -sc) main" > /etc/apt/sources.list.d/ros-latest.list'`

`sudo apt-key adv --keyserver hkp://pool.sks-keyservers.net --recv-key 0xAB17C654`

`sudo apt-get update`

`sudo apt-get install python3-vcstool`


It is used by the ros community and is the replacement for the wstool command we have been using in the past.
We should probably start using more vcstool commands rather than wstool, since wstool is deprecated, though wstool is handy too.

Autocompletion (tab completion for vcs commands can be added by adding this line to your ~/.bahsrc):
`source /usr/share/vcstool-completion/vcs.bash`

Commands:
* `vcs import < myrepos.rosinstall` -- imports a list of repositories from a .rosinstall or similar file and clones them all
Other commands are like git, except you specify which directory you want to recursively search for repositories:
* `vcs pull /path/to/dir` finds all repositories within the directory specified and pulls updates from all of them
* `vcs status /path/to/dir` reports status for all repositories within the directory

Important to note is that vcs stops recursion when it hits a directory that is included in a git repository.
For example if running `vcs pull` within `sawyer_ws` it will only pull the sawyer_ws repository. If however, you
run `vsc pull` within `sawyer_ws/src` then it will pull all the rest of the repositories. 
Equivalently you can run `vcs pull src` from within `sawyer_ws` and it will pull all of the repositories underneath that directory.

### Using wstool
wstool (workspace tool) is what we have been using previously for managing multiple repositories. (instead of vcstool)

However, we recently learned that it is deprecated in favor of vcstool.
The only disadvantage of using it is we want to be using the latest stuff we can, so future students aren't stuck with old stuff that might not work anymore.

Commands:
All commands find the nearest .rosinstall file in your path (searching all directories above you) to find which repositories to do commands to
* `wstool update` clones or updates all the repositories mentioned in .rosinstall to the path specified in the .rosinstall
* `wstool status` reports status for all the repositories mentioned in .rosinstall

### VSCode
VSCode actually has some nice features for dealing with git repositories.
Usually the second icon down on the left sidebar is a little branch icon. If you click it it will help you manage whatever git repository you are in. You can do most things graphically there, and you won't have to touch the command line. It also gives nice visual indicators if there are changes, and lets you see the changes you have made to files. In the files sidebar it highlights files differently if there are changes that you haven't committed. 

It gets even nicer when you set up vscode workspaces, which we have done for a variety of repositories. This is because it shows exactly which files in which repositories have changed, and makes it easy to commit them all and push or pull chanages without having to navigate around folders on the command line.