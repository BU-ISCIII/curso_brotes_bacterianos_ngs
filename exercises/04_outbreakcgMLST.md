# Bacterial WGS training : Exercise 4

|**Title**| cgMLST bacterial outbreak investigation.|
|---------|-------------------------------------------|
|**Training dataset:**|                                |
|**Questions:**| <ul><li>Do I have the needed depth of coverage?</li><li>Do I have correct assemblies?</li><li>How do I download a cgMLST schema?</li><li>How can I analyze my samples using a cgMLST schema?</li><li>How do I visualize the results?</li><li>Which strains belong to the outbreak?</li></ul>|
|**Objectives**:|<ul><li>Trimming and quality control of raw reads.</li><li>Assembly and quality control</li><li>cgMLST analysis</li><li>Minnimum spanning tree visualization</li><li>Results interpretation</li></ul>|  
|**Time estimation**:| 1 h|
|**Key points**:|<ul><li>Importance of assembly in cgMLST typification.</li><li>Summary of alleles reconstruction, and missing data is important.</li><li>Interpretation of results is case, species and epidemiology dependant.</li></ul>|
  

## Introduction

<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/taranis_diagram_identify_alleles.jpg" width="1000"></p>

## Preprocessing
Addressed in previous exercises.
## Assembly
Addressed in previous exercises.
## cgMLST Analysis
We are using Taranis as the main software for cgMLST analysis. Following the development of the former exercises we are using nextflow, in this case using `outbreakMLST` step.
This step includes the following processes:
  - Preprocessing with trimmomatic and FastQC.
  - Assembly and quality control.
  - Download of cgMLST schema for L. monocytogenes from Pasteur bigsdb site.
  - cgMLST analysis using Taranis app.

### Run the exercise
First of all we need to be clear in which folder we are. We need to be in our working directory `/home/alumno/Documents/wgs` and our training dataset downloaded the first day must be there (If you had any problem the previous sessions please refere to the [setup tutorial](00_SetUp.md)).

You can run this command to check where you are:
```Bash
pwd
```
Output:
```
/home/alumno/Documents/wgs
```
And this one to list all the files in your working directory. Check there is the training_dataset folder and the results folder from previous sessions.
```Bash
ls
```
Output:
```
training_dataset results work
```
Once our localization is correct we will launch nextflow with the next parameters:
  - Raw reads
  - step outbreakMLST
  - gtf file needed for assembly step.
  
```
nextflow BU-ISCIII/bacterial_wgs_training \
--reads 'training_dataset/*R{1,2}*.fastq.gz' \
--fasta test/listeria_NC_021827.1_NoPhagues.fna \
--step outbreakMLST \
--gtf test/listeria_NC_021827.1_NoPhagues.gff \
-profile singularity
```

**Output:**
```
N E X T F L O W  ~  version 0.32.0                                                        
Launching `BU-ISCIII/bacterial_wgs_training` [sad_ptolemy] - revision: 068d646a9e [master]                                   
WARN: Process `multiqc` is defined two or more times                                                                         
WARN: Process `multiqc` is defined two or more times                                                                         
WARN: Process `multiqc` is defined two or more times                                                                         
=========================================                                                                                   
 BU-ISCIII/bacterial_wgs_training : WGS analysis practice v1.0                                                               
=========================================
Reads                : training_dataset/*_R{1,2}.fastq.gz 
Data Type            : Paired-End                                                                                           
Fasta Ref            : training_dataset/listeria_NC_021827.1_NoPhagues.fna
GTF File             : training_dataset/listeria_NC_021827.1_NoPhagues.gff
Keep Duplicates      : false
Step                 : outbreakMLST
Container            : ./wgs_bacterial.simg
Pipeline Release     : master
Current home         : /home/alumno
Current user         : alumno
Current path         : /home/alumno/Documents/wgs
Working dir          : /home/alumno/Documents/wgs/work
Output dir           : results
Script dir           : /home/alumno/.nextflow/assets/BU-ISCIII/bacterial_wgs_training
Save Reference       : false
Save Trimmed         : false
Save Intermeds       : false
Trimmomatic adapters file: $TRIMMOMATIC_PATH/adapters/NexteraPE-PE.fa
Trimmomatic adapters parameters: 2:30:10
Trimmomatic window length: 4
Trimmomatic window value: 20
Trimmomatic minimum length: 50
Config Profile       : singularity
====================================
[warm up] executor > local
[45/0e3862] Submitted process > fastqc (RA-L2281)
[f2/417d0b] Submitted process > scheme_download (SchemeDownload)
[34/ca35c2] Submitted process > fastqc (RA-L2701)
[e4/4c2690] Submitted process > trimming (RA-L2281)
................
BU-ISCIII Workflow complete
```
This will take a while as usual, and it is performed with a downsampled dataset, so we will describe here the results with the full dataset for practice our interpretation.

