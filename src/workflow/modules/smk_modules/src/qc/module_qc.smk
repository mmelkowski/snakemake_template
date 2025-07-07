threads_high = workflow.cores
threads_medium = max(1, int(workflow.cores / 2))
threads_low = max(1, int(workflow.cores / 4))

"""
   ___   ___ 
  / _ \ / __|
 | (_) | (__ 
  \__\_\\___|

"""

rule fastqc_pe:
    input:
        fq1="fastp/{sample}_R1.trimmed.fastq.gz",
        fq2="fastp/{sample}_R2.trimmed.fastq.gz"
    output:
        html1="qc/fastqc/{sample}_R1_fastqc.html",
        zip1="qc/fastqc/{sample}_R1_fastqc.zip",
        html2="qc/fastqc/{sample}_R2_fastqc.html",
        zip2="qc/fastqc/{sample}_R2_fastqc.zip"
        dir="qc/fastqc"
    threads: threads_low
    conda:
        "envs/fastqc.yaml"
    shell:
        """
        fastqc -t {threads} -o {output.dir} {input.fq1} {input.fq2}
        """

rule nanoplot:
    input:
        fq="{sample}.fastq.gz"
    output:
        report="qc/nanoplot/{sample}/NanoPlot-report.html"
    threads: threads_low
    conda:
        "envs/nanoplot.yaml"
    shell:
        """
        mkdir -p qc/nanoplot/{wildcards.sample}
        NanoPlot --fastq {input.fq} --outdir qc/nanoplot/{wildcards.sample} --threads {threads}
        """


def multiqc_inputs(wildcards):
    samples_sheet = config["samples_sheet"]
    platform = samples_sheet.loc[wildcards.sample, "platform"]
    inputs = []
    if platform == "hybrid":
        inputs.append(f"qc/fastqc/{wildcards.sample}_R1_fastqc.html")
        inputs.append(f"qc/fastqc/{wildcards.sample}_R2_fastqc.html")
        inputs.append(f"qc/nanoplot/{wildcards.sample}/NanoPlot-report.html")
    elif platform == "ill":
        inputs.append(f"qc/fastqc/{wildcards.sample}_R1_fastqc.html")
        inputs.append(f"qc/fastqc/{wildcards.sample}_R2_fastqc.html")
    elif platform == "ont":
        inputs.append(f"qc/nanoplot/{wildcards.sample}/NanoPlot-report.html")
    else:
        raise ValueError(f"module_qc::multiqc_inputs: platform value: {platform} for sample: {wildcards.sample} is not in: hybrid, ill or ont.")
    return inputs

rule multiqc:
    input:
        multiqc_inputs
    output:
        "qc/multiqc/multiqc_report.html"
    threads: threads_low
    conda:
        "envs/multiqc.yaml"
    shell:
        """
        mkdir -p qc/multiqc
        multiqc qc/ -o qc/multiqc
        """