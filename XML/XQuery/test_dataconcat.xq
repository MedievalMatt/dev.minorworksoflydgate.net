xquery version "1.0" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function local:copy($input as item()*) as item()* {
for $node in $input
   return 
      typeswitch($node)
        case element()
           return
              element {name($node)} {

                (: output each attribute in this element :)
                for $att in $node/@*
                   return
                      attribute {name($att)} {$att}
                ,
                (: output all the sub-elements of this element recursively :)
                for $child in $node
                   return local:copy($child/node())

              }
        (: otherwise pass it through.  Used for text(), comments, and PIs :)
        default return $node
};

let $files := (doc("../Quis_Dabit/Clopton_Quis_Dabit.xml"), doc("../Quis_Dabit/Clopton_Editorial.xml"))
for $x in $files//u//s//w
return local:copy($x)