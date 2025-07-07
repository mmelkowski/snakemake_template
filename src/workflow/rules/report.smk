rule generate_report:
    input:
        freebayes="results/{sample}/variant_calling/freebayes/{sample}_variants.vcf",
        lofreq="results/{sample}/variant_calling/lofreq/{sample}_variants.vcf"
    output:
        report="results/report/variant_summary.yaml"
    shell:
        """
        python scripts/generate_report.py \
            --freebayes {input.freebayes} \
            --lofreq {input.lofreq} \
            --output {output.report}
        """