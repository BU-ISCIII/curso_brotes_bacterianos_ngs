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
 	- 1.2: Fastp
 - 2. : Mapping
 	- 2.1: BWA alignment against reference genome
 	- 2.2: Post-alignment processing and format conversion
 	- 2.3: Statistics about mapped reads
 - 4. : Picard for duplicate read identification
 	- 4.1: Statistics about read counts
 - 5. : Assembly
 	- 5.1 : Assembly with unicycler
 	- 5.2 : Assembly stats
 - 6. : SNP outbreak analysis
 	- 6.1 : Snippy
 	- 6.2 : Phylogeny
 - 7. : wg/cgMLST:
 	- 7.1 : ChewBBACA
 	- 7.2 : Phyloviz (MST)
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
	  --step [str]					Select which step to perform (preprocessing|mapping|assembly|outbreakSNP|outbreakMLST|plasmidID|strainCharacterization|mapAnnotation)
    Options:

    Trimming options
    --cut_mean_quality [int]          The mean quality requirement option shared by fastp cut_front, cut_tail or cut_sliding options. Range: 1~36 (Default: 30 (Q30))
      --qualified_quality_phred [int]   The quality value that a base is qualified. Default 30 means phred quality >=Q30 is qualified (Default: 30)
      --unqualified_percent_limit [int] Percentage of bases that are allowed to be unqualified (0~100) (Default: 10)
      --min_trim_length [int]           Reads shorter than this length after trimming will be discarded (Default: 50)
      --notrim                      Specifying --notrim will skip the adapter trimming step.
      --saveTrimmed                 Save the trimmed Fastq files in the the Results directory.

    Assembly options

    Mapping options
	  --keepduplicates				Keep duplicate reads. Picard MarkDuplicates step skipped.
	  --saveAlignedIntermediates	Save intermediate bam files.

    PlasmidID options
      --plasmidid_database          Plasmids database
      --plasmidid_config            PlasmidID annotation config file

    Strain Characterization options
      --srst2_resistance            Fasta file/s for gene resistance databases
      --srst2_virulence             Fasta file/s for gene virulence databases
      --srst2_db_mlst               Fasta file of MLST alleles
      --srst2_def_mlst              ST definitions for MLST scheme
      --srst2_db_sero               Fasta file of serogroup
      --srst2_def_sero              ST definitions for serogroup scheme

	OutbreakMLST options
	  --scheme                      path to scheme alleles folder.


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

if( params.fasta ){
    fasta_file = file(params.fasta)
    if( !fasta_file.exists() ) exit 1, "Fasta file not found: ${params.fasta}."
}

// bwa index

if( params.bwa_index ){
    bwa_file = file(params.bwa_index)
    if( !fasta_file.exists() ) exit 1, "BWAIndex file not found: ${params.bwa_index}."
}

// gtf file

if( params.gtf ){
    gtf_file = file(params.gtf)
    if( !gtf_file.exists() ) exit 1, "GTF file not found: ${params.gtf}."
}

// cgMLST scheme
if( params.scheme ){
    scheme = file(params.scheme)
    if( !scheme.exists() ) exit 1, "Scheme path not found: ${params.scheme}."
}

// Steps
if ( ! (params.step =~ /(preprocessing|mapping|assembly|plasmidID|outbreakSNP|outbreakMLST|strainCharacterization|mapAnnotation)/) ) {
	exit 1, 'Please provide a valid --step option [preprocessing,mapping,assembly,plasmidID,outbreakSNP,outbreakMLST,strainCharacterization,mapAnnotation]'
}

// MultiQC config file

if (params.multiqc_config){
	multiqc_config = file(params.multiqc_config)
}

