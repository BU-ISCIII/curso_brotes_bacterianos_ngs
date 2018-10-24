#!/usr/bin/env nextflow

/*
========================================================================================
                  B A C T E R I A L   W G S   P R A C T I C E
========================================================================================
 #### Homepage / Documentation
 https://github.com/BU-ISCIII/bacterial_wgs_training
 @#### Authors
 Sara Monzon <smonzon@isciii.es>
----------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------
Pipeline overview:
 - 1. : Preprocessing
 	- 1.1: FastQC for raw sequencing reads quality control
 	- 1.2: Trimmomatic
 - 2. : Mapping
 	- 2.1: BWA alignment against reference genome
 	- 2.2: Post-alignment processing and format conversion
 	- 2.3: Statistics about mapped reads
 - 4. : Picard for duplicate read identification
 	- 4.1: Statistics about read counts
 - 5. : Assembly
 	- 5.1 : Assembly with spades
 	- 5.2 : Assembly stats
 - 6. : SNP outbreak analysis
 	- 6.1 : CFSAN snp pipeline
 	- 6.2 : WGS-Outbreaker pipeline
 	- 6.3 : Phylogeny
 - 7. : wg/cgMLST:
 	- 7.1 : ChewBBACA
 	- 7.2 : Phyloviz (MST)
 - 8. : Comparative Genomics
 	- Get homologues
 	- Artemis
 - 9. : PlasmidID
 - 10. : SRST2
 - 11. : MultiQC
 - 12. : Output Description HTML
 ----------------------------------------------------------------------------------------
*/

def helpMessage() {
    log.info"""
    =========================================
     BU-ISCIII/bacterial_wgs_training : WGS analysis practice v${version}
    =========================================
    Usage:

    The typical command for running the pipeline is as follows:

    nextflow run BU-ISCIII/bacterial_wgs_training --reads '*_R{1,2}.fastq.gz' --fasta listeria.fasta --step preprocessing

    Mandatory arguments:
      --reads                       Path to input data (must be surrounded with quotes).
      --fasta                       Path to Fasta reference

    References
      --bwa_index                   Path to BWA index
      --gtf							Path to GTF reference file. (Mandatory if step = assembly)
      --saveReference				Save reference file and indexes.

	Steps available:
	  --step [str]					Select which step to perform (preprocessing|mapping|assembly|outbreakSNP|outbreakMLST|plasmidID|strainCharacterization)

    Options:
      --singleEnd                   Specifies that the input is single end reads

    Trimming options
      --notrim                      Specifying --notrim will skip the adapter trimming step.
      --saveTrimmed                 Save the trimmed Fastq files in the the Results directory.
      --trimmomatic_adapters_file   Adapters index for adapter removal
      --trimmomatic_adapters_parameters Trimming parameters for adapters. <seed mismatches>:<palindrome clip threshold>:<simple clip threshold>. Default 2:30:10
      --trimmomatic_window_length   Window size. Default 4
      --trimmomatic_window_value    Window average quality requiered. Default 20
      --trimmomatic_mininum_length  Minimum length of reads

    Assembly options

    Mapping options
	  --keepduplicates				Keep duplicate reads. Picard MarkDuplicates step skipped.
	  --saveAlignedIntermediates	Save intermediate bam files.

    PlasmidID options
      --plasmidid_database          Plasmids database
      --plasmidid_options           Command line options for PlasmidID

    Strain Characterization options
      --srst2_resistance            Fasta file/s for gene resistance databases
      --srst2_db                    Fasta file of MLST alleles
      --srst2_def                   ST definitions for MLST scheme

    OutbreakSNP options
      --outbreaker_config			Config needed by wgs-outbreaker.

	OutbreakMLST options


    Other options:
      --outdir                      The output directory where the results will be saved
    """.stripIndent()
}

/*
 * SET UP CONFIGURATION VARIABLES
 */

// Pipeline version
version = '1.0'

// Show help message
params.help = false
if (params.help){
    helpMessage()
    exit 0
}

/*
 * Default and custom value for configurable variables
 */

