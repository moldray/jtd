dts = [ DateTime()+Dates.Millisecond(i) for i=1:1000000 ]
open(f->serialize(f,dts),"test.jls","w")