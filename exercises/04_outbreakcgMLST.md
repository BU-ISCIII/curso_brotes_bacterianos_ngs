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
  
```
nextflow -C nextflow.config run main.nf \
--reads 'test/downsampling_250K/*R{1,2}*.fastq.gz' \
--fasta test/listeria_NC_021827.1_NoPhagues.fna \
--step outbreakMLST \
--gtf test/listeria_NC_021827.1_NoPhagues.gff \
-profile singularity
```

## Minimum spanning tree visualization
In order to generate the minimum spanning tree from our ```results.tsv``` file we are going to use [Phyloviz](https://online.phyloviz.net/index), an online tool for MST visualization.

So..open click [here](https://online.phyloviz.net/index) and phyloviz website should open

<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz1.PNG" width="1000"></p>

<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz2.PNG" width="1000"></p>

<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz3.PNG" width="1000"></p>

<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz4.PNG" width="1000"></p>
<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz5.PNG" width="1000"></p>
<p align="center"><img src="https://github.com/BU-ISCIII/bacterial_wgs_training/blob/master/exercises/img/phyloviz6.PNG" width="1000"></p>


