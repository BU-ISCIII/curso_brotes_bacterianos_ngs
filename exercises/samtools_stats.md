This command will internally execute the following programs with our samples:
 1. Preprocessiong
Quality control and read trimming with FastQC and Trimmomatic:	
```
fastqc reads_R1.fastq.gz reads_R2.fastq.gz
java -jar trimmomatic.jar PE -phred33 reads_R1.fastq.gz reads_R2.fastq.gz \ reads_paired_R1.fastq reads_unpaired_R1.fastq \ reads_paired_R2.fastq reads_unpaired_R2.fastq \ ILLUMINACLIP:Truseq3-PE.fa:2:30:10 \ SLIDINGWINDOW:4:20 \ MINLEN:50
fastqc reads_paired_R[1|2].fastq reads_unpaired_R[1|2].fastq
```
2. Building bwa index
Bwa needs to build an index from the reference genome in order to now how to map the reads.
```
bwa index -a bwtsw $fasta
```
3. Mapping
Map each read against the reference genome.
```
bwa mem -M $fasta $reads | samtools view -bT $fasta - > ${prefix}.bam
```
4. Post-processing and statistics
A handful of steps have to be executed before using the bam files resulting from the mapping. 
First, bam files have to be sorted and indexed:
```
samtools sort $bam -o ${bam.baseName}.sorted.bam
samtools index ${bam.baseName}.sorted.bam
```
A bed file can now be generated from the bam file:
```
bedtools bamtobed -i ${bam.baseName}.sorted.bam | sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 > ${bam.baseName}.sorted.bed
```
And mapping stats generated:
```
samtools stats ${bam.baseName}.sorted.bam > ${bam.baseName}.stats.txt
samtools idxstats \${i} | awk -v filename="\${i}" '{mapped+=\$3; unmapped+=\$4} END {print filename,"\t",mapped,"\t",unmapped}'
```
And finally we can remove some sequencing and mapping artifacts, as the duplicated reads:
```
java -jar \$PICARD_HOME/picard.jar MarkDuplicates \\
	INPUT=$bam \\
	OUTPUT=${prefix}.dedup.bam \\
	ASSUME_SORTED=true \\
	REMOVE_DUPLICATES=true \\
	METRICS_FILE=${prefix}.picardDupMetrics.txt \\
	VALIDATION_STRINGENCY=LENIENT \\
	PROGRAM_RECORD_ID='null'
	samtools sort ${prefix}.dedup.bam -o ${prefix}.dedup.sorted.bam
	samtools index ${prefix}.dedup.sorted.bam
	bedtools bamtobed -i ${prefix}.dedup.sorted.bam | sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 > ${prefix}.dedup.sorted.bed
```
4. MultiQC report
MultiQC will automatically search for the stats files and will compare them in user-friendly graphs
```
multiqc RESULTS_DIRECTORY
```

* The file starts with a header with meta-info about the software version and the command executed:

