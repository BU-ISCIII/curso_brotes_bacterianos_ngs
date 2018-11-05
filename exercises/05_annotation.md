# Bacterial WGS training : Exercise 5

|**Title**| Chromosome, plasmid, resistance and virulence annotation|
|---------|-------------------------------------------|
|**Training dataset:**|                                |
|**Questions:**| <ul><li>How many genes there are in my sample?</li><li>Are there virulence and/or antibiotic resistance genes?</li><li>Where are the genes located?</li><li>Which plasmids are present in the sample?</li><li>How do I visualize the results?</li></ul>|
|**Objectives**:|<ul><li>Annotate virulence and ABR genes</li><li>Determine gene variants</li><li>Determine plasmidome</li><li>Locate annotated genes</li><li>Results interpretation</li></ul>|  
|**Time estimation**:| 1 h|
|**Key points**:|<ul><li>Comparing annotation using mapping vs assembly</li><li>Plasmid, virulence and resistance determination</li></ul>|
  
- [Introduction](#introduction)
- [Exercise](#exercise)
    - [Mapping based annotation](#mapping-based-annotation)
    - [Assembly based annotation](#assembly-based-annotation)

## Introduction
### Training summary

<p align="center"><img src="img/bacterial_wgs_training.png" alt="Fastqc_1" width="500"></p>

### Training dataset description
This dataset was used for [external quality assessment (EQA-5)](https://ecdc.europa.eu/en/publications-data/fifth-external-quality-assessment-scheme-listeria-monocytogenes-typing) scheme for typing of
Listeria monocytogenes (*L. monocytogenes*) organised for laboratories providing data to the Food and Waterborne
Diseases and Zoonoses Network (FWD-Net) managed by ECDC. Since 2012, the Section for Foodborne Infections
at the Statens Serum Institut (SSI) in Denmark has arranged this EQA under a framework contract with ECDC. The
EQA-5 contain serotyping and molecular typing-based cluster analysis.


<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/map_vs_assembly.png" width="900"></p>

| NC_016838.1 | NC_016839.1 | NC_016840.1 |
| :---: | :---: | :---: | 
| ![](https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/KPN_TEST_R_paired_NC_016838.1.png) | ![](https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/KPN_TEST_R_paired_NC_016839.1.png) | ![](https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/KPN15_000240185_NC_016840.1.png) | 
| **NC_016841.1** | **NC_016846.1** | **NC_016847.1** |
![](https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/KPN15_000240185_NC_016841.1.png) | ![](https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/KPN_TEST_R_paired_NC_016846.1.png) | ![](https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/KPN15_000240185_NC_016847.1.png) |


## Exercise

### Mapping based annotation
### Assembly based annotation

```Bash
cd
cd Documents/wgs
nextflow run BU-ISCIII/bacterial_wgs_training \
-profile singularity \
--reads '/home/pjsola/Documents/wgs/training_dataset/plasmidid_test/KPN_TEST_R{1,2}.fastq.gz' \
--fasta training_dataset/listeria_NC_021827.1_NoPhagues.fna \
--gtf training_dataset/listeria_NC_021827.1_NoPhagues.gff \
--plasmidid_database training_dataset/plasmidid_test/plasmids_TEST_database.fasta \
--plasmidid_config /home/pjsola/Documents/wgs/training_dataset/plasmidid_test/plasmidid_config_pjsola.txt \
--step plasmidID
```