//srst2
params.srst2_db_mlst = false
if ( params.srst2_db_mlst ){
	srst2_db_mlst = file(params.srst2_db_mlst)
	if ( !srst2_db_mlst.exists() ) exit 1, "SRST2 db file not found: ${params.srst2_db_mlst}"
}
params.srst2_def_mlst = false
if ( params.srst2_def_mlst ){
	srst2_def_mlst = file(params.srst2_def_mlst)
	if ( !srst2_def_mlst.exists() ) exit 1, "SRST2 mlst definitions file not found: ${params.srst2_def_mlst}"
}
params.srst2_db_sero = false
if ( params.srst2_db_sero ){
	srst2_db_sero = file(params.srst2_db_sero)
	if ( !srst2_db_sero.exists() ) exit 1, "SRST2 db file not found: ${params.srst2_db_sero}"
}
params.srst2_def_sero = false
if ( params.srst2_def_sero ){
	srst2_def_sero = file(params.srst2_def_sero)
	if ( !srst2_def_sero.exists() ) exit 1, "SRST2 mlst definitions file not found: ${params.srst2_def_sero}"
}
params.srst2_resistance = false
if ( params.srst2_resistance ){
	srst2_resistance = file(params.srst2_resistance)
	if ( !srst2_resistance.exists() ) exit 1, "SRST2 resistance database not found: ${params.srst2_resistance}"
}

params.srst2_virulence = false
if ( params.srst2_virulence ){
	srst2_virulence = file(params.srst2_virulence)
	if ( !srst2_virulence.exists() ) exit 1, "SRST2 virulence database not found: ${params.srst2_virulence}"
}

// PlasmidID parameters
params.plasmidid_database = false
if( params.plasmidid_database && params.step =~ /plasmidID/ ){
    plasmidid_database = file(params.plasmidid_database)
    if( !plasmidid_database.exists() ) exit 1, "PlasmidID database file not found: ${params.plasmidid_database}."
}

params.plasmidid_config = false
if( params.plasmidid_config && params.step =~ /plasmidID/ ){
    plasmidid_config = file(params.plasmidid_config)
    if( !plasmidid_config.exists() ) exit 1, "PlasmidID config file not found: ${params.plasmidid_config}."
}

// SingleEnd option
params.singleEnd = false

// Validate  mandatory inputs
params.reads = false
if (! params.reads ) exit 1, "Missing reads: $params.reads. Specify path with --reads"

if( params.step =~ /mapping|outbreakSNP/ && ! params.fasta ) exit 1, "Missing Reference genome: '$params.fasta'. Specify path with --fasta"

if (params.step =~ /assembly|plasmidID/ && ! params.gtf ){
    exit 1, "GTF file not provided for assembly step, please declare it with --gtf /path/to/gtf_file"
}

if( ! params.plasmidid_database && params.step =~ /plasmidID/ ){
    exit 1, "PlasmidID database file must be declared with --plasmidid_database /path/to/database.fasta"
}

if( ! params.plasmidid_config && params.step =~ /plasmidID/ ){
    exit 1, "PlasmidID annotation config file must be declared with --plasmidid_database /path/to/database.fasta"
}

if( ! params.srst2_db_mlst && params.step =~ /strainCharacterization/ ){
    exit 1, "SRST2 allele mlst database not provided for strainCharacterization step, please declare it with --srst2_db_mlst /path/to/db."
}

if( ! params.srst2_def_mlst && params.step =~ /strainCharacterization/ ){
    exit 1, "SRST2 mlst schema definitions not provided for strainCharacterization step, please declare it with --srst2_def_mlst /path/to/db."
}

if( ! params.srst2_db_sero && params.step =~ /strainCharacterization/ ){
    exit 1, "SRST2 allele serogroup database not provided for strainCharacterization step, please declare it with --srst2_db_sero /path/to/db."
}

if( ! params.srst2_def_sero && params.step =~ /strainCharacterization/ ){
    exit 1, "SRST2 serogroup schema definitions not provided for strainCharacterization step, please declare it with --srst2_def_sero /path/to/db."
}

if( ! params.srst2_resistance && params.step =~ /mapAnnotation/ ){
    exit 1, "SRST2 resistance database not provided for mapAnnotation step, please declare it with --srst2_resistance /path/to/db."
}

