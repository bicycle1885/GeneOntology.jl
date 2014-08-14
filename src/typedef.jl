immutable Typedef
    id::ASCIIString
    name::ASCIIString
    namespace::ASCIIString
    xref::ASCIIString
end

import Base: isequal, ==

isequal(td1::Typedef, td2::Typedef) = td1.id == td2.id
==(td1::Typedef, td2::Typedef) = isequal(td1, td2)