params.fasta = false
if( params.fasta ){
    fasta_file = file(params.fasta)
    if( !fasta_file.exists() ) exit 1, "Fasta file not found: ${params.fasta}."
}

// bwa index
params.bwa_index = false

if( params.bwa_index ){
    bwa_file = file(params.bwa_index)
    if( !fasta_file.exists() ) exit 1, "BWAIndex file not found: ${params.bwa_index}."
}

// gtf file
params.gtf = false

if( params.gtf ){
    gtf_file = file(params.gtf)
    if( !gtf_file.exists() ) exit 1, "GTF file not found: ${params.gtf}."
}

// WGS-Outbreaker config
params.outbreaker_config = false
if ( params.outbreaker_config ){
	outbreaker_config_file = file(params.outbreaker_config)
	if ( !outbreaker_config_file.exists() ) exit 1, "WGS-Outbreaker config file not found: ${params.outbreaker_config}"
}
// Steps
params.step = "preprocessing"
if ( ! (params.step =~ /(preprocessing|mapping|assembly|plasmidID|outbreakSNP|outbreakMLST|strainCharacterization)/) ) {
	exit 1, 'Please provide a valid --step option [preprocessing,mapping,assembly,plasmidID,outbreakSNP,outbreakMLST,strainCharacterization]'
}

// Mapping-duplicates defaults
params.keepduplicates = false
params.notrim = false


// MultiQC config file
params.multiqc_config = "${baseDir}/conf/multiqc_config.yaml"

if (params.multiqc_config){
	multiqc_config = file(params.multiqc_config)
}

// Output md template location
output_docs = file("$baseDir/docs/output.md")

// Output files options
params.saveReference = false
params.saveTrimmed = false
params.saveAlignedIntermediates = false

// Default trimming options
params.trimmomatic_adapters_file = "\$TRIMMOMATIC_PATH/adapters/NexteraPE-PE.fa"
params.trimmomatic_adapters_parameters = "2:30:10"
params.trimmomatic_window_length = "4"
params.trimmomatic_window_value = "20"
params.trimmomatic_mininum_length = "50"

//srst2
params.srst2_db = false
if ( params.srst2_db ){
	srst2_db = file(params.srst2_db)
	if ( !srst2_db.exists() ) exit 1, "SRST2 db file not found: ${params.srst2_db}"
}
params.srst2_def = false
if ( params.srst2_def ){
	srst2_def = file(params.srst2_def)
	if ( !srst2_def.exists() ) exit 1, "SRST2 mlst definitions file not found: ${params.srst2_def}"
}
params.srst2_resistance = false
if ( params.srst2_resistance ){
	srst2_db = file(params.srst2_resistance)
	if ( !srst2_resistance.exists() ) exit 1, "SRST2 resistance database not found: ${params.srst2_resistance}"
}

// PlasmidID parameters
params.plasmidid_database = false
if( params.plasmidid_database && params.step =~ /plasmidID/ ){
    plasmidid_database = file(params.plasmidid_database)
    if( !plasmidid_database.exists() ) exit 1, "PlasmidID database file not found: ${params.plasmidid_database}."
}

// SingleEnd option
params.singleEnd = false

// Validate  mandatory inputs
params.reads = false
if (! params.reads ) exit 1, "Missing reads: $params.reads. Specify path with --reads"

if( ! params.fasta ) exit 1, "Missing Reference genome: '$params.fasta'. Specify path with --fasta"

if (params.step =~ /assembly/ && ! params.gtf ){
    exit 1, "GTF file not provided for assembly step, please declare it with --gtf /path/to/gtf_file"
}

if( ! params.plasmidid_database && params.step =~ /plasmidID/ ){
    exit 1, "PlasmidID database file must be declared with --plasmidid_database /path/to/database.fasta"
}

if( ! params.outbreaker_config && params.step =~ /outbreakSNP/ ){
    exit 1, "WGS-Outbreaker config file not provided for outbreakSNP step, please declare it with --outbreaker_config /path/to/config.file."
}

if( ! params.srst2_db && params.step =~ /strainCharacterization/ ){
    exit 1, "SRST2 allele mlst database not provided for strainCharacterization step, please declare it with --srst2_db /path/to/db."
}