```
# This file was produced by samtools stats (1.9+htslib-1.9) and can be plotted using plot-bamstats
# This file contains statistics for all reads.
# The command line was:  stats RA-L2073_paired.sorted.bam
# CHK, Checksum	[2]Read Names	[3]Sequences	[4]Qualities
# CHK, CRC32 of reads which passed filtering followed by addition (32bit overflow)
CHK	347f3b2a	9afad54b	a4ef69d7
```
* Mapping statistics:
```
# Summary Numbers. Use `grep ^SN | cut -f 2-` to extract this part.
SN	raw total sequences:	1043656
SN	filtered sequences:	0
SN	sequences:	1043656
SN	is sorted:	1
SN	1st fragments:	521828
SN	last fragments:	521828
SN	reads mapped:	1023086
SN	reads mapped and paired:	1023014	# paired-end technology bit set + both mates mapped
SN	reads unmapped:	20570
SN	reads properly paired:	1016484	# proper-pair bit set
SN	reads paired:	1043656	# paired-end technology bit set
SN	reads duplicated:	0	# PCR or optical duplicate bit set
SN	reads MQ0:	17214	# mapped and MQ=0
SN	reads QC failed:	0
SN	non-primary alignments:	9023
SN	total length:	202576990	# ignores clipping
SN	total first fragment length:	105484283	# ignores clipping
SN	total last fragment length:	97092707	# ignores clipping
SN	bases mapped:	198829793	# ignores clipping
SN	bases mapped (cigar):	198118932	# more accurate
SN	bases trimmed:	0
SN	bases duplicated:	0
SN	mismatches:	153131	# from NM fields
SN	error rate:	7.729246e-04	# mismatches / bases mapped (cigar)
SN	average length:	194
SN	average first fragment length:	202
SN	average last fragment length:	186
SN	maximum length:	301
SN	maximum first fragment length:	301
SN	maximum last fragment length:	301
SN	average quality:	36.6
SN	insert size average:	259.1
SN	insert size standard deviation:	146.7
SN	inward oriented pairs:	355544
SN	outward oriented pairs:	153333
SN	pairs with other orientation:	2630
SN	pairs on different chromosomes:	0
SN	percentage of properly paired reads (%):	97.4
```
* Qualities of the fist frament of each contig:
```
# First Fragment Qualities. Use `grep ^FFQ | cut -f 2-` to extract this part.
# Columns correspond to qualities and rows to cycles. First column is the cycle number.
FFQ	1	0	0	0	0	0	0	0	0	0	0	0	0	742	0	0	0	0	0	0	0	0	390	0	426	930	0	0	2526	0	0	84	5019	2048	3345	506318	0	0	0	0	0
FFQ	2	0	0	0	0	0	0	0	0	0	0	0	0	993	0	0	0	0	0	0	0	0	577	0	855	1492	0	0	2713	0	0	201	5376	4080	4411	501130	0	0	0	0	0
[...]

```
* Qualities of the las fragment of each contig:
```
# Last Fragment Qualities. Use `grep ^LFQ | cut -f 2-` to extract this part.
# Columns correspond to qualities and rows to cycles. First column is the cycle number.
LFQ	1	0	0	0	0	0	0	0	0	0	0	0	0	3009	0	0	0	0	0	0	0	0	1024	0	765	1724	0	0	3564	0	0	177	7226	3171	4796	496372	0	0	0	0	0
LFQ	2	0	0	0	0	0	0	0	0	0	0	0	0	2316	0	0	0	0	0	0	0	0	1229	0	1449	2194	0	0	3695	0	0	321	7339	5262	5281	492742	0	0	0	0	0
[...]

```
* GC content of the first framents:
```
# GC Content of first fragments. Use `grep ^GCF | cut -f 2-` to extract this part.
GCF	4.02	0
GCF	8.79	1
[...]
```
* GC content of the last fragments:
```
# GC Content of last fragments. Use `grep ^GCL | cut -f 2-` to extract this part.
GCL	4.02	0
GCL	8.79	1
[...]
```
* Frequency of each base per cycle:
```
# ACGT content per cycle. Use `grep ^GCC | cut -f 2-` to extract this part. The columns are: cycle; A,C,G,T base counts as a percentage of all A/C/G/T bases [%]; and N and O counts as a percentage of all A/C/G/T bases [%]
GCC	1	20.72	28.98	29.59	20.72	0.00	0.00
GCC	2	33.20	16.37	16.44	33.99	0.00	0.00
[...]
```
* Frequency of each base per cycle for the frist fragments:
```
# ACGT content per cycle for first fragments. Use `grep ^FBC | cut -f 2-` to extract this part. The columns are: cycle; A,C,G,T base counts as a percentage of all A/C/G/T bases [%]; and N and O counts as a percentage of all A/C/G/T bases [%]
FBC	1	20.73	28.90	29.57	20.81	0.00	0.00
FBC	2	33.19	16.37	16.43	34.02	0.00	0.00
[...]
```
* Frequency of each base per cycle for the last fragments:
```
# ACGT content per cycle for last fragments. Use `grep ^LBC | cut -f 2-` to extract this part. The columns are: cycle; A,C,G,T base counts as a percentage of all A/C/G/T bases [%]; and N and O counts as a percentage of all A/C/G/T bases [%]
LBC	1	20.72	29.05	29.61	20.62	0.00	0.00
LBC	2	33.20	16.37	16.46	33.97	0.00	0.00
[...]
```
* Insert sizes:
```
# Insert sizes. Use `grep ^IS | cut -f 2-` to extract this part. The columns are: insert size, pairs total, inward oriented pairs, outward oriented pairs, other pairs
IS	0	0	0	0	0
IS	1	0	0	0	0
[...]
```
* Read lengths:
```
# Read lengths. Use `grep ^RL | cut -f 2-` to extract this part. The columns are: read length, count
RL	50	1061
RL	51	992
[...]
```
* Read lengths for the first fragments:
```
# Read lengths - first fragments. Use `grep ^FRL | cut -f 2-` to extract this part. The columns are: read length, count
FRL	50	486
FRL	51	460
[...]
```
* Read lengths for the last fragments:
```
# Read lengths - last fragments. Use `grep ^LRL | cut -f 2-` to extract this part. The columns are: read length, count
LRL	50	575
LRL	51	532
[...]
```
* Indel distribution:
```
# Indel distribution. Use `grep ^ID | cut -f 2-` to extract this part. The columns are: length, number of insertions, number of deletions
ID	1	611	3056
ID	2	29	124
[...]
```
* Indels per cycle:
```
# Indels per cycle. Use `grep ^IC | cut -f 2-` to extract this part. The columns are: cycle, number of insertions (fwd), .. (rev) , number of deletions (fwd), .. (rev)
IC	3	0	0	5	1
IC	4	1	1	5	6
[...]
```
* Coverage distribution:
```
# Coverage distribution. Use `grep ^COV | cut -f 2-` to extract this part.
COV	[1-1]	1	70
COV	[2-2]	2	254
[...]
```
* GC-depth:
```
# GC-depth. Use `grep ^GCD | cut -f 2-` to extract this part. The columns are: GC%, unique sequence percentiles, 10th, 25th, 50th, 75th and 90th depth percentile
GCD	0.0	1.351	0.000	0.000	0.000	0.000	0.000
GCD	33.0	2.027	45.347	45.347	45.347	45.347	45.347
[...]
```

While this statistics can be plotted with `plot-bamstats`
