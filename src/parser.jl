# The OBO Flat File Format

const Minimal = 1
const Normal = 2
const Full = 3

type OBOParser
    mode::Int  # 1: Minimal, 2: Normal (default), 3: Full
    filepath::String
    stream::IOStream
    version::ASCIIString
    headertags::Dict{ASCIIString,String}

    function OBOParser(filepath::String; mode::Int=Normal)
        1 <= mode <= 3 || error("invalid mode: $mode")
        stream = open(filepath, "r")
        finalizer(stream, s -> close(s))
        headertags = parse_header(stream)
        haskey(headertags, "format-version") || error("required tag 'format-version' does not exist")
        version = headertags["format-version"]
        new(mode, filepath, stream, version, headertags)
    end
end

type EachTerm
    mode::Int
    stream::IO
end

function seekstanza(s::IO, target::ASCIIString)
    mark(s)
    for line in eachline(s)
        if line[1] == '['
            if rstrip(line) == target
                unmark(s)
                return true
            else
                reset(s)
                return false
            end
        end
    end
    false
end

import Base: start, done, next

eachterm(parser::OBOParser) = EachTerm(parser.mode, parser.stream)
start(iter::EachTerm) = iter.stream

done(iter::EachTerm, s) = !seekstanza(s, "[Term]")

macro checktag(tag)
    quote
        haskey(pairs, $tag) || error("'$($tag)' tag is required")
        pairs[$tag]
    end
end

function next(iter::EachTerm, s)
    pairs = Dict{ASCIIString,ASCIIString}()
    is_a = ASCIIString[]
    obsolete = false

    for line in eachline(s)
        line = rstrip(line)
        isempty(line) && break
        tag, value, ok = tagvalue(line)
        ok || error("cannot find a tag (position: $(position(s)))")
        if tag == "is_a"
            push!(is_a, value)
        elseif tag == "is_obsolete"
            obsolete = value == "true" ? true : false
        else
            pairs[tag] = value
        end
    end

    # check required tags
    id = @checktag "id"
    name = @checktag "name"

    if iter.mode == Minimal
        return Term(id, name, obsolete=obsolete), s
    elseif iter.mode == Normal || iter.mode == Full
        namespace = @checktag "namespace"
        def = parse_def(@checktag "def")
        return Term(id, name, namespace, def, is_a, obsolete=obsolete), s
    end

    @assert false "unsupported mode"
end

type EachTypedef
    stream::IO
end

eachtypedef(parser::OBOParser) = EachTypedef(parser.stream)
start(iter::EachTypedef) = iter.stream
done(iter::EachTypedef, s) = !seekstanza(s, "[Typedef]")

function next(iter::EachTypedef, s)
    local id, name, namespace, xref
    for line in eachline(s)
        line = rstrip(line)
        isempty(line) && break
        tag, value, ok = tagvalue(line)
        ok || error("cannot find a tag $(position(stream))")
        if tag == "id"
            id = value
        elseif tag == "name"
            name = value
        elseif tag == "namespace"
            namespace = value
        elseif tag == "xref"
            xref = value
        end
    end
    Typedef(id, name, namespace, xref), s
end

function tagvalue(line::ASCIIString)
    # TODO: what an ad hoc parser!
    i = searchindex(line, ": ")
    if i == 0
        # empty strings are dummy
        return "", "", false
    end

    j = searchindex(line, " !")
    tag = line[1:i-1]
    if j == 0
        value = line[i+2:end]
    else
        value = line[i+2:j-1]
    end

    return tag, value, true
end

# parsers

function parse_header(stream::IOStream)
    pairs = Dict{ASCIIString,String}()
    for line in eachline(stream)
        line = rstrip(line)
        isempty(line) && break
        tag, value, ok = tagvalue(line)
        ok || error("cannot find a tag at $(position(stream))")
        pairs[tag] = value
    end
    pairs
end

function parse_def(s::ASCIIString)
    i = searchindex(s, "\"")
    j = searchindex(s, "\"", i+1)
    s[i+1:j-1]
end


# Gene annotation parser

type AnnotaionParser
    filepath::String
    stream::IOStream
    version::ASCIIString

    function AnnotaionParser(filepath::String)
        stream = open(filepath, "r")
        finalizer(stream, s -> close(s))
        version = parse_version(stream)
        new(filepath, stream, version)
    end
end

type EachAnnotRecord
    stream::IO
end

eachannot(parser::AnnotaionParser) = EachAnnotRecord(parser.stream)
start(iter::EachAnnotRecord) = nothing
done(iter::EachAnnotRecord, _) = eof(iter.stream)
function next(iter::EachAnnotRecord, _)
    line = readline(iter.stream)
    fields = split(line, '\t')
    fields[end] = rstrip(fields[end])

    AnnotationRecord(
        fields[1],
        fields[2],
        fields[3],
        split(fields[4], '|'),
        parseid(fields[5]),
        split(fields[6], '|'),
        fields[7],
        split(fields[8], '|'),
        namespaceof(fields[9][1]),
        isempty(fields[10]) ? nothing : convert(ASCIIString, fields[10]),
        split(fields[11], '|'),
        fields[12],
        split(fields[13], '|'),
        fields[14],
        fields[15],
        split(fields[16], ','),
        isempty(fields[17]) ? nothing : convert(ASCIIString, fields[17])
    ), nothing
end

function parse_version(stream::IOStream)
    local version
    while true
        mark(stream)
        eof(stream) && break
        line = readline(stream)
        if line[1] != '!'
            reset(stream)
            break
        end
        m = match(r"!gaf-version: ([\d\.])+", line)
        if !is(m, nothing)
            version = m.captures[1]
        end
    end
    version
end