if( ! params.srst2_virulence && params.step =~ /mapAnnotation/ ){
    exit 1, "SRST2 virulence database not provided for mapAnnotation step, please declare it with --srst2_virulence /path/to/db."
}

if( ! params.scheme && params.step =~ /outbreakMLST/ ){
    exit 1, "cg/wgMLST schema not provided for outbreakMLST step, please declare it with --scheme /path/to/scheme."
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
	if (params.cut_mean_quality)          summary['Fastp Mean Qual'] = params.cut_mean_quality
    if (params.qualified_quality_phred)   summary['Fastp Qual Phred'] = params.qualified_quality_phred
    if (params.unqualified_percent_limit) summary['Fastp Unqual % Limit'] = params.unqualified_percent_limit
    if (params.min_trim_length)           summary['Fastp Min Trim Length'] = params.min_trim_length
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
if (params.step =~ /(mapping|outbreakSNP)/){
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
}


/*
 * STEP 1.1 - FastQC
 */
if (params.step =~ /(preprocessing|mapping|assembly|outbreakSNP|outbreakMLST|plasmidID|strainCharacterization|mapAnnotation)/ ){
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
    else if (filename.indexOf(".fastq.gz") > 0) "trimmed/$filename"
				else params.saveTrimmed ? filename : null
		}

		input:
		set val(name), file(reads) from raw_reads_trimming

		output:
		file '*_trimmed.fastq.gz' into trimmed_paired_reads,trimmed_paired_reads_bwa,trimmed_paired_reads_unicycler,trimmed_paired_reads_snippy,trimmed_paired_reads_plasmidid,trimmed_paired_reads_mlst,trimmed_paired_reads_res,trimmed_paired_reads_sero,trimmed_paired_reads_vir
		file '*_fail.fastq.gz' into trimmed_unpaired_reads
		file '*_fastqc.{zip,html}' into trimmomatic_fastqc_reports
		file '*.log' into trimmomatic_results

		script:
		prefix = name - ~/(_S[0-9]{2})?(_L00[1-9])?(.R1)?(_1)?(_R1)?(_trimmed)?(_val_1)?(_00*)?(\.fq)?(\.fastq)?(\.gz)?$/
		"""
		IN_READS='--in1 ${prefix}_R1.fastq.gz --in2 ${prefix}_R2.fastq.gz'
        OUT_READS='--out1 ${prefix}_R1_trimmed.fastq.gz --out2 ${prefix}_R2_trimmed.fastq.gz --unpaired1 ${prefix}_R1_fail.fastq.gz --unpaired2 ${prefix}_R2_fail.fastq.gz'
		fastp \\
            \$IN_READS \\
            \$OUT_READS \\
            --detect_adapter_for_pe \\
            --cut_front \\
            --cut_tail \\
            --cut_mean_quality $params.cut_mean_quality \\
            --qualified_quality_phred $params.qualified_quality_phred \\
            --unqualified_percent_limit $params.unqualified_percent_limit \\
            --length_required $params.min_trim_length \\
            --trim_poly_x \\
            --thread $task.cpus \\
            --json ${prefix}.fastp.json \\
            --html ${prefix}.fastp.html \\
            2> ${prefix}.fastp.log
        fastqc --quiet --threads $task.cpus *_trimmed.fastq.gz
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
		file reads from trimmed_paired_reads_bwa
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
		samtools sort $bam -o ${bam.baseName}.sorted.bam -T ${bam.baseName}
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
			"""
			picard MarkDuplicates \\
				INPUT=$bam \\
				OUTPUT=${prefix}.dedup.bam \\
				ASSUME_SORTED=true \\
				REMOVE_DUPLICATES=true \\
				METRICS_FILE=${prefix}.picardDupMetrics.txt \\
				VALIDATION_STRINGENCY=LENIENT \\
				PROGRAM_RECORD_ID='null'

			samtools sort ${prefix}.dedup.bam -o ${prefix}.dedup.sorted.bam -T ${prefix}
			samtools index ${prefix}.dedup.sorted.bam
			bedtools bamtobed -i ${prefix}.dedup.sorted.bam | sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 > ${prefix}.dedup.sorted.bed
			"""
		}
		//Change variables to dedup variables
	}
}

	/*
	* STEP 5 Assembly
	*/
if (params.step =~ /(assembly|plasmidID|outbreakMLST)/){

	process unicycler {
		tag "$prefix"
		publishDir path: { "${params.outdir}/unicycler" }, mode: 'copy'

		input:
		set file(readsR1),file(readsR2) from trimmed_paired_reads_unicycler

		output:
		file "${prefix}_assembly.fasta" into scaffold_quast,scaffold_prokka,scaffold_plasmidid,scaffold_taranis

		script:
		prefix = readsR1.toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_paired)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
		"""
		unicycler -1 $readsR1 -2 $readsR2 -o .
		mv assembly.fasta $prefix"_assembly.fasta"
		"""
	}

	process quast {
		tag "$prefix"
		publishDir path: {"${params.outdir}/quast"}, mode: 'copy',
							saveAs: { filename -> if(filename == "quast_results") "${prefix}_quast_results"}

		input:
		file scaffolds from scaffold_quast.collect()
		file fasta from fasta_file
		file gtf from gtf_file

		output:
		file "quast_results" into quast_results
		file "quast_results/latest/report.tsv" into quast_multiqc

		script:
		prefix = scaffolds[0].toString() - ~/(_scaffolds\.fasta)?$/
		"""
		quast.py -R $fasta -G $gtf $scaffolds
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
		file "prokka_results/${prefix}_prokka.txt" into prokka_multiqc

		script:
		prefix = scaffold.toString() - ~/(_scaffolds\.fasta)?$/
		"""
		prokka --force --outdir prokka_results --prefix prokka --genus Listeria --species monocytogenes --strain $prefix --locustag BU-ISCIII --compliant --kingdom Bacteria $scaffold
		mv prokka_results/prokka.txt prokka_results/${prefix}_prokka.txt
		"""
	}

}

