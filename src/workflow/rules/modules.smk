"""
  __  __         _      _                       _   
 |  \/  |___  __| |_  _| |___ ___      ____ __ | |__
 | |\/| / _ \/ _` | || | / -_|_-<  _  (_-< '  \| / /
 |_|  |_\___/\__,_|\_,_|_\___/__/ (_) /__/_|_|_|_\_\
                                        
"""


config["modules"]["preprocessing"]["samples_sheet"] = samples_sheet
module preprocessing:
    snakefile: config["modules"]["path"]
    config: config["modules"]["preprocessing"]

use rule * from preprocessing as module_preprocessing__*


module qc:
    snakefile: config["modules"]["path"]
    config: config["modules"]["qc"]
    prefix: "results/{sample}"

use rule * from qc as module_qc__*


module mapping:
    snakefile: config["modules"]["path"]
    config: config["modules"]["mapping"]
    prefix: "results/{sample}"

use rule * from mapping as module_mapping__*


module variant_calling:
    snakefile: config["modules"]["path"]
    config: config["modules"]["variant_calling"]
    prefix: "results/{sample}"

use rule * from variant_calling as module_variant_calling__*