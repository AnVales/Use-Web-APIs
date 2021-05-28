require 'rest-client'
require 'json'
require './class_helper.rb'
require 'ruby-progressbar'


class Gene_info

    ########## CLASS ##########
    # this class have as objects as genes are in @both_interactions(class interaction_network)

    ########## ATTRIBUTE ##########
    # network_gene: the gene
    # kegg_id: all the kegg_id of the gene
    # pathway_name: all the pathway_name of the gene
    # go_id: all the go_id of the gene
    # term_name: all the term_name of the gene

    ########## METHODS ##########
    # get_kegginfo: search kegg id and pathway name in kegg 
    # get_goinfo: search GO id and GO term name in ebi-uniprot
    # fill_network_genes: fills all the attributes of each object of class Gene_info


    ########## ATTRIBUTE ##########
    attr_accessor :network_gene 
    attr_accessor :kegg_id 
    attr_accessor :pathway_name
    attr_accessor :go_id
    attr_accessor :term_name 


    ########## METHODS ##########

    # initialize 
    def initialize (params = {}) 
        @network_genes = params.fetch(:network_gene, 'unknown') 
        @kegg_id = params.fetch(:kegg_id, 'unknown')
        @pathway_name = params.fetch(:pathway_name, 'unknown')
        @go_id = params.fetch(:go_id, 'unknown')
        @term_name = params.fetch(:term_name, 'unknown')
    end


    # get_kegginfo
    def self.get_kegginfo(locus_code)
        response=Helper.fetch("http://togows.org/entry/kegg-genes/ath:#{locus_code}/pathways.json")
        # a list to store kegg id
        array_id=[]  
        # a list to store pathway names
        array_name=[] 

        # make a hash with the response of kegg
        parsed_response = JSON.parse(response.body)

        if not parsed_response.empty?
            # the hash is inside an array
            dict_response=parsed_response[0]
            dict_response.each do |key,value|
                array_id<<key
                array_name<<value.downcase
            end
        end
        # the first return is the list with kegg id 
        # the second return is the list with pathway name
        return array_id, array_name       
    end


    # get_goinfo
    def self.get_goinfo(locus_code)
        response=Helper.fetch("http://togows.org/entry/ebi-uniprot/#{locus_code}/dr.json")
        # a list to store GO id
        array_goid=[]
        # a list to store GO names
        array_goname=[]

        # make a hash with the response of GO
        parsed_response = JSON.parse(response.body)
        if not parsed_response.empty?
            dict_response=parsed_response[0]

            # regular expresions of the go id and the term name
            go_iden=/(GO:\d\d\d\d\d\d\d)/
            go_names=/P:(.+)/ 
            # P: Biological Process, C: Cellular Component, F: Molecular Function. 
            #http://geneontology.org/docs/ontology-documentation/

            # "GO" is a key in the uniprot hash
            # in his values: he firts position has the GO id and the second position has the term name
            key_go = dict_response["GO"]
            if not key_go.nil? and not key_go.empty?
                key_go.each do |array_info|
                    go_identificator = array_info[0].scan(go_iden)
                    go_termnames = array_info[1].scan(go_names)

                    # check if it found the matches and save them
                    if not go_identificator.empty? and not go_termnames.empty?
                        array_goid<<go_identificator[0][0]
                        array_goname<<go_termnames[0][0].downcase
                    end
                end
            end
        end    
        return array_goid, array_goname      
    end    


    # fill_network_genes
    def self.fill_network_genes(network) 
        # this need the attribute both_interactions of the object of class_interaction_network
        network_genes_dict={}

        # progressBar
        progressbar = ProgressBar.create(format: "%a |%b>>%i| %p%% %t",
            starting_at: 0,
            total: network.length)
        #code: https://www.rubydoc.info/gems/ruby-progressbar/1.7.0

        network.each do |key,value| # the attribute both_interactions contains a dict which keys are the genes of the input with interactions 
            kegg_id, kegg_name = self.get_kegginfo(key) # GET KEGG INFORMATION
            go_id, term_name = self.get_goinfo(key) # GET GO INFORMATION

            # fills each atribute of the object and save the object in the dict with key the agi
            obj=Gene_info.new(:network_gene => key, :go_id=> go_id, :term_name=> term_name, :kegg_id=> kegg_id, :pathway_name=> kegg_name) #, :kegg_id=> kegg_id, :pathway_name=> kegg_name
            1.times { progressbar.increment }
            network_genes_dict[key] = obj
        end
        return network_genes_dict
    end

end