if (params.step =~ /outbreakSNP/){

	process snippy {
	tag "$prefix"
	publishDir "${params.outdir}/Snippy", mode: 'copy'

	input:
  set file(readsR1),file(readsR2) from trimmed_paired_reads_snippy
	file fasta from fasta_file

	output:
	file "${prefix}*" into snippy_results
	//file "outbreaker_results/Alignment" into picard_reports

	script:
  prefix = readsR1.toString() - ~/(_R1_trimmed.fastq.gz)?$/
	"""
  snippy --outdir $prefix --R1 $readsR1 --R2 $readsR2 --ref $fasta --cpus $task.cpus
	"""
	}

  process snippy_core {
  tag "snippy_core"
  publishDir "${params.outdir}/Snippy/core", mode: 'copy'

  input:
  file snippys from snippy_results.collect()
  file fasta from fasta_file

  output:
  file "core*" into snippy_core_alignment
  file "clean.full.aln" into snippy_core_gubbins

  script:
  ref_file = snippys[0]
  """
  snippy-core --ref $fasta $snippys
  snippy-clean_full_aln core.full.aln > clean.full.aln
  """
  }

  process gubbins {
  tag "gubbins"
  publishDir "${params.outdir}/gubbins", mode: 'copy'

  input:
  file core_align from snippy_core_gubbins
  file fasta from fasta_file

  output:
  file "gubbins.filtered_polymorphic_sites.fasta" into gubbins_results
  file "clean.core.aln" into gubbins_alignment,gubbins_alignment_fastree

  script:
  """
  run_gubbins.py --threads $task.cpus -p gubbins clean.full.aln
  snp-sites -c gubbins.filtered_polymorphic_sites.fasta > clean.core.aln
  """
  }

  process iqtree {
  tag "iqtree"
  publishDir "${params.outdir}/iqtree", mode: 'copy'

  input:
  file clean_align from gubbins_alignment_fastree

  output:
  file "clean.core.aln.*" into iqtree_results

  script:
  """
  iqtree -s $clean_align --boot 100
  """
  }
}

