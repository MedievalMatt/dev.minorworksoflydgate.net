
let $q:=collection('/home/matrygg/minorworksoflydgate.net/XML/XQuery/MED/?select=*.xml')

return <root>
{for $e in $q

let $b := fn:base-uri($e)

(:let $m := transform(map {"stylesheet-location": "MED_Organizer.xsl","source-node": $e)}:)
let $i := $e//td
let $f := $i//span[@class="FORM"]
let $p := $f//span[@class="POS"]
let $h := $f//span[@class="HDORTH"]
let $v := $f//span[@class="ORTH"]


return 
<word id="{substring-after(substring-before($b,'.xml'),'/MED/MED')}">
		{for $t at $l in $h
		 return <headword id="{$l}">{$t/text()}</headword>
		}		
		{for $x at $m in $v
		 return <variant id="{$m}">{$x/text()}</variant>
		}
		<speech_part>{normalize-space($p/text())}</speech_part>

</word>}
</root>