if( ! params.srst2_def && params.step =~ /strainCharacterization/ ){
    exit 1, "SRST2 mlst schema definitions not provided for strainCharacterization step, please declare it with --srst2_def /path/to/db."
}

if( ! params.srst2_resistance && params.step =~ /strainCharacterization/ ){
    exit 1, "SRST2 resistance database not provided for strainCharacterization step, please declare it with --srst2_resistance /path/to/db."
}

/*
 * Create channel for input files
 */

// Create channel for bwa_index if supplied
if( params.bwa_index ){
    bwa_index = Channel
        .fromPath(params.bwa_index)
        .ifEmpty { exit 1, "BWA index not found: ${params.bwa_index}" }
}

// Create channel for input reads.
Channel
    .fromFilePairs( params.reads, size: params.singleEnd ? 1 : 2 )
    .ifEmpty { exit 1, "Cannot find any reads matching: ${params.reads}\nIf this is single-end data, please specify --singleEnd on the command line." }
    .into { raw_reads_fastqc; raw_reads_trimming }


// Header log info
log.info "========================================="
log.info " BU-ISCIII/bacterial_wgs_training : WGS analysis practice v${version}"
log.info "========================================="
def summary = [:]
summary['Reads']               = params.reads
summary['Data Type']           = params.singleEnd ? 'Single-End' : 'Paired-End'
if(params.bwa_index)  summary['BWA Index'] = params.bwa_index
else if(params.fasta) summary['Fasta Ref'] = params.fasta
if(params.gtf)  summary['GTF File'] = params.gtf
summary['Keep Duplicates']     = params.keepduplicates
summary['Step']                = params.step
summary['Container']           = workflow.container
if(workflow.revision) summary['Pipeline Release'] = workflow.revision
summary['Current home']        = "$HOME"
summary['Current user']        = "$USER"
summary['Current path']        = "$PWD"
summary['Working dir']         = workflow.workDir
summary['Output dir']          = params.outdir
summary['Script dir']          = workflow.projectDir
summary['Save Reference']      = params.saveReference
summary['Save Trimmed']        = params.saveTrimmed
summary['Save Intermeds']      = params.saveAlignedIntermediates
if( params.notrim ){
    summary['Trimming Step'] = 'Skipped'
} else {
    summary['Trimmomatic adapters file'] = params.trimmomatic_adapters_file
    summary['Trimmomatic adapters parameters'] = params.trimmomatic_adapters_parameters
    summary["Trimmomatic window length"] = params.trimmomatic_window_length
    summary["Trimmomatic window value"] = params.trimmomatic_window_value
    summary["Trimmomatic minimum length"] = params.trimmomatic_mininum_length
}
summary['Config Profile'] = workflow.profile
log.info summary.collect { k,v -> "${k.padRight(21)}: $v" }.join("\n")
log.info "===================================="

// Check that Nextflow version is up to date enough
// try / throw / catch works for NF versions < 0.25 when this was implemented
nf_required_version = '0.25.0'
try {
    if( ! nextflow.version.matches(">= $nf_required_version") ){
        throw GroovyException('Nextflow version too old')
    }
} catch (all) {
    log.error "====================================================\n" +
              "  Nextflow version $nf_required_version required! You are running v$workflow.nextflow.version.\n" +
              "  Pipeline execution will continue, but things may break.\n" +
              "  Please run `nextflow self-update` to update Nextflow.\n" +
              "============================================================"
}

/*
 * Build BWA index
 */
if (params.step =~ /(mapping|outbreakSNP)/)
if(!params.bwa_index && fasta_file){
    process makeBWAindex {
        tag "${fasta.baseName}"
        publishDir path: { params.saveReference ? "${params.outdir}/reference_genome" : params.outdir },
                   saveAs: { params.saveReference ? it : null }, mode: 'copy'

        input:
        file fasta from fasta_file

        output:
        file "${fasta}*" into bwa_index

        script:
        """
        mkdir BWAIndex
        bwa index -a bwtsw $fasta
        """
    }
}


