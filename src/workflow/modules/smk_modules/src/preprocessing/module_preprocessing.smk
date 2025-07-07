rule fastp:
    input:
        R1=lambda wildcards: f"local_data/{wildcards.sample}_R1.fastq.gz",
        R2=lambda wildcards: f"local_data/{wildcards.sample}_R2.fastq.gz"
    output:
        R1="results/{sample}/fastp/{sample}_R1.trimmed.fastq.gz",
        R2="results/{sample}/fastp/{sample}_R2.trimmed.fastq.gz",
        json="results/{sample}/fastp/{sample}.fastp.json",
        html="results/{sample}/fastp/{sample}.fastp.html"
    params:
        extra=""
    threads: 4
    conda: f"{config['envs']}/fastp.yaml"
    shell:
        """
        fastp -i {input.R1} -I {input.R2} \
              -o {output.R1} -O {output.R2} \
              -j {output.json} -h {output.html} \
              {params.extra} \
              --thread {threads}
        """


rule chopper:
    input:
        lambda wildcards: f"local_data/{wildcards.sample}.fastq.gz"
    output:
        "results/{sample}/chopper/{sample}.chopped.fastq.gz"
    params:
        extra=""
    threads: 2
    conda: f"{config['envs']}/chopper.yaml"
    shell:
        """
        chopper -i {input} -o {output} {params.extra} \
                --threads {threads}
        """