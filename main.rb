require './class_interaction_genes.rb' 
require './class_gene_info.rb' 
require './class_helper.rb'
require './class_input.rb'
require './class_network.rb'
require 'rest-client'
require 'json'
require 'ruby-progressbar'


# INPUT
ara_SubNetwork_GeneList = ARGV[0] # The file with the Subnetworks genes
reportTask2 = ARGV[1] # The file where the report will be written

# CORRECT NUMBER OF FILES?
Helper.number_input(ARGV)

# DOES THE FILE WITH GENES EXIST?
Helper.file_exist(ara_SubNetwork_GeneList)

# .TXT WITH THE REPORT IS AN INPUT OR NOT?
reportTask2=Helper.input_writefile(ARGV)

# puts reportTask2.class
# NEW INPUT
input_info = Input.new # the subnetwork object

# FILL input_genes
puts "Reading a file with genes..."
input_info.fill_input_genes(ara_SubNetwork_GeneList)

# NEW INTERACTION
interaction_genes = Interaction_genes.new

# FILL all_info_interactions
puts "Searching interactions..."
interaction_genes.fill_all_info_interactions(input_info)
# interaction_genes.fill_all_info_interactions_from_file # this is very useful for save time and ebi the days 8 and 9 has an error

# FILL direct_interactions
interaction_genes.fill_direct_interactions(input_info)

# NEW NETWORK OBJECT
check_network = Network.new

# FILL network object
# It can seems to a be a huge depth, but this only allows to search each gene interactions once and it's very fast because it's a hash
check_network.dfs_fillinteractions(interaction_genes, input_info)

# CHECK SOME INFO 
# puts input_info.input_genes
# puts interaction_genes.all_info_interactions
# puts interaction_genes.direct_interactions
# puts check_network.network

# FILL network_genes
puts "Searching information from Kegg and GO..."
network_genes_dict=Gene_info.fill_network_genes(check_network.network)

# CHECK SOME INFO 
# clase_kegg=network_genes_dict["At1g15820"].kegg_id
# puts network_genes_dict["At1g15820"].pathway_name.class
# puts network_genes_dict["At1g15820"].go_id.class
# puts network_genes_dict["At1g15820"].term_name

# FILL the information of each network
Network.fill_api_information(check_network, network_genes_dict)
# check_network.fill_keggid_network(network_genes_dict)
# check_network.fill_pathwayname_network(network_genes_dict)
# check_network.fill_goid_network(network_genes_dict)
# check_network.fill_termname_network(network_genes_dict)

# write the report
puts "Writing a report..."
check_network.write_report(reportTask2)
puts "Everything is done!"

####### comments ########
puts "As you can see, there are 4 networks, not a big one.\nThis doesn't mean that the report is false,\nwith BAR and EBI there are 67 genes that aren't found,\nso these genes could link the four networks."