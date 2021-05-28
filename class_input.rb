class Input


    ########## CLASS ##########
    # this class stores the genes of the input

    ########## ATTRIBUTE ##########
    # input_genes: a hash with the input genes of an Arabidopsis sub-network

    ########## METHODS ##########
    # fill_input_genes: fill the attribute input_genes


    ########## ATTRIBUTE ##########
    attr_accessor :input_genes 

    ########## METHODS ##########

    # initialize 
    def initialize (params = {}) 
        @input_genes = params.fetch(:input_genes, nil)
    end

    # fill_input_genes
    def fill_input_genes(genes_file)
        @input_genes={} # dict with input genes
        genes = File.open(genes_file, "r") # open the file, read it and put the genes in the dict
        genes.each_line do |line| 
            locus_id = line.split(/\n/)
            locus_id = locus_id[0].downcase
            locus_id = locus_id.capitalize # in some pages, the t of for example "AT4g22890" is t, so this dict will have the downcase t too
            @input_genes[locus_id]=locus_id 
        end
        # code: https://stackoverflow.com/questions/43216556/how-to-split-line-read-from-text-file
    end
    
    
    
end