if (params.step =~ /outbreakMLST/){

	process scheme_evaluation {
	tag "checkScheme"
	publishDir "${params.outdir}/scheme_eval", mode: 'copy'

	input:
	file scheme from scheme

	output:
	file "reference_alleles_dir" into ref_alleles_taranis
	file "taranis_analyze_schema_dir" into analyze_schema_out

	script:
	"""
		taranis.py analyze_schema \\
		-inputdir $scheme \\
		-outputdir taranis_analyze_schema_dir

		taranis.py reference_alleles \\
		-coregenedir $scheme \\
		-outputdir reference_alleles_dir
	"""

	}
 	process taranis {
     tag "cgMLST"
     publishDir "${params.outdir}/Taranis", mode: 'copy'

     input:
     file (assembly:"assembly/*") from scaffold_taranis.collect()
	 file fasta from fasta_file
     file scheme from scheme
     file ref_alleles from ref_alleles_taranis

     output:
     file "*.tsv" into taranis_results

     script:
     """
     taranis.py allele_calling -coregenedir $scheme -refgenome $fasta -refalleles $ref_alleles -inputdir assembly -outputdir .
     """
 	}
}


/#*
 * STEP 9 PlasmidID
 */
if (params.step =~ /plasmidID/){

 process plasmidid {
     tag "PlasmidID"
     publishDir "${params.outdir}/PlasmidID", mode: 'copy'

     input:
     set file(readsR1),file(readsR2) from trimmed_paired_reads_plasmidid
     file assembly from scaffold_plasmidid

     output:
     file "plasmidid_results" into plasmidid_results

     script:
     prefix = readsR1.toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_paired)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
     """
     plasmidID -1 $readsR1 -2 $readsR2 -d $plasmidid_database -s $prefix --no-trim -c $assembly -o plasmidid_results -a $plasmidid_config
     """
 }

}

/*
 * STEP 10 SRST2
 */

if (params.step =~ /strainCharacterization/){

  process srst2_mlst {
  tag "$prefix"
  publishDir "${params.outdir}/SRST2_MLST", mode: 'copy'

  input:
  set file(readsR1),file(readsR2) from trimmed_paired_reads_mlst

  output:
  file "*results.txt" into srst2_mlst_results, srst2_mlst_plots

  script:
  prefix = readsR1.toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_paired)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
  """
  srst2 --input_pe $readsR1 $readsR2 --forward "_R1_trimmed" --reverse "_R2_trimmed" --output $prefix --log --mlst_db $srst2_db_mlst --mlst_definitions $srst2_def_mlst --mlst_delimiter "_"
  """
 }

  process srst2_serogroup {
  tag "$prefix"
  publishDir "${params.outdir}/SRST2_SERO", mode: 'copy'

  input:
  set file(readsR1),file(readsR2) from trimmed_paired_reads_sero

  output:
  file "*results.txt" into srst2_sero_results, srst2_sero_plots

  script:
  prefix = readsR1.toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_paired)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
  """
  srst2 --input_pe $readsR1 $readsR2 --output $prefix --forward "_R1_trimmed" --reverse "_R2_trimmed" --log --mlst_db $srst2_db_sero --mlst_definitions $srst2_def_sero --mlst_delimiter "_"
  """
 }

}

if (params.step =~ /mapAnnotation/){

  process srst2_resistance {
  tag "$prefix"
  publishDir "${params.outdir}/SRST2_RES", mode: 'copy'

  input:
  set file(readsR1),file(readsR2) from trimmed_paired_reads_res

  output:
  file "*results.txt" into srst2_res_results, srst2_res_plots

  script:
  prefix = readsR1.toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_paired)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
  """
  srst2 --input_pe $readsR1 $readsR2 --forward "_R1_trimmed" --reverse "_R2_trimmed" --output $prefix --log --gene_db $srst2_resistance
  """
 }

  process srst2_virulence {
  tag "$prefix"
  publishDir "${params.outdir}/SRST2_VIR", mode: 'copy'

  input:
  set file(readsR1),file(readsR2) from trimmed_paired_reads_vir

  output:
  file "*results.txt" into srst2_vir_results

  script:
  prefix = readsR1.toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_paired)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
  """
  srst2 --input_pe $readsR1 $readsR2 --forward "_R1_trimmed" --reverse "_R2_trimmed" --output $prefix --log --gene_db $srst2_virulence
  """
 }
}

