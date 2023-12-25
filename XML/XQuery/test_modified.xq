xquery version "1.0" encoding "UTF-8";

declare namespace tei = "http://www.tei-c.org/ns/1.0";

declare variable $zone external;
declare variable $marginalia external;
declare variable $line external;
declare variable $collection external;

declare function local:if-empty
($arg as item()?,
$value as item()*) as item()* {
    
    if (string($arg) != '')
    then
        data($arg)
    else
        $value
};

declare function local:remove-elements($input as element(), $remove-names as xs:string*) as element() {
    element {node-name($input)}
    {
        $input/@*,
        for $child in $input/node()[not(name(.) = $remove-names)]
        return
            if ($child instance of element())
            then
                local:remove-elements($child, $remove-names)
            else
                $child
    }
};

declare function local:remove-empty-elements($nodes as node()*) as node()* {
    for $node in $nodes
    return
        if (empty($node)) then
            ()
        else
            if ($node instance of element())
            then
                if (normalize-space($node) = '')
                then
                    ()
                else
                    element {node-name($node)}
                    {
                        $node/@*,
                        local:remove-empty-elements($node/node())
                    }
            else
                if ($node instance of document-node())
                then
                    local:remove-empty-elements($node/node())
                else
                    $node
};

<list>
    {
        (:let $collection := concat('../',$collection,'?select=*.xml')":)
        let $collection := concat('../', 'Mumming_Eltham', '?select=*.xml')
        let $q := collection($collection)
        let $remove-list := ('note')
        let $line := "l.3"
        let $zone := "EETS.ME.8"
        let $marginalia := "marginalia"
        
        
        for $y in $q
        let $s := $y//tei:surface
        let $t := $y//tei:titleStmt/@xml:id
        let $m := $y//tei:msDesc/@xml:id
        let $z := $s/tei:zone[@n = $zone]
        let $z := if (exists($s/tei:zone[@n = $zone]/tei:zone)) then
            $s/tei:zone[@n = $zone]/tei:zone[@n = $marginalia]
        else
            $s/tei:zone[@n = $zone]
            (:let $x := $z/tei:zone[@n = $marginalia]:)
        let $l := $z/tei:line[@n = $line]
        let $h := if (exists($s/tei:zone[@n = $zone]/tei:zone)) then
            concat(substring-before($l/../../../tei:graphic/@url, "."), ".html")
        else
            concat(substring-before($l/../../tei:graphic/@url, "."), ".html")
        
        let $w := concat($y//tei:msDesc/tei:msIdentifier/tei:settlement/text(), ', ', $y//tei:msDesc/tei:msIdentifier/tei:institution/text(), ' ', $y//tei:msDesc/tei:msIdentifier/tei:idno/text())
        let $g := concat($t, "/", $m, "/", $h)
        (:let $o := local:remove-elements($l, $remove-list):)
        let $o := if (exists($l/tei:note)) then
                    local:remove-elements($l, $remove-list)
                  else
                    $l
        
        
        
        return
            <item>{$w}: <ref
                    target="{$g}">{$o}</ref></item> 
            
    
    
    
    
    }
</list>