/*
 * STEP 1.1 - FastQC
 */
if (params.step =~ /(preprocessing|mapping|assembly|outbreakSNP|outbreakMLST|plasmidID|strainCharacterization)/ ){
	process fastqc {
		tag "$prefix"
		publishDir "${params.outdir}/fastqc", mode: 'copy',
			saveAs: {filename -> filename.indexOf(".zip") > 0 ? "zips/$filename" : "$filename"}

		input:
		set val(name), file(reads) from raw_reads_fastqc

		output:
		file '*_fastqc.{zip,html}' into fastqc_results
		file '.command.out' into fastqc_stdout

		script:

		prefix = name - ~/(_S[0-9]{2})?(_L00[1-9])?(.R1)?(_1)?(_R1)?(_trimmed)?(_val_1)?(_00*)?(\.fq)?(\.fastq)?(\.gz)?$/
		"""
		fastqc -t 1 $reads
		"""
	}

	process trimming {
		tag "$prefix"
		publishDir "${params.outdir}/trimming", mode: 'copy',
			saveAs: {filename ->
				if (filename.indexOf("_fastqc") > 0) "FastQC/$filename"
				else if (filename.indexOf(".log") > 0) "logs/$filename"
				else params.saveTrimmed ? filename : null
		}

		input:
		set val(name), file(reads) from raw_reads_trimming

		output:
		file '*_paired.fastq.gz' into trimmed_paired_reads
		file '*_unpaired.fastq.gz' into trimmed_unpaired_reads
		file '*_fastqc.{zip,html}' into trimming_fastqc_reports
		file '*.log' into trimmomatic_results

		script:
		prefix = name - ~/(_S[0-9]{2})?(_L00[1-9])?(.R1)?(_1)?(_R1)?(_trimmed)?(_val_1)?(_00*)?(\.fq)?(\.fastq)?(\.gz)?$/
		"""
		trimmomatic PE -phred33 $reads $prefix"_R1_paired.fastq" $prefix"_R1_unpaired.fastq" $prefix"_R2_paired.fastq" $prefix"_R2_unpaired.fastq" ILLUMINACLIP:${params.trimmomatic_adapters_file}:${params.trimmomatic_adapters_parameters} SLIDINGWINDOW:${params.trimmomatic_window_length}:${params.trimmomatic_window_value} MINLEN:${params.trimmomatic_mininum_length} 2>&1 > $name".log"

		gzip *.fastq

		fastqc -q *_paired.fastq.gz

		"""
	}
}
/*
 * STEP 3.1 - align with bwa
 */