/*
 * STEP 11 MultiQC
 */


//if (!params.keepduplicates) {  Channel.empty().set { picard_reports } }

if (params.step =~ /preprocessing/){

 process multiqc_preprocessing {
    tag "$prefix"
    publishDir "${params.outdir}/MultiQC", mode: 'copy'

    input:
    file multiqc_config
    file (fastqc:'fastqc/*') from fastqc_results.collect()
    file ('trimommatic/*') from trimmomatic_results.collect()
    file ('trimommatic/*') from trimmomatic_fastqc_reports.collect()

    output:
    file '*multiqc_report.html' into multiqc_report
    file '*_data' into multiqc_data
    file '.command.err' into multiqc_stderr
    val prefix into multiqc_prefix

    script:
    prefix = fastqc[0].toString() - '_fastqc.html' - 'fastqc/'

    """
    multiqc -d . --config $multiqc_config
    """

 }
}

if (params.step =~ /mapping/){

 process multiqc_mapping {
    tag "$prefix"
    publishDir "${params.outdir}/MultiQC", mode: 'copy'

    input:
    file multiqc_config
    file (fastqc:'fastqc/*') from fastqc_results.collect()
    file ('trimommatic/*') from trimmomatic_results.collect()
    file ('trimommatic/*') from trimmomatic_fastqc_reports.collect()
    file ('samtools/*') from samtools_stats.collect()
    file ('picard/*') from picard_reports.collect()

    output:
    file '*multiqc_report.html' into multiqc_report
    file '*_data' into multiqc_data
    file '.command.err' into multiqc_stderr
    val prefix into multiqc_prefix

    script:
    prefix = fastqc[0].toString() - '_fastqc.html' - 'fastqc/'

    """
    multiqc -d . --config $multiqc_config
    """

 }
}

if (params.step =~ /assembly/){

 process multiqc_assembly {
    tag "$prefix"
    publishDir "${params.outdir}/MultiQC", mode: 'copy'

    input:
    file multiqc_config
    file (fastqc:'fastqc/*') from fastqc_results.collect()
    file ('trimommatic/*') from trimmomatic_results.collect()
    file ('trimommatic/*') from trimmomatic_fastqc_reports.collect()
    file ('prokka/*') from prokka_multiqc.collect()
    file ('quast/*') from quast_multiqc.collect()

    output:
    file '*multiqc_report.html' into multiqc_report
    file '*_data' into multiqc_data
    file '.command.err' into multiqc_stderr
    val prefix into multiqc_prefix

    script:
    prefix = fastqc[0].toString() - '_fastqc.html' - 'fastqc/'

    """
    multiqc -d . --config $multiqc_config
    """

 }
}

if (params.step =~ /outbreakSNP/){

process multiqc_outbreakSNP {
    tag "$prefix"
    publishDir "${params.outdir}/MultiQC", mode: 'copy'

    input:
    file multiqc_config
    file (fastqc:'fastqc/*') from fastqc_results.collect()
    file ('trimommatic/*') from trimmomatic_results.collect()
    file ('trimommatic/*') from trimmomatic_fastqc_reports.collect()

    output:
    file '*multiqc_report.html' into multiqc_report
    file '*_data' into multiqc_data
    file '.command.err' into multiqc_stderr
    val prefix into multiqc_prefix

    script:
    prefix = fastqc[0].toString() - '_fastqc.html' - 'fastqc/'

    """
    multiqc -d . --config $multiqc_config
    """

 }
}


workflow.onComplete {
	log.info "BU-ISCIII - Pipeline complete"
}
