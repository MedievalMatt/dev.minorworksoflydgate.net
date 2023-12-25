<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" 
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
  xmlns:teix="http://www.tei-c.org/ns/Examples" 
  xmlns:d="http://www.oxygenxml.com/ns/doc/xsl"
  xpath-default-namespace="http://www.tei-c.org/ns/1.0"
  exclude-result-prefixes="#all">
  <d:doc>
    <d:desc>
      <d:p type="title">Data Dictionary Generator</d:p>
      <d:p>An open-source TEI documentation tool</d:p>
      <d:p>Special thanks to Martin Holmes, University of Victoria, for the egXML code-rendering
        mechanism.</d:p>
      <d:p>This script uses a TEI-formatted glossary of local definitions and the TEI source to P5
        to generate an XHTML "dictionary" profile of the TEI file. See the included README for 
        further information.</d:p>
      <d:ul>
        <d:li type="dependency">p5subset.xml</d:li>
        <d:li type="dependency">*_dictionary.xml</d:li>
      </d:ul>
      <d:p type="creator">Joe Easterly</d:p>
      <d:p type="contributor">Syd Bauman</d:p>
      <d:p type="contributor">Sean Morris</d:p>
      <d:p type="updated">2015-09-01</d:p>
      <d:ref>http://humanities.lib.rochester.edu/</d:ref>
      <d:p>This work is licensed under the Creative Commons Attribution-ShareAlike 4.0 International
        License. To view a copy of this license, visit
        http://creativecommons.org/licenses/by-sa/4.0/.</d:p>
    </d:desc>
  </d:doc>
  <xsl:key name="elements" match="*" use="name()"/>
  <xsl:key name="attributes" match="@*" use="name()"/>
  <xsl:param name="debug" select="'true'"/>
  <xsl:param name="displayModule" select="'false'"/>
  <xsl:param name="outputFormat" select="'html'"/>
  <xsl:param name="teiOutPath" select="'/tmp/data_dictionary_tei.xml'"/>
  <xsl:param name="P5source" select="'p5subset.xml'"/>
  <xsl:param name="dictFile">
    <xsl:if test="doc-available('mwjl_dictionary.xml')">
      <xsl:value-of select="'mwjl_dictionary.xml'"/>
    </xsl:if>
  </xsl:param>
  
  <!-- folder variables for proper placement of image and text files -->
  <xsl:variable name="full_image_folder" select="'Images'"/>
  <xsl:variable name="thumbnail_folder" select="'Thumbnails'"/>
  <xsl:variable name="witness"
    select="normalize-space(//teiHeader/fileDesc/sourceDesc/msDesc/@xml:id)"/>
  <xsl:variable name="title_folder"
    select="normalize-space(//teiHeader/fileDesc/titleStmt/@xml:id)"/>
  
  <xsl:decimal-format name="us" decimal-separator="." grouping-separator=","/>
  <xsl:variable name="maxReferences" select="4"/>
  <xsl:variable name="archive_title"
    select="normalize-space(//teiHeader/fileDesc/titleStmt/title)"/>
  <xsl:variable name="full_title"
    select="normalize-space(concat(//teiHeader/fileDesc/titleStmt/title/title[@type='main'],': ',/TEI/teiHeader/fileDesc/titleStmt/title/title[@type='sub']))"/>
  <xsl:variable name="next_page"/>
  <xsl:variable name="prev_page"/>
  <xsl:variable name="author_name"
    select="normalize-space(concat(//teiHeader/fileDesc/titleStmt/author/persName/forename[@sort='1'],' ',/TEI/teiHeader/fileDesc/titleStmt/author/persName/forename[@sort='2'],' ',/TEI/teiHeader/fileDesc/titleStmt/author/persName/surname))"/>
  <xsl:variable name="editor_name"
    select="normalize-space(concat(//teiHeader/fileDesc/titleStmt/editor/persName/forename[@sort='1'],' ',/TEI/teiHeader/fileDesc/titleStmt/editor/persName/forename[@sort='2'],' ',/TEI/teiHeader/fileDesc/titleStmt/editor/persName/surname))"/>
  <xsl:variable name="roleDate"
    select="normalize-space(concat(self::text(),', ',../date[@type='year']))"/>
  <xsl:variable name="XMLFileName" select="concat('../../XML/',$title_folder,'/',$fileName)"/>
  
  <xsl:variable name="fileName">
    <xsl:call-template name="GetFileName">
      <xsl:with-param name="path"
        select="concat(//teiHeader/fileDesc/sourceDesc/msDesc/@xml:id,concat('_',//teiHeader/fileDesc/titleStmt/@xml:id),'.xml')"
      />
    </xsl:call-template>
  </xsl:variable>
  
  <xsl:template name="GetFileName">
    <xsl:param name="path"/>
    <xsl:choose>
      <xsl:when test="contains($path, '/')">
        <xsl:call-template name="GetFileName">
          <xsl:with-param name="path" select="substring-after($path, '/')"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$path"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="siteHeader">
    <h1 class="siteHeader">
      <xsl:if test="not(name()='surface')">
        <xsl:attribute name="id">
          <xsl:text>noText</xsl:text>
        </xsl:attribute>
      </xsl:if>
      <span class="menuitem" id="siteitem">
        <a class="nav_link" id="home" href="../../index.html">Home</a>
      </span>
      <span class="menuitem" id="siteitem">
        <a class="nav_link" id="archive" href="../../archive.html">About the Archive</a>
      </span>
      <span class="menuitem" id="siteitem">
        <a class="nav_link" id="lydgate" href="../../lydgate.html">About John Lydgate</a>
      </span>
      <span class="menuitem" id="siteitem">
        <a class="nav_link" id="works" href="../../works.html">Works</a>
      </span>
      <span class="menuitem" id="siteitem">
        <a class="nav_link" id="manuscripts" href="../../manuscripts.html">Manuscripts</a>
      </span>
      <xsl:choose>
        <xsl:when test="//text/@xml:id = 'GeneralEditorial'">
          <span class="menuitem" id="siteitem">
            <a class="nav_link" id="description">
              <xsl:attribute name="href"><xsl:value-of
                select="concat(//teiHeader/fileDesc/sourceDesc/msDesc/@xml:id,concat('_',//teiHeader/fileDesc/titleStmt/@xml:id),'_description.html')"
              /></xsl:attribute>About this Manuscript</a>
          </span>
          <span class="menuitem" id="siteitem">
            <a class="nav_link" id="return" onclick="history.go(-1)" onmouseover="this.style.cursor='pointer'">Return to Text</a>
          </span>
        </xsl:when>
        
        <xsl:when test="name()='fileDesc'">
          <span class="menuitem" id="siteitem">
            <a class="nav_link" id="return" onclick="history.go(-1)" onmouseover="this.style.cursor='pointer'">Return to Text</a>
          </span>
          <span class="menuitem" id="siteitem">
            <a class="nav_link" id="apparatus">
              <xsl:attribute name="href"><xsl:value-of
                select="concat(//teiHeader/fileDesc/sourceDesc/msDesc/@xml:id,concat('_',//teiHeader/fileDesc/titleStmt/@xml:id),'_Editorial.html')"
              /></xsl:attribute>Editorial Apparatus</a></span>
        </xsl:when>
        <xsl:when test="name()='surface'">
          <span class="menuitem" id="siteitem">
            <a class="nav_link" id="description">
              <xsl:attribute name="href"><xsl:value-of
                select="concat(//teiHeader/fileDesc/sourceDesc/msDesc/@xml:id,concat('_',//teiHeader/fileDesc/titleStmt/@xml:id),'_description.html')"/></xsl:attribute>About this Manuscript</a></span>
          <span class="menuitem" id="siteitem">
            <a class="nav_link" id="apparatus">
              <xsl:attribute name="href"><xsl:value-of
                select="concat(//teiHeader/fileDesc/sourceDesc/msDesc/@xml:id,concat('_',//teiHeader/fileDesc/titleStmt/@xml:id),'_Editorial.html')"
              /></xsl:attribute>Editorial Apparatus</a></span>
        </xsl:when>
        <xsl:when test="name()='body'">
          <xsl:choose>
            <xsl:when
              test="not(//teiHeader/fileDesc/sourceDesc/msDesc)">
              <xsl:choose>
                <xsl:when test="@xml:id = 'include'">
                  <span class="menuitem" id="siteitem">
                    <a class="nav_link" id="description">
                      <xsl:attribute name="href"><xsl:value-of
                        select="concat(//teiHeader/fileDesc/sourceDesc/@n,'_description.html')"
                      /></xsl:attribute>About this Manuscript</a>
                  </span>
                  <span class="menuitem" id="siteitem">
                    <a class="nav_link" id="apparatus">
                      <xsl:attribute name="href"><xsl:value-of
                        select="concat(//teiHeader/fileDesc/sourceDesc/@n,'_apparatus.html')"
                      /></xsl:attribute>Editorial Apparatus</a>
                  </span>
                </xsl:when>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:choose>
                <xsl:when test="@xml:id = 'include'">
                  <span class="menuitem" id="siteitem">
                    <a class="nav_link" id="description">
                      <xsl:attribute name="href"><xsl:value-of
                        select="concat(//teiHeader/fileDesc/sourceDesc/msDesc/@xml:id,concat('_',//teiHeader/fileDesc/titleStmt/@xml:id),'_description.html')"
                      /></xsl:attribute>About this Manuscript</a>
                  </span>
                  <span class="menuitem" id="siteitem">
                    <a class="nav_link" id="apparatus">
                      <xsl:attribute name="href"><xsl:value-of
                        select="concat(//teiHeader/fileDesc/sourceDesc/msDesc/@xml:id,concat('_',//teiHeader/fileDesc/titleStmt/@xml:id),'_Editorial.html')"
                      /></xsl:attribute>Editorial Apparatus</a>
                  </span>
                </xsl:when>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="name()='msDesc/@xml:id'">
          <xsl:apply-templates/>
        </xsl:when>
      </xsl:choose>
      <span class="menuitem" id="siteitem">
        <a class="nav_link" href="../../contact.html">Contact</a>
      </span>
    </h1>
  </xsl:template>
  
  <xsl:variable name="dictAvail">
    <xsl:choose>
      <xsl:when test="doc-available($dictFile)">
        <xsl:value-of select="'yes'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'no'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="newline" select="'&#x0A;'"/>
  <xsl:variable name="bullet" select="' • '"/>
  <xsl:variable name="pipe" select="' | '"/>
  <xsl:template match="/">
    <xsl:if test="$debug = 'true'">
      <xsl:message>
        <xsl:value-of select="current-time()"/>
        <xsl:text> - D1001: Starting TEI Template</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="intermediate_TEI">
      <xsl:variable name="teiFile" select="document($P5source)"/>
      <TEI xmlns="http://www.tei-c.org/ns/1.0">
        <xsl:choose>
          <xsl:when test="$dictAvail = 'yes'">
            <xsl:copy-of select="document($dictFile)//teiHeader"/>
          </xsl:when>
          <xsl:otherwise>
            <teiHeader>
              <fileDesc>
                <titleStmt>
                  <title type="main">
                    Data Dictionary
                  </title>
                </titleStmt>
                <publicationStmt>
                  <p>This sample TEI file was created using the Data Dictionary Generator,
                    originally release by the River Campus Libraries, University of Rochester.</p>
                </publicationStmt>
                <sourceDesc>
                  <p>A description of your data dictionary goes here.</p>
                </sourceDesc>
              </fileDesc>
            </teiHeader>
          </xsl:otherwise>
        </xsl:choose>
        <text>
          <body>
            <!--Start working on the element list-->
            <xsl:for-each select="//*[generate-id(.) = generate-id(key('elements', name())[1])]">
              <xsl:sort select="name()"/>
              <xsl:variable name="elementName" select="name()"/>
              <xsl:if test="$debug = 'true'">
                <xsl:message>
                  <xsl:value-of select="current-time()"/>
                  <xsl:text> - Processing element </xsl:text>
                  <xsl:value-of select="$elementName"/>
                </xsl:message>
              </xsl:if>
              <xsl:variable name="teiGloss"
                select="$teiFile//elementSpec[@ident eq $elementName]/gloss[@xml:lang = 'en']"/>
              <xsl:variable name="teiDesc"
                select="$teiFile//elementSpec[@ident eq $elementName]/desc[@xml:lang = 'en']"/>
              <xsl:variable name="eleModuleName"
                select="$teiFile//elementSpec[@ident eq $elementName]/@module"/>
              <xsl:variable name="eleClassNames"
                select="$teiFile//elementSpec[@ident eq $elementName]/classes/memberOf/@key"/>
              <xsl:variable name="dictEntries"
                select="document($dictFile)//body/div[@corresp eq $elementName][@type = 'element']"/>
              <xsl:for-each select="key('elements', name())">
                <xsl:if test="position() = 1">
                  <!--For the elements in the dictionary, start grabbing metadata from the source document-->
                  <xsl:variable name="eleCount" select="count(//*[name() = name(current())])"/>
                  <xsl:variable name="eleContainedBy"
                    select="distinct-values(//*[name() = name(current())]/parent::*/name())"/>
                  <xsl:variable name="eleMayContain"
                    select="distinct-values(//*[name() = name(current())]/child::*/name())"/>
                  <xsl:variable name="eleAttributes"
                    select="distinct-values(//*[name() = name(current())]/@*/name())"/>

                  <!-- Build a div for each element -->
                  <div>
                    <xsl:attribute name="type" select="'element'"/>
                    <xsl:attribute name="corresp" select="$elementName"/>
                    <xsl:attribute name="xml:id">
                      <xsl:text>e.</xsl:text>
                      <xsl:value-of select="$elementName"/>
                    </xsl:attribute>
                    <!-- Grab the gloss (i.e., fuller name) for the element -->
                    <xsl:if test="$teiGloss != ''">
                      <ab>
                        <xsl:attribute name="type" select="'gloss'"/>
                        <xsl:value-of select="$teiGloss"/>
                      </ab>
                    </xsl:if>
                    <!-- Grab the module and class data, if requested -->
                    <xsl:if test="$displayModule = 'true'">
                      <ab>
                        <xsl:attribute name="type" select="'module'"/>
                        <xsl:value-of select="$eleModuleName"/>
                      </ab>
                      <ab>
                        <xsl:attribute name="type" select="'classes'"/>
                        <xsl:for-each select="$eleClassNames">
                          <seg>
                            <xsl:value-of select="."/>
                          </seg>
                        </xsl:for-each>
                      </ab>
                    </xsl:if>
                    <!-- Count how many times the element appears in the document -->
                    <ab>
                      <xsl:attribute name="type" select="'count'"/>
                      <xsl:value-of select="$eleCount"/>
                    </ab>
                    <xsl:if test="$eleContainedBy != ''">
                      <ab>
                        <xsl:attribute name="type" select="'parents'"/>
                        <xsl:for-each select="distinct-values($eleContainedBy)">
                          <seg>
                            <xsl:attribute name="ana">
                              <xsl:text>#</xsl:text>
                              <xsl:text>e.</xsl:text>
                              <xsl:value-of select="."/>
                            </xsl:attribute>
                            <xsl:value-of select="."/>
                          </seg>
                        </xsl:for-each>
                      </ab>
                    </xsl:if>
                    <xsl:if test="$eleMayContain != ''">
                      <ab>
                        <xsl:attribute name="type" select="'children'"/>
                        <xsl:value-of select="$newline"/>
                        <xsl:for-each select="distinct-values($eleMayContain)">
                          <seg>
                            <xsl:attribute name="ana">
                              <xsl:text>#</xsl:text>
                              <xsl:text>e.</xsl:text>
                              <xsl:value-of select="."/>
                            </xsl:attribute>
                            <xsl:value-of select="."/>
                          </seg>
                          <xsl:value-of select="$newline"/>
                        </xsl:for-each>
                      </ab>
                    </xsl:if>
                    <xsl:if test="$eleAttributes != ''">
                      <ab>
                        <xsl:attribute name="type" select="'attributes'"/>
                        <xsl:value-of select="$newline"/>
                        <xsl:for-each select="distinct-values($eleAttributes)">
                          <seg>
                            <xsl:attribute name="ana">
                              <xsl:text>#</xsl:text>
                              <xsl:text>a.</xsl:text>
                              <xsl:value-of select="."/>
                            </xsl:attribute>
                            <xsl:value-of select="."/>
                          </seg>
                          <xsl:value-of select="$newline"/>
                        </xsl:for-each>
                      </ab>
                    </xsl:if>
                    <!-- Insert the local definition -->
                    <xsl:if test="count($dictEntries) ge 1">
                      <div>
                        <xsl:attribute name="type" select="'entry'"/>
                        <xsl:attribute name="ana" select="'project'"/>
                        <xsl:copy-of select="$dictEntries/div[@type = 'entry']/child::node()"/>
                      </div>
                    </xsl:if>
                    <!-- Insert the definition from the TEI Guidelines -->
                    <xsl:if test="$teiDesc != ''">
                      <div>
                        <xsl:attribute name="type" select="'entry'"/>
                        <xsl:attribute name="ana" select="'tei'"/>
                        <span type="definition">
                          <xsl:attribute name="target">
                            <xsl:text>http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-</xsl:text>
                            <xsl:value-of select="$elementName"/>
                            <xsl:text>.html</xsl:text>
                          </xsl:attribute>
                          <xsl:value-of select="$teiDesc"/>
                        </span>
                      </div>
                    </xsl:if>
                  </div>
                </xsl:if>
              </xsl:for-each>

            </xsl:for-each>
            <!--Start working on the attribute list-->
            <xsl:for-each select="//@*[generate-id(.) = generate-id(key('attributes', name())[1])]">
              <xsl:sort select="name()"/>
              <xsl:variable name="attName" select="name()"/>
              <xsl:if test="$debug = 'true'">
                <xsl:message>
                  <xsl:value-of select="current-time()"/>
                  <xsl:text> - Processing attribute @</xsl:text>
                  <xsl:value-of select="$attName"/>
                </xsl:message>
              </xsl:if>
              <xsl:variable name="teiGloss"
                select="$teiFile//attDef[@ident eq $attName][1]/gloss[@xml:lang eq 'en']"/>
              <xsl:variable name="teiURL"
                select="document($dictFile)//body/div[@corresp eq $attName][@type eq 'attribute']/span[@type eq 'teiurl']"/>
              <xsl:variable name="teiAttDescSet"
                select="$teiFile//classSpec[descendant::attDef/@ident = $attName]"/>
              <xsl:variable name="attEntries"
                select="document($dictFile)//body/div[@corresp eq $attName][@type = 'attribute']"/>
              <xsl:variable name="attContents"
                select="document($dictFile)//body/div[@corresp eq $attName][@type eq 'attribute']//span[@type eq 'mayContain']"/>

              <xsl:for-each select="key('attributes', name())">
                <xsl:if test="position() = 1">

                  <!--For the attributes in the dictionary, start grabbing metadata from the source document-->
                  <xsl:variable name="attCount" select="count(//@*[name() = name(current())])"/>
                  <xsl:variable name="attContainedBy"
                    select="distinct-values(//@*[name() = name(current())]/parent::*/name())"/>
                  <xsl:variable name="attMayContain">
                    <xsl:choose>
                      <xsl:when test="$attContents != ''">
                        <xsl:value-of select="$attContents"/>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:value-of select="distinct-values(//@*[name() = name(current())])"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:variable>
                  <!-- Build a div for each attribute -->
                  <div>
                    <xsl:attribute name="type" select="'attribute'"/>
                    <xsl:attribute name="corresp" select="$attName"/>
                    <xsl:attribute name="xml:id">
                      <xsl:text>a.</xsl:text>
                      <xsl:value-of select="translate($attName, ':', '.')"/>
                    </xsl:attribute>
                    <xsl:if test="$teiGloss != ''">
                      <ab>
                        <xsl:attribute name="type" select="'gloss'"/>
                        <xsl:value-of select="$teiGloss"/>
                      </ab>
                    </xsl:if>
                    <!-- Count how many times the attribute appears in the document -->
                    <ab>
                      <xsl:attribute name="type" select="'count'"/>
                      <xsl:value-of select="$attCount"/>
                    </ab>
                    <xsl:if test="$attContainedBy != ''">
                      <ab>
                        <xsl:attribute name="type" select="'parents'"/>
                        <xsl:for-each select="distinct-values($attContainedBy)">
                          <seg>
                            <xsl:attribute name="ana">
                              <xsl:text>#</xsl:text>
                              <xsl:text>e.</xsl:text>
                              <xsl:value-of select="."/>
                            </xsl:attribute>
                            <xsl:value-of select="."/>
                          </seg>
                        </xsl:for-each>
                      </ab>
                    </xsl:if>
                    <xsl:if test="$attMayContain != ''">
                      <ab>
                        <xsl:attribute name="type" select="'children'"/>
                        <xsl:value-of select="$attMayContain"/>
                      </ab>
                    </xsl:if>

                    <xsl:if test="count($teiAttDescSet) ge 1">
                      <div>
                        <xsl:attribute name="type" select="'entry'"/>
                        <xsl:attribute name="ana" select="'tei'"/>
                        <xsl:for-each select="$teiAttDescSet">
                          <span>
                            <xsl:attribute name="type" select="'definition'"/>
                            <xsl:attribute name="target">
                              <xsl:text>http://www.tei-c.org/release/doc/tei-p5-doc/en/html/ref-</xsl:text>
                              <xsl:value-of select="@ident"/>
                              <xsl:text>.html</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of
                              select="attList/attDef[@ident = $attName]/desc[@xml:lang = 'en']"/>
                            <xsl:if test="@ident != ''">
                              <ident>
                                <xsl:value-of select="@ident"/>
                              </ident>
                            </xsl:if>
                          </span>
                        </xsl:for-each>
                      </div>
                    </xsl:if>
                    <xsl:if test="$attEntries != ''">
                      <div>
                        <xsl:attribute name="type" select="'entry'"/>
                        <xsl:attribute name="ana" select="'project'"/>
                        <xsl:copy-of select="$attEntries/div[@type = 'entry']/child::node()"/>
                      </div>
                    </xsl:if>
                  </div>
                </xsl:if>
              </xsl:for-each>

            </xsl:for-each>

          </body>
        </text>
      </TEI>
    </xsl:variable>
    <xsl:if test="$outputFormat = 'tei'">
      <xsl:result-document href="{$teiOutPath}">
        <xsl:copy-of select="$intermediate_TEI"/>
      </xsl:result-document>
    </xsl:if>
    <xsl:apply-templates select="$intermediate_TEI" mode="TEI2HTML"/>
  </xsl:template>
  
  <xsl:template name="head">
    <head>
      <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
      <meta name="viewport" content="initial-scale=1"/>
      <xsl:choose>
        <xsl:when test="name()='handNote'">
          <title>
            <xsl:value-of
              select="normalize-space(concat($full_title,' - Editorial Notes'))"/>
          </title>
        </xsl:when>
        <xsl:when test="name()='body'">
          <title>
            <xsl:value-of select="normalize-space($archive_title)"/>
          </title>
        </xsl:when>
        <xsl:otherwise>
          <title>
            <xsl:value-of select="normalize-space(concat($full_title,' - Data Dictionary'))"/>
          </title>
        </xsl:otherwise>
      </xsl:choose>
      <meta name="author">
        <xsl:attribute name="content">
          <xsl:value-of select="$author_name"/>
        </xsl:attribute>
      </meta>
      <meta name="editor">
        <xsl:attribute name="content">
          <xsl:value-of select="$editor_name"/>
        </xsl:attribute>
      </meta>
      <meta>
        <xsl:attribute name="generator">
          <xsl:value-of
            select="normalize-space('Custom Stylesheet based on Text Encoding Initiative
            Consortium XSLT stylesheets')"
          />
        </xsl:attribute>
      </meta>
      <meta>
        <xsl:attribute name="DC.Title">
          <xsl:choose>
            <xsl:when test="name()='handNote'">
              <xsl:value-of
                select="normalize-space(concat($full_title,' - Scribal Notes'))"/>
            </xsl:when>
            <xsl:when test="name()='body'">
              <xsl:value-of select="normalize-space($archive_title)"/>
            </xsl:when>
            <xsl:when test="sourceDesc/@n">
              <xsl:value-of
                select="normalize-space(concat($full_title,' - Editorial Apparatus'))"
              />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="normalize-space(concat($full_title,' - Data Dictionary'))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </meta>
      <meta name="DC.Type" content="Text"/>
      <meta name="DC.Format" content="text/html"/>
      <link>
        <xsl:attribute name="href">../../../tei-modified.css</xsl:attribute>
        <!--<xsl:attribute name="href">../../tei-modified-new.css</xsl:attribute>-->
        <xsl:attribute name="rel">stylesheet</xsl:attribute>
        <xsl:attribute name="type">text/css</xsl:attribute>
      </link>
      <script>
        <xsl:attribute name="src">../../../javascript/OpenLayers.js</xsl:attribute></script>
      <!--<script>
                <xsl:attribute name="src">../../javascript/djatoka-viewer.js</xsl:attribute>
            </script>-->
      <script>
        <xsl:attribute name="src">../../../javascript/custom-functions.js</xsl:attribute>
      </script>
      <script>
        <xsl:attribute name="src">../../../javascript/jquery-2.1.4.min.js</xsl:attribute>
      </script>
      <script>
        <xsl:attribute name="src">../../../javascript/featherlight/release/featherlight.min.js</xsl:attribute>
      </script>
      <script>
        <xsl:attribute name="src">../../../mirador/build/mirador/mirador.js</xsl:attribute>
      </script>
    </head>
  </xsl:template>
  
  <xsl:template name="bannerChoice">
    <xsl:choose>
      <xsl:when
        test="../../..//teiHeader/fileDesc/sourceDesc/@xml:id = 'index.html'">
        <img src="/Images/Lydgate_banner.png">
          <xsl:attribute name="id">banner</xsl:attribute>
        </img>
      </xsl:when>
      <xsl:otherwise>
        <img src="/Images/Lydgate_interior.png">
          <xsl:attribute name="id">interiorBanner</xsl:attribute>
        </img>
        <xsl:choose>
          <!--RETHINK THIS.  CREATE A TEMPLATE THAT GENERATES THE TITLE BASED ON WHERE THE LINK IS COMING FROM, RATHER THAN WHAT IS IN THE XML -->
          <xsl:when test="name() = 'surface'">
            <span class="titleText"><em><xsl:value-of
              select="normalize-space(//teiHeader/fileDesc/titleStmt/title/title[@type='main'])"
            /></em>: <xsl:value-of
              select="normalize-space(//teiHeader/fileDesc/titleStmt/title/title[@type='sub'])"
            />
            </span>
          </xsl:when>
          <xsl:when test="name() = 'fileDesc'">
            <span class="titleText"><em><xsl:value-of
              select="normalize-space(//teiHeader/fileDesc/titleStmt/title/title[@type='main'])"
            /></em>: <xsl:value-of
              select="normalize-space(//teiHeader/fileDesc/titleStmt/title/title[@type='sub'])"
            />
            </span>
          </xsl:when>
          <xsl:when test="name() = 'handNote'">
            <span class="titleText"><xsl:value-of
              select="normalize-space(//teiHeader/fileDesc/titleStmt/title/title[@type='sub'])"
            />: Scribal Notes</span>
          </xsl:when>
          
          <xsl:when test="name() = 'body'">
            <span class="titleText"><xsl:value-of
              select="normalize-space(//teiHeader/fileDesc/titleStmt/title)"
            /></span>
          </xsl:when>
          
          <xsl:when test="sourceDesc/@n">
            <span class="titleText"><xsl:value-of
              select="normalize-space(//teiHeader/fileDesc/titleStmt/title/title[@type='sub'])"
            />: Editorial Apparatus</span>
          </xsl:when>
          
          <xsl:otherwise>
            <span class="titleText"><em><xsl:value-of
              select="normalize-space(//teiHeader/fileDesc/titleStmt/title/title[@type='main'])"
            /></em>: <xsl:value-of
              select="normalize-space(concat(//teiHeader/fileDesc/titleStmt/title/title[@type='sub'], ' - Data Dictionary'))"
            />
            </span>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="footer">
    <div class="footer">
      <xsl:apply-templates select="//teiHeader/fileDesc/publicationStmt/availability"/>
    </div>
  </xsl:template>

  <xsl:template name="makeNotes">
    <xsl:variable name="num" select="count(.//note)"/>
    <xsl:choose>
      <xsl:when test=".//note">
        <div class="notes">
          <div class="noteHeading">Notes</div>
          <ol>
            <xsl:for-each select=".//note">
              <xsl:choose>
                <xsl:when test="@n='dummy'"/>
                <xsl:otherwise>
                  <div class="note">
                    <li>
                      <xsl:attribute name="id">
                        <xsl:value-of select="concat('fn',position())"/>
                      </xsl:attribute>
                      <xsl:attribute name="class">
                        <xsl:choose>
                          <xsl:when test="@xml:id ='explanatory'">
                            <xsl:text>explanatory</xsl:text>
                          </xsl:when>
                          <xsl:when test="@xml:id ='informational'">
                            <xsl:text>informational</xsl:text>
                          </xsl:when>
                          <xsl:otherwise>
                            <xsl:text>other</xsl:text>
                          </xsl:otherwise>
                        </xsl:choose>
                      </xsl:attribute>
                      <div class="noteBody">
                        <xsl:apply-templates/>
                        <a>
                          <xsl:attribute name="href"><xsl:value-of
                            select="concat('#fn',position())"
                          />-ref</xsl:attribute>
                          <xsl:attribute name="title">return to
                            text</xsl:attribute> &#8617; </a>
                      </div>
                    </li>
                  </div>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </ol>
        </div>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="/" mode="TEI2HTML">
    <html xmlns="http://www.w3.org/1999/xhtml" xmlns:idhmc="http://idhmc.tamu.edu/"
      xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
      xml:lang="en">
      <xsl:call-template name="head"/>
      <body>
        <xsl:attribute name="class">simple</xsl:attribute>
        <xsl:attribute name="id">TOP</xsl:attribute>
        <script>
          <xsl:attribute name="async"/>
          <xsl:attribute name="defer"/>
          <xsl:attribute name="src">https://hypothes.is/embed.js</xsl:attribute>
        </script>
        <script src="https://cdn.rawgit.com/google/code-prettify/master/loader/run_prettify.js"></script>
        <div id="wrapper">
          <div>
            <xsl:attribute name="class">stdheader</xsl:attribute>
            <h1>
              <xsl:attribute name="class">maintitle</xsl:attribute>
              <xsl:attribute name="id">noText</xsl:attribute>
              <xsl:call-template name="bannerChoice"/>
            </h1>
            <xsl:call-template name="siteHeader"/>
          </div>
          <div class="surface">
            <xsl:attribute name="id">noText</xsl:attribute>
          <div class="tagline">
            <xsl:value-of select="//sourceDesc/p[1]"/>
            <br/>
            <xsl:text>Last updated: </xsl:text>
            <xsl:value-of select="format-date(current-date(), '[MNn] [D1], [Y1]')"/>
          </div>
        
        <div class="body">
          <xsl:variable name="eListCount"
            select="count(distinct-values(//div[@type = 'element']/@corresp))"/>
          <xsl:variable name="eListColQuant" select="round(($eListCount div 3))"/>
          <xsl:variable name="eListColTwo" select="$eListColQuant * 2"/>

          <div class="columns">
            <div class="red">
              <xsl:variable name="elementList"
                select="distinct-values(//div[@type = 'element']/@corresp)"/>
              <ul>
                <xsl:for-each select="$elementList">
                  <xsl:if test="position() lt ($eListColQuant + 1)">
                    <li>
                      <a>
                        <xsl:attribute name="href">
                          <xsl:text>#e.</xsl:text>
                          <xsl:value-of select="."/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                      </a>
                    </li>
                  </xsl:if>
                  <xsl:text> </xsl:text>
                </xsl:for-each>
              </ul>
            </div>
            <div class="grey">
              <xsl:variable name="elementList"
                select="distinct-values(//div[@type = 'element']/@corresp)"/>
              <ul>
                <xsl:for-each select="$elementList">
                  <xsl:if
                    test="(position() gt $eListColQuant) and (position() lt ($eListCount - $eListColQuant + 1))">
                    <li>
                      <a>
                        <xsl:attribute name="href">
                          <xsl:text>#e.</xsl:text>
                          <xsl:value-of select="."/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                      </a>
                    </li>
                  </xsl:if>
                  <xsl:text> </xsl:text>
                </xsl:for-each>
              </ul>
            </div>
            <div class="red">
              <xsl:variable name="elementList"
                select="distinct-values(//div[@type = 'element']/@corresp)"/>
              <ul>
                <xsl:for-each select="$elementList">
                  <xsl:if test="position() gt ($eListCount - $eListColQuant)">
                    <li>
                      <a>
                        <xsl:attribute name="href">
                          <xsl:text>#e.</xsl:text>
                          <xsl:value-of select="."/>
                        </xsl:attribute>
                        <xsl:value-of select="."/>
                      </a>
                    </li>
                  </xsl:if>
                  <xsl:text> </xsl:text>
                </xsl:for-each>
              </ul>
            </div>
            <div class="grey">
              <xsl:variable name="attributeList"
                select="distinct-values(//div[@type = 'attribute']/@corresp)"/>
              <ul>
                <xsl:for-each select="$attributeList">
                  <li>
                    <a>
                      <xsl:attribute name="class" select="'attributeTOCLink'"/>
                      <xsl:attribute name="href">
                        <xsl:text>#a.</xsl:text>
                        <xsl:value-of select="."/>
                      </xsl:attribute>
                      <xsl:text>@</xsl:text>
                      <xsl:value-of select="."/>
                    </a>
                  </li>
                  <xsl:text> </xsl:text>
                </xsl:for-each>
              </ul>
            </div>
          </div>
          <div class="clear"/>
          <xsl:apply-templates select="//div[@type = 'element']" mode="TEI2HTML"/>
          <hr/>
          <xsl:apply-templates select="//div[@type = 'attribute']" mode="TEI2HTML"/>
        </div>
        <div>
          <a href="#" class="go-top">Back to top</a>
        </div>
          </div>
          <xsl:call-template name="footer"/>  
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="div" mode="TEI2HTML">
    <div class="entry">
      <xsl:attribute name="id">
        <xsl:if test="@type = 'element'">
          <xsl:text>e.</xsl:text>
        </xsl:if>
        <xsl:if test="@type = 'attribute'">
          <xsl:text>a.</xsl:text>
        </xsl:if>
        <xsl:value-of select="@corresp"/>
      </xsl:attribute>

      <div class="header">
        <span class="name">
          <xsl:if test="@type eq 'attribute'">
            <xsl:text>@</xsl:text>
          </xsl:if>
          <xsl:value-of select="@corresp"/>
        </span>
        <xsl:if test="ab[@type eq 'gloss']">
          <span class="gloss">
            <span class="divider">
              <xsl:value-of select="$pipe"/>
            </span>
            <xsl:value-of select="ab[@type = 'gloss']"/>
          </span>
        </xsl:if>
        <xsl:if test="ab[@type eq 'count']">
          <span class="count">
            <xsl:value-of select="ab[@type = 'count']"/>
          </span>
        </xsl:if>
      </div>
      <div class="descriptions">
        <xsl:apply-templates select="div[@ana = 'tei']" mode="TEI2HTML"/>
        <xsl:apply-templates select="div[@ana = 'project']" mode="TEI2HTML"/>
      </div>
      <div class="context">
        <xsl:apply-templates select="ab[@type = 'attributes']" mode="TEI2HTML"/>
        <xsl:apply-templates select="ab[@type = 'parents']" mode="TEI2HTML"/>
        <xsl:apply-templates select="ab[@type = 'children']" mode="TEI2HTML"/>
      </div>

    </div>
  </xsl:template>

  <xsl:template match="div[@ana = 'project']" mode="TEI2HTML">
    <div>
      <span class="label">Project: </span>
      <span class="local_description">
        <xsl:for-each select="span[@type = 'definition']">
          <xsl:apply-templates/>
          <xsl:if test="position() lt last()">
            <xsl:value-of select="$bullet"/>
          </xsl:if>
        </xsl:for-each>
        <xsl:if test="span[@type = 'usage']">
          <span class="usage_label">
            <xsl:text> Usage: </xsl:text>
          </span>
          <span class="usage">
            <xsl:for-each select="span[@type = 'usage']">
              <xsl:apply-templates/>
              <xsl:choose>
                <xsl:when test="position() != last()">
                  <xsl:value-of select="$bullet"/>
                </xsl:when>
              </xsl:choose>
            </xsl:for-each>
          </span>
        </xsl:if>
        <xsl:if test="span[@type = 'seeAlso']">
          <span class="see_also_label">
            <xsl:text> See also: </xsl:text>
          </span>
          <span class="see_also">
            <xsl:for-each select="span[@type = 'seeAlso']/*">
              <a>
                <xsl:attribute name="href">
                  <xsl:if test="./name() eq 'gi'">
                    <xsl:text>#e.</xsl:text>
                  </xsl:if>
                  <xsl:if test="./name() eq 'att'">
                    <xsl:text>#a.</xsl:text>
                  </xsl:if>
                  <xsl:value-of select="."/>
                </xsl:attribute>
                <xsl:if test="./name() eq 'att'">
                  <xsl:text>@</xsl:text>
                </xsl:if>
                <xsl:value-of select="."/>
              </a>
              <xsl:choose>
                <xsl:when test="position() != last()">
                  <xsl:text>, </xsl:text>
                </xsl:when>
              </xsl:choose>
            </xsl:for-each>
          </span>
        </xsl:if>
      </span>
      <div class="examples">
        <xsl:if test="teix:egXML">
          <span class="label">Example(s): </span>
        </xsl:if>
        <xsl:apply-templates select="teix:egXML"/>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="ref">
    <a>
      <xsl:attribute name="href" select="@target"/>
      <xsl:attribute name="target" select="'_blank'"/>
      <xsl:apply-templates/>
    </a>
  </xsl:template>


  <xsl:template match="div[@ana = 'tei']" mode="TEI2HTML">
    <div>
      <span class="label">P5 Guidelines: </span>
      <span class="tei_description">
        <xsl:for-each select="span[@type = 'definition']">
          <xsl:apply-templates mode="TEI2HTML"/>
          <xsl:text> </xsl:text>
          <a>
            <xsl:attribute name="target" select="'_blank'"/>
            <xsl:attribute name="href" select="@target"/>
            <xsl:text>[more]</xsl:text>
          </a>
          <xsl:if test="position() lt last()">
            <xsl:value-of select="$bullet"/>
          </xsl:if>
          <xsl:if test="$displayModule = 'true'">
            <xsl:text> Module: </xsl:text>
            <xsl:value-of select="preceding-sibling::ab[@type = 'module'][1]"/>
            <xsl:text> Class(es): </xsl:text>
            <xsl:value-of select="preceding-sibling::ab[@type = 'classes'][1]/seg"/>
          </xsl:if>
        </xsl:for-each>
      </span>
    </div>
  </xsl:template>

  <xsl:template match="
      ab[@type = ('gloss',
      'count')]" mode="TEI2HTML"/>

  <xsl:template match="
      ab[@type = ('parents',
      'children')]" mode="TEI2HTML">
    <div>
      <xsl:attribute name="class">
        <xsl:if test="@type = 'parents'">
          <xsl:value-of select="'parents'"/>
        </xsl:if>
        <xsl:if test="@type = 'children'">
          <xsl:value-of select="'children'"/>
        </xsl:if>
      </xsl:attribute>
      <xsl:if test="@type = 'parents'">
        <span class="label">Contained by: </span>
      </xsl:if>
      <xsl:if test="@type = 'children'">
        <span class="label">May contain: </span>
      </xsl:if>
      <ul>
        <xsl:choose>
          <xsl:when test="(@type = 'children') and (parent::div[@type = 'attribute'])">
            <li>
              <xsl:value-of select="."/>
            </li>
          </xsl:when>
          <xsl:otherwise>
            <xsl:for-each select="seg">
              <li>
                <a>
                  <xsl:attribute name="href" select="@ana"/>
                  <xsl:attribute name="target" select="'_self'"/>
                  <xsl:value-of select="."/>
                </a>
              </li>
            </xsl:for-each>
          </xsl:otherwise>
        </xsl:choose>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="ab[@type = 'attributes']" mode="TEI2HTML">
    <div class="attributes">
      <span class="label">Attributes: </span>
      <ul>
        <xsl:for-each select="seg">
          <li>
            <a>
              <xsl:attribute name="href" select="@ana"/>
              <xsl:attribute name="target" select="'_self'"/>
              <xsl:text>@</xsl:text>
              <xsl:value-of select="."/>
            </a>
          </li>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>

  <xsl:template match="gi">
    <span class="giTag">
      <xsl:text>&lt;</xsl:text>
      <xsl:apply-templates mode="TEI2HTML"/>
      <xsl:text>&gt;</xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="att">
    <span class="attTag">
      <xsl:text>@</xsl:text>
      <xsl:apply-templates mode="TEI2HTML"/>
    </span>
  </xsl:template>

  <!-- Handling of <egXML> elements in the TEI example namespace. -->
  <xsl:template match="teix:egXML">
    <pre class="teiCode">
      <xsl:apply-templates mode="TEI2HTML"/>
    </pre>
  </xsl:template>

  <!-- Escaping all tags and attributes within the teix (examples) namespace except for the containing egXML. -->
  <xsl:template match="teix:*[not(self::teix:egXML)]" mode="TEI2HTML">
    <!-- Indent based on the number of ancestor elements. -->
    <xsl:variable name="indent">
      <xsl:for-each select="ancestor::teix:*">
        <xsl:text/>
      </xsl:for-each>
    </xsl:variable>
    <!-- Indent before every opening tag if not inside a paragraph. -->
    <xsl:if test="not(ancestor::teix:p)">
      <xsl:value-of select="$indent"/>
    </xsl:if>
    <!-- Opening tag, including any attributes. -->
    <xsl:if test=".[text()]">
      <span class="xmlTag">&lt;<xsl:value-of select="name()"/></span>
      <xsl:for-each select="@*">
        <span class="xmlAttName">
          <xsl:text> </xsl:text>
          <xsl:value-of select="name()"/>=</span>
        <span class="xmlAttVal">"<xsl:value-of select="."/>"</span>
      </xsl:for-each>
      <span class="xmlTag">&gt;</span>
      <!-- Return before processing content, if not inside a p. -->
      <xsl:if test="not(ancestor::teix:p)">
        <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:apply-templates select="* | text() | comment()" mode="TEI2HTML"/>
      <!-- Closing tag, following indent if not in a p. -->
      <xsl:if test="not(ancestor::teix:p)">
        <xsl:value-of select="$indent"/>
      </xsl:if>
      <span class="xmlTag">&lt;/<xsl:value-of select="local-name()"/>&gt;</span>
      <!-- Return after closing tag, if not in a p. -->
      <xsl:if test="not(ancestor::teix:p)">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:if>
    <!-- Process Empty Elements Differently -->
    <xsl:if test=".[not(text())]">
      <span class="xmlTag">&lt;<xsl:value-of select="name()"/></span>
      <xsl:for-each select="@*">
        <span class="xmlAttName">
          <xsl:text> </xsl:text>
          <xsl:value-of select="name()"/>=</span>
        <span class="xmlAttVal">"<xsl:value-of select="."/>"</span>
      </xsl:for-each>
      <xsl:apply-templates select="* | text() | comment()" mode="TEI2HTML"/>
      <!-- Closing tag, following indent if not in a p. -->
      <xsl:if test="not(ancestor::teix:p)">
        <xsl:value-of select="$indent"/>
      </xsl:if>
      <span class="xmlTag">/&gt;</span>
      <!-- Return after closing tag, if not in a p. -->
      <xsl:if test="not(ancestor::teix:p)">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <!-- For good-looking tree output, we need to include a return after any text content, assuming we're not inside a paragraph tag. -->
  <xsl:template match="teix:*/text()" mode="TEI2HTML">
    <xsl:if test="not(ancestor::teix:p)">
      <xsl:for-each select="ancestor::teix:*">
        <xsl:text/>
      </xsl:for-each>
    </xsl:if>
    <xsl:value-of select="replace(., '&amp;', '&amp;amp;')"/>
    <xsl:if test="not(ancestor::teix:p) or not(following-sibling::* or following-sibling::text())">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
