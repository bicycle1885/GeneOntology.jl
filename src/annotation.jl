# Annotations related to GeneOntology
# http://geneontology.org/page/go-annotation-file-gaf-format-20

# Spec of annotation record (copied from GO Annotation File (GAF) Format 2.0)
#
#  Column    Content                         Required?   Cardinality     Example
# -------------------------------------------------------------------------------------
#  1         DB                              required    1               UniProtKB
#  2         DB Object ID                    required    1               P12345
#  3         DB Object Symbol                required    1               PHO3
#  4         Qualifier                       optional    0 or greater    NOT
#  5         GO ID                           required    1               GO:0003993
#  6         DB:Reference (|DB:Reference)    required    1 or greater    PMID:2676709
#  7         Evidence Code                   required    1               IMP
#  8         With (or) From                  optional    0 or greater    GO:0000346
#  9         Aspect                          required    1               F
#  10        DB Object Name                  optional    0 or 1          Toll-like receptor 4
#  11        DB Object Synonym (|Synonym)    optional    0 or greater    hToll|Tollbooth
#  12        DB Object Type                  required    1               protein
#  13        Taxon(|taxon)                   required    1 or 2          taxon:9606
#  14        Date                            required    1               20090118
#  15        Assigned By                     required    1               SGD
#  16        Annotation Extension            optional    0 or greater    part_of(CL:0000576)
#  17        Gene Product Form ID            optional    0 or 1          UniProtKB:P12345-2

type AnnotationRecord
    db::ASCIIString
    db_object_id::ASCIIString
    db_object_symbol::ASCIIString
    qualifier::Vector{ASCIIString}
    go_id::TermID
    db_reference::Vector{ASCIIString}
    evidence_code::ASCIIString
    with_or_from::Vector{ASCIIString}
    aspect::RootOntology
    db_object_name::Union(ASCIIString,Nothing)
    db_object_synonym::Vector{ASCIIString}
    db_object_type::ASCIIString
    taxon::Vector{ASCIIString}
    date::ASCIIString
    assigned_by::ASCIIString
    annotation_extension::Vector{String}
    gene_product_form::Union(ASCIIString,Nothing)
end

Base.show(io::IO, annot::AnnotationRecord) = @printf io "AnnotationRecord(\"%s\", \"%s\", \"%s\")" annot.db annot.db_object_id annot.go_id
