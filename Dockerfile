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
ENV PATH=$PATH:/scif/apps/aragorn/bin
ENV PATH=$PATH:/scif/apps/bamutil/bin
ENV PATH=$PATH:/scif/apps/barrnap/bin
ENV PATH=$PATH:/scif/apps/bcftools/bin
ENV PATH=$PATH:/scif/apps/bedtools/bin
ENV PATH=$PATH:/scif/apps/bigsdbdownload/bin
ENV PATH=$PATH:/scif/apps/bowtie2/bin
ENV PATH=$PATH:/scif/apps/bwa/bin
ENV PATH=$PATH:/scif/apps/cdhit/bin
ENV PATH=$PATH:/scif/apps/chewbbaca/bin
ENV PATH=$PATH:/scif/apps/circos/bin
ENV PATH=$PATH:/scif/apps/fastqc/bin
ENV PATH=$PATH:/scif/apps/gatk/bin
ENV PATH=$PATH:/scif/apps/gcc/bin
ENV PATH=$PATH:/scif/apps/get_homologues/bin
ENV PATH=$PATH:/scif/apps/hmmer3/bin
ENV PATH=$PATH:/scif/apps/htslib/bin
ENV PATH=$PATH:/scif/apps/minced/bin
ENV PATH=$PATH:/scif/apps/multiqc/bin
ENV PATH=$PATH:/scif/apps/ncbiblast/bin
ENV PATH=$PATH:/scif/apps/openmpi/bin
ENV PATH=$PATH:/scif/apps/picard/bin
ENV PATH=$PATH:/scif/apps/pilon/bin
ENV PATH=$PATH:/scif/apps/plasmidid/bin
ENV PATH=$PATH:/scif/apps/prodigal/bin
ENV PATH=$PATH:/scif/apps/prokka/bin
ENV PATH=$PATH:/scif/apps/python3/bin
ENV PATH=$PATH:/scif/apps/quast/bin
ENV PATH=$PATH:/scif/apps/R/bin
ENV PATH=$PATH:/scif/apps/raxml/bin
ENV PATH=$PATH:/scif/apps/samtools/bin
ENV PATH=$PATH:/scif/apps/snppipeline/bin
ENV PATH=$PATH:/scif/apps/spades/bin
ENV PATH=$PATH:/scif/apps/sratoolkit/bin
ENV PATH=$PATH:/scif/apps/srst2/bin
ENV PATH=$PATH:/scif/apps/taranis/bin
ENV PATH=$PATH:/scif/apps/tbl2asn/bin
ENV PATH=$PATH:/scif/apps/trimmomatic/bin
ENV PATH=$PATH:/scif/apps/unicycler/bin
ENV PATH=$PATH:/scif/apps/varscan/bin
ENV PATH=$PATH:/scif/apps/vcftools/bin
ENV PATH=$PATH:/scif/apps/wgsoutbreaker/bin
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
RUN echo "export LC_ALL=en_US.UTF-8" >> /etc/bashrc
RUN find /scif/apps -maxdepth 2 -name "bin" | while read in; do echo "export PATH=\$PATH:$in" >> /etc/bashrc;done 
RUN if [ -z "${LD_LIBRARY_PATH-}" ]; then echo "export LD_LIBRARY_PATH=/usr/local/lib" >> /etc/bashrc;fi
RUN find /scif/apps -maxdepth 2 -name "lib" | while read in; do echo "export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:$in" >> /etc/bashrc;done
