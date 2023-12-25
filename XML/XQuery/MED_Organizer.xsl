<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
    
<xsl:variable name="id" select="base-uri()"/>
    
    <xsl:template match="node()|@*">
        <xsl:copy>
            <xsl:apply-templates/>
        </xsl:copy>
    </xsl:template>
    
<xsl:template match="td">
        <xsl:apply-templates/>
</xsl:template>

<xsl:template match="span[@class='FORM']">
    <word id="{replace($id,'[^\d]', '')}">
        <xsl:apply-templates/>
    </word>
</xsl:template>
    
    <xsl:template match="span[@class='HDORTH']">
        <headword>
            <xsl:apply-templates/>
        </headword>
    </xsl:template>
    
    <xsl:template match="span[@class='ORTH']">
        <variant>
            <xsl:apply-templates/>
        </variant>
    </xsl:template>
    
    <xsl:template match="span[@class='POS']">
        <speech_part>
            <xsl:apply-templates/>
        </speech_part>
    </xsl:template>
    
</xsl:stylesheet>