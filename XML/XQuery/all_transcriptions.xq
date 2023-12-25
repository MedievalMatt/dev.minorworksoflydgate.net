xquery version "1.0" encoding "UTF-8";

declare namespace tei="http://www.tei-c.org/ns/1.0";

declare function local:if-empty
  ( $arg as item()? ,
    $value as item()* )  as item()* {

  if (string($arg) != '')
  then data($arg)
  else $value
 };
 

  (:
  The rules are:
  #1 Retain one leading space if the node isn't first, has non-space content, and has leading space.
  #2 Retain one trailing space if the node isn't last, isn't first, and has trailing space. 
  #3 Retain one trailing space if the node isn't last, is first, has trailing space, and has non-space content.
  #4 Retain a single space if the node is an only child and only has space content.
  
  declare function local:tei-normalize-space($input)
  {
     element {node-name($input)}
       {$input/@*,
         for $child in $input/node()
         return
           if ($child instance of element())
           then local:tei-normalize-space($child)
           else
             if ($child instance of text())
             then
               (:#1 Retain one leading space if node isn't first, has non-space content, and has leading space:)
               if ($child/position() ne 1 and matches($child,'^\s') and normalize-space($child) ne '')
               then (' ', normalize-space($child))
               else
                 (:#4 retain one space, if the node is an only child, and has content but it's all space:)
                 if ($child/last() eq 1 and string-length($child) ne 0 and normalize-space($child) eq '')
                 (:NB: this overrules standard normalization:)
                 then ' '
                 else
                   (:#2 if the node isn't last, isn't first, and has trailing space, retain trailing space and collapse and trim the rest:)
                   if ($child/position() ne 1 and $child/position() ne last() and matches($child,'\s$'))
                   then (normalize-space($child), ' ')
                   else
                     (:#3 if the node isn't last, is first, has trailing space, and has non-space content, then keep trailing space:)
                     if ($child/position() eq 1 and matches($child,'\s$') and normalize-space($child) ne '')
                     then (normalize-space($child), ' ')
                     (:if the node is an only child, and has content which is not all space, then trim and collapse, that is, apply standard normalization:)
                     else normalize-space($child)
              (:output comments and pi's:)
              else $child
      }
  };
  :)
  

  
declare function local:remove-elements($input as element(), $remove-names as xs:string*) as element() {
   element {node-name($input) }
      {$input/@*,
       for $child in $input/node()[not(name(.)=$remove-names)]
          return
             if ($child instance of element())
                then local:remove-elements($child, $remove-names)
                else $child
      }
};

declare function local:remove-empty-elements($nodes as node()*)  as node()* {
   for $node in $nodes
   return
     if (empty($node)) then () else
     if ($node instance of element())
     then if (normalize-space($node) = '')
          then ()
          else element { node-name($node)}
                { $node/@*,
                  local:remove-empty-elements($node/node())}
     else if ($node instance of document-node())
     then local:remove-empty-elements($node/node())
     else $node
 };
 
 declare function local:copy-xml($element as element()) {
  element {node-name($element)}
    {$element/@*,
     for $child in $element/node()
        return if ($child instance of element())
          then local:copy-xml($child)
          else $child
    }
};
<teiCorpus>
{(:

let $q:=collection($collection)
let $remove-list := ('note')

(:let $q:=local:remove-empty-elements($q):)

for $y in $q 
let $s := $y//tei:surface   
let $t := $y//tei:titleStmt/@xml:id
let $m := $y//tei:msDesc/@xml:id
(:let $w := concat($s/../../../..//msDesc/msIdentifier/settlement,', ',$s/../../../..//msDesc/msIdentifier/institution,' ',$s/../../../..//msDesc/msIdentifier/idno):)
let $z := $s/tei:zone[@n=$zone]
let $l := $z/tei:line[@n=$line]
(:let $w := $l/../../../../../../name():)
let $w := concat($y//tei:msDesc/tei:msIdentifier/tei:settlement/text(),', ',$y//tei:msDesc/tei:msIdentifier/tei:institution/text(),' ',$y//tei:msDesc/tei:msIdentifier/tei:idno/text())
let $g := concat($t, "/" , $m, "/", substring-before($l/../../tei:graphic/@url,"."),".html")
(:let $o := $l/tei:orig :)
let $o:=local:remove-elements($l/tei:orig,$remove-list)
(:let $o:=local:tei-normalize-space(local:remove-elements($l/tei:orig, $remove-list)):)
where ($z//tei:line/@n = "l.1")


return 

<item>{$w}: <ref target="{$g}">{$o}</ref></item>
:)

for $x in (doc("/home/matrygg/minorworksoflydgate.net/XML/Quis_Dabit/British_Library_Harley_2251_Quis_Dabit.xml"),doc("/home/matrygg/minorworksoflydgate.net/XML/Quis_Dabit/British_Library_Harley_2255_Quis_Dabit.xml"),doc("/home/matrygg/minorworksoflydgate.net/XML/Quis_Dabit/Clopton_Quis_Dabit.xml"),doc("/home/matrygg/minorworksoflydgate.net/XML/Quis_Dabit/Jesus_College_Q_G_8_Quis_Dabit.xml"),doc("/home/matrygg/minorworksoflydgate.net/XML/Quis_Dabit/Laud_683_Quis_Dabit.xml"),doc("/home/matrygg/minorworksoflydgate.net/XML/Quis_Dabit/St_John_56_Quis_Dabit.xml"),doc("/home/matrygg/minorworksoflydgate.net/XML/Testament/Clopton_Testament.xml"))
return $x
}
</teiCorpus>