if (params.step =~ /mapping/){
	process bwa {
		tag "$prefix"
		publishDir path: { params.saveAlignedIntermediates ? "${params.outdir}/bwa" : params.outdir }, mode: 'copy',
				saveAs: {filename -> params.saveAlignedIntermediates ? filename : null }

		input:
		file reads from trimmed_paired_reads
		file index from bwa_index
		file fasta from fasta_file

		output:
		file '*.bam' into bwa_bam

		script:
		prefix = reads[0].toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
		"""
		bwa mem -M $fasta $reads | samtools view -bT $fasta - > ${prefix}.bam
		"""
	}


	/*
	* STEP 3.2 - post-alignment processing
	*/
	process samtools {
		tag "${bam.baseName}"
		publishDir path: "${params.outdir}/bwa", mode: 'copy',
				saveAs: { filename ->
					if (filename.indexOf(".stats.txt") > 0) "stats/$filename"
					else params.saveAlignedIntermediates ? filename : null
				}

		input:
		file bam from bwa_bam

		output:
		file '*.sorted.bam' into bam_for_mapped, bam_picard
		file '*.sorted.bam.bai' into bwa_bai, bai_picard,bai_for_mapped
		file '*.sorted.bed' into bed_total
		file '*.stats.txt' into samtools_stats

		script:
		"""
		samtools sort $bam -o ${bam.baseName}.sorted.bam
		samtools index ${bam.baseName}.sorted.bam
		bedtools bamtobed -i ${bam.baseName}.sorted.bam | sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 > ${bam.baseName}.sorted.bed
		samtools stats ${bam.baseName}.sorted.bam > ${bam.baseName}.stats.txt
		"""
	}


	/*
	* STEP 3.3 - Statistics about mapped and unmapped reads against ref genome
	*/

	process bwa_mapped {
		tag "${input_files[0].baseName}"
		publishDir "${params.outdir}/bwa/mapped", mode: 'copy'

		input:
		file input_files from bam_for_mapped.collect()
		file bai from bai_for_mapped.collect()

		output:
		file 'mapped_refgenome.txt' into bwa_mapped

		script:
		"""
		for i in $input_files
		do
		samtools idxstats \${i} | awk -v filename="\${i}" '{mapped+=\$3; unmapped+=\$4} END {print filename,"\t",mapped,"\t",unmapped}'
		done > mapped_refgenome.txt
		"""
	}

	/*
	* STEP 4 Picard
	*/
	/* Comment duplicated reads removal*/
	if (!params.keepduplicates){

		process picard {
			tag "$prefix"
			publishDir "${params.outdir}/picard", mode: 'copy'

			input:
			file bam from bam_picard

			output:
			file '*.dedup.sorted.bam' into bam_dedup_spp, bam_dedup_ngsplot, bam_dedup_deepTools, bam_dedup_macs, bam_dedup_saturation, bam_dedup_epic
			file '*.dedup.sorted.bam.bai' into bai_dedup_deepTools, bai_dedup_spp, bai_dedup_ngsplot, bai_dedup_macs, bai_dedup_saturation, bai_dedup_epic
			file '*.dedup.sorted.bed' into bed_dedup,bed_epic_dedup
			file '*.picardDupMetrics.txt' into picard_reports

			script:
			prefix = bam[0].toString() - ~/(\.sorted)?(\.bam)?$/
			if( task.memory == null ){
				log.warn "[Picard MarkDuplicates] Available memory not known - defaulting to 6GB ($prefix)"
				avail_mem = 6000
			} else {
				avail_mem = task.memory.toMega()
				if( avail_mem <= 0){
					avail_mem = 6000
					log.warn "[Picard MarkDuplicates] Available memory 0 - defaulting to 6GB ($prefix)"
				} else if( avail_mem < 250){
					avail_mem = 250
					log.warn "[Picard MarkDuplicates] Available memory under 250MB - defaulting to 250MB ($prefix)"
				}
			}
			"""
			java -Xmx${avail_mem}m -jar \$PICARD_HOME/picard.jar MarkDuplicates \\
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
			"""
		}
		//Change variables to dedup variables
		bam_spp = bam_dedup_spp
		bam_ngsplot = bam_dedup_ngsplot
		bam_deepTools = bam_dedup_deepTools
		bam_macs = bam_dedup_macs
		bam_epic = bam_dedup_epic
		bam_for_saturation = bam_dedup_saturation
		bed_total = bed_dedup
		bed_epic = bed_epic_dedup

		bai_spp = bai_dedup_spp
		bai_ngsplot = bai_dedup_ngsplot
		bai_deepTools = bai_dedup_deepTools
		bai_macs = bai_dedup_macs
		bai_epic = bai_dedup_epic
		bai_for_saturation = bai_dedup_saturation
	}
}

	/*
	* STEP 5 Assembly
	*/
