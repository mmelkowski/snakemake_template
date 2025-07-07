threads_high = workflow.cores
threads_medium = max(1, int(workflow.cores / 2))
threads_low = max(1, int(workflow.cores / 4))


"""
  __  __                _             _            _    
 |  \/  |__ _ _ __ _ __(_)_ _  __ _  | |_ ___  ___| |___
 | |\/| / _` | '_ \ '_ \ | ' \/ _` | |  _/ _ \/ _ \ (_-<
 |_|  |_\__,_| .__/ .__/_|_||_\__, |  \__\___/\___/_/__/
             |_|  |_|         |___/                     
"""

# ILL mapping
rule bwamem2:
    input:
        ref="reference/reference.fasta",
        reads1="fastp/{sample}_R1.trimmed.fastq.gz",
        reads2="fastp/{sample}_R2.trimmed.fastq.gz"
    output:
        bam="bwa_mem2/{sample}.bam"
    threads: threads_high
    conda: f"{config['envs']}/bwa_mem2.yaml"
    shell:
        """
        bwa-mem2 mem -t {threads} {input.ref} {input.reads1} {input.reads2} | \
        samtools view -bS - > {output.bam}
        """


rule bowtie2:
    input:
        ref="reference/reference.fasta",
        reads1="fastp/{sample}_R1.trimmed.fastq.gz",
        reads2="fastp/{sample}_R2.trimmed.fastq.gz"
    output:
        bam="bowtie2/{sample}.bam"
    threads: threads_high
    conda: f"{config['envs']}/bowtie2.yaml"
    shell:
        """
        bowtie2 -x {input.ref} -1 {input.reads1} -2 {input.reads2} -p {threads} | \
        samtools view -bS - > {output.bam}
        """

# ONT mapping
rule minimap2:
    input:
        ref="reference/reference.fasta",
        reads1="data/{sample}_R1.fastq.gz",
        reads2="data/{sample}_R2.fastq.gz"
    output:
        bam="minimap2/{sample}.bam"
    threads: threads_high
    conda: f"{config['envs']}/minimap2.yaml"
    shell:
        """
        minimap2 -ax sr -t {threads} {input.ref} {input.reads1} {input.reads2} | \
        samtools view -bS - > {output.bam}
        """


"""
  ___                         ___   _   __  __ 
 | _ \_ _ ___  __ ___ ______ | _ ) /_\ |  \/  |
 |  _/ '_/ _ \/ _/ -_|_-<_-< | _ \/ _ \| |\/| |
 |_| |_| \___/\__\___/__/__/ |___/_/ \_\_|  |_|

"""


rule sort_bam:
    input:
        bam="{mapper}/{sample}.bam"
    output:
        sorted_bam="{mapper}/{sample}.sorted.bam"
    threads: threads_medium
    conda: f"{config['envs']}/samtools.yaml"
    shell:
        """
        samtools sort -@ {threads} -o {output.sorted_bam} {input.bam}
        """


rule index_bam:
    input:
        bam="{mapper}/{sample}.bam"
    output:
        bai="{mapper}/{sample}.bam.bai"
    threads: threads_low
    conda: f"{config['envs']}/samtools.yaml"
    shell:
        """
        samtools index {input.bam} {output.bai}
        """
