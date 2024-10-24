# Bacterial WGS training : Exercise 1

<div class="tables-start"></div>

|**Title**| Linux command line.|
|---------|-------------------------------------------|
|**Training dataset:**| None
|**Questions:**| <ul><li>How do I use the command line?</li><li>How do I navigate the file system?</li></ul>|
|**Objectives**:|<ul><li>Learn/Remember how to use the command line.</li><li>Learn/Remember how to navigate through the Linux file system.</li></ul>|
|**Time estimation**:| 30 min |
|**Key points**:|<ul><li>Remeber the shell basic commands: *pwd cd ls mkdir rmdir mv nano cat less more head tail rm*</li></ul>|

<div class="tables-end"></div>

## :bangbang: Important things to remnenber:

- Use Tab to automatically complete file names and paths, so it can be easiert to write in the terminal
- Use keyboard arrows (:arrow_up: :arrow_down:) to move through your terminal's history, so you don't have to write the commands again.
- Try not to use spaces, accents or special characters like "Ñ" letter, when writting directory of file names.
- Basic commands you should always remember: *pwd cd ls mkdir mv rm rmdir less nano*

## Answering to main questions

### How do I use the command line?

Open a terminal by clicking in the icon or typing __Ctrl+Alt+T__. Now you can type in the prompt.

### How do I navigate the file system?

Let's remember the basics: *pwd cd ls mkdir mv rm rmdir less nano*. We are going to use those commands to:

### Checking the working directory (pwd)

Check our working directory:

```bash
pwd
#Output: /home/alumno
```

#### Moving between directories (cd)

Move to our Desktop folder:

```bash
cd ~/Escritorio
pwd
#Output: /home/alumno/Escritorio
```

Move to the course folder:

```bash
cd 
pwd
#Output: /home/alumno
cd wgs
pwd
#Output: /home/alumno/wgs
cd bacterial_wgs_training_dataset/RAW/FULL_DATA
pwd
#Output: /home/alumno/wgs/bacterial_wgs_training_dataset/RAW/FULL_DATA
cd .
pwd
#Output: /home/alumno/wgs/bacterial_wgs_training_dataset/RAW/FULL_DATA
cd ..
#Output: /home/alumno/wgs/bacterial_wgs_training_dataset/RAW/
cd ../../..
#Output: /home/alumno/
```

**Questions:**

<details>
<summary>Which is the meaning of the "~" symbol?</summary>
  
It is the abreviation of `/home/user/` path

</details>

<details>
<summary>What does de `cd` command without arguments do?</summary>

It changes the current directory to `/home/user/` path.

</details>

<details>
<summary>What does "." mean?</summary>
Current directory
</details>

<details>
<summary>What does ".." mean? </summary>
Parent directory
</details>

#### Listing directories (ls)

```bash
cd wgs
cd bacterial_wgs_training_dataset
ls
#Output: ANALYSIS RAW  REFERENCES  RESULTS
```

This is the folder structure we will use for this training. Now we are going to list the files in the `REFERENCE` folder:

```bash
ls REFERENCES
```

This command will output a big list of files, which are the files that we will usea as REFERENCE through the different exercises of the training. Now wi will run this other command:

```bash
ls /home/alumno/wgs/bacterial_wgs_training_dataset/REFERENCES/
```

**Questions:**

<details>
<summary>What does ".." mean? </summary>
Parent directory
</details>

<details>
<summary>Which is the difference between this last command and the previous one? </summary>
There is no difference, they are listing the content of the exact same directory.
</details>


<details>
<summary> Do they display the same information? </summary>
Yes!
</details>

<details>
<summary> Which one is relative path? </summary>

`ls REFERENCES`

</details>

<details>
<summary> Which one is absolute path? </summary>

`ls /home/alumno/wgs/bacterial_wgs_training_dataset/REFERENCES/`

</details>

Let's see different parameters for the `ls` command. Write:

```bash
ls REFERENCES
ls -l REFERENCES
ls -a REFERENCES
ls -la REFERENCES
```

**Questions:**

<details>
<summary>

What does de different arguments of `ls` do? 
</summary>
<br>
-l : Long listing format: Displays the permission information</br>
<br>
-a : All files: Lists also hiddent files</br>
<br>
-la : Long format listing and hidden files together. </br>
</details>

<details>
<summary> What does the new file special? </summary>
It is a hidden file, whose file name starts by dot.
</details>

