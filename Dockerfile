
FROM mambaorg/micromamba:2.3.2

LABEL maintainer="Parth Vyas"
LABEL description="Bioinformatics tools for Nextflow WES analysis"
LABEL version="1.0"

WORKDIR /opt/wes

COPY environment.yml /tmp/environment.yml

RUN micromamba create -y \
    -n wes-tools \
    -f /tmp/environment.yml \
    && micromamba clean --all --yes

ENV PATH="/opt/conda/envs/wes-tools/bin:/opt/conda/bin:${PATH}"

WORKDIR /work
