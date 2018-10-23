## Bacterial WGS training : Exercise 2

|**Title**| Sequence quality and assambly.|
|---------|-------------------------------------------|
|**Training dataset:**|  
|**Questions:**| <ul><li>How do I know if my data was correctly sequenced?</li><li>How can I improve my data quality?</li><li>How do I assamble the reads?</li><li>How do I know if my reads were correctly assembled</li></ul>|
|**Objectives**:|<ul><li>Check quality of sequenced data.</li><li>Trimm low quality segments and adapters.</li><li>Map raw reads against reference.</li><li>Remove duplicated reads.</li><li>Assamble mapped reads.</li></ul>|  
|**Time estimation**:| 1 h 30 min |
|**Key points**:|<ul><li>Analysis of sequence quality.</li><li>Mapping.</li><li>Assembly.</li></ul>|

## Training dataset description
This dataset was used for [external quality assessment (EQA-5)](https://ecdc.europa.eu/en/publications-data/fifth-external-quality-assessment-scheme-listeria-monocytogenes-typing) scheme for typing of
Listeria monocytogenes (L. monocytogenes) organised for laboratories providing data to the Food- and Waterborne
Diseases and Zoonoses Network (FWD-Net) managed by ECDC. Since 2012, the Section for Foodborne Infections
at the Statens Serum Institut (SSI) in Denmark has arranged this EQA under a framework contract with ECDC. The
EQA-5 contain serotyping and molecular typing-based cluster analysis.

Human listeriosis is a relatively rare but serious zoonotic disease with an EU notification rate of 0.47 cases per 100
000 population in 2016. The number of human listeriosis cases in the EU has increased since 2008, with the
highest annual number of deaths since 2009 reported in 2015 at 270.

The objectives of the EQA are to assess the quality and comparability of the typing data reported by public health
national reference laboratories participating in FWD-Net. Test isolates for the EQA were selected to cover isolates
currently relevant to public health in Europe and represent a broad range of clinically relevant types for invasive
listeriosis. Two separate sets of 11 test isolates were selected for serotyping and molecular typing-based cluster
analysis. The expected cluster was based on a pre-defined categorisation by the organiser. 
Twenty-two L. monocytogenes test isolates were selected to fulfil the following criteria:
- cover a broad range of the common clinically relevant types for invasive listeriosis
- include closely related isolates
- remain stable during the preliminary test period at the organising laboratory.

The 11 test isolates for cluster analysis were selected to include isolates with different or varying relatedness isolates and different multi locus sequence types.


## How do I know if my data was correctly sequenced?

Despite the improvement of sequencing methods, there is no error-free technique. The Phred quality score (Ewing et al., 2005) has been used since the late 90s as a measure of the quality of each sequenced nucleotide. Phred quality scores not only allow us to determine the accuracy of sequencing and of each individual position in an assembled consensus sequence, but it is also used to compare the efficiency of the sequencing methods.

Phred quality scores Q are defined (Ewing et al., 2005) as a property which is logarithmically related to the base-calling error probabilities P . The Phred quality score is the negative ratio of the error probability to the reference level of P = 1 expressed in Decibel (dB): 

<p align="center">𝑄 = −10 log<sub>10</sub> P</p>

A correct measuring of the sequencing quality is essential for identifying problems in the sequencing and removal of low-quality sequences or sub sequences. Conversion of typical Phred scores used for quality thresholds into accuracy can be ead in the following table:

|**Phred score**| Error probability | Accuracy|
|----------------|--------------------|---------|
|10|1/10|90%|
|20|1/100|99%|
|30|1/1000|99.9%|
|40|1/10000|99.99%|
|50|1/100000|99.999%|
|60|1/1000000|99.99999%|
|70|1/10000000|99.999999%|

There are multiple software to read and generate statistics to help with the interpretation of the quality of a sequence. One of the most commonly used methods for this task is [FastQC](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/) (Andrews, 2010), a java program that run on any system and has both command line and graphic interface. 

![](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/fastqc.png)

FastQC aims to provide a simple way to do some quality control checks on raw sequence data coming from high throughput sequencing pipelines. It provides a modular set of analyses which you can use to give a quick impression of whether your data has any problems of which you should be aware before doing any further analysis. Here you can compare examples of a [good sequencing output](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/good_sequence_short_fastqc.html) and a [bad one](https://www.bioinformatics.babraham.ac.uk/projects/fastqc/bad_sequence_fastqc.html).


## How can I improve my data quality?

Most modern aligners can filter out low quality reads and clip off low quality ends and adapters. In case it has to be done manually, because the sequencing was poor but you still need to use that data or because you want to have more control on the
trimming of reads or use a particular method, there are standalone applications that allow you to do it. [Trimmomatic](http://www.usadellab.org/cms/?page=trimmomatic) (Bolger, Lohse, & Usadel, 2014) is one of the most broadly used. It is written in java and performs a variety of useful trimming tasks for illumina paired-end and single ended data.

Common trimming includes removal of short reads, and cut off adapters and a number of bases, if below a threshold quality. Modern algorithms also include more complex methods, as the sliding window trimming in Trimmomatic. This is the method we will use in the exercises, and it allows to trimm a variable number of bases in each read, cutting once the average quality within the window falls below a threshold.

## How do I map?