### Results analysis
Let's proceed to analyze the results. We can find them in:
```
/home/alumno/course_shared_folder/results_final/Taranis
```
This directory contains several files including:
```
├── deletions.tsv -> sequence of alleles with deletions detected.
├── inferred_alleles.tsv -> sequences for inferred alleles (not present in the scheme)
├── insertions.tsv -> sequence of alleles with deletions detected.
├── matching_contigs.tsv -> contigs where alleles are found.
├── paralog.tsv -> paralogues genes found.
├── plot.tsv -> locus found in end of start of a contig (possible broken cds)
├── result.tsv -> allele matrix. 
├── snp.tsv -> snps found in inferred alleles (beta feature)
└── summary_result.tsv -> summary of found/not found alleles.
```
Since alignment and quality control results has been previously addresed in this course (see [02_QualityAndAssembly.md](02_QualityAndAssembly.md), we will proceed to analyze cgMLST results.

The most important files at this point for cgMLST analsysis are ```results.tsv``` and ```summary_result.tsv``` files. Remaining files are useful for particular analysis where we may want to look at things not present at the cgMLST, or to explain some phenotipic behaviour.

We will focus on the main output in this exercise. In the summary file we will find which alleles have been found as exact match against a scheme allele, which ones were new inferred alleles, and which ones are alleles not found in or samples, have deletions/insertions or may be caused by a bad assembly.

In this case we obtain something like this:

|File|Exact match|INF|ASM_INSERT|ASM_DELETE|ALM_INSERT|ALM_DELETE|LNF|NIPH|NIPHEM|PLOT|ERROR|
|----|-----------|---|----------|----------|----------|----------|---|----|------|----|-----|
|RA-L2073|1744|3|0|0|1|0|0|0|0|0|0|
|RA-L2281|1747|1|0|0|0|0|0|0|0|0|0|
|RA-L2327|1744|4|0|0|0|0|0|0|0|0|0|
|RA-L2391|1747|1|0|0|0|0|0|0|0|0|0|
|RA-L2450|1745|3|0|0|0|0|0|0|0|0|0|
|RA-L2677|1731|13|1|0|0|0|0|0|0|3|0|
|RA-L2701|1740|8|0|0|0|0|0|0|0|0|0|
|RA-L2709|0|0|0|0|0|0|1748|0|0|0|0|
|RA-L2782|1746|1|1|0|0|0|0|0|0|0|0|
|RA-L2805|1745|3|0|0|0|0|0|0|0|0|0|
|RA-L2978|1746|2|0|0|0|0|0|0|0|0|0|

But...it may be useful for you taking a look at the downsampling results this time, what happens with the cgMLST analysis when we use data with low coverage, and consequently a fragmented analysis? The summary results changes and we see this:

**TODO INCLUDE TABLE**

>PLOT alleles rise notably, this is because fragmented genome makes more probable the appearance of broken cds that fall in the start of end of a contig.

## Minimum spanning tree visualization
In order to generate the minimum spanning tree from our ```results.tsv``` file we are going to use [Phyloviz](https://online.phyloviz.net/index), an online tool for MST visualization.

So..open click [here](https://online.phyloviz.net/index) and phyloviz website should open

<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz1.PNG" width="1000"></p>

Next we need to upload our file, so we select profile data as input and select *Launch tree*

<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz2.PNG" width="1000"></p>

We now have our minimum spanning tree but it looks pretty ugly and with little information. Let's add the samples names to the nodes. In order to do this we have to click on Graphic propertis in the left dropdown menu, click on nodes and check the Add Link Labels checkbox as shown in the image:

<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz3.PNG" width="1000"></p>

Next we are goint to add link labels which will show the absolute distance (number of alleles) among the nodes. As before we click on Graphic properties, next on Links and we check Add Link Labels checkbox.

<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz4.PNG" width="1000"></p>

Now we have a "pretty" minimum spanning tree with enough annotation for interpret our results. However we can also make it prettier (easy right?) adding some colors based on any locus of the profile or based on any auxiliary data we want to provide, p.e one useful data is the samples **ST**, for this we have to create
<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz7.PNG" width="1000"></p>


<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz5.PNG" width="1000"></p>


<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz6.PNG" width="1000"></p>


