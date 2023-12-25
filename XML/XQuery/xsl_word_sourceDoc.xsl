<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main"
    exclude-result-prefixes="xs w"
    version="2.0">
    <xsl:strip-space elements="*"/>
    
    <xsl:template match="*">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="w:body">
            <sourceDoc>
                <surfaceGrp>
                    <surface>
                        <label/>
                        <graphic/>
                        <zone>
                            <xsl:apply-templates/>
                        </zone>
                    </surface>
                  <xsl:apply-templates/>
                </surfaceGrp>
            </sourceDoc>
    </xsl:template>
    
    
    <xsl:template match="w:p">
        <xsl:choose>
            <xsl:when test="not(normalize-space(.))"/>
<!--            <xsl:when test="contains(w:r/w:t/text(),'FOLIO') and contains(w:r/w:t/text(),'START')">
                <surface>
                    <label/>
                    <graphic/>
            </xsl:when>
            <xsl:when test="contains(w:r/w:t/text(),'FOLIO') and contains(w:r/w:t/text(),'END')">
                </surface>
            </xsl:when> -->
            <xsl:otherwise>
                    <line>
                        <orig>
                            <xsl:apply-templates/>
                        </orig>
                    </line>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="w:r">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="w:t">
        <xsl:choose>
            <xsl:when test="../w:rPr/w:b">
                <hi>
                    <xsl:apply-templates/>
                </hi>
            </xsl:when>
            <xsl:when test="../w:rPr/w:u">
                <hi rend="underline">
                    <xsl:apply-templates/>
                </hi>
            </xsl:when>
            <xsl:when test="../w:rPr/w:i">
                <ex>
                    <xsl:apply-templates/>
                </ex>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>