if (params.step =~ /(assembly|plasmidID)/){

//	process spades {
//		tag "$prefix"
//		publishDir path: { "${params.outdir}/spades" }, mode: 'copy'
//
//		input:
//		set file(readsR1),file(readsR2) from trimmed_paired_reads
//
//		output:
//		file "${prefix}_scaffolds.fasta" into scaffold_quast,scaffold_prokka
//		file "${prefix}_contigs.fasta" into contigs_quast,contigs_prokka
//
//		script:
//		prefix = readsR1.toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_paired)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
//		"""
//		spades.py --phred-offset 33 --only-assembler -1 $readsR1 -2 $readsR2 -o .
//		mv scaffolds.fasta $prefix"_scaffolds.fasta"
//		mv contigs.fasta $prefix"_contigs.fasta"
//		"""
//	}

	process unicycler {
		tag "$prefix"
		publishDir path: { "${params.outdir}/unicycler" }, mode: 'copy'

		input:
		set file(readsR1),file(readsR2) from trimmed_paired_reads

		output:
		file "${prefix}_assembly.fasta" into scaffold_quast,scaffold_prokka,scaffold_plasmidid

		script:
		prefix = readsR1.toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_paired)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
		"""
		unicycler -1 $readsR1 -2 $readsR2 --pilon_path \$PILON_PATH -o .
		mv assembly.fasta $prefix"_assembly.fasta"
		"""
	}

	process quast {
		tag "$prefix"
		publishDir path: {"${params.outdir}/quast"}, mode: 'copy',
							saveAs: { filename -> if(filename == "quast_results") "${prefix}_quast_results"}

		input:
		file scaffold from scaffold_quast
		file fasta from fasta_file
		file gtf from gtf_file

		output:
		file "quast_results" into quast_results
		file "quast_results/latest/report.tsv" into quast_multiqc

		script:
		prefix = scaffold.toString() - ~/(_scaffolds\.fasta)?$/
		"""
		quast.py -R $fasta -G $gtf $scaffold
		"""
	}

	process prokka {
		tag "$prefix"
		publishDir path: {"${params.outdir}/prokka"}, mode: 'copy',
							saveAs: { filename -> if(filename == "prokka_results") "${prefix}_prokka_results"}

		input:
		file scaffold from scaffold_prokka

		output:
		file "prokka_results" into prokka_results
		file "prokka_results/prokka.txt" into prokka_multiqc

		script:
		prefix = scaffold.toString() - ~/(_scaffolds\.fasta)?$/
		"""
		prokka --force --outdir prokka_results --prefix prokka --genus Listeria --species monocytogenes --strain $prefix --locustag BU-ISCIII --compliant --kingdom Bacteria $scaffold
		"""
	}

}

if (params.step =~ /outbreakSNP/){

	process wgsoutbreaker {
	tag "WGSOutbreaker"
	publishDir "${params.outdir}/WGS-Outbreaker", mode: 'copy'

	input:
	file reads from trimmed_paired_reads.collect()
	file index from bwa_index
	file fasta from fasta_file
	file config from outbreaker_config_file

	output:
	file "outbreaker_results" into outbreaker_results
	file "outbreaker_results/Alignment" into picard_reports

	script:
	"""
	run_outbreak_wgs.sh $config
	"""

	}
}


if (!params.keepduplicates) {  Channel.empty().set { picard_reports } }

if (params.step =~ /preprocessing/){
	Channel.empty().set { samtools_stats }
	Channel.empty().set { picard_reports }
	Channel.empty().set { prokka_multiqc }
	Channel.empty().set { quast_multiqc }
}

if (params.step =~ /mapping/){
	Channel.empty().set { prokka_multiqc }
	Channel.empty().set { quast_multiqc }
}

if (params.step =~ /assembly/){
	Channel.empty().set { samtools_stats }
	Channel.empty().set { picard_reports }
}

if (params.step =~ /outbreakSNP/){
	Channel.empty().set { samtools_stats }
	Channel.empty().set { prokka_multiqc }
	Channel.empty().set { quast_multiqc }
}

/*
 * STEP 9 PlasmidID
 */
if (params.step =~ /plasmidID/){

 process plasmidid {
     tag "PlasmidID"
     publishDir "${params.outdir}/PlasmidID", mode 'copy'

     input:
     set file(readsR1),file(readsR2) from trimmed_paired_reads
     file assembly from scaffold_plasmidid

     output:
     file "plasmidid_results" into plasmidid_results

     script:
     prefix = readsR1.toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_paired)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
     """
     plasmidID.sh -1 $readsR1 -2 $readsR2 -d $plasmidid_database -s $prefix --no-trim -c $assembly -o plasmidid_results
     """
 }

}

/*
 * STEP 10 SRST2
 */

