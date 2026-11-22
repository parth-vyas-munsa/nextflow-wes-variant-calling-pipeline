process DOWNLOAD_VEP_CACHE {

    tag "VEP_GRCh38_CACHE"

    output:
    path "homo_sapiens", emit: vep_cache

    script:
    """
    set -euo pipefail

    mkdir -p vep_cache

    vep_install \
        -a cf \
        -s homo_sapiens \
        -y GRCh38 \
        -c vep_cache

    cp -a vep_cache/homo_sapiens .
    """
}