# BNN_Deployment

If using these files and algorithms please reference "T. Murovič, A. Trost, Massively Parallel Combinational Binary Neural Networks for Edge Processing, Elektrotehniški vestnik, vol. 86, no. 1-2, pp. 47-53, 2019". 

Researchgate link: https://www.researchgate.net/publication/333563328_Massively_parallel_combinational_binary_neural_networks_for_edge_processing 

Paper link: https://ev.fe.uni-lj.si/1-2-2019/Murovic.pdf 


# Datasets
cybersecurity_dataset.unswb15.m, hep_dataset_susy.m, imaging_dataset_mnist.m and iot_dataset_uji.m are binarization scripts for datasets referenced in the mentioned paper. The algorithms transform multi-modal notation of datasets to purely binary features and labels. 

Datasets are also available in this repository --> "dataset.zip".

Transformed datasets serve as inputs to binary neural networks training software by "M. Courbariaux, “Binary net.”
https://github.com/MatthieuCourbariaux/BinaryNet, 2016". This software trains and produces network parameters for the desired dataset. As this parameters are still in the form of [-1 / 1] for weights or signed integer for biases the procedure from "Y. Umuroglu, N. J. Fraser, G. Gambardella, M. Blott, P. H. W.
Leong, M. Jahre, and K. A. Vissers, “Finn: A framework for fast,
scalable binarized neural network inference,” in FPGA, 2017" is used to transform this values to binary 0 and 1 and unsigned integers. 

# Parameters and Verilog Files
Subfolders include dump.txt files which are the already transformed weights and thresholds/biases for each layer of each dataset. In addition model.txt files are Verilog files of combinational circuits for each layer of a network. These can be directly copied into your Vivado or Quartus synthesis project.