⚠️ **REMINDER:** ⚠️ EVERY TIME YOU CHANGE DIRECTORY (cd) YOU HAVE TO CHECK YOUR PATH (pwd) AND LIST THE FILES INSIDE (ls) TO CHECK YOU DIDN'T MAKE MISTAKES

##### Creating and removing directories (mkdir & rmdir)

Now we are going to move to the ANALYSIS folder which is the folder were we will run all the exercises

```bash
cd ANALYSIS
pwd
#Output: /home/alumno/wgs/bacterial_wgs_training_dataset/ANALYSIS
ls
```

As you can see the folder is empty, so now we will fill this folder. Create a directory for this handson: **Remember:** Linux is case sensitive and does not like white spaces in names

```bash
mkdir 01-handsonLinux
ls
#Output: 01-handsonLinux
```

Now type:

```bash
mkdir 01-handsonlinux 01-HandsOnLinux
ls
#Output: 01-handsonlinux 01-handsonLinux 01-HandsOnLinux
```

**Questions:**

<details>
<summary> Is it possible to create more than one directory at the same time? </summary>
Yes, it is!
</details>

<details>
<summary> If the names of the folders are the same, why it creates three different directories? </summary>
Because it is case sensitive, so the names are not exactly the same!
</details>

Now we will remove the extra directories:

```bash
rmdir 01-handsonLinux 01-HandsOnLinux
ls
#Output: 01-handsonlinux
```

##### Moving and renaming files (mv)

Move to the new folder

```bash
cd 01-handsonlinux
pwd
#Output: /home/alumno/wgs/bacterial_wgs_training_dataset/ANALYSIS/01-handsonlinux
```

We are going to move the hidden file in REFERENCE folder to this directory and then rename it:

```bash
mv ../../REFERENCES/.ThisIsAHiddenFile .
ls
ls -a
ls -a ../../REFERENCES/
mv .ThisIsAHiddenFile NowImNotHidden
ls -a
ls
```

**Questions:**

<details>
<summary> Which is the difference between the two `mv` commands? </summary>
The first one moves a file to a different folder and the second one renames the file.
</details>

<details>
<summary> Do you remember what "." mean from the first questions? </summary>
Current directory
</details>

<details>
<summary> And ".."? </summary>
Parent directory
</details>

⚠️ **REMINDER:** ⚠️ LINUX DOES NOT REQUIRE FILE EXTENSIONS

##### Editing files and displaying them (nano & cat)

We are going to read the file and edit it:

```bash
cat NowImNotHidden
#Output: I'm a hidden file.
```

This is not true, so we are going to edit it:

```bash
nano NowImNotHidden
```

Write: `I'm not a hidden file.`

And **save** it:
_Ctrl + O_
_Intro_

**Close** the new file:
_Ctrl + X_

Now read the new file:

```bash
cat NowImNotHidden
#Output: I'm not a hidden file.
ls
#Output: NowImNotHidden
cd ../../
```

##### Read files other ways (less & more & head & tail)

And now we will read this file:

```bash
cat REFERENCES/bacterial_wgs_training_initial.tree
less REFERENCES/bacterial_wgs_training_initial.tree
```

Remember: To close less press "q"

```bash
more REFERENCES/bacterial_wgs_training_initial.tree
```

Remember: To close more press "q"

```bash
head REFERENCES/bacterial_wgs_training_initial.tree
tail REFERENCES/bacterial_wgs_training_initial.tree
```

```bash
head -n4 REFERENCES/bacterial_wgs_training_initial.tree
tail -n3 REFERENCES/bacterial_wgs_training_initial.tree
```

**Questions:**

<details>
<summary> 
  
Which is the difference between `head` and `tail`?  
</summary>
<br>Head displays first lines of a file.</br>
<br>Tail displays the last lines of a file</br>
</details>

<details>
<summary>
  
What does the argument `-nX` do to `tail` and `head`?
</summary>
Displays de X numbers of lines from the begining (head) or end (tail) of a file.
</details>

##### Removing a file (rm)

Now we will learn how to remove files:

```bash
cd ANALYSIS/01-handsonlinux/
pwd
ls
#Output: NowImNotHidden
mv ../../REFERENCES/bacterial_wgs_training_initial.tree .
ls
#Output: bacterial_wgs_training_initial.tree NowImNotHidden
rm NowImNotHidden
ls
#Output: bacterial_wgs_training_initial.tree
```
