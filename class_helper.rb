require 'rest-client'


class Helper

    ########## CLASS ##########
    # this class has useful methods for the other classes

    ########## METHODS ##########
    # fetch method: try to contact the website and if it fails, return the error
    # is_bar method: returns true if the information comes from bar, false if it's from ebi
    # make_sentence method: transforms an array into comma separated values ​​and the last one by and
    # number_input: checks if the number of input files is correct, if it isn't prints a helpful error
    # file_exist: checks if the input file with genes exist, if it isn't prints a helpful error
    # input_writefile: if the input doesn't contains the file where the report is going to be written, set this file by default "reportTask2.txt"


    ########## METHODS ##########

    # fetch
    def self.fetch(url, headers = {accept: "*/*"}, user = "", pass="")
        response = RestClient::Request.execute({
        method: :get,
        url: url.to_s,
        user: user,
        password: pass,
        headers: headers})
        return response
        
        rescue RestClient::ExceptionWithResponse => e
        $stderr.puts e.inspect
        response = false
        return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
        rescue RestClient::Exception => e
        $stderr.puts e.inspect
        response = false
        return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
        rescue Exception => e
        $stderr.puts e.inspect
        response = false
        return response  # now we are returning 'False', and we will check that with an \"if\" statement in our main code
    end 
    


    # is_bar
    def self.is_bar(value)
        tair=/tair:/
        return tair.match?(value) # is this information from bar or from ebi?, TRUE:bar, FALSE: ebi
    end


    # make_sentence
    def self.make_sentence(array)
        return nil if array.nil?
        return array[0] if array.length == 1
        return array[0..-2].join(', ') + " and " + array[-1] if array.length > 1
    end
    # code: https://codereview.stackexchange.com/questions/5863/ruby-function-to-join-array-with-commas-and-a-conjunction/5890


    # number_input
    def self.number_input(array_input)
        # the input must be one file (file with genes) or two files (file with genes and the file for the report)
        if array_input.length()<1 or array_input.length()>2
            abort("Incorrect number of input files")
        end
    end


    # file_exist
    def self.file_exist (test_file)
        # if the files doesn't exist, abort
        if File.exist?(test_file)!=true
            abort("This file doesn't exist")
        end
    end


    # input_writefile
    def self.input_writefile(array_input)
        if array_input.length()<2
            # if the input doesn't contain a file for the report, reportTask2.txt is set by default
            return 'reportTask2.txt'
        elsif array_input.length()==2
            return ARGV[1]
        end
    end


end