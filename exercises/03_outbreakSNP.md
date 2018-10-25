# Bacterial WGS training : Exercise 3

|**Title**| SNP-based bacterial outbreak investigation.|
|---------|-------------------------------------------|
|**Training dataset:**|                                |
|**Questions:**| <ul><li>Do I have the needed depth of coverage?</li><li>Have I chosen the correct reference?</li><li>How do I create a SNP matrix? How many SNPs do I have?</li><li>How can I visualize my phylogenetic tree? Which problems can I encounter?</li><li>Which strains belong to the outbreak?</li></ul>|
|**Objectives**:|<ul><li>Trimming and quality control of raw reads.</li><li>Mapping against genome reference and duplicate filter.</li><li>Variant Calling.</li><li>SNP matrix creation.</li><li>Maximum Likelihood phylogeny.</li><li>Visualization of results.</li></ul>|  
|**Time estimation**:| 1 h|
|**Key points**:|<ul><li>Importance of reference selecion in SNP-based tipification.</li><li>Variant calling and SNP reconstruction is a key step in the process.</li><li>Interpretation of results is case, species and epidemiology dependant.</li></ul>|
  

## Introduction
Although scientific community efforts have been focused on assembly-based methods and the optimization of reconstructing complete genomes, variant calling is a essential procedure that allows per base comparison between different genomes ([Olson et al 2015](https://www.frontiersin.org/articles/10.3389/fgene.2015.00235/full)).

SNP-based strain typing using WGS can be performed via reference-based mapping of either reads or assembled contigs. There are many available microbial SNP pipelines, such as [Snippy](https://github.com/tseemann/snippy), [NASP](https://github.com/TGenNorth/NASP), [SNVphyl](https://snvphyl.readthedocs.io/en/latest/), [CFSAN SNP Pipeline](https://github.com/CFSAN-Biostatistics/snp-pipeline), or [Lyve-SET](https://github.com/lskatz/lyve-SET). 

Variant calling is a process with a bunch of potential error sources that may lead to incorrect variant calls. Identifying and resolving this incorrect calls is critical for bacterial genomics to advance. In this exercise we will use WGS-Outbreaker a SNP-based tool developed by BU-ISCIII that uses bwa mapper, GATK variant caller and several SNP-filtering steps for SNP matrix contruction following maximun likelihood phylogeny using RAxML. Next image resumes the steps we are going to execute:

<img src="https://github.com/BU-ISCIII/WGS-Outbreaker/blob/master/img/wgs_outbreaker_schema.png" width="600">

## Preprocessing

## Mapping

## Variant Calling
We are using WGS-Outbreaker as the main software for variant calling, SNP-matrix creation and phylogeny performance. Following the development of the former exercises we are using nextflow, in this case using `outbreakSNP` step.
This step includes the following processes:
- Preprocessing: 
    - Trimming with trimmomatic software.
    - Quality control with fastQC.
- WGS-Outbreak software comprises the rest of steps:
    - Mapping with bwa.
    - Variant calling with GATK.
    - SNP-Matrix creation.
    - SNP-filtering:
        * PhredQ > 30
        * Strand-bias
        * MAPQ
        * SNP cluster, < 3 SNPs / 1000 pb
        
Everything clear..? So let's run it. 

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
  - step outbreakSNP
  - saveTrimmed -> this parameters saves the fastq files trimmed in our results dir.
  - outbreaker_config <- config file with all the parameters required by WGS-Outbreaker

```Bash
nextflow BU-ISCIII/bacterial_wgs_training run --reads 'training_dataset/downsampling_250K/*_R{1,2}.fastq.gz' \
  --fasta training_dataset/listeria_NC_021827.1_NoPhagues.fna \
  --step outbreakSNP \
  -profile singularity \
  --saveTrimmed \
  --outbreaker_config training_dataset/outbreaker.config \
  -resume
```

Output:

```Bash
N E X T F L O W  ~  version 0.29.0                                                                                                                   
Launching `main.nf` [distracted_magritte] - revision: 3508cbd2da                                                                                     
WARN: Process `multiqc` is defined two or more times                                                                                                 
WARN: Process `multiqc` is defined two or more times                                                                                                 
WARN: Process `multiqc` is defined two or more times                                                                                                 
=========================================                                                                                                            
 BU-ISCIII/bacterial_wgs_training : WGS analysis practice v1.0                                                                                       
=========================================                                                                                                            
Reads                : test/full_dataset/*_R{1,2}*.fastq.gz                                                                 
Data Type            : Paired-End                         
Fasta Ref            : test/listeria_NC_021827.1_NoPhagues.fna                                                             
Keep Duplicates      : false                                                                                                 
Step                 : outbreakSNP                                                                                           
Container            : ./wgs_bacterial.simg                                            
Current home         : /home/smonzon                                                                                         
Current user         : smonzon                                                                                               
Current path         : /home/smonzon/Documents/desarrollo/bacterial_wgs_training                                             
Working dir          : /home/smonzon/Documents/desarrollo/bacterial_wgs_training/work                                        
Output dir           : results                                                                                               
Script dir           : /home/smonzon/Documents/desarrollo/bacterial_wgs_training                                             
Save Reference       : false                                                                                               
Save Trimmed         : true
Save Intermeds       : false
Trimmomatic adapters file: $TRIMMOMATIC_PATH/adapters/NexteraPE-PE.fa
Trimmomatic adapters parameters: 2:30:10
Trimmomatic window length: 4
Trimmomatic window value: 20
Trimmomatic minimum length: 50
Config Profile       : singularity
====================================
[warm up] executor > local
[ca/cbb117] Submitted process > fastqc (RA-L2805)
[4b/65f7a1] Submitted process > fastqc (RA-L2450)
[32/8ebe88] Submitted process > fastqc (RA-L2281)
[23/04ab41] Submitted process > fastqc (RA-L2073)
[a7/f9e938] Submitted process > fastqc (RA-L2391)
[75/709471] Submitted process > trimming (RA-L2073)
[94/87b2b5] Submitted process > makeBWAindex (listeria_NC_021827.1_NoPhagues)
[94/b39b86] Submitted process > trimming (RA-L2805)
[df/e01505] Submitted process > fastqc (RA-L2709)
..................
BU-ISCIII - Pipeline complete
```

>This will take a while so we need move forward and understand what we are doing and learn how to see and interpret our results.

### Understand WGS-Outbreaker config file
First of all, let's take a look to the config file for a moment: [WGS-Outbreaker config_file](../config.file). This file will allow us to configure all necessary parameters for running WGS-Outbreaker.
The file is organized in several sections.
1. Steps configuration: in this section we can select with YES/NO which pipeline steps we would want to run, in this case we have prefilled the steps that we can run in this trainning.
```
############################# Pipeline steps: Fill in with YES or NO (capital letter) ###################################
TRIMMING=NO
CHECK_REFERENCES=YES
MAPPING=YES
DUPLICATE_FILTER=YES
VARIANT_CALLING=YES
KMERFINDER=NO
SRST2=NO
CFSAN=NO
VCF_TO_MSA=YES
RAXML=YES
STATS=YES
```
2. Input data: we can provide the path where the input files are, and the path where we want our results. Also we can include our sample names and the raw reads filenames. These reads must be in the input directory provided.
```
# Directory with input files
INPUT_DIR=/home/smonzon/Documents/desarrollo/bacterial_wgs_training/results/trimming

# Directory for output files
OUTPUT_DIR=/home/smonzon/Documents/desarrollo/bacterial_wgs_training/results/wgs_outbreaker

########################################## INPUT VARIABLES########################################################

# Samples info:
# All samples ID must be separated by ":", then for each sample there must be a line with the names for
# R1 and R2 separated by tabulator
# Example:
	#=AAAA_01:BBBB_02
	# AAAA_01=AAAA_01_R1.fastq.gz    AAAA_01_R2.fastq.gz
	# BBBB_02=BBBB_02_R1.fastq.gz    BBBB_02_R2.fastq.gz
```
More over we have to include the path for our reference files:
```
######################################################### Reference Variables ###########################################

# Path to reference genome
GENOME_REF=listeria_NC_021827.1_NoPhagues.fna

# Path to reference genome without ".fasta"
GENOME_NAME=listeria_NC_021827.1_NoPhagues
```
3. Trimming, mapping, variant calling and phylogeny parameters: The end of the config file includes a series of default parameters we use for our analysis, mainly in foodborne bacteria, but that can be modified in order to match other analysis or other species requirements.
For example the most variable parameter we can probably find is the maximum number of SNPs we are going to allow in a sequence window. This parameter is going to depend on the species variability, and also on the similarity of our reference with the isolates being analyzed.
```
##############  SNP FILTERS #########################
# The maximum number of SNPs allowed in a window.
MAX_SNP=3

# The length of the window in which the number of SNPs should be no more than max_num_snp
WINDOW_SIZE=1000
```

