## Bacterial WGS training : Exercise 1

<div class="tables-start"></div>

|**Title**| Linux command line.|
|---------|-------------------------------------------|
|**Training dataset:**| None
|**Questions:**| <ul><li>How do I use the command line?</li><li>How do I navigate the file system?</li></ul>|
|**Objectives**:|<ul><li>Learn/Remember how to use the command line.</li><li>Learn/Remember how to navigate through the Linux file system.</li></ul>|
|**Time estimation**:| 30 min |
|**Key points**:|<ul><li>Remeber the shell basic commands: *pwd cd ls mkdir rmdir mv nano cat tree less more head tail rm*</li></ul>|

<div class="tables-end"></div>

### :bangbang: Important things to remnenber:
- Use Tab to automatically complete file names and paths, so it can be easiert to write in the terminal
- Use keyboard arrows (:arrow_up: :arrow_down:) to move through your terminal's history, so you don't have to write the commands again.
- Try not to use spaces, accents or special characters like "Ñ" letter, when writting directory of file names.
- Basic commands you should always remember: *pwd cd ls mkdir mv rm rmdir less nano*

### Answering to main questions

#### How do I use the command line?

Open a terminal by clicking in the icon or typing __Ctrl+Alt+T__. Now you can type in the prompt.

#### How do I navigate the file system?

Let's remember the basics: *pwd cd ls mkdir mv rm rmdir less nano*. We are going to use those commands to:

##### Checking the working directory (pwd)
Check our working directory:

```
pwd
#Output: /home/alumno
```

##### Moving between directories (cd)

Move to our Desktop folder:

```
cd ~/Escritorio
pwd
#Output: /home/alumno/Escritorio
```
Move to the course folder:

```
cd 
pwd
#Output: /home/alumno
cd wgs
pwd
#Output: /home/alumno/wgs
cd RAW/FULL_DATA
pwd
#Output: /home/alumno/wgs/RAW/FULL_DATA
cd .
pwd
#Output: /home/alumno/wgs/RAW/FULL_DATA
cd ..
#Output: /home/alumno/wgs/RAW/
cd ../..
#Output: /home/alumno/
```

**Questions:**

- Which is the meaning of the "~" symbol?
- What does de `cd` command without arguments do?
- What does "." mean?
- What does ".." mean?

##### Listing directories (ls)

```
cd wgs
ls
#Output: ANALYSIS bacterial_wgs_training RAW  REFERENCES  RESULTS
```

This is the folder structure we will use for this training. Now we are going to list the files in the `REFERENCE` folder:

```
ls REFERENCES
```

This command will output a big list of files, which are the files that we will usea as REFERENCE through the different exercises of the training. Now wi will run this other command:

```
ls /home/alumno/wgs/REFERENCES/
```

**Questions:**

- Which is the difference between this las command and the previous one?
- Do they display the same information?
- Which one is relative path?
- Which one is absolute path?

Let's see different parameters for the `ls` command. Write:

```
ls
ls -l
ls -a
ls -la
```

**Questions:**

- What does de different arguments of `ls` do?
- What does the new file special?

⚠️ **REMINDER:** ⚠️ EVERY TIME YOU CHANGE DIRECTORY (cd) YOU HAVE TO CHECK YOUR PATH (pwd) AND LIST THE FILES INSIDE (ls) TO CHECK YOU DIDN'T MAKE MISTAKES

##### Creating and removing directories (mkdir & rmdir)

Now we are going to move to the ANALYSIS folder which is the folder were we will run all the exercises

```
cd ANALYSIS
pwd
#Output: /home/alumno/wgs/ANALYSIS
ls
```

As you can see the folder is empty, so now we will fill this folder. Create a directory for this handson: **Remember:** Linux is case sensitive and does not like white spaces in names

```
mkdir 01-handsonLinux
ls
#Output: 01-handsonLinux
```

Now type:

```
mkdir 01-handsonlinux 01-HandsOnLinux
ls
#Output: 01-handsonLinux 01-handsonlinux 01-HandsOnLinux
```

**Questions:**

- Is it possible to create more than one directory at the same time?
- If the names of the folders are the same, why it creates three different directories?

Now we will remove the extra directories:

```
rmdir 01-handsonLinux 01-HandsOnLinux
ls
#Output: 01-handsonlinux
```

##### Moving and renaming files (mv)

Move to the new folder

```
cd 01-handsonlinux
pwd
#Output: /home/alumno/wgs/ANALYSIS/01-handsonlinux
```

We are going to move the hidden file in REFERENCE folder to this directory and then rename it:

```
mv ../../REFERENCES/.ThisIsAHiddenFile .
ls
ls -a
ls -a ../../REFERENCES/
mv .ThisIsAHiddenFile NowImNotHidden
ls -a
ls
```

**Questions:**

- Which is the difference between the two `mv` commands?
- Do you remember what "." mean from the first questions?
- And ".."?

⚠️ **REMINDER:** ⚠️ LINUX DOES NOT REQUIRE FILE EXTENSIONS

##### Editing files and displaying them (nano & cat)

We are going to read the file and edit it:

```
cat NowImNotHidden
#Output: I'm a hidden file.
```
This is not true, so we are going to edit it:

```
nano NowImNotHidden
```

Write: `I'm not a hidden file.`

And **save** it:
_Ctrl + O_
_Intro_

**Close** the new file:
_Ctrl + X_

Now read the new file:

```
cat NowImNotHidden
#Output: I'm not a hidden file.
ls
#Output: NowImNotHidden
```

##### Creating a tree of a folder (tree)

We are going to create a file with this course folder's tree:

```
tree /home/alumno/wgs > bacterial_wgs_training_initial.tree
ls
#Output: NowImNotHidden bacterial_wgs_training_initial.tree
```

##### Read files other ways (less & more & head & tail)

And now we will read this file:

```
less bacterial_wgs_training_initial.tree
#Remember: To close less press "q"
```

```
more bacterial_wgs_training_initial.tree
#Remember: To close more press "q"
```

```
head bacterial_wgs_training_initial.tree
tail bacterial_wgs_training_initial.tree
```

```
head -n1 bacterial_wgs_training_initial.tree
tail -n2 bacterial_wgs_training_initial.tree
```



**Questions:**
- What do you see in this file?
- What does the command `tree` do?
- Which is the difference between `less` and `more`?
- Which is the difference between `head` and `tail`?
- What does the argument `-nX` do to `tail` and `head`?

##### Removing a file (rm)

Now we will learn how to remove files:

```
ls
#Output: NowImNotHidden bacterial_wgs_training_initial.tree
rm NowImNotHidden
ls
#Output: bacterial_wgs_training_initial.tree
```
