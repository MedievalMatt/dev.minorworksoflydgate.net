<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    exclude-result-prefixes="xs tei"
    version="2.0">
    <xsl:output method="html" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="tei:ex tei:hi tei:note tei:code tei:gap"/>
    
    
    <xsl:template match="list">
                <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="item">
        <div class="compare_item">
                    <xsl:attribute name="zonenum">
                        <xsl:value-of select="translate(ref/@zonenum,'.','_')"/>
                    </xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    
    <xsl:template match="ref">
        <a style="text-decoration:none; color:#D5D5E5;">
            <xsl:attribute name="href">
                <xsl:value-of select="@target"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="tei:damage[@n = 'legible']">
        <xsl:choose>
            <xsl:when
                test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Clopton_Chantry_Chapel'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="span">
                    <xsl:attribute name="class">damage legible</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:damage[@agent = 'tearing']">
        <xsl:element name="span">
            <xsl:attribute name="class">damage tearing</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:supplied">
        <xsl:element name="span">
            <xsl:attribute name="class">supplied</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:damage[@n = 'illegible']">
        <xsl:choose>
            <xsl:when
                test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Clopton_Chantry_Chapel'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="span">
                    <xsl:attribute name="class">damage illegible</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--<xsl:template match="tei:damage">
        <span class="damage">
            <xsl:apply-templates/>
        </span>
    </xsl:template>-->
    
    <!--<xsl:template match="tei:damage">
            <xsl:apply-templates/>
    </xsl:template>-->
    
    <xsl:template match="tei:damage[@n = 'legible']">
        <xsl:choose>
            <xsl:when
                test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Clopton_Chantry_Chapel'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="span">
                    <xsl:attribute name="class">damage legible</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:damage[@n = 'illegible']">
        <xsl:choose>
            <xsl:when
                test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Clopton_Chantry_Chapel'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="span">
                    <xsl:attribute name="class">damage illegible</xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="tei:damage/tei:gap">
        <xsl:text>[</xsl:text>
        <xsl:variable name="max" select="@quantity"/>
        <xsl:for-each select="1 to $max">
            <xsl:text>.</xsl:text>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
    </xsl:template>
        
    <xsl:template match="tei:hi">
        <xsl:choose>
            <xsl:when test="@rend = 'underline'">
                <span class="underline">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'underline_red'">
                <span class="underline red">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'underline_blue'">
                <span class="underline blue">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'underline_gold'">
                <span class="underline">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'underline_green'">
                <span class="underline green">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'underline_gold'">
                <span class="underline gold">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'capital_2'">
                <span class="capital_2">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'capital_2_red'">
                <span class="capital_2 red">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'capital_2_blue'">
                <span class="capital_2 blue">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'capital_2_gold'">
                <span class="capital_2 gold">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'capital_2_green'">
                <span class="capital_2 gold">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'capital_missing_2'">
                <span class="capital_2 missing">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'capital_3'">
                <span class="capital_3">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'capital_3_red'">
                <span class="capital_3 red">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'capital_3_blue'">
                <span class="capital_3 blue">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'capital_3_gold'">
                <span class="capital_3 gold">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'capital_3_gold'">
                <span class="capital_3 green">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'capital_missing_3'">
                <span class="capital_3 missing">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'touched'">
                <span class="touched">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'touched_underline_red'">
                <span class="touched underline red">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'touched_underline_blue'">
                <span class="touched underline blue">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'touched_underline_green'">
                <span class="touched underline green">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'touched_underline_gold'">
                <span class="touched underline gold">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@rend = 'symbol'">
                <div class="symbol">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="@rend = 'pilcrow'">
                <div class="pilcrow">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="@rend = 'red_pilcrow'">
                <div class="pilcrow red">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="@rend = 'blue_pilcrow'">
                <div class="pilcrow blue">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="@rend = 'gold_pilcrow'">
                <div class="pilcrow gold">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="@rend = 'green_pilcrow'">
                <div class="pilcrow gold">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <span class="capital">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    
    <xsl:template match="tei:ex">
        <xsl:element name="span">
            <xsl:attribute name="class">ex</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="tei:note"/>
    
    <xsl:template match="tei:line">
        <div class="item_text">
            <xsl:attribute name="linenum">
                <xsl:value-of select="translate(@n,'.','_')"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    
    <xsl:template match="tei:line/tei:gap">
        <xsl:text>[</xsl:text>
        <xsl:variable name="max" select="@quantity"/>
        <xsl:for-each select="1 to $max">
            <xsl:text>.</xsl:text>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
    </xsl:template>
    
    <xsl:template match="tei:ref/tei:gap">
        <!-- <xsl:if test="not(preceding-sibling::tei:gap)"> -->
        <xsl:text>[</xsl:text>
        <!-- </xsl:if> -->
        <xsl:variable name="max" select="@quantity"/>
        <xsl:for-each select="1 to $max">
            <xsl:text>.</xsl:text>
        </xsl:for-each>
        <!-- <xsl:if test="not(following-sibling::tei:gap)"> -->
        <xsl:text>]</xsl:text>
        <!-- </xsl:if>    -->
    </xsl:template>
    
    
</xsl:stylesheet>
