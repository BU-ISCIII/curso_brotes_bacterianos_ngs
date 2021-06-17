FROM continuumio/miniconda3:latest
LABEL authors="Sarai Varona and Sara Monzon" \
      description="Docker image containing all software requirements for running the bacterial wgs training course exercises"

ADD environment.yml /

RUN /opt/conda/bin/conda env create -f /environment.yml && /opt/conda/bin/conda clean -a
RUN /opt/conda/bin/conda env export --name bacterial_wgs_training > bacterial_wgs_training.yml
ENV PATH /opt/conda/envs/bacterial_wgs_training/bin:$PATH
