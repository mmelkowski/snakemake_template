module preprocessing:
    snakefile: config["modules"]["path"]
    config: config["modules"]["preprocessing"]
    prefix: "results/{sample}"

use rule * from preprocessing as module_preprocessing__*