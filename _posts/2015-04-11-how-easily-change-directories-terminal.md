---
title: How to Easily Change Directories In Terminal
tags: ["Command Line", "Terminal", "Quick Tip"]
categories: ["Web Development"]
date: 2015-04-11
node: 137
---

I used to be terrified of the command line terminal. I'm a visual learner, and the command line is the exact opposite of visual. Plus, I'm a front end developer. My thought was that I didn't need to use the command line since all I'm doing is editing HTML, CSS and jQuery.

But, I quickly found that I needed to learn the command line if I wanted to be a **good** front end developer. In order to use some of today's best tools like [Sass](http://sass-lang.com/), [drush](http://www.drush.org/en/master/), or simply apply a patch to Drupal, I needed to learn the command line.

For all intents and purposes, all I ever need to do when it comes to the command line are two things:

1. Navigate to the proper directory.
2. Run a command.

This applies to pretty much everything I do, from compiling Sass files, running drush commands and applying patches. But, how do I navigate to the directory when I don't even know where I am? I open up the terminal and it's just black. With finder I can see exactly where I am and navigate with ease.

Well, if you're on a Mac you're in luck. All you need to do is open up the terminal and do the following:

1. Type `cd`
2. Click and drag the directory into the terminal window.
3. Hit enter. 

![](/assets/images/posts/how-easily-change-directories-terminal/spd-terminal-quicktip.gif)

If you want to list all the files and subdirectories within this directory, type `ls` and hit enter. You can always type `pwd` to see where you are within the file structure.

![](/assets/images/posts/how-easily-change-directories-terminal/spd-terminal-quicktip-ls.gif)

To see hidden files, type `ls -a` and hit enter. This is useful to see files like **.htaccess**.

![](/assets/images/posts/how-easily-change-directories-terminal/spd-terminal-quicktip-ls-a.gif)

Finally, to see all files and subdirectories (including hidden files) along with their permissions, type `ls -al` and hit enter. This is useful if you are having directory issues within the Drupal file system. Sometimes Drupal cannot create custom image styles if the `sites/default/files` directory is not properly configured.

![](/assets/images/posts/how-easily-change-directories-terminal/spd-terminal-quicktip-ls-al.gif)