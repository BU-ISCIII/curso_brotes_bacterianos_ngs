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

<p align="center"><img src="https://github.com/BU-ISCIII/WGS-Outbreaker/blob/master/img/wgs_outbreaker_schema.png" width="600"></p>

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

>This will take a while so we need to move forward and understand what we are doing and learn how to see and interpret our results.

### Understanding WGS-Outbreaker config file
First of all, let's take a look to the config file for a moment: [WGS-Outbreaker config_file](../config.file). This file will allow us to configure all necessary parameters for running WGS-Outbreaker.
The file is organized in several sections.
1. **Steps configuration:** in this section we can select with YES/NO which pipeline steps we would want to run, in this case we have prefilled the steps that we can run in this trainning.
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
2. **Input data:** we can provide the path where the input files are, and the path where we want our results. Also we can include our sample names and the raw reads filenames. These reads must be in the input directory provided.
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
Moreover we have to include the path for our reference files:
```
######################################################### Reference Variables ###########################################

# Path to reference genome
GENOME_REF=listeria_NC_021827.1_NoPhagues.fna

# Path to reference genome without ".fasta"
GENOME_NAME=listeria_NC_021827.1_NoPhagues
```
3. **Trimming, mapping, variant calling and phylogeny parameters:** The end of the config file includes a series of default parameters we use for our analysis, mainly in foodborne bacteria, but that can be modified in order to match other analysis or other species requirements.
For example the most variable parameter we can probably find is the maximum number of SNPs we are going to allow in a sequence window. This parameter is going to depend on the species variability, and also on the similarity of our reference with the isolates being analyzed.
```
##############  SNP FILTERS #########################
# The maximum number of SNPs allowed in a window.
MAX_SNP=3

# The length of the window in which the number of SNPs should be no more than max_num_snp
WINDOW_SIZE=1000
```
### Results analysis
Let's proceed to analyze the results. We can find them in:
```
/home/alumno/Documents/wgs/results_def/wgs_outbreaker
```
This directory contains several folders including:
```
├── Alignment -> already analyzed 
├── QC -> already analyzed
├── raw -> symbolic links to raw reads
├── RAXML -> phylogenetic results
├── stats -> alignment and variant calling stats.
└── variant_calling -> variant calling files.
```
Since alignment and quality control results has been previously addresed in this course (see [02_QualityAndAssembly.md](02_QualityAndAssembly.md) and [Mapping Section](#Mapping)), we will proceed to analyze variant calling results.

#### Variant calling results
Variants are stored in plain text files in vcf format (variant calling format). Vcf files can be found in:
```
wgs_outbreaker/variant_calling/variants_gatk/variants
```
Here we can find a bunch of vcf files for each filtering steps we made:
- *.g.vcf <- this file contains a special vcf format that includes both variant and invariants sites information.
- snps_indels.vcf <- contains raw variants, both indels and snps found by GATK in the samples. This is a multisample vcf file and contains genotype information for all the samples at the same time.
- In order to follow GATK's best practice protocol for high quality variant filtering, snps and indels must be treated separately, so we have snps_only_flags.vcf and indels_only_flags.vcf with quality flags for each type of variants.
```
##fileformat=VCFv4.2
##ALT=<ID=NON_REF,Description="Represents any possible alternative allele at this location">
##FILTER=<ID="p-value StrandBias",Description="FS > 60.0">
##FILTER=<ID=LowQD,Description="QD < 2.0">
##FILTER=<ID=LowQual,Description="Low quality">
##FILTER=<ID=MaxDepth,Description="DP < 5">
##FILTER=<ID=RMSMappingQuality,Description="MQ < 40.0">
##FILTER=<ID=SnpCluster,Description="SNPs found in clusters">
##FILTER=<ID=StandOddRatio,Description="SOR > 3.0">
##FORMAT=<ID=AD,Number=R,Type=Integer,Description="Allelic depths for the ref and alt alleles in the order listed">
##FORMAT=<ID=DP,Number=1,Type=Integer,Description="Approximate read depth (reads with MQ=255 or with bad mates are filtered)">
##FORMAT=<ID=GQ,Number=1,Type=Integer,Description="Genotype Quality">
##FORMAT=<ID=GT,Number=1,Type=String,Description="Genotype">
##FORMAT=<ID=MIN_DP,Number=1,Type=Integer,Description="Minimum DP observed within the GVCF block">
##FORMAT=<ID=PL,Number=G,Type=Integer,Description="Normalized, Phred-scaled likelihoods for genotypes as defined in the VCF specification">
##FORMAT=<ID=RGQ,Number=1,Type=Integer,Description="Unconditional reference genotype confidence, encoded as a phred quality -10*log10 p(genotype call is wrong)">
##FORMAT=<ID=SB,Number=4,Type=Integer,Description="Per-sample component statistics which comprise the Fisher's Exact Test to detect strand bias.">
##GATKCommandLine.GenotypeGVCFs=<ID=GenotypeGVCFs,Version=3.8-0-ge9d806836,Date="Sun Oct 28 11:20:56 UTC 2018",Epoch=1540725656730,CommandLineOptions="analysis_type=GenotypeGVCFs input_file=[] showFullBamList=false read_buffer_size=null read_filter=[] disable_read_filter=[] intervals=null excludeIntervals=null interval_set_rule=UNION interval_merging=ALL interval_padding=0 reference_sequence=listeria_NC_021827.1_NoPhagues.fna nonDeterministicRandomSeed=false disableDithering=false maxRuntime=-1 maxRuntimeUnits=MINUTES downsampling_type=BY_SAMPLE downsample_to_fraction=null downsample_to_coverage=1000 baq=OFF baqGapOpenPenalty=40.0 refactor_NDN_cigar_string=false fix_misencoded_quality_scores=false allow_potentially_misencoded_quality_scores=false useOriginalQualities=false defaultBaseQualities=-1 performanceLog=null BQSR=null quantize_quals=0 static_quantized_quals=null round_down_quantized=false disable_indel_quals=false emit_original_quals=false preserve_qscores_less_than=6 globalQScorePrior=-1.0 secondsBetweenProgressUpdates=10 validation_strictness=SILENT remove_program_records=false keep_program_records=false sample_rename_mapping_file=null unsafe=null use_jdk_deflater=false use_jdk_inflater=false disable_auto_index_creation_and_locking_when_reading_rods=false no_cmdline_in_header=false sites_only=false never_trim_vcf_format_field=false bcf=false bam_compression=null simplifyBAM=false disable_bam_indexing=false generate_md5=false num_threads=1 num_cpu_threads_per_data_thread=1 num_io_threads=0 monitorThreadEfficiency=false num_bam_file_handles=null read_group_black_list=null pedigree=[] pedigreeString=[] pedigreeValidationType=STRICT allow_intervals_with_unindexed_bam=false generateShadowBCF=false variant_index_type=DYNAMIC_SEEK variant_index_parameter=-1 reference_window_stop=0 phone_home= gatk_key=null tag=NA logging_level=INFO log_to_file=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/snp_indels.vcf-jointGVCF.log help=false version=false variant=[(RodBindingCollection [(RodBinding name=variant source=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/RA-L2073.g.vcf), (RodBinding name=variant2 source=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/RA-L2281.g.vcf), (RodBinding name=variant3 source=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/RA-L2327.g.vcf), (RodBinding name=variant4 source=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/RA-L2391.g.vcf), (RodBinding name=variant5 source=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/RA-L2450.g.vcf), (RodBinding name=variant6 source=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/RA-L2677.g.vcf), (RodBinding name=variant7 source=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/RA-L2701.g.vcf), (RodBinding name=variant8 source=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/RA-L2782.g.vcf), (RodBinding name=variant9 source=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/RA-L2805.g.vcf), (RodBinding name=variant10 source=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/RA-L2978.g.vcf)])] out=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/snp_indels.vcf includeNonVariantSites=false uniquifySamples=false annotateNDA=false useNewAFCalculator=false heterozygosity=0.001 indel_heterozygosity=1.25E-4 heterozygosity_stdev=0.01 standard_min_confidence_threshold_for_calling=10.0 standard_min_confidence_threshold_for_emitting=30.0 max_alternate_alleles=6 max_genotype_count=1024 max_num_PL_values=100 input_prior=[] sample_ploidy=2 annotation=[] group=[StandardAnnotation] dbsnp=(RodBinding name= source=UNBOUND) filter_reads_with_N_cigar=false filter_mismatching_base_and_quals=false filter_bases_not_stored=false">
##GATKCommandLine.HaplotypeCaller=<ID=HaplotypeCaller,Version=3.8-0-ge9d806836,Date="Sun Oct 28 11:17:56 UTC 2018",Epoch=1540725476471,CommandLineOptions="analysis_type=HaplotypeCaller input_file=[/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/Alignment/BAM/RA-L2805/RA-L2805.woduplicates.bam] showFullBamList=false read_buffer_size=null read_filter=[] disable_read_filter=[] intervals=null excludeIntervals=null interval_set_rule=UNION interval_merging=ALL interval_padding=0 reference_sequence=listeria_NC_021827.1_NoPhagues.fna nonDeterministicRandomSeed=false disableDithering=false maxRuntime=-1 maxRuntimeUnits=MINUTES downsampling_type=BY_SAMPLE downsample_to_fraction=null downsample_to_coverage=500 baq=OFF baqGapOpenPenalty=40.0 refactor_NDN_cigar_string=false fix_misencoded_quality_scores=false allow_potentially_misencoded_quality_scores=false useOriginalQualities=false defaultBaseQualities=-1 performanceLog=null BQSR=null quantize_quals=0 static_quantized_quals=null round_down_quantized=false disable_indel_quals=false emit_original_quals=false preserve_qscores_less_than=6 globalQScorePrior=-1.0 secondsBetweenProgressUpdates=10 validation_strictness=LENIENT remove_program_records=false keep_program_records=false sample_rename_mapping_file=null unsafe=null use_jdk_deflater=false use_jdk_inflater=false disable_auto_index_creation_and_locking_when_reading_rods=false no_cmdline_in_header=false sites_only=false never_trim_vcf_format_field=false bcf=false bam_compression=null simplifyBAM=false disable_bam_indexing=false generate_md5=false num_threads=1 num_cpu_threads_per_data_thread=1 num_io_threads=0 monitorThreadEfficiency=false num_bam_file_handles=null read_group_black_list=null pedigree=[] pedigreeString=[] pedigreeValidationType=STRICT allow_intervals_with_unindexed_bam=false generateShadowBCF=false variant_index_type=DYNAMIC_SEEK variant_index_parameter=-1 reference_window_stop=0 phone_home= gatk_key=null tag=NA logging_level=INFO log_to_file=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/snp_indels.vcf-HaplotypeCaller.log help=false version=false likelihoodCalculationEngine=PairHMM heterogeneousKmerSizeResolution=COMBO_MIN dbsnp=(RodBinding name= source=UNBOUND) dontTrimActiveRegions=false maxDiscARExtension=25 maxGGAARExtension=300 paddingAroundIndels=150 paddingAroundSNPs=20 comp=[] annotation=[StrandBiasBySample] excludeAnnotation=[ChromosomeCounts, FisherStrand, StrandOddsRatio, QualByDepth] group=[StandardAnnotation, StandardHCAnnotation] debug=false useFilteredReadsForAnnotations=false emitRefConfidence=GVCF bamOutput=null bamWriterType=CALLED_HAPLOTYPES emitDroppedReads=false disableOptimizations=false annotateNDA=false useNewAFCalculator=false heterozygosity=0.001 indel_heterozygosity=1.25E-4 heterozygosity_stdev=0.01 standard_min_confidence_threshold_for_calling=-0.0 standard_min_confidence_threshold_for_emitting=30.0 max_alternate_alleles=6 max_genotype_count=1024 max_num_PL_values=100 input_prior=[] sample_ploidy=1 genotyping_mode=DISCOVERY alleles=(RodBinding name= source=UNBOUND) contamination_fraction_to_filter=0.0 contamination_fraction_per_sample_file=null p_nonref_model=null exactcallslog=null output_mode=EMIT_VARIANTS_ONLY allSitePLs=true gcpHMM=10 pair_hmm_implementation=FASTEST_AVAILABLE phredScaledGlobalReadMismappingRate=45 noFpga=false nativePairHmmThreads=1 useDoublePrecision=false sample_name=null kmerSize=[10, 25] dontIncreaseKmerSizesForCycles=false allowNonUniqueKmersInRef=false numPruningSamples=1 recoverDanglingHeads=false doNotRecoverDanglingBranches=false minDanglingBranchLength=4 consensus=false maxNumHaplotypesInPopulation=128 errorCorrectKmers=false minPruning=2 debugGraphTransformations=false allowCyclesInKmerGraphToGeneratePaths=false graphOutput=null kmerLengthForReadErrorCorrection=25 minObservationsForKmerToBeSolid=20 GVCFGQBands=[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 58, 59, 60, 70, 80, 90, 99] indelSizeToEliminateInRefModel=10 min_base_quality_score=10 includeUmappedReads=false useAllelesTrigger=false doNotRunPhysicalPhasing=true keepRG=null justDetermineActiveRegions=false dontGenotype=false dontUseSoftClippedBases=false captureAssemblyFailureBAM=false errorCorrectReads=false pcr_indel_model=CONSERVATIVE maxReadsInRegionPerSample=10000 minReadsPerAlignmentStart=10 mergeVariantsViaLD=false activityProfileOut=null activeRegionOut=null activeRegionIn=null activeRegionExtension=null forceActive=false activeRegionMaxSize=null bandPassSigma=null maxReadsInMemoryPerSample=30000 maxTotalReadsInMemory=10000000 maxProbPropagationDistance=50 activeProbabilityThreshold=0.002 min_mapping_quality_score=20 filter_reads_with_N_cigar=false filter_mismatching_base_and_quals=false filter_bases_not_stored=false">
##GATKCommandLine.SelectVariants=<ID=SelectVariants,Version=3.8-0-ge9d806836,Date="Sun Oct 28 11:21:12 UTC 2018",Epoch=1540725672421,CommandLineOptions="analysis_type=SelectVariants input_file=[] showFullBamList=false read_buffer_size=null read_filter=[] disable_read_filter=[] intervals=null excludeIntervals=null interval_set_rule=UNION interval_merging=ALL interval_padding=0 reference_sequence=listeria_NC_021827.1_NoPhagues.fna nonDeterministicRandomSeed=false disableDithering=false maxRuntime=-1 maxRuntimeUnits=MINUTES downsampling_type=BY_SAMPLE downsample_to_fraction=null downsample_to_coverage=1000 baq=OFF baqGapOpenPenalty=40.0 refactor_NDN_cigar_string=false fix_misencoded_quality_scores=false allow_potentially_misencoded_quality_scores=false useOriginalQualities=false defaultBaseQualities=-1 performanceLog=null BQSR=null quantize_quals=0 static_quantized_quals=null round_down_quantized=false disable_indel_quals=false emit_original_quals=false preserve_qscores_less_than=6 globalQScorePrior=-1.0 secondsBetweenProgressUpdates=10 validation_strictness=LENIENT remove_program_records=false keep_program_records=false sample_rename_mapping_file=null unsafe=null use_jdk_deflater=false use_jdk_inflater=false disable_auto_index_creation_and_locking_when_reading_rods=false no_cmdline_in_header=false sites_only=false never_trim_vcf_format_field=false bcf=false bam_compression=null simplifyBAM=false disable_bam_indexing=false generate_md5=false num_threads=8 num_cpu_threads_per_data_thread=1 num_io_threads=0 monitorThreadEfficiency=false num_bam_file_handles=null read_group_black_list=null pedigree=[] pedigreeString=[] pedigreeValidationType=STRICT allow_intervals_with_unindexed_bam=false generateShadowBCF=false variant_index_type=DYNAMIC_SEEK variant_index_parameter=-1 reference_window_stop=0 phone_home= gatk_key=null tag=NA logging_level=INFO log_to_file=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/snp_indels.vcf-selectSNP.log help=false version=false variant=(RodBinding name=variant source=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/snp_indels.vcf) discordance=(RodBinding name= source=UNBOUND) concordance=(RodBinding name= source=UNBOUND) out=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/snp_only.vcf sample_name=[] sample_expressions=null sample_file=null exclude_sample_name=[] exclude_sample_file=[] exclude_sample_expressions=[] selectexpressions=[] invertselect=false excludeNonVariants=false excludeFiltered=false preserveAlleles=false removeUnusedAlternates=false restrictAllelesTo=ALL keepOriginalAC=false keepOriginalDP=false mendelianViolation=false invertMendelianViolation=false mendelianViolationQualThreshold=0.0 select_random_fraction=0.0 remove_fraction_genotypes=0.0 selectTypeToInclude=[SNP] selectTypeToExclude=[] keepIDs=null excludeIDs=null fullyDecode=false justRead=false maxIndelSize=2147483647 minIndelSize=0 maxFilteredGenotypes=2147483647 minFilteredGenotypes=0 maxFractionFilteredGenotypes=1.0 minFractionFilteredGenotypes=0.0 maxNOCALLnumber=2147483647 maxNOCALLfraction=1.0 setFilteredGtToNocall=false ALLOW_NONOVERLAPPING_COMMAND_LINE_SAMPLES=false forceValidOutput=false filter_reads_with_N_cigar=false filter_mismatching_base_and_quals=false filter_bases_not_stored=false">
##GATKCommandLine.VariantFiltration=<ID=VariantFiltration,Version=3.8-0-ge9d806836,Date="Sun Oct 28 11:21:16 UTC 2018",Epoch=1540725676106,CommandLineOptions="analysis_type=VariantFiltration input_file=[] showFullBamList=false read_buffer_size=null read_filter=[] disable_read_filter=[] intervals=null excludeIntervals=null interval_set_rule=UNION interval_merging=ALL interval_padding=0 reference_sequence=listeria_NC_021827.1_NoPhagues.fna nonDeterministicRandomSeed=false disableDithering=false maxRuntime=-1 maxRuntimeUnits=MINUTES downsampling_type=BY_SAMPLE downsample_to_fraction=null downsample_to_coverage=1000 baq=OFF baqGapOpenPenalty=40.0 refactor_NDN_cigar_string=false fix_misencoded_quality_scores=false allow_potentially_misencoded_quality_scores=false useOriginalQualities=false defaultBaseQualities=-1 performanceLog=null BQSR=null quantize_quals=0 static_quantized_quals=null round_down_quantized=false disable_indel_quals=false emit_original_quals=false preserve_qscores_less_than=6 globalQScorePrior=-1.0 secondsBetweenProgressUpdates=10 validation_strictness=LENIENT remove_program_records=false keep_program_records=false sample_rename_mapping_file=null unsafe=null use_jdk_deflater=false use_jdk_inflater=false disable_auto_index_creation_and_locking_when_reading_rods=false no_cmdline_in_header=false sites_only=false never_trim_vcf_format_field=false bcf=false bam_compression=null simplifyBAM=false disable_bam_indexing=false generate_md5=false num_threads=1 num_cpu_threads_per_data_thread=1 num_io_threads=0 monitorThreadEfficiency=false num_bam_file_handles=null read_group_black_list=null pedigree=[] pedigreeString=[] pedigreeValidationType=STRICT allow_intervals_with_unindexed_bam=false generateShadowBCF=false variant_index_type=DYNAMIC_SEEK variant_index_parameter=-1 reference_window_stop=0 phone_home= gatk_key=null tag=NA logging_level=INFO log_to_file=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/snp_indels.vcf-filterSNPs.log help=false version=false variant=(RodBinding name=variant source=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/snp_only.vcf) mask=(RodBinding name= source=UNBOUND) out=/home/smonzon/Documents/bacterial_wgs_training/results/wgs_outbreaker/variant_calling/variants_gatk/variants/snp_only_flags.vcf filterExpression=[MQ < 40.0, DP < 5, QD < 2.0, FS > 60.0, SOR > 3.0] filterName=[RMSMappingQuality, MaxDepth, LowQD, p-value StrandBias, StandOddRatio] genotypeFilterExpression=[] genotypeFilterName=[] clusterSize=3 clusterWindowSize=1000 maskExtension=0 maskName=Mask filterNotInMask=false missingValuesInExpressionsShouldEvaluateAsFailing=false invalidatePreviousFilters=false invertFilterExpression=false invertGenotypeFilterExpression=false setFilteredGtToNocall=false filter_reads_with_N_cigar=false filter_mismatching_base_and_quals=false filter_bases_not_stored=false">
##INFO=<ID=AC,Number=A,Type=Integer,Description="Allele count in genotypes, for each ALT allele, in the same order as listed">
##INFO=<ID=AF,Number=A,Type=Float,Description="Allele Frequency, for each ALT allele, in the same order as listed">
##INFO=<ID=AN,Number=1,Type=Integer,Description="Total number of alleles in called genotypes">
##INFO=<ID=BaseQRankSum,Number=1,Type=Float,Description="Z-score from Wilcoxon rank sum test of Alt Vs. Ref base qualities">
##INFO=<ID=ClippingRankSum,Number=1,Type=Float,Description="Z-score From Wilcoxon rank sum test of Alt vs. Ref number of hard clipped bases">
##INFO=<ID=DP,Number=1,Type=Integer,Description="Approximate read depth; some reads may have been filtered">
##INFO=<ID=DS,Number=0,Type=Flag,Description="Were any of the samples downsampled?">
##INFO=<ID=END,Number=1,Type=Integer,Description="Stop position of the interval">
##INFO=<ID=ExcessHet,Number=1,Type=Float,Description="Phred-scaled p-value for exact test of excess heterozygosity">
##INFO=<ID=FS,Number=1,Type=Float,Description="Phred-scaled p-value using Fisher's exact test to detect strand bias">
##INFO=<ID=HaplotypeScore,Number=1,Type=Float,Description="Consistency of the site with at most two segregating haplotypes">
##INFO=<ID=InbreedingCoeff,Number=1,Type=Float,Description="Inbreeding coefficient as estimated from the genotype likelihoods per-sample when compared against the Hardy-Weinberg expectation">
##INFO=<ID=MLEAC,Number=A,Type=Integer,Description="Maximum likelihood expectation (MLE) for the allele counts (not necessarily the same as the AC), for each ALT allele, in the same order as listed">
##INFO=<ID=MLEAF,Number=A,Type=Float,Description="Maximum likelihood expectation (MLE) for the allele frequency (not necessarily the same as the AF), for each ALT allele, in the same order as listed">
##INFO=<ID=MQ,Number=1,Type=Float,Description="RMS Mapping Quality">
##INFO=<ID=MQRankSum,Number=1,Type=Float,Description="Z-score From Wilcoxon rank sum test of Alt vs. Ref read mapping qualities">
##INFO=<ID=QD,Number=1,Type=Float,Description="Variant Confidence/Quality by Depth">
##INFO=<ID=RAW_MQ,Number=1,Type=Float,Description="Raw data for RMS Mapping Quality">
##INFO=<ID=ReadPosRankSum,Number=1,Type=Float,Description="Z-score from Wilcoxon rank sum test of Alt vs. Ref read position bias">
##INFO=<ID=SOR,Number=1,Type=Float,Description="Symmetric Odds Ratio of 2x2 contingency table to detect strand bias">
##contig=<ID=NC_021827.1,length=2953716>
##contig=<ID=NC_022047.1,length=55804>
##reference=file:///home/smonzon/Documents/bacterial_wgs_training/work/ba/20837f0b9838403205e62589d7ac8b/listeria_NC_021827.1_NoPhagues.fna
##source=SelectVariants
#CHROM	POS	ID	REF	ALT	QUAL	FILTER	INFO	FORMAT	RA-L2073	
NC_021827.1	276	.	C	A	291.68	RMSMappingQuality;SnpCluster;StandOddRatio	AC=1;AF=0.100;AN=10;DP=35;FS=0.000;MLEAC=1;MLEAF=0.100;MQ=38.49;QD=34.24;SOR=4.407	GT:AD:DP:GQ:PL	0:3,0:3:99:0,117
NC_021827.1	731	.	A	G	2313.68	SnpCluster	AC=1;AF=0.100;AN=10;DP=101;FS=0.000;MLEAC=1;MLEAF=0.100;MQ=60.00;QD=33.05;SOR=0.811	GT:AD:DP:GQ:PL	0:3,0:3:99:0,101
NC_021827.1	921	.	C	T	1841.68	SnpCluster	AC=1;AF=0.100;AN=10;DP=110;FS=0.000;MLEAC=1;MLEAF=0.100;MQ=60.00;QD=29.70;SOR=0.826	GT:AD:DP:GQ:PL	0:3,0:3:99:0,101
NC_021827.1	1067	.	C	T	2250.68	SnpCluster	AC=1;AF=0.100;AN=10;DP=168;FS=0.000;MLEAC=1;MLEAF=0.100;MQ=60.00;QD=31.70;SOR=0.779	GT:AD:DP:GQ:PL	0:3,0:3:99:0,101
NC_021827.1	2114	.	C	T	8324.89	SnpCluster	AC=3;AF=0.300;AN=10;DP=341;FS=0.000;MLEAC=3;MLEAF=0.300;MQ=60.00;QD=30.49;SOR=0.841	GT:AD:DP:GQ:PL	0:3,0:3:99:0,101
NC_021827.1	2180	.	G	A	7855.89	SnpCluster	AC=3;AF=0.300;AN=10;DP=342;FS=0.000;MLEAC=3;MLEAF=0.300;MQ=60.00;QD=28.67;SOR=0.832	GT:AD:DP:GQ:PL	0:3,0:3:99:0,101
```
- Finally we continue to filter snps calls for our SNP matrix, and we filter SNPs which are included in a window of 1000 pb with an acumulation of more than 3 snps. We process two files snps_Pass.fasta and snps_PassCluster.fasta, one including only SNPs that PASS all the filters, and one that includes PASS snps and also those filtered by our cluster filter. We do this because usually we haven't select the window size and max snps properly for our samples and we need to analyze the complete set of SNPs.

#### Phylogeny results
Phylogenetic tree reconstruction is performed using RAxML with 100 inferences and 100 bootstrap repetitions. RAxML results can be checked in RAxML folder:
```
/home/Alumno/Documents/wgs/results/RAxML/{variant_caller}
```
Two different trees are generated one with only SNPs passing all filters (preser) and one with all snps (all_snp). Both trees are outputed for evaluation. In this case we are going to use the tree with the filtered SNPs because snp cluster filter has performed correctly.

RAxML outputs one file per inference and per bootstrap so the folder is full of files. Don't worry we only need the final tree file, which is in newick format for visualization. The file is called:
```
RAxML_bipartitions.RAXML_TREE_ANNOT
```
Now we are going to open firefox browser and go to [iTOL website](https://itol.embl.de/). This web allows us to visualize and annotate phylogenetics trees with a very user-friendly interface. Also, it has good exporting options for publication.

Once in iTOL website we click in Upload in the top menu. Next we upload our tree as shown in the image:
<p align="center"><img src="img/itol_web1.png" width="1000"></p>

Now we are visualizing our tree and we can manipulate it. First of all, as we are facing an unrooted tree with long and small branches, we are going to perform a midpoint rooting method for improve the visualization. For this we choose the longest branch an we click on it. We have to get a menu like this image:
<p align="center"><img src="img/itol_web2.png" width="1000"></p>

iTOL offers multiple annotation and maniputation options. We can selecto for example the display of bootstrap in the advance tab.
<p align="center"><img src="img/itol_web3.png" width="1000"></p>

You can play with all the options iTOL offers reading its [documentation](https://itol.embl.de/help.cgi), and export the tree in the export tab. 

<p align="center"><img src="img/itol_web2.png" width="1000"></p>

Now we are going to focus on our results. Our final tree should look something like this:

<p align="center"><img src="img/tree_with_bad_sample_snps.png" width="1000"></p>

Which strains do you think belong to the outbreak?
Tips: At this point you should focus on the bootstrap and the branch lenght.

#### SNPs distance
As we have studied in the theory class, maximum likelihood methods for phylogeny only offers as branch lenght the average nucleotide substitution rate, this means the branch lenght is only a estimation of the number of nucleotide changes a strain has suffer respect to another.
In order to know exactly the SNPs differences between the strains WGS-Outbreaker outputs a distance matrix showing the paired diffences among the samples.
We can check this file in:
```
/home/alumno/Documents/wgs/results/wgs_outbreaker/stats
```
Include here the file....


As we see the SNP difference cutoff is important here, and it will depend on the strain and the case. If we stablish 3-5 snps as our cutoff we can detect that the strains belonging to the outbreak are: 2978, 2805 and 2073
