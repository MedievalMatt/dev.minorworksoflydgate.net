<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xi="http://www.w3.org/2001/XInclude"    
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    
    exclude-result-prefixes="xs xi"
    version="2.0">
    
    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@*[name() != 'part']|node()" />
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>
