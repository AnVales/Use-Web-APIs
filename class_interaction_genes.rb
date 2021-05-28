require './class_helper.rb'
require './class_interaction_genes.rb'
require './class_input.rb'
require 'ruby-progressbar'
require 'rest-client'
require 'json'

class Interaction_genes

    ########## CLASS ##########
    # this class store the direct interactions of each gene

    ########## ATTRIBUTE ##########
    # all_info_interactions: a hash with all the information about the interactions of the input genes (uniprotkb, tair, pubmed, intact-miscore)
    # direct_interactions: a hash with the direct interactions of the input genes and others, 
    #   the key is a gene and the value the genes with direct interaction with this gene

    ########## METHODS ##########
    # fill_all_info_interactions: fill the attribute all_info_interactions with data of BAR and EBI
    # fill_all_info_interactions_from_file: fill the attribute all_info_interactions with the data in a json file
    # fill_direct_interactions: fill the attribute direct_interactions

    ########## ATTRIBUTE ##########
    attr_accessor :all_info_interactions 
    attr_accessor :direct_interactions


    ########## METHODS ##########
    # initialize 
    def initialize (params = {}) 
        @all_info_interactions = params.fetch(:all_info_interactions, nil) 
        @direct_interactions = params.fetch(:direct_interactions, nil)
    end

    # fill_all_info_interactions
    def fill_all_info_interactions(input_info)
        @all_info_interactions={} # a dict for all the interaction information
        progressbar = ProgressBar.create(format: "%a |%b>>%i| %p%% %t",
            starting_at: 0,
            total: input_info.input_genes.length)
        # counters
        bar_count=0
        ebi_count=0
        search_count=0
        input_info.input_genes.each do |agi,agi_value|

            search_count=search_count+1
            # search in BAR
            response=Helper.fetch("http://bar.utoronto.ca:9090/psicquic/webservices/current/search/query/tair:#{agi}?format=tab25")
            if not response.empty? 
                todo = response.to_str.split(/\n/) 
                @all_info_interactions[agi]=todo # save all as value with key the initial agi
                bar_count=bar_count+1

            else 
                # search in EBI 
                response=Helper.fetch("http://www.ebi.ac.uk/Tools/webservices/psicquic/intact/webservices/current/search/interactor/#{agi}/?format=tab25")
                if not response.empty?
                    todo = response.to_str.split(/\n/) 
                    @all_info_interactions[agi]=todo # save all as value with key the initial agi
                    ebi_count=ebi_count+1 
                end
            end
            1.times { progressbar.increment }
        end
        # some informations about the searches
        puts "Search: #{search_count} genes"
        puts "Bar: #{bar_count} genes are found"
        puts "Ebi: #{ebi_count} genes are found"
        puts "#{search_count-bar_count-ebi_count} genes aren't found"

        # the searches are saved in .json file
        # File.open("responses.json","w") do |f|
        #     f.write(@all_info_interactions.to_json)
        # end
    end


    # fill_all_info_interactions_from_file
    def fill_all_info_interactions_from_file()
        @all_info_interactions={} # a dict for all the interaction information

        File.open("responses.json") do |f| # open de json file and put all the info the dict
            @all_info_interactions = JSON.parse(f.read)
        end
    end


    # fill_direct_interactions
    def fill_direct_interactions(input_info)
        count_interactions=0
        @direct_interactions={} # dict of direct relation

        # bar regular expresions    
        agi_bar=/tair:(A[Tt][\d\w][Gg]\d\d\d\d\d)\ttair:(A[Tt][\d\w][Gg]\d\d\d\d\d)/
        taxid_bar=/taxid:(\d+)\ttaxid:(\d+)/

        # ebi regular expresions  
        agi_ebi=/uniprotkb:(A[Tt][\d\w][Gg]\d\d\d\d\d)\(locus\sname\).+uniprotkb:(A[Tt][\d\w][Gg]\d\d\d\d\d)\(locus\sname\)/
        taxid_ebi=/taxid:(\d+)\(arath\).+taxid:(\d+)\(arath\)/

        # bar + ebi regular expresion
        intact_miscore=/intact-miscore:(0.\d+)/

        # Filters
        taxid_ara=3702
        miscore_quality=0.79

        # all_info_interactions is a dict with keys and values
        @all_info_interactions.each do |key, value_array|
            value_array.each do |value|
                
                if Helper.is_bar(value) 
                    # bar information have this regular expresions
                    value.match(agi_bar)
                    gen_a=$1
                    gen_b=$2

                    value.match(taxid_bar)
                    taxid_a=$1.to_i
                    taxid_b=$2.to_i

                else
                    # ebi information have this regular expresions
                    value.match(agi_ebi)
                    gen_a=$1
                    gen_b=$2

                    value.match(taxid_ebi)
                    taxid_a=$1.to_i
                    taxid_b=$2.to_i

                end
                # bar and ebi information have this regular expresion
                value.match(intact_miscore)
                miscore=$1.to_f

                # filters: both taxid must be Arabidopsis taxid/ intact-miscore must be more than 0.79
                if taxid_a==taxid_ara && taxid_b==taxid_ara
                    if miscore>miscore_quality

                        count_interactions=count_interactions+1

                        # both genes must exist
                        if not gen_a.nil? and not gen_b.nil?

                            if @direct_interactions[gen_a].nil?
                                @direct_interactions[gen_a]=[gen_b]
                            else
                                @direct_interactions[gen_a]<<gen_b
                            end
                            if @direct_interactions[gen_b].nil?
                                @direct_interactions[gen_b]=[gen_a]
                            else
                                @direct_interactions[gen_b]<<gen_a
                            end
                        end
                    end
                end
            end  
        end

    # some information of direct interactions
    puts "There are #{count_interactions} direct interactions"
    puts "There are #{@direct_interactions.keys.length} genes in the hash"
    puts "In the .txt file there are only #{input_info.input_genes.length}"
    if @direct_interactions.keys.length>input_info.input_genes.length*2
        puts "This means that many interactions are with genes that aren't in the file"
    end
    end
    
end