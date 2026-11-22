nextflow.enable.dsl = 2
// they are the parameters require for dir set

params.id = "acc_id.txt"
params.outdir = "sra"
params.fastq_dir = "fastq"
params.qc_dir = "qc"
params.trimmed_dir = "fastp"
params.multiqc_dir = "multiqc"
params.release = 116
params.ref_dir = "ref"
params.ref_index_dir = "ref_index"
params.alignment_dir = "alignment"
params.bam_dir = "bam"
params.markdup_dir = "mark_duplicates"
params.known_sites_dir = "known_sites"
params.bqsr_dir = "bqsr"
params.metrics_dir = "metrics"
params.vcf_dir = "vcf_dir"
params.variant_dir = "variants"
params.variants_filter_dir = "var_filter"
params.variants_pass_dir = "pass_var"
params.variants_annotation_dir = "annotate_var"
params.merge_ann_var_dir = "${projectDir}/annotation/MERGED"
params.vep_table_dir = "${projectDir}/annotation/VEP_TABLE"





// INCLUDE MODULES NEXTFLOW SCRIPT IN ORDER



include { PREFETCH } from './modules/01_prefetch'
include { SPLIT } from './modules/02_split'
include { QUALITY } from './modules/03_fastqc'
include { FASTP } from './modules/04_fastp'
include { MULTIQC } from './modules/05_multiqc'
include { BWA_INDEX } from './modules/06_bwa_index'
include { ALIGNMENT } from './modules/07_sam_making'
include { BAM_PROCESSING } from './modules/08_bam_processing'
include { MARK_DUPLICATES } from './modules/09_bam_markduplicates'
include { DOWNLOAD_REFERENCE } from './modules/download_reference'
include { DOWNLOAD_ANNOTATION } from './modules/download_annotation'
include { DOWNLOAD_KNOWN_SITES } from './modules/download_known_sites'
include { BQSR  } from './modules/10_bqsr'
include{COLLECT_METRICS} from './modules/11_insert_size_matrix'
include{HAPLOTYPE_CALLER} from './modules/12_Haplotypecaller'
include { EXTRACT_SNP; EXTRACT_INDEL } from './modules/13_select_variants'
include { FILTER_SNP; FILTER_INDEL } from './modules/14_filter_variants'
include { PASS_SNP; PASS_INDEL } from './modules/15_pass_variants'
include { VEP_SNP; VEP_INDEL } from './modules/16_variants_annotation'
include {MERGE_VEP} from './modules/17_merge_variants'
include {EXTRACT_VEP_ANNOTATION} from './modules/18_vep_table'

























// WORKFLOW CHANNELS


workflow {
ch_id = Channel
        .fromPath(params.id)
        .splitText()
        .map { it.trim() }
        .filter { it }

PREFETCH(ch_id)
SPLIT(PREFETCH.out.sra)
QUALITY(SPLIT.out)
FASTP(SPLIT.out)
ch_multiqc = QUALITY.out.zip
    .mix(FASTP.out)
    .collect()

MULTIQC(ch_multiqc)
DOWNLOAD_REFERENCE()
ref_fasta = DOWNLOAD_REFERENCE.out.fasta
ref_fai   = DOWNLOAD_REFERENCE.out.fai
ref_dict  = DOWNLOAD_REFERENCE.out.dict
index_ch = BWA_INDEX(ref_fasta)
DOWNLOAD_ANNOTATION()
ALIGNMENT(
        FASTP.out.trimmed,
        index_ch.bwa_index
    )
BAM_PROCESSING(ALIGNMENT.out.sam)
MARK_DUPLICATES(BAM_PROCESSING.out.bam)
known_sites_ch = DOWNLOAD_KNOWN_SITES()
BQSR(
    MARK_DUPLICATES.out.marked_bam,
    ref_fasta,
    known_sites_ch.known_sites
)
COLLECT_METRICS(
    BQSR.out.recalibrated,
    ref_fasta
)

 HAPLOTYPE_CALLER(
    BQSR.out.recalibrated.map { id, bam, bai, table ->
        tuple(id, bam, bai)
    },
    ref_fasta,
    ref_fai,
    ref_dict
)

EXTRACT_SNP(
    HAPLOTYPE_CALLER.out.gvcf,
    ref_fasta
)

EXTRACT_INDEL(
    HAPLOTYPE_CALLER.out.gvcf,
    ref_fasta
)

FILTER_SNP(
    EXTRACT_SNP.out.snps,
    ref_fasta
)

FILTER_INDEL(
    EXTRACT_INDEL.out.indels,
    ref_fasta
)

PASS_SNP(FILTER_SNP.out.snps_filtered)

PASS_INDEL(FILTER_INDEL.out.indel_filtered)







VEP_SNP(PASS_SNP.out.snps_pass)

VEP_INDEL(PASS_INDEL.out.indel_pass)

merged_input = VEP_SNP.out.snps_annotated
    .join(VEP_INDEL.out.indel_annotated)
    .map { id, snp_vcf, indel_vcf ->
        tuple(id, snp_vcf, indel_vcf)
    }

MERGE_VEP(merged_input)
EXTRACT_VEP_ANNOTATION(MERGE_VEP.out.merge_annotated)





}