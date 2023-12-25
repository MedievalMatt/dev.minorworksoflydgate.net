<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:teix="http://www.tei-c.org/ns/Examples"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:idhmc="http://idhmc.tamu.edu/" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    exclude-result-prefixes="#default html a fo rng tei teix" version="2.0">
    <xsl:preserve-space elements="tei:ex tei:hi tei:note tei:code tei:gap"/>
    <xsl:strip-space elements="tei:note tei:damage tei:gap"/>
    
    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>