if (params.step =~ /strainCharacterization/){

  process srst2_mlst {
  tag "SRST2_DB"
  publishDir "${params.outdir}/SRST2_MLST", mode 'copy'

  input:
  set file(readsR1),file(readsR2) from trimmed_paired_reads

  output:
  file "*results.txt" into srst2_mlst_results

  script:
  prefix = readsR1.toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_paired)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
  """
  srst2 --input_pe $readsR1 $readsR2 --output $prefix --log --mlst_db $srst2_db --mlst_definitions $srst2_def
  """
 }

  process srst2_db {
  tag "SRST2_DB"
  publishDir "${params.outdir}/SRST2_DB", mode 'copy'

  input:
  set file(readsR1),file(readsR2) from trimmed_paired_reads

  output:
  file "*results.txt" into srst2_db_results

  script:
  prefix = readsR1.toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_paired)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
  """
  srst2 --input_pe $readsR1 $readsR2 --output $prefix --log --gene_db $srst2_resistance
  """
 }

}

/*
 * STEP 11 MultiQC
 */

process multiqc {
    tag "$prefix"
    publishDir "${params.outdir}/MultiQC", mode: 'copy'

    input:
    file multiqc_config
    file (fastqc:'fastqc/*') from fastqc_results.collect()
    file ('trimommatic/*') from trimmomatic_results.collect()
    file ('samtools/*') from samtools_stats.collect()
    file ('picard/*') from picard_reports.collect()
    file ('prokka/*') from prokka_multiqc.collect()
    file ('quast/*') from quast_multiqc.collect()

    output:
    file '*multiqc_report.html' into multiqc_report
    file '*_data' into multiqc_data
    file '.command.err' into multiqc_stderr
    val prefix into multiqc_prefix

    script:
    prefix = fastqc[0].toString() - '_fastqc.html' - 'fastqc/'
    rtitle = custom_runName ? "--title \"$custom_runName\"" : ''
    rfilename = custom_runName ? "--filename " + custom_runName.replaceAll('\\W','_').replaceAll('_+','_') + "_multiqc_report" : ''

    """
    multiqc -f $rtitle $rfilename --config $multiqc_config . 2>&1
    """

}


workflow.onComplete {
	log.info "BU-ISCIII - Pipeline complete"
}

