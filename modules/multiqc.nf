
process MULTIQC {

    tag "WES_QC_Report"

    cpus 1

    publishDir "${params.multiqc_dir}", mode: 'copy'

    input:
    path fastqc_files
    path alignment_metrics
    path insert_size_metrics
    path markdup_metrics

    output:
    path "multiqc_report.html", emit: report
    path "multiqc_data", emit: data

    script:
    """
    set -euo pipefail

    multiqc \
        ${fastqc_files} \
        ${alignment_metrics} \
        ${insert_size_metrics} \
        ${markdup_metrics} \
        --filename multiqc_report.html \
        --outdir .
    """
}
