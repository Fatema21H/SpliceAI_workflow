#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.SpliceAI_input_csv = "SpliceAI_input.csv"
params.ref_genome = "genome.fa"
params.annotation_file = "gencode.v50.basic.annotation.txt"

process run_SpliceAI {

    tag "${gene_name}"

    publishDir "${gene_name}", mode: 'copy'

    container 'quay.io/biocontainers/spliceai'

    input:
    tuple val(gene_name),
          val(CM_type),
          path(input_vcf_file)

    path ref_genome
    path annotation_file

    output:
    path "${gene_name}_${CM_type}_SpliceAI_output.vcf"

    script:
    """
    spliceai -I ${input_vcf_file} -O ${gene_name}_${CM_type}_SpliceAI_output.vcf -R ${ref_genome} -A ${annotation_file} -D 500
    """
}

workflow {


    input_ch = Channel
        .fromPath(params.SpliceAI_input_csv)
        .splitCsv(header: true)
        .map { row ->
            tuple(
                row.gene_name,
                row.CM_type,
                file(row.input_vcf_file)
            )
        }
    ref_genome = Channel.value(file(params.ref_genome))
    annotation_file = Channel.value(file(params.annotation_file))

    run_SpliceAI(input_ch, ref_genome,annotation_file)
}
