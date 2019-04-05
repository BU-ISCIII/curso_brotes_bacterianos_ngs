FROM buisciii/centos7_base_image:latest

COPY ./scif_app_recipes/* /opt/

RUN echo "Install basic development tools" && \
    yum -y groupinstall "Development Tools" && \
    yum -y update && yum -y install wget curl && \
    echo "Install python2.7 setuptools and pip" && \
    yum -y install python-setuptools && \
    easy_install pip && \
    echo "Installing SCI-F" && \
    pip install scif ipython

RUN echo "Installing FastQC app" && \
    scif install /opt/fastqc_v0.11.7_centos7.scif && \
    echo "Installing trimmomatic app" && \
    scif install /opt/trimmomatic_v0.38_centos7.scif && \
    echo "Installing samtools app" && \
    scif install /opt/samtools_v1.2_centos7.scif && \
    echo "Installing htslib app" && \
    scif install /opt/htslib_v1.9_centos7.scif && \
    echo "Installing picard app" && \
    scif install /opt/picard_v1.140_centos7.scif && \
    echo "Installing spades app" && \
    scif install /opt/spades_v3.8.0_centos7.scif && \
    echo "Installing prokka app" && \
    scif install /opt/prokka_v1.13_centos7.scif && \
    echo "Installing quast app" && \
    scif install /opt/quast_v5.0.0_centos7.scif && \
    echo "Installing multiqc app" && \
    scif install /opt/multiqc_v1.4_centos7.scif && \
    echo "Installing bwa app" && \
    scif install /opt/bwa_v0.7.17_centos7.scif && \
    echo "Installing chewbbaca app" && \
    scif install /opt/chewbbaca_v2.0.5_centos7.scif && \
    echo "Installing outbreaker app" && \
    scif install /opt/outbreaker_v1.1_centos7.scif && \
    echo "Installing get_homologues app" && \
    scif install /opt/gethomologues_v3.1.4_centos7.scif && \
    echo "Installing Unicycler app" && \
    scif install /opt/unicycler_v0.4.7_centos7.scif && \
    echo "Installing Taranis app" && \
    scif install /opt/taranis_v0.3.3_centos7.scif && \
    echo "Installing Download bigsdb api app" && \
    scif install /opt/bigsdbdownload_v0.1_centos7.scif && \
    echo "Installing plasmidID app" && \
    scif install /opt/plasmidid_v1.4.2_centos7.scif

    ## R packages

    # Install core R dependencies
    RUN echo "r <- getOption('repos'); r['CRAN'] <- 'https://ftp.acc.umu.se/mirror/CRAN/'; options(repos = r);" > ~/.Rprofile && \
    Rscript -e "install.packages('ggplot2',dependencies=TRUE,lib='/usr/local/lib64/R/library')" && \
    Rscript -e "install.packages('ape',dependencies=TRUE,lib='/usr/local/lib64/R/library')" && \
    Rscript -e "source('https://bioconductor.org/biocLite.R');biocLite('ggtree',dependencies=TRUE,lib='/usr/local/lib64/R/library')" && \
    Rscript -e "install.packages('tidyr',dependencies=TRUE,lib='/usr/local/lib64/R/library')" && \
    Rscript -e "install.packages('plyr',dependencies=TRUE,lib='/usr/local/lib64/R/library')"

# Include ENV variables
ENV LC_ALL=en_US.UTF-8
ENV PATH=$PATH:/scif/apps/aragorn
ENV PATH=$PATH:/scif/apps/bamutil
ENV PATH=$PATH:/scif/apps/barrnap
ENV PATH=$PATH:/scif/apps/bcftools
ENV PATH=$PATH:/scif/apps/bedtools
ENV PATH=$PATH:/scif/apps/bigsdbdownload
ENV PATH=$PATH:/scif/apps/bowtie2
ENV PATH=$PATH:/scif/apps/bwa
ENV PATH=$PATH:/scif/apps/cdhit
ENV PATH=$PATH:/scif/apps/chewbbaca
ENV PATH=$PATH:/scif/apps/circos
ENV PATH=$PATH:/scif/apps/fastqc
ENV PATH=$PATH:/scif/apps/gatk
ENV PATH=$PATH:/scif/apps/gcc
ENV PATH=$PATH:/scif/apps/get_homologues
ENV PATH=$PATH:/scif/apps/hmmer3
ENV PATH=$PATH:/scif/apps/htslib
ENV PATH=$PATH:/scif/apps/minced
ENV PATH=$PATH:/scif/apps/multiqc
ENV PATH=$PATH:/scif/apps/ncbiblast
ENV PATH=$PATH:/scif/apps/openmpi
ENV PATH=$PATH:/scif/apps/picard
ENV PATH=$PATH:/scif/apps/pilon
ENV PATH=$PATH:/scif/apps/plasmidid
ENV PATH=$PATH:/scif/apps/prodigal
ENV PATH=$PATH:/scif/apps/prokka
ENV PATH=$PATH:/scif/apps/python3
ENV PATH=$PATH:/scif/apps/quast
ENV PATH=$PATH:/scif/apps/R
ENV PATH=$PATH:/scif/apps/raxml
ENV PATH=$PATH:/scif/apps/samtools
ENV PATH=$PATH:/scif/apps/snppipeline
ENV PATH=$PATH:/scif/apps/spades
ENV PATH=$PATH:/scif/apps/sratoolkit
ENV PATH=$PATH:/scif/apps/srst2
ENV PATH=$PATH:/scif/apps/taranis
ENV PATH=$PATH:/scif/apps/tbl2asn
ENV PATH=$PATH:/scif/apps/trimmomatic
ENV PATH=$PATH:/scif/apps/unicycler
ENV PATH=$PATH:/scif/apps/varscan
ENV PATH=$PATH:/scif/apps/vcftools
ENV PATH=$PATH:/scif/apps/wgsoutbreaker
ENV LD_LIBRARY_PATH=/usr/local/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/aragorn/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/bamutil/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/barrnap/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/bcftools/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/bedtools/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/bigsdbdownload/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/bowtie2/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/bwa/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/cdhit/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/chewbbaca/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/circos/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/fastqc/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/gatk/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/gcc/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/get_homologues/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/hmmer3/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/htslib/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/minced/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/multiqc/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/ncbiblast/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/openmpi/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/picard/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/pilon/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/plasmidid/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/prodigal/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/prokka/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/python3/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/quast/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/raxml/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/R/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/samtools/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/snppipeline/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/spades/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/sratoolkit/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/srst2/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/taranis/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/tbl2asn/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/trimmomatic/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/unicycler/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/varscan/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/vcftools/lib/lib
ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/scif/apps/wgsoutbreaker/lib/lib

#ENTRYPOINT ["/opt/docker-entrypoint.sh"]
#CMD ["scif"]

RUN find /scif/apps -maxdepth 2 -name "bin" | while read in; do echo "export PATH=\$PATH:$in" >> /etc/bashrc;done 
RUN if [ -z "${LD_LIBRARY_PATH-}" ]; then echo "export LD_LIBRARY_PATH=/usr/local/lib" >> /etc/bashrc;fi
RUN find /scif/apps -maxdepth 2 -name "lib" | while read in; do echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$in" >> /etc/bashrc;done
