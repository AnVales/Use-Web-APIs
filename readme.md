This project searchs the interactions between a list of genes (ArabidopsisSubNetwork_GeneList.txt in this case).

At first, it searchs the direct interactions of these genes in BAR and EBI. There is a file with these responses because EBI eventually is not available.
Then, it is verified if the interactions are between genes of the same organism and are confidence.
With these verified interactions the indirect relationships are searched for each gene that is in the list.
Kegg and GO information is saved for each gene in the list with interactions.

At the end a report is written: Gene of the list+ genes that interact with this gene+ kegg information+ GO information



To make it work: ruby main ArabidopsisSubNetwork_GeneList.txt reportTask2.txt

Note: reportTask2.txt is optional
