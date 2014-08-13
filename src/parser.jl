# The OBO Flat File Format

const Minimal = 1
const Normal = 2
const Full = 3

type OBOParser
    mode::Int  # 1: minimal, 2: normal (default), 3: full
    filepath::String
    stream::IOStream
    version::ASCIIString
    headertags::Dict{ASCIIString,String}

    function OBOParser(filepath::String)
        stream = open(filepath, "r")
        finalizer(stream, s -> close(s))
        headertags = header(stream)
        haskey(headertags, "format-version") || error("required tag 'format-version' does not exist")
        version = headertags["format-version"]
        new(Normal, filepath, stream, version, headertags)
    end
end

type EachTerm
    mode::Int
    stream::IO
end

eachterm(parser::OBOParser) = EachTerm(parser.mode, parser.stream)

Base.start(iter::EachTerm) = iter.stream

function Base.done(iter::EachTerm, s)
    for line in eachline(s)
        if rstrip(line) == "[Term]"
            return false
        end
    end
    true
end

macro checktag(tag)
    quote
        haskey(pairs, $tag) || error("'$($tag)' tag is required")
        pairs[$tag]
    end
end

function Base.next(iter::EachTerm, s)
    pairs = Dict{ASCIIString,ASCIIString}()
    is_a = ASCIIString[]

    for line in eachline(s)
        line = rstrip(line)
        isempty(line) && break
        tag, value, ok = tagvalue(line)
        ok || error("cannot find a tag $(position(stream))")
        if tag == "is_a"
            push!(is_a, value)
        else
            pairs[tag] = value
        end
    end

    # check required tags
    id = @checktag "id"
    name = @checktag "name"

    if iter.mode == Minimal
        return Term(id, name), s
    elseif iter.mode == Normal || iter.mode == Full
        namespace = @checktag "namespace"
        def = parse_def(@checktag "def")
        return Term(id, name, namespace, def, is_a), s
    end

    @assert false "unsupported mode"
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

function header(stream::IOStream)
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
