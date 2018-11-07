FROM centos:latest

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

ENTRYPOINT ["/opt/docker-entrypoint.sh"]
CMD ["scif"]
