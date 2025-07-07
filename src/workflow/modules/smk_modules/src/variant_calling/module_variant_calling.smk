threads_high = workflow.cores
threads_medium = max(1, int(workflow.cores / 2))
threads_low = max(1, int(workflow.cores / 4))


"""
 __   __        _          _      ___      _ _ _           
 \ \ / /_ _ _ _(_)__ _ _ _| |_   / __|__ _| | (_)_ _  __ _ 
  \ V / _` | '_| / _` | ' \  _| | (__/ _` | | | | ' \/ _` |
   \_/\__,_|_| |_\__,_|_||_\__|  \___\__,_|_|_|_|_||_\__, |
                                                     |___/ 
"""


rule freebayes:
    input:
        bam="mapping/{sample}.bam",
        ref="reference/reference.fasta"
    output:
        vcf="variant_calling/freebayes/{sample}.vcf"
    params:
        extra=""
    threads: threads_medium
    conda: f"{config['envs']}/freebayes.yaml"
    shell:
        """
        freebayes -f {input.ref} {input.bam} {params.extra} > {output.vcf}
        """

rule lofreq:
    input:
        bam="input/{sample}.bam",
        ref="reference/reference.fasta"
    output:
        vcf="variant_calling/lofreq/{sample}.vcf"
    params:
        extra=""
    threads: threads_medium
    conda: f"{config['envs']}/lofreq.yaml"
    shell:
        """
        lofreq call -f {input.ref} -o {output.vcf} {params.extra} {input.bam}
        """

rule medaka:
    input:
        bam="minimap2/{sample}.bam",
        ref="reference/reference.fasta"
    output:
        vcf="variant_calling/medaka/{sample}.vcf",
        dir = directory("variant_calling/medaka/{sample}")
    params:
        model="r941_min_high_g360",  # adjust model as needed
        extra=""
    threads: threads_medium
    conda: f"{config['envs']}/medaka.yaml"
    shell:
        """
        medaka_variant -i {input.bam} -f {input.ref} -o {output.dir} -m {params.model} {params.extra}
        cp {output.dir}/variants.vcf {output.vcf}
        """


"""
  ___                        __   _____ ___ 
 | _ \_ _ ___  __ ___ ______ \ \ / / __| __|
 |  _/ '_/ _ \/ _/ -_|_-<_-<  \ V / (__| _| 
 |_| |_| \___/\__\___/__/__/   \_/ \___|_|  
                                            
"""


rule merge_vcf:
    input:
        vcfs=expand("normalized/{caller}/{sample}.vcf",
                    caller=["freebayes", "lofreq", "medaka"], 
                    sample=lambda wildcards: config["samples"])
    output:
        vcf="variant_calling/merged/{sample}.vcf"
    threads: threads_low
    conda: f"{config['envs']}/bcftools.yaml"
    shell:
        """
        bcftools merge -Oz -o {output.vcf} {input.vcfs}
        bcftools index {output.vcf}
        """


rule sort_vcf:
    input:
        vcf="variant_calling/merged/{sample}.vcf"
    output:
        vcf="variant_calling/merged/sorted/{sample}.vcf"
    threads: threads_low
    conda: f"{config['envs']}/bcftools.yaml"
    shell:
        """
        bcftools sort {input.vcf} -Oz -o {output.vcf}
        bcftools index {output.vcf}
        """


rule filter_vcf:
    input:
        vcf="variant_calling/merged/sorted/{sample}.vcf"
    output:
        vcf="variant_calling/merged/filtered/{sample}.vcf"
    params:
        filter_expr="QUAL>20"  # adjust as needed
    threads: threads_low
    conda: f"{config['envs']}/bcftools.yaml"
    shell:
        """
        bcftools view -i '{params.filter_expr}' {input.vcf} -Oz -o {output.vcf}
        bcftools index {output.vcf}
        """


rule decompose_vcf:
    input:
        vcf="variant_calling/merged/filtered/{sample}.vcf"
    output:
        vcf="variant_calling/merged/decomposed/{sample}.vcf"
    threads: threads_low
    conda: f"{config['envs']}/vt.yaml"
    shell:
        """
        vt decompose -s {input.vcf} | vt normalize -r reference/reference.fasta - > {output.vcf}
        """


rule normalize_vcf:
    input:
        vcf="variant_calling/merged/decomposed/{sample}.vcf"
    output:
        vcf="variant_calling/merged/normalized/{sample}.vcf"
    threads: threads_low
    conda: f"{config['envs']}/vt.yaml"
    shell:
        """
        vt normalize -r reference/reference.fasta {input.vcf} > {output.vcf}
        """


# place the results at the root
rule copy_normalized_vcf:
    input:
        vcf="variant_calling/merged/normalized/{sample}.vcf"
    output:
        vcf="variant_calling/{sample}.vcf"
    threads: 1
    shell:
        """
        cp {input.vcf} {output.vcf}
        """
