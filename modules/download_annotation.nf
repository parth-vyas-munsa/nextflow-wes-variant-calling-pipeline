process DOWNLOAD_ANNOTATION {

    tag "GRCh38_GTF"

    publishDir "${params.ref_dir}/annotation", mode: 'copy'

    output:
    path "GRCh38.gtf", emit: gtf

    script:
    """
    set -euo pipefail

    wget -4 -c \
      https://ftp.ensembl.org/pub/release-${params.release}/gtf/homo_sapiens/Homo_sapiens.GRCh38.${params.release}.gtf.gz \
      -O GRCh38.gtf.gz

    gunzip GRCh38.gtf.gz

    mv Homo_sapiens.GRCh38.${params.release}.gtf GRCh38.gtf
    """
}