///*
// * STEP 12 - Output Description HTML
// */
//process output_documentation {
//    tag "$prefix"
//    publishDir "${params.outdir}/Documentation", mode: 'copy'
//
//    input:
//    val prefix from multiqc_prefix
//    file output from output_docs
//
//    output:
//    file "results_description.html"
//
//    script:
//    def rlocation = params.rlocation ?: ''
//    """
//    markdown_to_html.r $output results_description.html $rlocation
//    """
//}
//
//
///*
// * Completion e-mail notification
// */
//
//workflow.onComplete {
//
//    // Set up the e-mail variables
//    def subject = "[BU-ISCIII/ChIPseq-nf] Successful: $workflow.runName"
//    if(!workflow.success){
//      subject = "[BU-ISCIII/ChIPseq-nf] FAILED: $workflow.runName"
//    }
//    def email_fields = [:]
//    email_fields['version'] = version
//    email_fields['runName'] = custom_runName ?: workflow.runName
//    email_fields['success'] = workflow.success
//    email_fields['dateComplete'] = workflow.complete
//    email_fields['duration'] = workflow.duration
//    email_fields['exitStatus'] = workflow.exitStatus
//    email_fields['errorMessage'] = (workflow.errorMessage ?: 'None')
//    email_fields['errorReport'] = (workflow.errorReport ?: 'None')
//    email_fields['commandLine'] = workflow.commandLine
//    email_fields['projectDir'] = workflow.projectDir
//    email_fields['summary'] = summary
//    email_fields['summary']['Date Started'] = workflow.start
//    email_fields['summary']['Date Completed'] = workflow.complete
//    email_fields['summary']['Nextflow Version'] = workflow.nextflow.version
//    email_fields['summary']['Nextflow Build'] = workflow.nextflow.build
//    email_fields['summary']['Nextflow Compile Timestamp'] = workflow.nextflow.timestamp
//    email_fields['summary']['Pipeline script file path'] = workflow.scriptFile
//    email_fields['summary']['Pipeline script hash ID'] = workflow.scriptId
//    if(workflow.repository) email_fields['summary']['Pipeline repository Git URL'] = workflow.repository
//    if(workflow.commitId) email_fields['summary']['Pipeline repository Git Commit'] = workflow.commitId
//    if(workflow.revision) email_fields['summary']['Pipeline Git branch/tag'] = workflow.revision
//    if(workflow.container) email_fields['summary']['Docker/Singularity image'] = workflow.container
//
//    // Render the TXT template
//    def engine = new groovy.text.GStringTemplateEngine()
//    def tf = new File("$baseDir/assets/email_template.txt")
//    def txt_template = engine.createTemplate(tf).make(email_fields)
//    def email_txt = txt_template.toString()
//
//    // Render the HTML template
//    def hf = new File("$baseDir/assets/email_template.html")
//    def html_template = engine.createTemplate(hf).make(email_fields)
//    def email_html = html_template.toString()
//
//    // Render the sendmail template
//    def smail_fields = [ email: params.email, subject: subject, email_txt: email_txt, email_html: email_html, baseDir: "$baseDir" ]
//    def sf = new File("$baseDir/assets/sendmail_template.txt")
//    def sendmail_template = engine.createTemplate(sf).make(smail_fields)
//    def sendmail_html = sendmail_template.toString()
//
//    // Send the HTML e-mail
//    if (params.email) {
//        try {
//          if( params.plaintext_email ){ throw GroovyException('Send plaintext e-mail, not HTML') }
//          // Try to send HTML e-mail using sendmail
//          [ 'sendmail', '-t' ].execute() << sendmail_html
//          log.info "[BU-iSCIII/ChIPseq-nf] Sent summary e-mail to $params.email (sendmail)"
//        } catch (all) {
//          // Catch failures and try with plaintext
//          [ 'mail', '-s', subject, params.email ].execute() << email_txt
//          log.info "[BU-ISCIII/ChIPseq] Sent summary e-mail to $params.email (mail)"
//        }
//    }
//
//    // Switch the embedded MIME images with base64 encoded src
//    ngichipseqlogo = new File("$baseDir/assets/NGI-ChIPseq_logo.png").bytes.encodeBase64().toString()
//    scilifelablogo = new File("$baseDir/assets/SciLifeLab_logo.png").bytes.encodeBase64().toString()
//    ngilogo = new File("$baseDir/assets/NGI_logo.png").bytes.encodeBase64().toString()
//    email_html = email_html.replaceAll(~/cid:ngichipseqlogo/, "data:image/png;base64,$ngichipseqlogo")
//    email_html = email_html.replaceAll(~/cid:scilifelablogo/, "data:image/png;base64,$scilifelablogo")
//    email_html = email_html.replaceAll(~/cid:ngilogo/, "data:image/png;base64,$ngilogo")
//
//    // Write summary e-mail HTML to a file
//    def output_d = new File( "${params.outdir}/Documentation/" )
//    if( !output_d.exists() ) {
//      output_d.mkdirs()
//    }
//    def output_hf = new File( output_d, "pipeline_report.html" )
//    output_hf.withWriter { w -> w << email_html }
//    def output_tf = new File( output_d, "pipeline_report.txt" )
//    output_tf.withWriter { w -> w << email_txt }
//
//    log.info "[BU-ISCIII/ChIPseq-nf] Pipeline Complete"
//
//    if(!workflow.success){
//        if( workflow.profile == 'standard'){
//            if ( "hostname".execute().text.contains('.uppmax.uu.se') ) {
//                log.error "====================================================\n" +
//                        "  WARNING! You are running with the default 'standard'\n" +
//                        "  pipeline config profile, which runs on the head node\n" +
//                        "  and assumes all software is on the PATH.\n" +
//                        "  This is probably why everything broke.\n" +
//                        "  Please use `-profile uppmax` to run on UPPMAX clusters.\n" +
//                        "============================================================"
//            }
//        }
//    }
//}
