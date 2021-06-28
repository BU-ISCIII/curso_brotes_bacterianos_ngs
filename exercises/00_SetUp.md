## Bacterial WGS training : Exercise 0

<div class="tables-start"></div>

|**Title**| Working environment setup.|
|---------|-------------------------------------------|
|**Training dataset:**|
|**Questions:**| <ul><li> Connect to VCenter</li><li>Copy course data</li></ul>|
|**Objectives**:|<ul><li>In this document we will cover the working environment setup for the exercises.</li></ul>|
|**Time estimation**:| 5 min |
|**Key points**:|<ul><li>Each practical is designed to work on this [folder structure](#final-folder-structure), so make sure you follow these steps correctly.</li></ul>|

<div class="tables-end"></div>

#### IMPORTANT: Make sure you understand and execute these commands in the right order.

FOLLOW THESE STEPS:
In your computer:

- Open in your internet browser this URL: https://vcenter.isciii.es/.
- Advanced options > Go to website
- Go to `vSphere Client (HTML5): funcionalidad parcial`
- Then type your ISCIII e-mail and password.
- Select your working machine (e.g. bioinfo01) in the left pannel
- Click on `iniciar consola remota`

In the remote console:

- Now click on your user: alumno, and type the password we will tell you.
- There open a firefox window and open this tutorial again by:
  - Google: BU-ISCIII github
  - Select `bacterial_wgs_training`
  - Exercise0.

Now you are here again!

Open a new terminal and navigate to your home directory if you are not already there:

```
pwd
cd
pwd
#Output: /home/alumno
```

Create the project folder for the practises of the course:

```
mkdir -p wgs
```

Navigate to the directory:

```
cd wgs
```

Download git repository:

```
git clone https://github.com/BU-ISCIII/bacterial_wgs_training.git
```

Download training dataset:

```
cp -r /mnt/ngs_course_shared/bacterial_wgs_training_dataset .
```

Check that everything is correct:

```
ls
#Output: bacterial_wgs_training  bacterial_wgs_training_dataset
pwd
#Output: /home/alumno/wgs
```
