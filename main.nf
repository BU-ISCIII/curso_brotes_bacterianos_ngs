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
 - 9. : MultiQC
 - 10. : Output Description HTML
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

    References
      --fasta                       Path to Fasta reference (Mandatory if not --genome supplied)
      --bwa_index                   Path to BWA index (Mandatory if not --genome supplied)

	Steps available:
	  --steps [str]					Select which step to perform (preprocessing|mapping|assembly|outbreakSNP|outbreakMLST)

    Options:
      --singleEnd                   Specifies that the input is single end reads

    Trimming options
      --notrim                      Specifying --notrim will skip the adapter trimming step.
      --saveTrimmed                 Save the trimmed Fastq files in the the Results directory.

    Other options:
      --outdir                      The output directory where the results will be saved
    """.stripIndent()
}

/*
 * SET UP CONFIGURATION VARIABLES
 */

// Pipeline version
version = '1.0'

// Show help emssage
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
params.bwa_index = false

if( params.bwa_index ){
    bwa_file = file(params.bwa_index)
    if( !fasta_file.exists() ) exit 1, "BWAIndex file not found: ${params.bwa_index}."
}

// gtf file
params.gtf = false

if( params.gtf ){
    gtf = file(params.gtf)
    if( !gtf.exists() ) exit 1, "GTF file not found: ${params.gtf}."
}

// Steps
params.step = "preprocessing"

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
trimmomatic_path = "/scif/apps/trimmomatic/Trimmomatic-0.38"

// SingleEnd option
params.singleEnd = false

// Validate  mandatory inputs
if( ! params.fasta ) exit 1, "Missing Reference genome: '$params.fasta'. Specify path with --fasta"


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
    .into { raw_reads_fastqc; raw_reads_trimgalore }


// Header log info
log.info "========================================="
log.info " nf-core/ChIPseq: ChIP-Seq Best Practice v${version}"
log.info "========================================="
def summary = [:]
summary['Reads']               = params.reads
summary['Data Type']           = params.singleEnd ? 'Single-End' : 'Paired-End'
if(params.bwa_index)  summary['BWA Index'] = params.bwa_index
else if(params.fasta) summary['Fasta Ref'] = params.fasta
if(params.gtf)  summary['GTF File'] = params.gtf
summary['Keep Duplicates']     = params.keepduplicates
summary['Step']         = params.peakCaller
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
    summary['Trim R1'] = params.clip_r1
    summary['Trim R2'] = params.clip_r2
    summary["Trim 3' R1"] = params.three_prime_clip_r1
    summary["Trim 3' R2"] = params.three_prime_clip_r2
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
 * PREPROCESSING - Build BWA index
 */
if(!params.bwa_index && fasta_file){
    process makeBWAindex {
        tag fasta_file
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
process fastqc {
    tag "$name"
    publishDir "${params.outdir}/fastqc", mode: 'copy',
        saveAs: {filename -> filename.indexOf(".zip") > 0 ? "zips/$filename" : "$filename"}

    input:
    set val(name), file(reads) from raw_reads_fastqc

    output:
    file '*_fastqc.{zip,html}' into fastqc_results
    file '.command.out' into fastqc_stdout

    script:
    """
    fastqc -q $reads
    """
}


/*
 * STEP 1.2 - Trimmomatic
if(params.notrim){
    trimmed_reads = read_files_trimming
    trimgalore_results = []
    trimgalore_fastqc_reports = []
} else {
	process trimming {
		tag "$name"

		input:
		set val(name), file(reads) from raw_reads

		output:
		file '*_paired.fastq.gz' into trimmed_paired_reads
		file '*_unpaired.fastq.gz' into trimmed_unpaired_reads

		script:
		'''
		echo "Step 1.2 - Trimming files ${reads}"

		echo "Command is: trimmomatic PE -threads 10 -phred33 $reads $name_R1_paired.fastq $name_R1_unpaired.fastq $name_R2_paired.fastq $name_R2_unpaired.fastq ILLUMINACLIP:$trimmomatic_path/adapters/NexteraPE-PE.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50"

		trimmomatic PE -threads 10 -phred33 $reads $name_R1_paired.fastq $name_R1_unpaired.fastq $name_R2_paired.fastq $name_R2_unpaired.fastq ILLUMINACLIP:$trimmomatic_path/adapters/NexteraPE-PE.fa:2:30:10 SLIDINGWINDOW:4:20 MINLEN:50 2>&1 >> $lablog

		gzip *.fastq

		echo "Step 1.2 - Complete!" >> $lablog
		echo "-------------------------------------------------" >> $lablog
		'''
	}
}


///*
// * STEP 3.1 - align with bwa
// */
//process bwa {
//    tag "$prefix"
//    publishDir path: { params.saveAlignedIntermediates ? "${params.outdir}/bwa" : params.outdir }, mode: 'copy',
//               saveAs: {filename -> params.saveAlignedIntermediates ? filename : null }
//
//    input:
//    file reads from trimmed_paired_reads
//    file index from bwa_index
//    file fasta from fasta_file
//
//    output:
//    file '*.bam' into bwa_bam
//
//    script:
//    prefix = reads[0].toString() - ~/(.R1)?(_1)?(_R1)?(_trimmed)?(_val_1)?(\.fq)?(\.fastq)?(\.gz)?$/
//    filtering = params.allow_multi_align ? '' : "| samtools view -b -q 1 -F 4 -F 256"
//    """
//    bwa mem -M $fasta $reads | samtools view -bT $fasta - $filtering > ${prefix}.bam
//    """
//}
//
//
///*
// * STEP 3.2 - post-alignment processing
// */
///*
//process samtools {
//    tag "${bam.baseName}"
//    publishDir path: "${params.outdir}/bwa", mode: 'copy',
//               saveAs: { filename ->
//                   if (filename.indexOf(".stats.txt") > 0) "stats/$filename"
//                   else params.saveAlignedIntermediates ? filename : null
//               }
//
//    input:
//    file bam from bwa_bam
//
//    output:
//    file '*.sorted.bam' into bam_for_mapped, bam_picard,bam_spp, bam_ngsplot, bam_deepTools, bam_macs, bam_ded,bam_epic
//    file '*.sorted.bam.bai' into bwa_bai, bai_picard,bai_for_mapped, bai_deepTools, bai_ngsplot, bai_macs, bai_saturation, bai_epic
//    file '*.sorted.bed' into bed_total,bed_epic
//    file '*.stats.txt' into samtools_stats
//
//    script:
//    """
//    samtools sort $bam -o ${bam.baseName}.sorted.bam
//    samtools index ${bam.baseName}.sorted.bam
//    bedtools bamtobed -i ${bam.baseName}.sorted.bam | sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 > ${bam.baseName}.sorted.bed
//    samtools stats ${bam.baseName}.sorted.bam > ${bam.baseName}.stats.txt
//    """
//}
//
//
///*
// * STEP 3.3 - Statistics about mapped and unmapped reads against ref genome
// */
//
//process bwa_mapped {
//    tag "${input_files[0].baseName}"
//    publishDir "${params.outdir}/bwa/mapped", mode: 'copy'
//
//    input:
//    file input_files from bam_for_mapped.collect()
//    file bai from bai_for_mapped.collect()
//
//    output:
//    file 'mapped_refgenome.txt' into bwa_mapped
//
//    script:
//    """
//    for i in $input_files
//    do
//      samtools idxstats \${i} | awk -v filename="\${i}" '{mapped+=\$3; unmapped+=\$4} END {print filename,"\t",mapped,"\t",unmapped}'
//    done > mapped_refgenome.txt
//    """
//}
//
///*
// * STEP 4 Picard
// */
///* Comment duplicated reads removal*/
//if (!params.keepduplicates){
//
//	process picard {
//		tag "$prefix"
//		publishDir "${params.outdir}/picard", mode: 'copy'
//
//		input:
//		file bam from bam_picard
//
//		output:
//		file '*.dedup.sorted.bam' into bam_dedup_spp, bam_dedup_ngsplot, bam_dedup_deepTools, bam_dedup_macs, bam_dedup_saturation, bam_dedup_epic
//		file '*.dedup.sorted.bam.bai' into bai_dedup_deepTools, bai_dedup_spp, bai_dedup_ngsplot, bai_dedup_macs, bai_dedup_saturation, bai_dedup_epic
//		file '*.dedup.sorted.bed' into bed_dedup,bed_epic_dedup
//		file '*.picardDupMetrics.txt' into picard_reports
//
//		script:
//		prefix = bam[0].toString() - ~/(\.sorted)?(\.bam)?$/
//		if( task.memory == null ){
//			log.warn "[Picard MarkDuplicates] Available memory not known - defaulting to 6GB ($prefix)"
//			avail_mem = 6000
//		} else {
//			avail_mem = task.memory.toMega()
//			if( avail_mem <= 0){
//				avail_mem = 6000
//				log.warn "[Picard MarkDuplicates] Available memory 0 - defaulting to 6GB ($prefix)"
//			} else if( avail_mem < 250){
//				avail_mem = 250
//				log.warn "[Picard MarkDuplicates] Available memory under 250MB - defaulting to 250MB ($prefix)"
//			}
//		}
//		"""
//		java -Xmx${avail_mem}m -jar \$PICARD_HOME/picard.jar MarkDuplicates \\
//			INPUT=$bam \\
//			OUTPUT=${prefix}.dedup.bam \\
//			ASSUME_SORTED=true \\
//			REMOVE_DUPLICATES=true \\
//			METRICS_FILE=${prefix}.picardDupMetrics.txt \\
//			VALIDATION_STRINGENCY=LENIENT \\
//			PROGRAM_RECORD_ID='null'
//
//		samtools sort ${prefix}.dedup.bam -o ${prefix}.dedup.sorted.bam
//		samtools index ${prefix}.dedup.sorted.bam
//		bedtools bamtobed -i ${prefix}.dedup.sorted.bam | sort -k 1,1 -k 2,2n -k 3,3n -k 6,6 > ${prefix}.dedup.sorted.bed
//		"""
//	}
//	//Change variables to dedup variables
//	bam_spp = bam_dedup_spp
//	bam_ngsplot = bam_dedup_ngsplot
//	bam_deepTools = bam_dedup_deepTools
//	bam_macs = bam_dedup_macs
//	bam_epic = bam_dedup_epic
//	bam_for_saturation = bam_dedup_saturation
//	bed_total = bed_dedup
//	bed_epic = bed_epic_dedup
//
//	bai_spp = bai_dedup_spp
//	bai_ngsplot = bai_dedup_ngsplot
//	bai_deepTools = bai_dedup_deepTools
//	bai_macs = bai_dedup_macs
//	bai_epic = bai_dedup_epic
//	bai_for_saturation = bai_dedup_saturation
//}
//
///*
// * Parse software version numbers
// */
//process get_software_versions {
//
//    output:
//    file 'software_versions_mqc.yaml' into software_versions_yaml
//
//    script:
//    """
//    echo $version > v_ngi_chipseq.txt
//    echo $workflow.nextflow.version > v_nextflow.txt
//    fastqc --version > v_fastqc.txt
//    trim_galore --version > v_trim_galore.txt
//    echo \$(bwa 2>&1) > v_bwa.txt
//    samtools --version > v_samtools.txt
//    bedtools --version > v_bedtools.txt
//    echo "version" \$(java -Xmx2g -jar \$PICARD_HOME/picard.jar MarkDuplicates --version 2>&1) >v_picard.txt
//    echo \$(plotFingerprint --version 2>&1) > v_deeptools.txt
//    echo \$(ngs.plot.r 2>&1) > v_ngsplot.txt
//    echo \$(macs2 --version 2>&1) > v_macs2.txt
//    echo \$(epic --version 2>&1) > v_epic.txt
//    multiqc --version > v_multiqc.txt
//    scrape_software_versions.py > software_versions_mqc.yaml
//    """
//}
//
//
// if (!params.keepduplicates) {  Channel.empty().set { picard_reports } }
//
///*
// * STEP 11 MultiQC
// */
//
//process multiqc {
//    tag "$prefix"
//    publishDir "${params.outdir}/MultiQC", mode: 'copy'
//
//    input:
//    file multiqc_config
//    file (fastqc:'fastqc/*') from fastqc_results.collect()
//    file ('trimgalore/*') from trimgalore_results.collect()
//    file ('samtools/*') from samtools_stats.collect()
//    file ('deeptools/*') from deepTools_multiqc.collect()
//    file ('picard/*') from picard_reports.collect()
//    file ('phantompeakqualtools/*') from spp_out_mqc.collect()
//    file ('phantompeakqualtools/*') from calculateNSCRSC_results.collect()
//    file ('software_versions/*') from software_versions_yaml.collect()
//
//    output:
//    file '*multiqc_report.html' into multiqc_report
//    file '*_data' into multiqc_data
//    file '.command.err' into multiqc_stderr
//    val prefix into multiqc_prefix
//
//    script:
//    prefix = fastqc[0].toString() - '_fastqc.html' - 'fastqc/'
//    rtitle = custom_runName ? "--title \"$custom_runName\"" : ''
//    rfilename = custom_runName ? "--filename " + custom_runName.replaceAll('\\W','_').replaceAll('_+','_') + "_multiqc_report" : ''
//
//    """
//    multiqc -f $rtitle $rfilename --config $multiqc_config . 2>&1
//    """
//
//}
//
//
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
