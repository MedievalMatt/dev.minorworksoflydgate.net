<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:as="http://www.w3.org/2012/10/xslt-test-catalog"
    exclude-result-prefixes="xs as"
    version="3.0">
    
    <xsl:param name="result" as="node()?" select="()"/>
    <xsl:param name="assertion" as="node()" />
    <xsl:param name="testDir" as="xs:string" />

    <xsl:variable name="debug" select="false()" as="xs:boolean" />
    
    
    
    
    <xsl:template match="/" name="main">
        <xsl:if test="$debug">
            <xsl:message>Result: <xsl:value-of select="$result" /></xsl:message>
            <xsl:message>AssertValue: <xsl:copy-of select="$assertion" /></xsl:message>
            <span>Result: <xsl:value-of select="$result" /></span>
            <span>AssertValue: <xsl:copy-of select="$assertion" /></span>
            <span>testDir: <xsl:value-of select="$testDir" /></span>
        </xsl:if>
       <xsl:apply-templates select="$assertion/result" />        
    </xsl:template>
    
    
    
    <xsl:template match="all-of">
            <xsl:iterate select="./child::*">
                <xsl:sequence select="true()" />
                <xsl:if test="not(as:FunctionAssertion(.))">
                    <xsl:break >
                        <xsl:sequence select="false()" />
                    </xsl:break>
                </xsl:if>
            </xsl:iterate>
                
    </xsl:template>
    
    <xsl:function name="as:FunctionAssertion" as="xs:boolean">
        <xsl:param name="assert" as="node()"/>
        <xsl:apply-templates select="$assert" />
    </xsl:function>
    
    <xsl:template match="any-of">
        <xsl:iterate select="./child::*">
            <xsl:sequence select="true()" />
            <xsl:if test="as:FunctionAssertion(.)">
                <xsl:break >
                    <xsl:sequence select="true()" />
                </xsl:break>
            </xsl:if>
        </xsl:iterate>
        
    </xsl:template>    
    
    <xsl:template match="assert-count" as="xs:boolean" >
        <xsl:param name="assertVal" select="xs:integer(.)" as="xs:integer"/>
        <xsl:sequence select="count($result)=$assertVal" />
    </xsl:template>
    
    <xsl:template match="assert-deep-eq" as="xs:boolean" >
        <xsl:param name="assertVal" select="." as="item()"/>
        <xsl:sequence select="deep-equal($assertVal, $result)" />
    </xsl:template>
    
    <xsl:template match="assert-permutation" as="xs:boolean" >
        <xsl:param name="assertVal" select="." as="item()"/>
        <xsl:sequence select="deep-equal($assertVal, $result)" />
    </xsl:template>    
    
    <xsl:template match="assert-xml" as="xs:boolean" priority="1" >
        <xsl:param name="assertVal" select="." as="item()"/>
        
        <xsl:sequence select="deep-equal(parse-xml($assertVal), $result)" />
    </xsl:template>   
    
    <xsl:template match="assert-xml[exists(@file)]" as="xs:boolean"  priority="2">
        <xsl:param name="assertVal" select="doc(concat($testDir,@file))" as="item()"/>
        <xsl:sequence select="deep-equal($assertVal, $result)" />
    </xsl:template>       
    
    <xsl:template match="assert-type" as="xs:boolean" >
        <xsl:param name="assertStr" select="." as="xs:string"/>
        <xsl:if test="$debug">
            <xsl:message>Assert-type test: <xsl:value-of select="concat('$result = ', $result,'; $result instance of ', $assertStr)" /></xsl:message>
        </xsl:if>
        <xsl:variable name="outcome" as="xs:boolean"><xsl:evaluate xpath="concat('$result = ', $result,'; $result instance of ', $assertStr)" /></xsl:variable>
        <xsl:sequence select="empty($result)" />
    </xsl:template>    
    
    <xsl:template match="assert-empty" as="xs:boolean" >
        <xsl:sequence select="empty($result)" />
    </xsl:template>
    
    
    <xsl:template match="assert-string-value" as="xs:boolean" >
        <xsl:variable name="resultStr" select='string-join(for $r in $result return string($r), " ")' />
        <xsl:sequence select="$resultStr = $assertion" />
    </xsl:template>    
    
    <xsl:template match="assert-serialization" as="xs:boolean" >
        <!-- TODO -->
        <xsl:sequence select="false()" />
    </xsl:template>

    <xsl:template match="serialization-matches" as="xs:boolean" >
        <!-- TODO -->
        <xsl:sequence select="false()" />
    </xsl:template> 

    <xsl:template match="assert-true" as="xs:boolean" >
        <xsl:variable name="resultVar" select="$result" as="xs:boolean" />
        <xsl:sequence select="count($result)=1 and $resultVar=true()" />
    </xsl:template> 

    <xsl:template match="assert-false" as="xs:boolean" >
        <xsl:variable name="resultVar" select="$result" as="xs:boolean" />
        <xsl:sequence select="count($result)=1 and $resultVar=false()" />
    </xsl:template> 
    
    <xsl:template match="assert" as="xs:boolean" >
        <xsl:param name="assertStr" select="." as="xs:string"/>
        <xsl:variable name="outcome" as="xs:boolean"><xsl:evaluate xpath="$assertStr" context-item="$result"/></xsl:variable>
       
        <xsl:sequence select="$outcome" />
    
    </xsl:template>
    
    <xsl:template match="assert-eq" as="xs:boolean">
        <xsl:param name="assertStr" as="xs:string"/>
        
        <xsl:variable name="assert"><xsl:evaluate xpath="$assertStr"/></xsl:variable>
        
        <xsl:sequence select="$assert eq $result" />
        
    </xsl:template>
    
    <xsl:template match="error" as="xs:boolean" >
        <xsl:variable name="code" select="./@code"/>
        <xsl:sequence select="contains($result, $code)" />
    </xsl:template>
    
</xsl:stylesheet>