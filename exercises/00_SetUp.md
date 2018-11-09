## Bacterial WGS training : Exercise 0

<div class="tables-start"></div>
|**Title**| Working environment setup.|
|---------|-------------------------------------------|
|**Training dataset:**|
|**Questions:**| <ul><li>How do I install the software for the course?</li><li>Where do I get the data for the exercises?</li></ul>|
|**Objectives**:|<ul><li>In this document we will cover the working environment setup for the exercises.</li></ul>|
|**Time estimation**:| 5 min |
|**Key points**:|<ul><li>Each practical is designed to work on this [folder structure](#final-folder-structure), so make sure you follow these steps correctly.</li></ul>|

<div class="tables-end"></div>
#### IMPORTANT: Make sure you understand and execute these commands in the right order.

Open a new terminal and navigate to your home directory if you are not already there:

```
pwd
cd
pwd
```

Create the project folder for the practises of the course:

```
mkdir -p Documents/wgs
```

Navigate to the directory:

```
cd Documents/wgs
```

Download git repository:

```
git clone https://github.com/BU-ISCIII/bacterial_wgs_training.git
```

Download training dataset:

```
wget https://github.com/BU-ISCIII/bacterial_wgs_training/releases/download/1.0/training_dataset.tar.gz
tar -xvzf training_dataset.tar.gz
rm -f training_dataset.tar.gz
```

Download singularity image:

```
rsync ~/course_shared_folder/wgs_bacterial.simg ./
```


##### Final folder structure

```
.
├── bacterial_wgs_training
│   ├── bin
│   │   └── plotTreeHeatmap.R
│   ├── conf
│   │   ├── base.config
│   │   ├── docker.config
│   │   ├── multiqc_config.yaml
│   │   └── singularity.config
│   ├── config2.file
│   ├── config.file
│   ├── Dockerfile
│   ├── exercises
│   │   ├── 00_SetUp.md
│   │   ├── 01_LinuxNextflowSingularity.md
│   │   ├── 02_QualityAndAssembly.md
│   │   ├── 03_outbreakSNP.md
│   │   ├── 04_outbreakcgMLST
│   │   └── img
│   │       ├── Ex_2_1.png
│   │       ├── Ex_2_2.png
│   │       ├── itol_web1.png
│   │       ├── itol_web2.png
│   │       ├── tree_with_bad_sample_snps.png
│   │       └── tree_with_bad_sample_snps.svg
│   ├── main.nf
│   ├── nextflow.config
│   ├── README.md
│   ├── scif_app_recipes
│   ├── Singularity
│   └── slides
│       └── talk1
│           └── PITCHME.md
├── training_dataset
│   ├── ARGannot.r1.fasta
│   ├── downsampling_250K
│   │   ├── RA-L2073_R1.fastq.gz
│   │   ├── RA-L2073_R2.fastq.gz
│   │   ├── RA-L2281_R1.fastq.gz
│   │   ├── RA-L2281_R2.fastq.gz
│   │   ├── RA-L2327_R1.fastq.gz
│   │   ├── RA-L2327_R2.fastq.gz
│   │   ├── RA-L2391_R1.fastq.gz
│   │   ├── RA-L2391_R2.fastq.gz
│   │   ├── RA-L2450_R1.fastq.gz
│   │   ├── RA-L2450_R2.fastq.gz
│   │   ├── RA-L2677_R1.fastq.gz
│   │   ├── RA-L2677_R2.fastq.gz
│   │   ├── RA-L2701_R1.fastq.gz
│   │   ├── RA-L2701_R2.fastq.gz
│   │   ├── RA-L2709_R1.fastq.gz
│   │   ├── RA-L2709_R2.fastq.gz
│   │   ├── RA-L2782_R1.fastq.gz
│   │   ├── RA-L2782_R2.fastq.gz
│   │   ├── RA-L2805_R1.fastq.gz
│   │   ├── RA-L2805_R2.fastq.gz
│   │   ├── RA-L2978_R1.fastq.gz
│   │   └── RA-L2978_R2.fastq.gz
│   ├── listeria_NC_021827.1_NoPhagues.fna
│   ├── listeria_NC_021827.1_NoPhagues.gff
│   ├── pcr_serogroup_listeria.fas
│   └── pcr_serogroup_listeria.scheme
└── wgs_bacterial.simg
```
