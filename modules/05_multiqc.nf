
process MULTIQC {

    tag "MultiQC"

    publishDir "${params.multiqc_dir}", mode: 'copy'

    input:
    path reports

    output:
    path "multiqc_report.html", emit: report
    path "multiqc_data", emit: data

    script:
    """
    multiqc ${reports} \
        --outdir . \
        --filename multiqc_report.html \
        --force
    """
}
