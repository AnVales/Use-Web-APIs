require './class_helper.rb'
require './class_gene_info.rb'
require 'json'
require 'rest-client'

class Network

    ########## CLASS ##########
    # this class has one object which must be a subnetwork of Arabidopsis if the hypothesis is right

    ########## ATTRIBUTE ##########
    # network: a hash with the direct and indirect interactions of the input genes ONLY,
    #   the key is a gene and the value the genes with direct and indirect interaction with this gene
    # keggid_network: a hash with the Kegg id of the interactions (atribute network),
    #   the key is the same as in network and the value all the kegg ids
    # pathwayname_network: a hash with the pathway names in Kegg of the interactions (atribute network),
    #   the key is the same as in network and the value all the pathways name in Kegg
    # goid_network: a hash with the GO id of the interactions (atribute network),
    #   the key is the same as in network and the value all the GO ids
    # termname_network: a hash with the term name in GO of the interactions (atribute network),
    #   the key is the same as in network and the value all the term names in GO

    ########## METHODS ##########
    # rec_fillinteractions: recursive function that searches the interactions between the genes
    # dfs_fillinteractions: searches the interactions between genes calling the rec_fillinteractions functions, 
    # fill_keggid_network: fill keggid_network attribute 
    # fill_pathwayname_network: fill pathwayname_network attribute
    # fill_goid_network: fill goid_network attribute
    # fill_termname_network: fill termname_network attribute
    # self.fill_api_information: fill all the information obtained with API: keggid_network, pathwayname_network, goid_network, termname_network

    ########## ATTRIBUTE ##########
    attr_accessor :network
    attr_accessor :keggid_network
    attr_accessor :pathwayname_network
    attr_accessor :goid_network
    attr_accessor :termname_network

    ########## METHODS ##########

    # initialize 
    def initialize (params = {}) 
        @network = params.fetch(:network, nil)
        @keggid_network = params.fetch(:keggid_network, nil)
        @pathwayname_network = params.fetch(:pathwayname_network, nil)
        @goid_network = params.fetch(:goid_network, nil)
        @termname_network = params.fetch(:termname_network, nil)
    end

    # rec_fillinteractions
    def rec_fillinteractions(interaction_genes, input_info, gene, visited, genes_list, counter, depth_level)
        # this methods needs: gene for search interaction(gene), a list with the visited genes(visited), the list where genes are stored(genes_list),
        #   a counter of the times that this method is executed(counter), and a variable that indicates the maximum number of times that this is executed(depth_level)
            visited[gene] = true
            counter = counter + 1
            interaction_genes.direct_interactions[gene].each do |gen_value|
                if not visited[gen_value] and counter < depth_level # only if this gene isn't visited before
                    if not input_info.input_genes[gen_value].nil?
                        genes_list << gen_value
                    end
                    rec_fillinteractions(interaction_genes, input_info, gen_value, visited,genes_list, counter, depth_level) # call rec_fillinteractions inside rec_fillinteractions
                end
            end
        end


    # dfs_fillinteractions
    def dfs_fillinteractions(interaction_genes,input_info, depth_level=interaction_genes.direct_interactions.keys.length) #by default,but depth_level but it can be changed when it's executed
        # It can seems to a be a huge depth, but this only allows to search each gene interactions once and it's very fast because it's a hash
        @network = {}
        visited = {}
        interaction_genes.direct_interactions.each do |key, value|
            if not input_info.input_genes[key].nil?
                visited[key] = false
                genes_list = []
                rec_fillinteractions(interaction_genes,input_info, key, visited, genes_list, 0, depth_level) # calls rec_fillinteractions for each gene (key) with interactions (value)
                @network[key] = genes_list
            end
        end
    end


    # fill_keggid_network
    def fill_keggid_network(network_genes_dict)
        # this needs the hash with the objects of class gene_info
        @keggid_network={}
        @network.each do |gen_a,gen_array|
            # a list that will save kegg_id information 
            info_save=[]
            if not network_genes_dict[gen_a].nil?
                # seach kegg_id information of each gene
                array_info = network_genes_dict[gen_a].kegg_id 
                array_info.each do |each_info|
                    if not each_info=='unknown'
                    info_save<<each_info
                    end
                end
                gen_array.each do |gen_b|
                    if not network_genes_dict[gen_b].nil?
                        array_keggs = network_genes_dict[gen_b].kegg_id
                            array_keggs.each do |kegg| 
                                
                                if not kegg=='unknown'
                                    info_save<<kegg
                                end

                            end
                        end
                    end
                end
            # if we don't have any kegg_id of this genes, set this as unknown
            # if we have information, the array will be a set to delate the kegg_id that are more than one time
            # when repeated kegg_id information is delete, set this to array again and save it in the hash
            if not info_save.empty?
                info_save_set=info_save.to_set
                info_save_set=info_save_set.to_a
                @keggid_network[gen_a]=info_save_set
            else
                @keggid_network[gen_a]=['unknown']
            end
        end
    end


    # fill_pathwayname_network
    def fill_pathwayname_network(network_genes_dict)
        # this needs the hash with the objects of class gene_info
        @pathwayname_network={}
        @network.each do |gen_a,gen_array|
            # a list that will save pathway_name information
            info_save=[]
            if not network_genes_dict[gen_a].nil?
                # seach pathway_name information of each gene
                array_info = network_genes_dict[gen_a].pathway_name 
                array_info.each do |each_info|
                    if not each_info=='unknown'
                    info_save<<each_info
                    end
                end
                gen_array.each do |gen_b|
                    if not network_genes_dict[gen_b].nil?
                        array_pathwayname = network_genes_dict[gen_b].pathway_name
                            array_pathwayname.each do |pathwayname| 

                                if not pathwayname=='unknown'
                                    info_save<<pathwayname
                                end

                            end
                        end
                    end
                end
            # if we don't have any pathway_name of this genes, set this as unknown
            # if we have information, the array will be a set to delate the pathway_name that are more than one time
            # when repeated pathway_name information is delete, set this to array again and save it in the hash                
            if not info_save.empty?
                info_save_set=info_save.to_set
                info_save_set=info_save_set.to_a
                @pathwayname_network[gen_a]=info_save_set
            else
                @pathwayname_network[gen_a]=['unknown']
            end
        end
    end


    # fill_goid_network
    def fill_goid_network(network_genes_dict)
        # this needs the hash with the objects of class gene_info
        @goid_network={}
        @network.each do |gen_a,gen_array|
            # a list that will save go_id information
            info_save=[]
            if not network_genes_dict[gen_a].nil?
                # seach go_id information of each gene
                array_info = network_genes_dict[gen_a].go_id
                array_info.each do |each_info|
                    if not each_info=='unknown'
                    info_save<<each_info
                    end
                end
                gen_array.each do |gen_b|
                    if not network_genes_dict[gen_b].nil?
                        array_goid = network_genes_dict[gen_b].go_id
                            array_goid.each do |goid|

                                if not goid=='unknown'
                                    info_save<<goid
                                end

                            end
                        end
                    end
                end
            # if we don't have any go_id of this genes, set this as unknown
            # if we have information, the array will be a set to delate the go_id that are more than one time
            # when repeated go_id information is delete, set this to array again and save it in the hash                
            if not info_save.empty?
                info_save_set=info_save.to_set
                info_save_set=info_save_set.to_a
                @goid_network[gen_a]=info_save_set
            else
                @goid_network[gen_a]=['unknown']
            end
        end
    end


    # fill_termname_network
    def fill_termname_network(network_genes_dict)
        # this needs the hash with the objects of class gene_info
        @termname_network={}
        @network.each do |gen_a,gen_array| 
            # a list that will save term_name information
            info_save=[]
            if not network_genes_dict[gen_a].nil?
                # seach term_name information of each gene
                array_info = network_genes_dict[gen_a].term_name
                array_info.each do |each_info|
                    if not each_info=='unknown'
                    info_save<<each_info
                    end
                end
                gen_array.each do |gen_b|
                    if not network_genes_dict[gen_b].nil?
                        array_termname = network_genes_dict[gen_b].term_name
                            array_termname.each do |termname|

                                if not termname=='unknown'
                                    info_save<<termname
                                end

                            end
                        end
                    end
                end
            # if we don't have any term_name of this genes, set this as unknown
            # if we have information, the array will be a set to delate the term_name that are more than one time
            # when repeated term_name information is delete, set this to array again and save it in the hash                
            if not info_save.empty?
                info_save_set=info_save.to_set
                info_save_set=info_save_set.to_a
                @termname_network[gen_a]=info_save_set
            else
                @termname_network[gen_a]=['unknown']
            end
        end
    end


    # fill_api_information
    def self.fill_api_information(network, genes_dict)
        # this makes four methods at the same time, network is the object and genes_dict is a dict with objects with the API information
        network.fill_keggid_network(genes_dict)
        network.fill_pathwayname_network(genes_dict)
        network.fill_goid_network(genes_dict)
        network.fill_termname_network(genes_dict)
    end


    # write_report
    def write_report(newfile)
        File.open(newfile, "w") do |f|
            i=0
            # open the file and write the report with f.puts " "
            f.puts "Welcome to the report of the task 2: Intensive integration using Web APIs"
            @network.each do |gene_a,gene_array|

                # use Helper.make_sentence to make sentences with the arrays with the information
                genes_net=Helper.make_sentence(gene_array)
                keggid_net=Helper.make_sentence(keggid_network[gene_a])
                pathwayname_net=Helper.make_sentence(pathwayname_network[gene_a])
                goid_net=Helper.make_sentence(goid_network[gene_a])
                termname_net=Helper.make_sentence(termname_network[gene_a])
                
                # filter: only puts the interactions between two or more genes
                if gene_array.length>=1
                    f.puts
                    i=i+1
                    f.puts "Network #{i}"
                    f.puts "Number of genes: #{1+gene_array.length.to_i}"
                    if gene_array.length.to_i==1
                        f.puts "The genes that interact are #{gene_a} and #{genes_net}."
                    elsif gene_array.length.to_i>=2
                        f.puts "The genes that interact are #{gene_a}, #{genes_net}."
                    end

                    # write the report in singular if .length==1, in plural if .length>=2
                    if keggid_network[gene_a].length==1
                        f.puts "The genes of this network are involved in a pathway, the kegg id is #{keggid_net}."
                        f.puts "The name in kegg is #{pathwayname_net}."
                    elsif keggid_network[gene_a].length>1
                        f.puts "The genes of this network are involved in some pathways, kegg id are #{keggid_net}."
                        f.puts  "The names in kegg are #{pathwayname_net}."
                    end

                    if goid_network[gene_a].length==1
                        f.puts "The OG id is #{goid_net}."
                        f.puts "The name in OG is #{termname_net}."
                    elsif goid_network[gene_a].length>1
                        f.puts "The OG ids are #{goid_net}."
                        f.puts "The names in OG are #{termname_net}."
                    end
                    f.puts 
                end

            end
            puts "There are #{i} networks"
        end
    end



end


