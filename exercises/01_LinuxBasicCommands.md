## Bacterial WGS training : Exercise 1

<div class="tables-start"></div>

|**Title**| Linux command line.|
|---------|-------------------------------------------|
|**Training dataset:**| None
|**Questions:**| <ul><li>How do I use the command line?</li><li>How do I navigate the file system?</li><li>How do I know which software I am using?</li></ul>|
|**Objectives**:|<ul><li>Learn/Remember how to use the command line.</li><li>Learn/Remember how to navigate through the Linux file system.</li></ul>|
|**Time estimation**:| 15 min |
|**Key points**:|<ul><li>Remeber the shell basic commands</li></ul>|

<div class="tables-end"></div>

### :bangbang: Important things to remnenber:
- Use Tab to automatically complete file names and paths, so it can be easiert to write in the terminal
- Use keyboard arrows (:arrow_up: :arrow_down:) to move through your terminal's history, so you don't have to write the commands again.
- Try not to use spaces, accents or special characters like "Ñ" letter, when writting directory of file names.
- Basic commands you should always remember: *pwd cd ls mkdir mv rm rmdir less nano*

#### How do I use the command line?

Open a terminal by clicking in the icon or typing __Ctrl+Shift+T__. Now you can type into it.

#### How do I navigate the file system?

Let's remember the basics: *pwd cd ls mkdir mv rm rmdir less nano*. We are going to use those commands to:

Check our working directory:

```
pwd
#Output: /home/alumno
```

Move to our Desktop folder (using the absolute path and the alias "~", which means "path to your home folder"):

```
cd ~/Escritorio
```

Create a directory called "myDir" (Linux is case sensitive and does not like white spaces in names):

```
mkdir myDir
```

Move to the new folder (using a relative pathway):

```
cd myDir
```

Check our working directory (always do it before executing something):

```
pwd
#Output: /home/alumno/Escritorio/myDir
```

Create the folders "asdf", "AsDf", "ASDF" and "tmp" (at once, commands change their behavior depending on the parameters):

```
mkdir asdf AsDf ASDF tmp
```

Create a file inside "tmp" called "myFile.txt" (using a relative pathway, you can work with files outside your working directory):

```
nano tmp/myFile.txt
```

and write whatever you want and save it with __Ctrl + O__, then __Intro__ and close the new file with __Ctrl + X__

Rename "myFile.txt" to "whateverIwant" (Linux does not require file extensions):

```
mv tmp/myFile.txt tmp/whateverIwant
```

See the contents of "whateverIwant":

```
less tmp/whateverIwant
#Remember: To close less press "q"
```

Remove the file:

```
rm tmp/whateverIwant
```

Remove the folders inside "myDir" (wildcard character "\*" means "any character once or more times, or nothing"):

```
rmdir ./*
```

Go back to Desktop and remove everything you created (".." means parente directory, while "." refers to the directory itself):

```
cd ..; rm -rf myDir
```

Return to your home directory (without parameters, the behavior of the command changes):

```
cd
```

#### How do I know which software I am using?

Software may (and will) be installed in many different places. To discover the one you have loaded in your PATH use `which`, to see all the places where the shell is looking for software check the variable `$PATH`, to know the version of the software use the apropiate parameter (`-h --help -v --version`) and to check the manual of the software use `man`.

```
which git
echo $PATH
echo $USER
git -h
git --version
man git
```
