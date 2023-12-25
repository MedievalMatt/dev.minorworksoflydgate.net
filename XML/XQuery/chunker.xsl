<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:a="http://relaxng.org/ns/compatibility/annotations/1.0"
    xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:rng="http://relaxng.org/ns/structure/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:teix="http://www.tei-c.org/ns/Examples"
    xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:functx="http://www.functx.com" exclude-result-prefixes="#default html a fo rng tei teix"
    version="2.0">
    <xsl:import href="../XQuery/Stylesheets-dev/html/html.xsl"/>
    <xsl:strip-space elements="*"/>
    <xsl:preserve-space elements="tei:ex tei:hi tei:code tei:gap tei:line"/>

    <xsl:function name="functx:left-trim" as="xs:string" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>

        <xsl:sequence select="
                replace($arg, '^\s+', '')
                "/>

    </xsl:function>

    <xsl:function name="functx:right-trim" as="xs:string" xmlns:functx="http://www.functx.com">
        <xsl:param name="arg" as="xs:string?"/>

        <xsl:sequence select="
                replace($arg, '\s+$', '')
                "/>

    </xsl:function>


    <xsl:template match="node() | @*">
        <xsl:copy>
            <xsl:apply-templates select="@*[name() != 'part'] | node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="string-replace-all">
        <xsl:param name="text"/>
        <xsl:param name="replace"/>
        <xsl:param name="by"/>
        <xsl:choose>
            <xsl:when test="contains($text, $replace)">
                <xsl:value-of select="substring-before($text, $replace)"/>
                <xsl:value-of select="$by"/>
                <xsl:call-template name="string-replace-all">
                    <xsl:with-param name="text" select="substring-after($text, $replace)"/>
                    <xsl:with-param name="replace" select="$replace"/>
                    <xsl:with-param name="by" select="$by"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:damage[preceding-sibling::tei:damage]">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>

    <xsl:template match="tei:note[preceding-sibling::*[position() = 1][name() = 'damage']]">
        <xsl:variable name="num">
            <xsl:choose>
                <xsl:when test=".//body">
                    <xsl:number count="tei:note" level="any" from="tei:body"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:number count="tei:note" level="any" from="tei:surface"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="span">
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="@n = 'explanatory'">
                        <xsl:text>footnote explanatory</xsl:text>
                    </xsl:when>
                    <xsl:when test="@n = 'informational'">
                        <xsl:text>footnote informational</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>footnote other</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:element name="sup">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat('#fn', $num)"/>
                    </xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="concat('fn', $num)"
                        />-ref</xsl:attribute>
                    <xsl:attribute name="title">link to footnote <xsl:value-of select="$num"
                        /></xsl:attribute>
                    <xsl:value-of select="$num"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:code">

        <xsl:choose>
            <xsl:when test="@n = 'multiline'">
                <pre><code>
                    <xsl:attribute name="class">
                        <xsl:value-of select="@xml:id"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </code></pre>
            </xsl:when>
            <xsl:otherwise>
                <code>
                    <xsl:attribute name="class">
                        <xsl:value-of select="@xml:id"/>
                    </xsl:attribute>
                    <xsl:apply-templates/>
                </code>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="tei:l">
        <div class="verse">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <!-- Mirador info -->

    <xsl:variable name="mirador_base_clopton" select="'http://167.172.119.13/manifests/Lydgate/'"/>
    <xsl:variable name="mirador_base_harley" select="'http://167.172.119.13/manifests/Lydgate/'"/>
    <xsl:variable name="mirador_base_trinity" select="'http://167.172.119.13/manifests/Lydgate/'"/>

    <!-- folder variables for proper placement of image and text files -->
    <xsl:variable name="full_image_folder" select="'Images'"/>
    <xsl:variable name="thumbnail_folder" select="'Thumbnails'"/>
    <xsl:variable name="witness"
        select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/@xml:id)"/>
    <xsl:variable name="title_folder"
        select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id)"/>

    <xsl:decimal-format name="us" decimal-separator="." grouping-separator=","/>
    <xsl:variable name="maxReferences" select="4"/>
    <!-- <xsl:variable name="archive_title"
        select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"/> -->
    <!--  <xsl:variable name="archive_title"
        select="normalize-space(concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt//tei:title[@type = 'full']/tei:title[@type = 'main'], ': ', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'sub']))"/>
    <xsl:variable name="full_title"
        select="normalize-space(concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'full']/tei:title[@type = 'main'], ': ', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'sub']))"
        /> -->

    <xsl:variable name="full_title">
        <xsl:call-template name="GetFullTitle"/>
    </xsl:variable>

    <xsl:variable name="archive_title">
        <xsl:call-template name="GetArchiveTitle"/>
    </xsl:variable>

    <xsl:template name="GetFullTitle">
        <xsl:choose>
            <xsl:when
                test="tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'full']">
                <xsl:value-of
                    select="normalize-space(concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'full']/tei:title[@type = 'main'], ': ', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'sub']))"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'main'])"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="GetArchiveTitle">
        <xsl:choose>
            <xsl:when
                test="tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt//tei:title[@type = 'full']">
                <xsl:value-of
                    select="normalize-space(concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt//tei:title[@type = 'full']/tei:title[@type = 'main'], ': ', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'sub']))"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'main'])"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:variable name="next_page"/>
    <xsl:variable name="prev_page"/>
    <xsl:variable name="author_name"
        select="normalize-space(concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName/tei:forename[@sort = '1'], ' ', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName/tei:forename[@sort = '2'], ' ', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName/tei:surname))"/>
    <xsl:variable name="editor_name"
        select="normalize-space(concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor/tei:persName/tei:forename[@sort = '1'], ' ', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor/tei:persName/tei:forename[@sort = '2'], ' ', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:editor/tei:persName/tei:surname))"/>
    <xsl:variable name="roleDate"
        select="normalize-space(concat(self::text(), ', ', ../tei:date[@type = 'year']))"/>
    <xsl:variable name="XMLFileName" select="concat('../../XML/', $title_folder, '/', $fileName)"/>

    <xsl:variable name="fileName">
        <xsl:call-template name="GetFileName">
            <xsl:with-param name="path"
                select="concat(tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/@xml:id, concat('_', tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id), '.xml')"
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

    <xsl:template match="tei:msDesc">
        <xsl:apply-templates select="tei:msIdentifier"/>
        <xsl:apply-templates select="tei:history"/>
        <xsl:apply-templates select="tei:msContents"/>
        <xsl:apply-templates select="tei:physDesc"/>


    </xsl:template>

    <xsl:template match="tei:titleStmt"/>
    <xsl:template match="tei:publicationStmt">
        <xsl:comment>PUBLICATION STATEMENT</xsl:comment>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:profileDesc"/>

    <xsl:template match="tei:fileDesc">
        <!--<xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type='sub']/@ref"/>-->
        <xsl:result-document href="{concat($witness,'_',$title_folder,'_description.html')}"
            method="html">
            <html xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xi="http://www.w3.org/2001/XInclude" xml:lang="en">
                <xsl:call-template name="head"/>
                <body>
                    <xsl:attribute name="class">simple</xsl:attribute>
                    <xsl:attribute name="id">TOP</xsl:attribute>
                    <!--<script>
                        <xsl:attribute name="async"/>
                        <xsl:attribute name="defer"/>
                        <xsl:attribute name="src">https://hypothes.is/embed.js</xsl:attribute>
                    </script>-->
                    <div id="wrapper">
                        <div>
                            <xsl:attribute name="class">header col-10 col-s-10</xsl:attribute>
                            <h1>
                                <xsl:attribute name="id">mainTitle</xsl:attribute>
                                <xsl:call-template name="bannerChoice"/>
                            </h1>
                            <xsl:call-template name="siteHeader"/>
                        </div>
                        <div class="surface">
                            <xsl:attribute name="class">administrative paratext</xsl:attribute>
                            <xsl:apply-templates/>
                        </div>
                        <xsl:call-template name="makeNotes"/>
                        <xsl:call-template name="footer"/>
                    </div>
                </body>
                <script>adjustPageHeight();</script>
                <xsl:comment>
                <xsl:value-of select="name()"/>
            </xsl:comment>
            </html>
        </xsl:result-document>
    </xsl:template>

    <xsl:template match="tei:history">
        <div class="description_category" id="history">
            <h3 class="subheader" id="description_intro">Introduction</h3>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:physDesc">
        <div class="description_category" id="physical_description">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:objectDesc">
        <div class="description_category" id="physical_structure">
            <h3>Physical Structure</h3>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:support">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:layout">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:material"/>

    <xsl:template match="tei:decoDesc"/>

    <xsl:template match="tei:sourceDesc[1]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:sourceDesc"/>

    <xsl:template match="tei:supportDesc">
        <div class="description_subcategory" id="support">
            <h3 class="subheader">Support</h3>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:layoutDesc">
        <div class="description_subcategory" id="layout">
            <h3 class="subheader">Layout</h3>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:handDesc">
        <div class="description_category" id="hands">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:handNote">
        <xsl:apply-templates/>
    </xsl:template>



    <xsl:template match="tei:msIdentifier">
        <h2 id="paratext_title">
            <xsl:value-of select="concat(tei:settlement, ', ', tei:institution, ' ', tei:idno)"/>
        </h2>
    </xsl:template>

    <xsl:template match="tei:msContents">
        <div class="description_category" id="manuscript_contents">
            <h3 class="subheader">Manuscript Contents</h3>
            <ul>
                <xsl:apply-templates/>
            </ul>
            <xsl:choose>
                <xsl:when test="tei:p">
                    <div class="description_category" id="manuscript_contents">
                        <h3>Manuscript Referenced</h3>
                        <xsl:apply-templates/>
                    </div>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template match="tei:msItem">
        <xsl:variable name="classification" select="@n"/>
        <xsl:choose>
            <xsl:when test="position() = 1">
                <li>
                    <xsl:value-of select="@n"/>
                    <ul>
                        <xsl:for-each select="../tei:msItem[@n = $classification]/tei:p">
                            <li>
                                <xsl:apply-templates/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </li>
            </xsl:when>
            <xsl:when test="preceding-sibling::*[1]/@n != @n">
                <li>
                    <xsl:value-of select="@n"/>
                    <ul>
                        <xsl:for-each select="../tei:msItem[@n = $classification]/tei:p">
                            <li>
                                <xsl:apply-templates/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </li>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:msItem/tei:p">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template name="single_wrapper_image_filename">
        <xsl:text>display_image('</xsl:text>
        <xsl:value-of
            select="concat($title_folder, '/', $witness, '/', $full_image_folder, '/', tei:graphic/@url)"/>
        <xsl:text>')</xsl:text>
    </xsl:template>

    <xsl:template name="mirador_manifest_constructor">
        <!--<xsl:value-of select="concat('TORA TORA TORA ', ../../../../tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:availability/@xml:id)"/>-->
        <xsl:choose>
            <xsl:when
                test="../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Clopton_Chantry_Chapel'">
                <xsl:choose>
                    <xsl:when
                        test="../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Testament'">
                        <xsl:text>http://167.172.119.13/manifests/Lydgate/Testament/clopton.json</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Quis_Dabit'">
                        <xsl:text>http://167.172.119.13/manifests/Lydgate/Quis_Dabit/clopton.json</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'British_Library_Harley_2251'">

                <xsl:choose>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Testament'">
                        <xsl:text>http://167.172.119.13/manifests/Lydgate/Testament/Harley_2251.json</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Quis_Dabit'">
                        <xsl:text>http://167.172.119.13/manifests/Lydgate/Quis_Dabit/Harley_2251.json</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'British_Library_Harley_2255'">
                <xsl:choose>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Testament'">
                        <xsl:text>http://167.172.119.13/manifests/Lydgate/Testament/Harley_2255.json</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Quis_Dabit'">
                        <xsl:text>http://167.172.119.13/manifests/Lydgate/Quis_Dabit/Harley_2255.json</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Trinity_R_3_20'">
                        <xsl:text>https://mss-cat.trin.cam.ac.uk/Manuscript/R.3.20/manifest.json</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="mirador_canvas_constructor">
        <xsl:choose>
            <xsl:when
                test="../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Clopton_Chantry_Chapel'">
                <xsl:choose>
                    <xsl:when
                        test="../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Testament'">
                        <xsl:text>http://167.172.119.13/manifests/Lydgate/Testament/Clopton/canvas/</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Quis_Dabit'">
                        <xsl:text>http://167.172.119.13/manifests/Lydgate/Quis_Dabit/Clopton/canvas/</xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'British_Library_Harley_2251'">
                <xsl:choose>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Testament'">
                        <xsl:text>http://167.172.119.13/manifests/Lydgate/Testament/British_Library_Harley_2251/canvas/</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Quis_Dabit'">
                        <xsl:text>http://167.172.119.13/manifests/Lydgate/Quis_Dabit/British_Library_Harley_2251/canvas/</xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'British_Library_Harley_2255'">
                <xsl:choose>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Testament'">
                        <xsl:text>http://167.172.119.13/manifests/Lydgate/Testament/British_Library_Harley_2255/canvas/</xsl:text>
                    </xsl:when>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Quis_Dabit'">
                        <xsl:text>http://167.172.119.13/manifests/Lydgate/Quis_Dabit/British_Library_Harley_2255/canvas/</xsl:text>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:when>
            <xsl:when
                test="../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Trinity_R_3_20'">
                <xsl:call-template name="IIIF_call">
                    <xsl:with-param name="level" select="@xml:id"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise/>

        </xsl:choose>
    </xsl:template>

    <xsl:template name="mirador_javascript">
        <xsl:text>$(function() {test = Mirador({"id": "viewer","mainMenuSettings" : {'show' : false},"autoHideControls" : true,"data": [{"manifestUri": "</xsl:text>
        <xsl:call-template name="mirador_manifest_constructor"/>
        <xsl:text>", "location": "</xsl:text>
        <xsl:choose>
            <xsl:when
                test="../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Clopton_Chantry_Chapel'">
                <xsl:value-of
                    select="concat(../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:institution, ', ', ../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:settlement)"
                />
            </xsl:when>
            <xsl:when
                test="../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'British_Library_Harley_2251'">
                <xsl:value-of
                    select="concat(../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:institution, ', ', ../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:settlement)"
                />
            </xsl:when>
            <xsl:when
                test="../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'British_Library_Harley_2255'">
                <xsl:value-of
                    select="concat(../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:institution, ', ', ../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:settlement)"
                />
            </xsl:when>
            <xsl:when
                test="../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Trinity_R_3_20'">
                <xsl:value-of
                    select="concat(../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:institution, ', ', ../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:settlement)"
                />
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="concat(../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:institution, ', ', ../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:msIdentifier/tei:settlement)"
                />
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>"}],"windowObjects": [{"loadedManifest": "</xsl:text>
        <xsl:call-template name="mirador_manifest_constructor"/>
        <xsl:text>","canvasID": "</xsl:text>
        <xsl:call-template name="mirador_canvas_constructor"/>
        <xsl:choose>
            <xsl:when
                test="../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Trinity_R_3_20'">
                <xsl:choose>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Mumming_Eltham'"/>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Mumming_Hertford'"/>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Mumming_Windsor'"/>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Mumming_Goldsmiths_London'"/>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Mumming_Mercers_London'"/>
                    <xsl:when
                        test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Mumming_London'"/>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="substring(tei:graphic/@url, 1, string-length(tei:graphic/@url) - 4)"
                        />
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="substring(tei:graphic/@url, 1, string-length(tei:graphic/@url) - 4)"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:text>","availableViews" : false,"viewType" : "ImageView","bottomPanel" : false,"sidePanel" : false,"overlay" : false,"annotationLayer" : false,"annotationState" : false,"displayLayout": false,"fullScreen" : false}]});});</xsl:text>
    </xsl:template>

    <xsl:template name="static_image_javascript">
        <xsl:text>$(function() {adjustHeight();});</xsl:text>
    </xsl:template>

    <xsl:template name="checkfacs">
        <xsl:choose>
            <xsl:when test="@facs">
                <xsl:element name="div">
                    <xsl:attribute name="class">facsimage</xsl:attribute>
                    <xsl:element name="img">
                        <xsl:attribute name="src">
                            <xsl:value-of select="@facs"/>
                        </xsl:attribute>
                    </xsl:element>
                </xsl:element>
            </xsl:when>
            <xsl:when test="tei:graphic">
                <xsl:variable name="suffix_strip"
                    select="substring(tei:graphic/@url, 1, string-length(tei:graphic/@url) - 4)"/>
                <xsl:variable name="file_number"
                    select="substring($suffix_strip, string-length($suffix_strip) - 3)"/>
                <xsl:element name="div">
                    <xsl:choose>
                        <xsl:when test="../node()/@n = 'panel'">
                            <xsl:attribute name="id">panel</xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="id">page</xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:attribute name="class">facsimage col-5 col-s-5</xsl:attribute>
                    <xsl:choose>
                        <xsl:when
                            test="../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Clopton_Chantry_Chapel'">
                            <xsl:element name="div">
                                <xsl:attribute name="id">image</xsl:attribute>
                                <xsl:attribute name="class">image</xsl:attribute>
                            </xsl:element>
                            <xsl:element name="div">
                                <xsl:attribute name="id">viewer</xsl:attribute>
                                <xsl:attribute name="allowfullscreen"
                                    >allowfullscreen</xsl:attribute>
                            </xsl:element>
                            <xsl:element name="script">
                                <xsl:attribute name="type">text/javascript</xsl:attribute>
                                <xsl:call-template name="mirador_javascript"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when
                            test="../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'British_Library_Harley_2251'">
                            <xsl:element name="div">
                                <xsl:attribute name="id">image</xsl:attribute>
                                <xsl:attribute name="class">image</xsl:attribute>
                            </xsl:element>
                            <xsl:element name="div">
                                <xsl:attribute name="id">viewer</xsl:attribute>
                                <xsl:attribute name="allowfullscreen"
                                    >allowfullscreen</xsl:attribute>
                            </xsl:element>
                            <xsl:element name="script">
                                <xsl:attribute name="type">text/javascript</xsl:attribute>
                                <xsl:call-template name="mirador_javascript"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when
                            test="../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'British_Library_Harley_2255'">
                            <xsl:element name="div">
                                <xsl:attribute name="id">image</xsl:attribute>
                                <xsl:attribute name="class">image</xsl:attribute>
                            </xsl:element>
                            <xsl:element name="div">
                                <xsl:attribute name="id">viewer</xsl:attribute>
                                <xsl:attribute name="allowfullscreen"
                                    >allowfullscreen</xsl:attribute>
                            </xsl:element>
                            <xsl:element name="script">
                                <xsl:attribute name="type">text/javascript</xsl:attribute>
                                <xsl:call-template name="mirador_javascript"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:when
                            test="../../../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'Trinity_R_3_20'">
                            <xsl:element name="div">
                                <xsl:attribute name="id">image</xsl:attribute>
                                <xsl:attribute name="class">image</xsl:attribute>
                            </xsl:element>
                            <xsl:element name="div">
                                <xsl:attribute name="id">viewer</xsl:attribute>
                                <xsl:attribute name="allowfullscreen"
                                    >allowfullscreen</xsl:attribute>
                            </xsl:element>
                            <xsl:element name="script">
                                <xsl:attribute name="type">text/javascript</xsl:attribute>
                                <xsl:call-template name="mirador_javascript"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:element name="div">
                                <xsl:attribute name="id">image</xsl:attribute>
                                <xsl:attribute name="class">image</xsl:attribute>
                                <xsl:element name="img">
                                    <xsl:attribute name="src">
                                        <xsl:value-of
                                            select="concat('../../', $title_folder, '/', $witness, '/', $full_image_folder, '/', tei:graphic/@url)"
                                        />
                                    </xsl:attribute>
                                </xsl:element>
                                <xsl:element name="script">
                                    <xsl:attribute name="type">text/javascript</xsl:attribute>
                                    <xsl:call-template name="static_image_javascript"/>
                                </xsl:element>
                            </xsl:element>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="bannerChoice">
        <xsl:choose>
            <xsl:when
                test="../../../tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'index.html'">
                <img src="Images/Lydgate.jpg">
                    <xsl:attribute name="id">banner</xsl:attribute>
                    <xsl:attribute name="class">col-1 col-s-1</xsl:attribute>
                    <xsl:attribute name="alt">a picture of John Lydgate</xsl:attribute>
                </img>
            </xsl:when>
            <xsl:when test="name() = 'surface'">
                <img src="../../Images/Lydgate_interior.jpg">
                    <xsl:attribute name="id">interiorBanner</xsl:attribute>
                    <xsl:attribute name="class">col-1 col-s-1</xsl:attribute>
                    <xsl:attribute name="alt">a picture of John Lydgate with the initials of the
                        website</xsl:attribute>
                </img>
            </xsl:when>
            <xsl:when test="name() = 'fileDesc'">
                <img src="../../Images/Lydgate_interior.jpg">
                    <xsl:attribute name="id">interiorBanner</xsl:attribute>
                    <xsl:attribute name="class">col-1 col-s-1</xsl:attribute>
                    <xsl:attribute name="alt">a picture of John Lydgate with the initials of the
                        website</xsl:attribute>
                </img>
            </xsl:when>
            <xsl:otherwise>
                <img src="Images/Lydgate_interior.jpg">
                    <xsl:attribute name="id">interiorBanner</xsl:attribute>
                    <xsl:attribute name="class">col-1 col-s-1</xsl:attribute>
                    <xsl:attribute name="alt">a picture of John Lydgate with the initials of the
                        website</xsl:attribute>
                </img>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <!--RETHINK THIS.  CREATE A TEMPLATE THAT GENERATES THE TITLE BASED ON WHERE THE LINK IS COMING FROM, RATHER THAN WHAT IS IN THE XML -->
            <xsl:when test="name() = 'surface'">
                <xsl:choose>
                    <xsl:when
                        test="string-length(concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'], /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'sub'])) >= 75">
                        <div class="titleText smallText col-12 col-s-12"><em><xsl:value-of
                                    select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'])"
                                /></em>: </div>
                        <div class="manuscriptText smallText">
                            <xsl:value-of
                                select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'sub'])"
                            />
                        </div>
                    </xsl:when>
                    <xsl:otherwise>

                        <div class="titleText largeText col-12 col-s-12"><em><xsl:value-of
                                    select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'])"
                                /></em>: </div>
                        <div class="manuscriptText largeText">
                            <xsl:value-of
                                select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'sub'])"
                            />
                        </div>

                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="name() = 'fileDesc'">
                <xsl:choose>
                    <xsl:when
                        test="string-length(concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'], ' Physical Description')) >= 75">
                        <div class="titleText smallText col-12 col-s-12"><em>
                                <xsl:value-of
                                    select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'])"
                                />
                            </em>: </div>
                        <div class="manuscriptText smallText">
                            <xsl:text>Physical Description</xsl:text>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="titleText largeText col-12 col-s-12"><em>
                                <xsl:value-of
                                    select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'])"
                                />
                            </em>: </div>
                        <div class="manuscriptText largeText">
                            <xsl:text>Physical Description</xsl:text>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="name() = 'handNote'">
                <xsl:choose>
                    <xsl:when
                        test="string-length(concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'], ' Scribal Notes')) >= 75">
                        <div class="titleText smallText col-12 col-s-12"><em>
                                <xsl:value-of
                                    select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'])"
                                />
                            </em>: </div>
                        <div class="manuscriptText smallText">
                            <xsl:text>Scribal Notes</xsl:text>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="titleText largeText col-12 col-s-12"><em>
                                <xsl:value-of
                                    select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'])"
                                />
                            </em>: </div>
                        <div class="manuscriptText largeText">
                            <xsl:text>Scribal Notes</xsl:text>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="name() = 'body'">
                <xsl:choose>
                    <xsl:when
                        test="../../../tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'index.html'">
                        <div id="mastheadMain" class="titleText col-10 col-s-10">
                            <xsl:value-of
                                select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'main'])"
                            />
                        </div>
                        <div id="mastheadSub" class="manuscriptText col-10 col-s-10">
                            <xsl:value-of
                                select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[@type = 'sub'])"
                            />
                        </div>
                        <div id="editorName" class="col-10 col-s-10">
                            <xsl:value-of select="concat($editor_name, ', ', 'Editor')"/>
                            <!--                            <xsl:value-of
                                select="normalize-space(concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:persName/tei:forename[@n = 1], ' ', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:persName/tei:forename[@n = 2], ' ', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:persName/tei:surname, ', Editor.'))"
                            />-->
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when
                                test="string-length(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title) >= 75">
                                <div class="titleText smallText col-12 col-s-12" id="noSubtitle">
                                    <xsl:value-of
                                        select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"
                                    />
                                </div>
                            </xsl:when>
                            <xsl:otherwise>
                                <div class="titleText largeText col-12 col-s-12" id="noSubtitle">
                                    <xsl:value-of
                                        select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title)"/>

                                </div>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:when test="tei:sourceDesc/@n">
                <xsl:choose>
                    <xsl:when
                        test="string-length(concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'], 'Editorial Apparatus')) >= 75">
                        <div class="titleText smallText col-12 col-s-12"><em><xsl:value-of
                                    select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'])"
                                /></em>: </div>
                        <div class="manuscriptText smallText">
                            <xsl:text>Editorial Apparatus</xsl:text>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>

                        <div class="titleText largeText col-12 col-s-12"><em><xsl:value-of
                                    select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'])"
                                /></em>: </div>
                        <div class="manuscriptText largeText">
                            <xsl:text>Editorial Apparatus</xsl:text>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>

            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when
                        test="string-length(concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'], /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'sub'])) >= 75">
                        <div class="titleText smallText col-12 col-s-12"><em><xsl:value-of
                                    select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'])"
                                /></em>: </div>
                        <div class="manuscriptText smallText">
                            <xsl:value-of
                                select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'sub'])"
                            />
                        </div>
                    </xsl:when>
                    <xsl:otherwise>

                        <div class="titleText largeText col-12 col-s-12"><em><xsl:value-of
                                    select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'main'])"
                                /></em>: </div>
                        <div class="manuscriptText largeText">
                            <xsl:value-of
                                select="normalize-space(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title/tei:title[@type = 'sub'])"
                            />
                        </div>

                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:availability">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:license">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:licence">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template name="footer_IMEMS_statement">
        <div class="sponsors">
            <p>
                <a rel="external"
                    href="https://www.durham.ac.uk/research/institutes-and-centres/medieval-early-modern-studies/">
                    <img alt="Institute for Medieval and Early Modern Studies logo"
                        class="sponsor_logo" id="IMEMS_Durham"
                        src="../../Images/IMEMS_Full_Colour.jpg"/>
                </a>
            </p>
        </div>
        <div class="license">
            <p>
                <xsl:apply-templates select="//tei:licence"/>
            </p>
            <p> The work on this manuscript witness was generously sponsored by a <a
                    href="http://www.zenokarlschindler-foundation.ch/zks-lendrum-fellowship.html"
                    rel="external">ZKS-Lendrum Fellowship</a> in the Scientific Study of Manuscripts
                and Inscriptions at the <a
                    href="https://www.durham.ac.uk/research/institutes-and-centres/medieval-early-modern-studies/"
                    rel="external">Institute for Medieval and Early Modern Studies</a> at <a
                    href="https://www.durham.ac.uk/" rel="external">Durham University</a>.
                    <xsl:apply-templates select="//tei:p[@n = 'statement']"/>
            </p>
        </div>
    </xsl:template>

    <xsl:template name="footer_default_statement">
        <div class="license">
            <p>
                <xsl:apply-templates select="//tei:licence"/>
            </p>
            <p>
                <xsl:apply-templates select="//tei:p[@n = 'statement']"/>
            </p>
        </div>
    </xsl:template>

    <xsl:template name="footer">
        <div class="footer col-10 col-s-10">
            <xsl:choose>
                <xsl:when test="//tei:availability/@xml:id = 'CC-BY-NC-SA-MP'">
                    <p><a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"
                                ><img alt="Creative Commons License" style="border-width:0"
                                src="http://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png"
                        /></a><br/>Both the images and text of this work are licensed under a <a
                            rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"
                            >Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
                            License</a>.</p>
                </xsl:when>
                <xsl:when test="//tei:availability/@xml:id = 'clopton'">
                    <p><a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"
                                ><img alt="Creative Commons License" style="border-width:0"
                                src="http://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png"
                        /></a><br/>The transcription of this work is licensed under a <a
                            rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"
                            >Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
                            License</a>. All rights to the images, however, are reserved as a
                        courtesy to the Church of the Holy Trinity, Long Melford, which partially
                        relies on donations for its upkeep. Please contact the editor with any
                        requests.</p>
                </xsl:when>
                <xsl:when
                    test="//tei:availability/@xml:id = 'R.3.20' or //tei:availability/@xml:id = 'Add_29729'">
                    <xsl:choose>
                        <xsl:when
                            test="//tei:titleStmt/@xml:id = 'Mumming_Eltham' or //tei:titleStmt/@xml:id = 'Mumming_London' or //tei:titleStmt/@xml:id = 'Mumming_Goldsmiths_London' or //tei:titleStmt/@xml:id = 'Mumming_Hertford' or //tei:titleStmt/@xml:id = 'Mumming_Mercers_London' or //tei:titleStmt/@xml:id = 'Mumming_Windsor'">
                            <xsl:call-template name="footer_IMEMS_statement"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="footer_default_statement"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <p><a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"
                                ><img alt="Creative Commons License" style="border-width:0"
                                src="http://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png"
                        /></a><br/>Except where otherwise noted, this work is licensed under a <a
                            rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"
                            >Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
                            License</a>.</p>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="comparison">
        <div class="comparison col-5 col-s-5"> </div>
    </xsl:template>

    <xsl:template match="tei:ref">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="@target"/>
            </xsl:attribute>
            <xsl:attribute name="rel">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <xsl:template match="tei:ref[@n = 'iframe']">
        <xsl:attribute name="class">
            <xsl:text>iframe-container</xsl:text>
        </xsl:attribute>
        <div class="iframe-container">
            <iframe>
                <xsl:attribute name="name">
                    <xsl:text>curriculum_vitae</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="src">
                    <xsl:value-of select="@target"/>
                </xsl:attribute>
                <xsl:attribute name="seamless"/>
            </iframe>
        </div>
    </xsl:template>

    <xsl:template match="tei:p[descendant::tei:l]">
        <div class="poem">
            <xsl:apply-templates/>
        </div>

    </xsl:template>
    <xsl:template match="tei:p[@n = 'article']">
        <span class="article">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'review']">
        <span class="review">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'paper']">
        <span class="paper">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'lecture']">
        <span class="lecture">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'assistant']">
        <span class="assistant">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'panel']">
        <span class="panel">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'circumstance']">
        <xsl:text> </xsl:text>
        <span class="circumstance">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'name']">
        <xsl:choose>
            <xsl:when test="../@type = 'grant'">
                <div class="name">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="../@type = 'award'">
                <div class="name">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="../@type = 'service_item'">
                <div class="name">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="../@type = 'class'">
                <xsl:attribute name="class">name</xsl:attribute>
                <xsl:value-of select="current()"/>
                <xsl:if test="count(.././/descendant::tei:p[@n = 'semester']) &gt; 1">
                    <xsl:text> (</xsl:text>
                    <xsl:number value="count(.././/descendant::tei:p[@n = 'semester'])" format="w"
                        lang="en"/>
                    <xsl:text> times)</xsl:text>
                </xsl:if>

            </xsl:when>
            <xsl:when test="../@type = 'reference'"/>
            <xsl:otherwise>
                <span class="name">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'statement']">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:name">
        <xsl:choose>
            <xsl:when test="@type = 'building'">
                <div class="name">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:postBox">
        <div class="postbox">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:postCode">
        <xsl:text> </xsl:text>
        <div n="postcode">
            <xsl:apply-templates/>
        </div>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="tei:quote">
        <xsl:choose>
            <xsl:when test="@style = 'block'">
                <div class="blockquote">
                    <span class="blockquote-text">
                        <xsl:apply-templates/>
                    </span>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:p[@n = 'institution']">
        <xsl:choose>
            <xsl:when test="../tei:measure">
                <xsl:text>, </xsl:text>
                <span class="granting_institution">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="granting_institution">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'grantor']">
        <xsl:choose>
            <xsl:when test="../tei:measure">
                <xsl:text>, </xsl:text>
                <span class="grantor">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <span class="grantor">
                    <xsl:apply-templates/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'headquarters']">
        <xsl:text>, </xsl:text>
        <span class="headquarters">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:measure">
        <xsl:choose>
            <xsl:when test="@type = 'currency'">
                <xsl:choose>
                    <xsl:when test="@unit = 'dollar'">
                        <span class="amount">
                            <tei:text>$</tei:text>
                            <xsl:value-of select="format-number(current(), '###,###.00', 'us')"/>
                        </span>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'venue']">
        <xsl:choose>
            <xsl:when test="../@n = 'workshop'">
                <span class="venue" id="workshop">
                    <xsl:choose>
                        <xsl:when test="@xml:id = 'the'">
                            <xsl:text> (at the </xsl:text>
                            <xsl:apply-templates/>
                            <!--<xsl:apply-templates select="../tei:location"/>-->
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text> (at </xsl:text>
                            <xsl:apply-templates/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:when>
            <xsl:when test="../@type = 'talk'">
                <xsl:text>, </xsl:text>
                <span class="venue" id="talk">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="../@type = 'conference'">
                <span class="venue" id="conference">
                    <xsl:choose>
                        <xsl:when test="@xml:id = 'future'">
                            <xsl:text> To be presented at the </xsl:text>
                            <xsl:apply-templates/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text> Presented at the </xsl:text>
                            <xsl:apply-templates/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:location">
        <span class="location">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:placeName">
        <xsl:choose>
            <xsl:when test="../../@n = 'organization'">
                <xsl:choose>
                    <xsl:when test="*">
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="tei:settlement"/>
                        <xsl:text>, </xsl:text>
                        <xsl:choose>
                            <xsl:when test="tei:country = 'United States'">
                                <xsl:value-of select="tei:region"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="tei:country"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="current()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="../../@n = 'workshop'">
                <xsl:choose>
                    <xsl:when test="*">
                        <xsl:text>, </xsl:text>
                        <xsl:value-of select="tei:settlement"/>
                        <xsl:text>, </xsl:text>
                        <xsl:choose>
                            <xsl:when test="tei:country = 'United States'">
                                <xsl:value-of select="tei:region"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="tei:country"/>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>)</xsl:text>
                    </xsl:when>
                    <xsl:when test="../../tei:p[@n = 'venue']">
                        <xsl:choose>
                            <xsl:when test="../../tei:p[@n = 'venue'] = ''">
                                <xsl:value-of select="current()"/>
                                <xsl:text>)</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>, </xsl:text>
                                <xsl:value-of select="current()"/>
                                <xsl:text>)</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="current()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="../../@type = 'reference'">
                <xsl:choose>
                    <xsl:when test="*">
                        <span class="city">
                            <xsl:value-of select="tei:settlement"/>
                        </span>
                        <xsl:text>, </xsl:text>
                        <span class="region">
                            <xsl:choose>
                                <xsl:when test="tei:country = 'United States'">
                                    <xsl:value-of select="tei:region"/>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="tei:country"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </span>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>, </xsl:text>
                <xsl:value-of select="tei:settlement"/>
                <xsl:text>, </xsl:text>
                <xsl:choose>
                    <xsl:when test="tei:country = 'United States'">
                        <xsl:value-of select="tei:region"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="tei:country"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'role']">
        <div class="role">
            <xsl:value-of select="tei:p[@n = 'name']"/>
            <xsl:text>, </xsl:text>
            <span class="service_date">
                <xsl:value-of select="tei:date[@type = 'year']"/>
            </span>
        </div>
    </xsl:template>

    <xsl:template match="tei:p/tei:graphic">

        <img>
            <xsl:attribute name="src">
                <xsl:value-of select="@url"/>
            </xsl:attribute>
            <xsl:attribute name="class">
                <xsl:text>illustration</xsl:text>
            </xsl:attribute>
        </img>

    </xsl:template>

    <xsl:template match="tei:license/tei:p/tei:graphic">
        <a>
            <xsl:attribute name="href">
                <xsl:value-of select="../../@target"/>
            </xsl:attribute>
            <img>
                <xsl:attribute name="src">
                    <xsl:value-of select="@url"/>
                </xsl:attribute>
            </img>
        </a>
        <br/>
    </xsl:template>

    <xsl:template match="tei:p[@n = 'journal']">
        <xsl:choose>
            <xsl:when test="@xml:id = 'forthcoming'">
                <span class="journal">
                    <xsl:text> Forthcoming in </xsl:text>
                    <i>
                        <xsl:apply-templates/>
                    </i>
                    <xsl:text>.</xsl:text>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text> </xsl:text>
                <span class="journal">
                    <i>
                        <xsl:apply-templates/>
                    </i>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'volume']">
        <xsl:text> </xsl:text>
        <span class="volume">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:p">
        <xsl:choose>
            <xsl:when test="@n = 'hand_intro'">
                <h3>Scribal Hand</h3>
                <p>
                    <xsl:apply-templates/>
                </p>
            </xsl:when>
            <xsl:when test="@n = 'hand_otiose'">
                <div class="description_subcategory" id="otiose">
                    <h3 class="subheader">Ascenders, descenders, and otiose marks</h3>
                    <p>
                        <xsl:apply-templates/>
                    </p>
                </div>
            </xsl:when>
            <xsl:when test="@n = 'hand_capitals'">
                <div class="description_subcategory" id="capitals">
                    <h3 class="subheader">Capitals and illumination</h3>
                    <p>
                        <xsl:apply-templates/>
                    </p>
                </div>
            </xsl:when>
            <xsl:when test="../@type = 'research_agenda'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="../@type = 'position'">
                <span class="position">
                    <xsl:text>, </xsl:text>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@n = 'article'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="@n = 'review'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="@n = 'venue'">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <p>
                    <xsl:apply-templates/>
                </p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:surfaceGrp">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:text">
        <xsl:choose>
            <xsl:when
                test="not(contains(../../tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc[1]/@xml:id, '.html'))">
                <xsl:comment><xsl:value-of select="name()"/></xsl:comment>
                <xsl:result-document
                    href="{concat(../../tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/@xml:id,concat('_',../../tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id),'_Editorial.html')}"
                    method="html">
                    <xsl:apply-templates/>
                </xsl:result-document>
            </xsl:when>
            <xsl:otherwise>
                <xsl:result-document
                    href="{../../tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc[1]/@xml:id}"
                    method="html">
                    <xsl:apply-templates/>
                </xsl:result-document>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:body">
        <html xmlns="http://www.w3.org/1999/xhtml" xmlns:idhmc="http://idhmc.tamu.edu/"
            xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
            xml:lang="en">
            <xsl:call-template name="head"/>
            <body>
                <xsl:attribute name="class">simple</xsl:attribute>
                <xsl:attribute name="id">TOP</xsl:attribute>
                <!--  <script>
                    <xsl:attribute name="async"/>
                    <xsl:attribute name="defer"/>
                    <xsl:attribute name="src">https://hypothes.is/embed.js</xsl:attribute>
                </script>-->
                <div id="wrapper">
                    <div>
                        <xsl:attribute name="class">header col-10 col-s-10</xsl:attribute>
                        <h1>
                            <xsl:attribute name="id">mainTitle</xsl:attribute>
                            <xsl:choose>
                                <xsl:when
                                    test="../../tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'index.html'">
                                    <xsl:attribute name="class">mainPage</xsl:attribute>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:attribute name="class">paratext</xsl:attribute>
                                </xsl:otherwise>
                            </xsl:choose>
                            <xsl:call-template name="bannerChoice"/>
                        </h1>
                        <xsl:call-template name="siteHeader"/>
                    </div>
                    <div class="surface">
                        <xsl:attribute name="class">administrative paratext</xsl:attribute>
                        <xsl:apply-templates/>
                    </div>
                    <xsl:call-template name="makeNotes"/>
                    <xsl:call-template name="footer"/>
                </div>
            </body>
            <xsl:comment>
                <xsl:value-of select="name()"/>
            </xsl:comment>
            <script>adjustPageHeight();</script>
        </html>
    </xsl:template>

    <xsl:template name="mirador_css">
        <link>
            <xsl:attribute name="rel">preload</xsl:attribute>
            <xsl:attribute name="href"
                >../../../mirador/build/mirador/css/mirador-combined.css</xsl:attribute>
            <xsl:attribute name="as">style</xsl:attribute>
            <xsl:attribute name="onload">this.rel='stylesheet'</xsl:attribute>
        </link>
    </xsl:template>

    <xsl:template name="mirador_js">
        <script>
            <xsl:attribute name="src">../../javascript/jquery-2.1.4.min.js</xsl:attribute>
        </script>
        <script>
            <xsl:attribute name="src">../../mirador/build/mirador/mirador.min.js</xsl:attribute>
        </script>
    </xsl:template>

    <xsl:template name="image_preloader">
        <xsl:choose>
            <xsl:when
                test="../../../tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@xml:id = 'index.html'">
                <link>
                    <xsl:attribute name="rel">preload</xsl:attribute>
                    <xsl:attribute name="href">Images/Lydgate.jpg</xsl:attribute>
                    <xsl:attribute name="as">image</xsl:attribute>
                </link>
            </xsl:when>
            <xsl:when test="name() = 'surface'">
                <link>
                    <xsl:attribute name="rel">preload</xsl:attribute>
                    <xsl:attribute name="href">../../Images/Lydgate_interior.jpg</xsl:attribute>
                    <xsl:attribute name="as">image</xsl:attribute>
                </link>
            </xsl:when>
            <xsl:otherwise>
                <link>
                    <xsl:attribute name="rel">preload</xsl:attribute>
                    <xsl:attribute name="href">/Images/Lydgate_interior.jpg</xsl:attribute>
                    <xsl:attribute name="as">image</xsl:attribute>
                </link>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Clopton_Chantry_Chapel'">
                <xsl:apply-templates select="..//tei:graphic" mode="list">
                    <xsl:with-param name="image_preload" tunnel="yes">Yes</xsl:with-param>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="../..//tei:graphic" mode="list">
                    <xsl:with-param name="image_preload" tunnel="yes">Yes</xsl:with-param>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="head">
        <head>
            <link>
                <xsl:attribute name="rel">preload</xsl:attribute>
                <xsl:attribute name="href"
                    >http://www.minorworksoflydgate.net/Fonts/Cardo-Regular.ttf</xsl:attribute>
                <xsl:attribute name="as">font</xsl:attribute>
                <xsl:attribute name="type">font/woff2</xsl:attribute>
                <xsl:attribute name="crossorigin">anonymous</xsl:attribute>
            </link>
            <xsl:call-template name="image_preloader"/>
            <xsl:choose>
                <xsl:when test="not(tei:code)"/>
                <xsl:when test="not(tei:p/tei:code)"/>
                <xsl:otherwise>
                    <link>
                        <xsl:attribute name="rel">preload</xsl:attribute>
                        <xsl:attribute name="href">../../styles/googlecode.css</xsl:attribute>
                        <xsl:attribute name="as">style</xsl:attribute>
                        <xsl:attribute name="onload">this.rel='stylesheet'</xsl:attribute>
                    </link>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Clopton_Chantry_Chapel'">
                    <xsl:call-template name="mirador_css"/>
                </xsl:when>
                <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'British_Library_Harley_2251'">
                    <xsl:call-template name="mirador_css"/>
                </xsl:when>
                <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'British_Library_Harley_2255'">
                    <xsl:call-template name="mirador_css"/>
                </xsl:when>
                <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Trinity_R_3_20'">
                    <xsl:call-template name="mirador_css"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <link>
                <xsl:attribute name="rel">preload</xsl:attribute>
                <xsl:attribute name="id">responsive</xsl:attribute>
                <xsl:attribute name="href">../../responsive.css</xsl:attribute>
                <xsl:attribute name="as">style</xsl:attribute>
                <xsl:attribute name="onload">this.rel='stylesheet'</xsl:attribute>
            </link>
            <xsl:choose>
                <xsl:when test="./tei:zone/tei:zone/@n = 'text'">
                    <link>
                        <xsl:attribute name="rel">preload</xsl:attribute>
                        <xsl:attribute name="id">custom</xsl:attribute>
                        <xsl:attribute name="href">custom.css</xsl:attribute>
                        <xsl:attribute name="as">style</xsl:attribute>
                        <xsl:attribute name="onload">this.rel='stylesheet'</xsl:attribute>
                    </link>
                </xsl:when>
                <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'British_Library_Harley_2251'">
                    <xsl:comment><xsl:value-of select="name()"/></xsl:comment>
                    <link>
                        <xsl:attribute name="rel">preload</xsl:attribute>
                        <xsl:attribute name="id">custom</xsl:attribute>
                        <xsl:attribute name="href">custom.css</xsl:attribute>
                        <xsl:attribute name="as">style</xsl:attribute>
                        <xsl:attribute name="onload">this.rel='stylesheet'</xsl:attribute>
                    </link>
                </xsl:when>
                <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'British_Library_Harley_2255'">
                    <xsl:comment><xsl:value-of select="name()"/></xsl:comment>
                    <link>
                        <xsl:attribute name="rel">preload</xsl:attribute>
                        <xsl:attribute name="id">custom</xsl:attribute>
                        <xsl:attribute name="href">custom.css</xsl:attribute>
                        <xsl:attribute name="as">style</xsl:attribute>
                        <xsl:attribute name="onload">this.rel='stylesheet'</xsl:attribute>
                    </link>
                </xsl:when>
                <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Jesus_College_Q_G_8'">
                    <xsl:comment><xsl:value-of select="name()"/></xsl:comment>
                    <link>
                        <xsl:attribute name="rel">preload</xsl:attribute>
                        <xsl:attribute name="id">custom</xsl:attribute>
                        <xsl:attribute name="href">custom.css</xsl:attribute>
                        <xsl:attribute name="as">style</xsl:attribute>
                        <xsl:attribute name="onload">this.rel='stylesheet'</xsl:attribute>
                    </link>
                </xsl:when>
                <xsl:when
                    test="../../../../tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id = 'Mumming_Eltham'">
                    <link>
                        <xsl:attribute name="rel">preload</xsl:attribute>
                        <xsl:attribute name="id">custom</xsl:attribute>
                        <xsl:attribute name="href">custom.css</xsl:attribute>
                        <xsl:attribute name="as">style</xsl:attribute>
                        <xsl:attribute name="onload">this.rel='stylesheet'</xsl:attribute>
                    </link>
                </xsl:when>
                <xsl:otherwise>
                    <link>
                        <xsl:attribute name="rel">preload</xsl:attribute>
                        <xsl:attribute name="id">custom</xsl:attribute>
                        <xsl:attribute name="href">custom.css</xsl:attribute>
                        <xsl:attribute name="as">style</xsl:attribute>
                        <xsl:attribute name="onload">this.rel='stylesheet'</xsl:attribute>
                    </link>
                </xsl:otherwise>
            </xsl:choose>
            <link>
                <xsl:attribute name="rel">preload</xsl:attribute>
                <xsl:attribute name="id">decoToggle</xsl:attribute>
                <xsl:attribute name="href">../../decoration_suppress.css</xsl:attribute>
                <xsl:attribute name="as">style</xsl:attribute>
                <xsl:attribute name="onload">this.rel='stylesheet'</xsl:attribute>
                <xsl:attribute name="disabled">disabled</xsl:attribute>
            </link>
            <xsl:element name="script">
                <xsl:attribute name="src"
                    >https://www.minorworksoflydgate.net/javascript/custom-functions.js</xsl:attribute>
            </xsl:element>
            <xsl:element name="script">
                <xsl:attribute name="src">../../javascript/jquery-2.1.4.min.js</xsl:attribute>
            </xsl:element>
            <xsl:element name="script">
                <xsl:attribute name="async">async</xsl:attribute>
                <xsl:attribute name="src"
                    >https://www.googletagmanager.com/gtag/js?id=G-W1QFH1GHNF</xsl:attribute>
            </xsl:element>
            <xsl:element name="script"> window.dataLayer = window.dataLayer || []; function
                gtag(){dataLayer.push(arguments);} gtag('js', new Date()); gtag('config',
                'G-W1QFH1GHNF'); </xsl:element>
            <xsl:element name="meta">
                <xsl:attribute name="http-equiv">Content-Type</xsl:attribute>
                <xsl:attribute name="content">text/html; charset=UTF-8</xsl:attribute>
            </xsl:element>
            <xsl:element name="meta">
                <xsl:attribute name="name">viewport</xsl:attribute>
                <xsl:attribute name="content">width=device-width, initial-scale=1.0</xsl:attribute>
            </xsl:element>
            <xsl:choose>
                <xsl:when test="name() = 'handNote'">
                    <title>
                        <xsl:value-of
                            select="normalize-space(concat($full_title, ' - Editorial Notes'))"/>
                    </title>
                </xsl:when>
                <xsl:when test="name() = 'body'">
                    <title>
                        <xsl:value-of select="normalize-space($archive_title)"/>
                    </title>
                </xsl:when>
                <xsl:otherwise>
                    <title>
                        <xsl:value-of select="normalize-space($full_title)"/>
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
                    <xsl:value-of select="
                            normalize-space('Custom Stylesheet based on Text Encoding Initiative
                    Consortium XSLT stylesheets')"/>
                </xsl:attribute>
            </meta>
            <meta>
                <xsl:attribute name="DC.Title">
                    <xsl:choose>
                        <xsl:when test="name() = 'handNote'">
                            <xsl:value-of
                                select="normalize-space(concat($full_title, ' - Scribal Notes'))"/>
                        </xsl:when>
                        <xsl:when test="name() = 'body'">
                            <xsl:value-of select="normalize-space($archive_title)"/>
                        </xsl:when>
                        <xsl:when test="tei:sourceDesc/@n">
                            <xsl:value-of
                                select="normalize-space(concat($full_title, ' - Editorial Apparatus'))"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="normalize-space($full_title)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:attribute>
            </meta>
            <meta name="DC.Type" content="Text"/>
            <meta name="DC.Format" content="text/html"/>
            <xsl:choose>
                <xsl:when test="not(tei:code)"/>
                <xsl:when test="not(tei:p/tei:code)"/>
                <xsl:otherwise>
                    <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.7.0/highlight.min.js"/>
                </xsl:otherwise>
            </xsl:choose>
            <!--        <script>
                <xsl:attribute name="src">../../javascript/OpenLayers.js</xsl:attribute>
            </script>-->
            <script>
                <xsl:attribute name="src">../../javascript/custom-functions.js</xsl:attribute>
            </script>
            <xsl:choose>
                <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Clopton_Chantry_Chapel'">
                    <xsl:call-template name="mirador_js"/>
                </xsl:when>
                <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'British_Library_Harley_2251'">
                    <xsl:call-template name="mirador_js"/>
                </xsl:when>
                <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'British_Library_Harley_2255'">
                    <xsl:call-template name="mirador_js"/>
                </xsl:when>
                <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Trinity_R_3_20'">
                    <xsl:call-template name="mirador_js"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <!--        <script>
                <xsl:attribute name="src">../../javascript/featherlight/release/featherlight.min.js</xsl:attribute>
            </script>-->
            <xsl:choose>
                <xsl:when test="not(tei:code)"/>
                <xsl:when test="not(tei:p/tei:code)"/>
                <xsl:otherwise>
                    <script>hljs.initHighlightingOnLoad();</script>
                </xsl:otherwise>
            </xsl:choose>
            <style>
                .annotation-header__timestamp {
                    display: none !important;
                }</style>
        </head>
    </xsl:template>

    <xsl:template match="tei:revisionDesc"/>

    <xsl:template match="tei:surface">
        <xsl:variable name="filename_length" select="string-length(tei:graphic/@url)"/>
        <xsl:result-document
            href="{concat(substring(tei:graphic/@url,1,($filename_length - 4)),'.html')}"
            method="html" encoding="UTF-8">
            <html xmlns="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:xi="http://www.w3.org/2001/XInclude" xml:lang="en">
                <xsl:call-template name="head"/>
                <body>
                    <xsl:attribute name="class">simple</xsl:attribute>
                    <xsl:attribute name="id">TOP</xsl:attribute>
                    <!--
                       REMOVE UNTIL A BETTER HANDLE CAN BE GOTTEN ON THIS
                       <script>
                        <xsl:attribute name="async"/>
                        <xsl:attribute name="defer"/>
                        <xsl:attribute name="src">https://hypothes.is/embed.js</xsl:attribute>
                    </script>-->
                    <div id="wrapper">
                        <div>
                            <xsl:attribute name="class">header col-10 col-s-10</xsl:attribute>
                            <h1>
                                <xsl:attribute name="id">mainTitle</xsl:attribute>
                                <xsl:attribute name="class">col-12 col-s-12</xsl:attribute>
                                <xsl:call-template name="bannerChoice"/>
                            </h1>
                            <xsl:call-template name="fullMenu"/>
                        </div>
                        <div>
                            <xsl:call-template name="makeRendition"/>
                            <xsl:call-template name="checkfacs"/>
                            <div class="text col-5 col-s-5">
                                <xsl:attribute name="id">
                                    <xsl:value-of select="//tei:sourceDesc[1]/@xml:id"/>
                                </xsl:attribute>
                                <div class="breakout_bar col-10 col-s-10">
                                    <!--<xsl:call-template name="menuWidth"/>-->
                                    <span id="breakout_wrapper">
                                        <div class="decoFile">
                                            <div class="decoWrapper">
                                                <div class="decoBlock">
                                                  <xsl:element name="a">
                                                  <xsl:attribute name="href">
                                                  <xsl:text>javascript:void()</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="onclick">
                                                  <xsl:text>deco_toggle_visibility()</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="class">
                                                  <xsl:text>decoLink</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:text>Decoration</xsl:text>
                                                  </xsl:element>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="XMLFile">
                                            <div class="XMLWrapper">
                                                <div class="XMLBlock">
                                                  <a class="XMLLink">
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of select="$XMLFileName"/>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="download">
                                                  <xsl:value-of select="$fileName"/>
                                                  </xsl:attribute>
                                                  <xsl:text>Download XML</xsl:text>
                                                  </a>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="dictFile">
                                            <div class="dictWrapper">
                                                <div class="dictBlock">
                                                  <a class="dictLink"
                                                  href="../../XML/Data_Dictionary.html">Data
                                                  Dictionary</a>
                                                </div>
                                            </div>
                                        </div>
                                    </span>
                                </div>
                                <xsl:apply-templates/>
                            </div>
                        </div>
                        <xsl:call-template name="makeNotes"/>
                        <xsl:call-template name="footer"/>
                    </div>
                </body>
                <xsl:choose>
                    <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Clopton_Chantry_Chapel'"/>
                    <xsl:otherwise>
                        <script type="text/javascript">
                            <xsl:text>$(function() {adjustViewerHeight();});</xsl:text>
                        </script>
                    </xsl:otherwise>
                </xsl:choose>
            </html>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="tester">
        <xsl:value-of select="tei:TEI/tei:teiHeader/tei:encodingDesc"/>
    </xsl:template>
    <xsl:template match="tei:editorialDecl/tei:p"/>

    <xsl:template match="tei:editorialDecl/tei:div">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:editorialDecl">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:encodingDesc">
        <!--    <div id="EditNotes">
            <xsl:apply-templates/>
        </div> -->
    </xsl:template>


    <xsl:template name="fullMenu">
        <xsl:call-template name="siteHeader"/>
        <xsl:call-template name="menuHeader"/>
    </xsl:template>
    <xsl:template name="address">
        <xsl:for-each
            select="../../tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace/tei:address/tei:addrLine">
            <div>
                <xsl:value-of select="current()"/>
            </div>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="phone">
        <xsl:for-each
            select="../../tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace/tei:num[@n = 'telephone']">
            <xsl:value-of select="current()"/>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="email">
        <xsl:for-each
            select="../../tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace/tei:email">
            <div>
                <a>
                    <xsl:attribute name="href">mailto:<xsl:value-of select="current()"
                        /></xsl:attribute>
                    <xsl:value-of select="current()"/>
                </a>
            </div>
        </xsl:for-each>
    </xsl:template>
    <xsl:template name="affiliation">
        <xsl:choose>
            <xsl:when
                test="count(../../tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace/tei:affiliation) &gt; 1">
                <xsl:for-each
                    select="../../tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace/tei:affiliation">
                    <xsl:choose>
                        <xsl:when test="position() = last()">
                            <xsl:value-of select="concat('and ', current()[last()])"/>
                        </xsl:when>
                        <xsl:when test="position() = 1">
                            <xsl:value-of select="concat(current()[1], ' ')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat(', ', current())"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of
                    select="../../tei:teiHeader/tei:fileDesc/tei:publicationStmt/tei:pubPlace/tei:affiliation"
                />
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:head">
        <xsl:choose>
            <xsl:when test="../@type = 'category'">
                <h2 class="section">
                    <xsl:apply-templates/>
                </h2>
            </xsl:when>
            <xsl:when test="../@type = 'sub-category'">
                <xsl:choose>
                    <xsl:when test="@n = 'campus'"/>
                    <xsl:otherwise>
                        <h3>
                            <xsl:apply-templates/>
                        </h3>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="../@type = 'position'">
                <span class="institution">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="@type = 'status'">
                <h3 class="subheader status">
                    <xsl:apply-templates/>
                </h3>
            </xsl:when>
            <xsl:when test="@type = 'shelfmark'">
                <h3 class="subheader shelfmark">
                    <xsl:apply-templates/>
                </h3>
            </xsl:when>
            <xsl:when test="@type = 'subhead'">
                <h3 class="subheader">
                    <xsl:if test="@xml:id">
                        <xsl:attribute name="id">
                            <xsl:value-of select="@xml:id"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:apply-templates/>
                </h3>
            </xsl:when>
            <xsl:when test="@type = 'subhead2'">
                <div class="subheader2">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="@type = 'main'">
                <h2 class="main">
                    <xsl:apply-templates/>
                </h2>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--    <xsl:template name="nameBuilder">
        <xsl:value-of select="tei:forename[@type='first']"/>
        <xsl:if test="tei:forename/@type = 'middle'">
            <xsl:value-of select="concat(' ',tei:forename[@type='middle'])"/>
        </xsl:if>
        <xsl:value-of select="concat(' ',tei:surname)"/>
    </xsl:template>-->

    <xsl:template name="referenceBuilder">
        <xsl:param name="following"/>
        <xsl:choose>
            <xsl:when test="$following = 'true'">
                <xsl:value-of select="following-sibling::*[1]/@xml:id"/>
                <div class="name">
                    <xsl:apply-templates
                        select="following-sibling::tei:forename[@type = 'first'][1]"/>
                    <xsl:if test="following-sibling::tei:forename[1]/@type = 'middle'">
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates
                            select="following-sibling::tei:forename[@type = 'middle'][1]"/>
                    </xsl:if>
                    <xsl:text> </xsl:text>
                    <xsl:apply-templates select="following-sibling::tei:surname[1]"/>
                    <xsl:if test="following-sibling::tei:affiliation[@n = 'order'][1]">
                        <xsl:text>, </xsl:text>
                        <span class="affiliation" id="order">
                            <xsl:apply-templates
                                select="following-sibling::tei:affiliation[@n = 'order'][1]"/>
                        </span>
                    </xsl:if>
                </div>
                <div class="address">
                    <xsl:apply-templates select="following-sibling::tei:name[1]"/>
                    <xsl:apply-templates select="following-sibling::tei:postBox[1]"/>
                    <xsl:apply-templates select="following-sibling::tei:p[@n = 'campus'][1]"/>
                    <xsl:apply-templates select="following-sibling::tei:placeName[1]"/>
                    <xsl:apply-templates select="following-sibling::tei:postCode[1]"/>
                </div>
                <xsl:apply-templates select="following-sibling::tei:num[@n = 'telephone'][1]"/>
                <xsl:apply-templates select="following-sibling::tei:email[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@xml:id"/>
                <div class="name">
                    <xsl:apply-templates select="tei:forename[@type = 'first']"/>
                    <xsl:if test="tei:forename/@type = 'middle'">
                        <xsl:text> </xsl:text>
                        <xsl:apply-templates select="tei:forename[@type = 'middle']"/>
                    </xsl:if>
                    <xsl:text> </xsl:text>
                    <xsl:apply-templates select="tei:surname"/>
                    <xsl:if test="tei:affiliation[@n = 'order']">
                        <xsl:text>, </xsl:text>
                        <span class="affiliation" id="order">
                            <xsl:apply-templates select="tei:affiliation[@n = 'order']"/>
                        </span>
                    </xsl:if>
                </div>
                <div class="address">
                    <xsl:apply-templates select="tei:name"/>
                    <xsl:apply-templates select="tei:postBox"/>
                    <xsl:apply-templates select="tei:p[@n = 'campus']"/>
                    <xsl:apply-templates select="tei:placeName"/>
                    <xsl:apply-templates select="tei:postCode"/>
                </div>
                <xsl:apply-templates select="tei:num[@n = 'telephone']"/>
                <xsl:apply-templates select="tei:email"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="personBuilder">
        <span class="name">
            <xsl:apply-templates select="tei:forename[@type = 'first']"/>
            <xsl:if test="tei:forename/@type = 'middle'">
                <xsl:text> </xsl:text>
                <xsl:apply-templates select="tei:forename[@type = 'middle']"/>
            </xsl:if>
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="tei:surname"/>
        </span>
        <xsl:if test="tei:affiliation[@n = 'order']">
            <xsl:text>, </xsl:text>
            <span class="affiliation" id="order">
                <xsl:apply-templates select="tei:affiliation[@n = 'order']"/>
            </span>
        </xsl:if>
        <xsl:if test="tei:roleName">
            <xsl:text>, </xsl:text>
            <span class="role">
                <xsl:apply-templates select="tei:roleName"/>
            </span>
        </xsl:if>
        <xsl:if test="tei:orgName">
            <xsl:text>, </xsl:text>
            <span class="organization">
                <xsl:apply-templates select="tei:orgName"/>
            </span>
        </xsl:if>
        <xsl:if test="tei:affiliation[not(@n = 'order')]">
            <xsl:text>, </xsl:text>
            <span class="affiliation">
                <xsl:apply-templates select="tei:affiliation[not(@n = 'order')]"/>
            </span>
        </xsl:if>
    </xsl:template>



    <xsl:template match="tei:p[@n = 'thesis']">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:date[@type = 'month']">
        <xsl:text>, </xsl:text>
        <xsl:choose>
            <xsl:when test="../@type = 'conference'">
                <span class="conference_date">
                    <xsl:value-of select="../tei:date[@type = 'month']"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="../tei:date[@type = 'year']"/>
                    <xsl:text>.</xsl:text>
                </span>
            </xsl:when>
            <xsl:when test="../@type = 'talk'">
                <span class="talk_date">
                    <xsl:value-of select="../tei:date[@type = 'month']"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="../tei:date[@type = 'year']"/>
                    <xsl:text>.</xsl:text>
                </span>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>

    </xsl:template>
    <xsl:template match="tei:date[@type = 'year']">
        <xsl:choose>
            <xsl:when test="../@type = 'position'">
                <xsl:text>, </xsl:text>
                <span class="position_date">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="../@type = 'degree'">
                <span class="degree_date">
                    <xsl:text>, </xsl:text>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="../@type = 'grant'">
                <span class="grant_date">
                    <xsl:text>, </xsl:text>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="../@type = 'award'">
                <span class="award_date">
                    <xsl:text>, </xsl:text>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="../@n = 'workshop'">
                <span class="workshop_date">
                    <xsl:text>, </xsl:text>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="../@n = 'role'">
                <span class="service_date">
                    <xsl:text>, </xsl:text>
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:when test="../@type = 'conference'"/>
            <xsl:when test="../@type = 'talk'"/>
            <xsl:when test="../@type = 'class'"/>
            <xsl:when test="../tei:div[@type = 'class']"/>
            <xsl:when test="../@type = 'publication'">
                <xsl:text>, </xsl:text>
                <xsl:text> (</xsl:text>
                <span class="publication_date">
                    <xsl:apply-templates/>
                </span>
                <xsl:text>)</xsl:text>
                <xsl:choose>
                    <xsl:when test="../tei:p[@n = 'pages']"/>
                    <xsl:otherwise>
                        <xsl:text>.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'title']">
        <span class="job_title">
            <xsl:text>, </xsl:text>
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'organizer']">
        <div class="workshop_runner">
            <xsl:choose>
                <xsl:when test="count(tei:persName) &gt; 1">
                    <span class="organizer">
                        <xsl:text>Organizers: </xsl:text>
                    </span>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <span class="organizer">
                        <xsl:text>Organizer: </xsl:text>
                    </span>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'instructor']">
        <div class="instructor">
            <xsl:choose>
                <xsl:when test="count(tei:persName) &gt; 1">
                    <xsl:text>Instructors: </xsl:text>
                    <xsl:apply-templates/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:text>Instructor: </xsl:text>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    <xsl:template match="tei:forename[@type = 'first']">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:forename[@type = 'middle']">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:surname">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:roleName">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:orgName">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:affiliation">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:affiliation[@n = 'order']">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:persName">
        <xsl:choose>
            <xsl:when test="../@n = 'organizer'">
                <xsl:variable name="number">
                    <xsl:number/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$number = 1">
                        <div class="person">
                            <xsl:attribute name="id">first</xsl:attribute>
                            <xsl:call-template name="personBuilder"/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="person">
                            <xsl:call-template name="personBuilder"/>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="../@n = 'instructor'">
                <xsl:variable name="number">
                    <xsl:number/>
                </xsl:variable>
                <xsl:choose>
                    <xsl:when test="$number = 1">
                        <div class="person">
                            <xsl:attribute name="id">first</xsl:attribute>
                            <xsl:call-template name="personBuilder"/>
                        </div>
                    </xsl:when>
                    <xsl:otherwise>
                        <div class="person">
                            <xsl:call-template name="personBuilder"/>
                        </div>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <div class="person">
                    <xsl:call-template name="personBuilder"/>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:p[@n = 'duties']"/>

    <xsl:template match="tei:TEI/tei:div">
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="tei:div[@xml:id = 'EditNotes']">
        <div id="EditBlock" onclick="edit_toggle_visibility(); return false;">
            <!--<xsl:text>test test test</xsl:text>
            <xsl:value-of select="name()"/>-->
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'position']">
        <div class="job">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'publication']">
        <xsl:choose>
            <xsl:when test="@xml:id = 'working'"/>
            <xsl:when test="@xml:id = 'under_submission'">
                <div class="publication">
                    <xsl:text>(Under Submission) </xsl:text>
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise>
                <div class="publication">
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>
    <xsl:template match="tei:div[@type = 'grant']">
        <div class="grant">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'award']">
        <div class="award">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'conference']">
        <div class="conference">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'talk']">
        <div class="talk">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'service_item']">
        <div class="service_item">
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:p[@n = 'pages']">
        <xsl:text>: </xsl:text>
        <span class="pages">
            <xsl:apply-templates/>
        </span>
        <xsl:text>.</xsl:text>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'degree']">
        <div class="degree">
            <div class="granting">
                <xsl:value-of select="tei:head"/>
            </div>
            <div class="degree_level">
                <xsl:value-of select="tei:p[@n = 'level']"/>
                <xsl:apply-templates select="tei:date"/>
            </div>
            <xsl:choose>
                <xsl:when test="tei:p/@n = 'certificate'">
                    <div class="certificate">
                        <xsl:choose>
                            <xsl:when test="count(tei:p[@n = 'certificate']) &gt; 1">
                                <xsl:text>With certificates in </xsl:text>
                                <xsl:for-each select="tei:p[@n = 'certificate']">
                                    <xsl:choose>
                                        <xsl:when test="position() = last()">
                                            <xsl:value-of select="concat('and ', current()[last()])"
                                            />
                                        </xsl:when>
                                        <xsl:when test="position() = 1">
                                            <xsl:value-of select="concat(current()[1], ' ')"/>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:value-of select="concat(', ', current())"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:text>With certificate in </xsl:text>
                                <xsl:value-of select="tei:p[@n = 'certificate']"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </div>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="tei:p/@n = 'thesis'">
                    <xsl:choose>
                        <xsl:when test="tei:p/@xml:id = 'doctorate'">
                            <div class="thesis">
                                <xsl:text>Dissertation: </xsl:text>
                                <span class="thesis_title">
                                    <xsl:apply-templates select="tei:p[@n = 'thesis']"/>
                                    <!--<xsl:value-of select="tei:p[@n='thesis']"/>-->
                                </span>
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <div class="thesis">
                                <xsl:text>Thesis: </xsl:text>
                                <span class="thesis_title">
                                    <xsl:value-of select="tei:p[@n = 'thesis']"/>
                                </span>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
            <xsl:choose>
                <xsl:when test="tei:p/@n = 'director'">
                    <xsl:choose>
                        <xsl:when test="count(tei:p[@n = 'director']/tei:persName) &gt; 1">
                            <div class="thesis_director">
                                <xsl:text>Directors: </xsl:text>
                                <xsl:for-each select="tei:p[@n = 'director']/tei:persName">
                                    <xsl:choose>
                                        <xsl:when test="position() = last()">
                                            <xsl:text>and </xsl:text>
                                            <xsl:call-template name="personBuilder"/>
                                        </xsl:when>
                                        <xsl:when test="position() = 1">
                                            <xsl:call-template name="personBuilder"/>
                                            <xsl:choose>
                                                <xsl:when
                                                  test="count(tei:p[@n = 'director']/tei:persName) &gt; 2">
                                                  <xsl:text>, </xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:text> </xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:call-template name="personBuilder"/>
                                            <xsl:text>, </xsl:text>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:for-each>
                            </div>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>Director: </xsl:text>
                            <xsl:call-template name="personBuilder"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'research_agenda']">
        <div class="research_agenda">
            <xsl:for-each select="tei:p">
                <xsl:choose>
                    <xsl:when test="position() = 1">
                        <p>
                            <span class="research_description"><xsl:value-of select="../tei:head"/>: </span>
                            <xsl:apply-templates select="current()"/>
                        </p>
                    </xsl:when>
                    <xsl:otherwise>
                        <p>
                            <xsl:apply-templates select="current()"/>
                        </p>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'sub-category']">
        <xsl:choose>
            <xsl:when test="tei:head/@n = 'publications'">
                <div class="sub-category" id="publications">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="tei:head/@n = 'conference_papers'">
                <div class="sub-category" id="conference_papers">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="tei:head/@n = 'campus'">
                <div class="sub-category" id="campus">
                    <h3>
                        <span class="campus_name">
                            <xsl:value-of select="tei:head[@n = 'campus']"/>
                        </span>
                        <xsl:text>, </xsl:text>
                        <span class="campus_date">
                            <xsl:value-of select="tei:date[@type = 'year']"/>
                        </span>
                    </h3>
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="tei:div[@type = 'category']">
        <xsl:choose>
            <xsl:when test="tei:head/@n = 'education'">
                <div class="category" id="education">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="tei:head/@n = 'academic_employment'">
                <div class="category" id="academic_employment">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="tei:head/@n = 'it_employment'">
                <div class="category" id="it_employment">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="tei:head/@n = 'scholarship'">
                <div class="category" id="scholarship">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="tei:head/@n = 'talks'">
                <div class="category" id="talks">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="tei:head/@n = 'workshops'">
                <div class="category" id="workshops">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="tei:head/@n = 'awards'">
                <div class="category" id="awards">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="tei:head/@n = 'courses'">
                <div class="category" id="courses">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="tei:head/@n = 'service'">
                <div class="category" id="service">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:when test="tei:head/@n = 'references'">
                <div class="category" id="references">
                    <xsl:apply-templates/>
                </div>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:div[@type = 'reference']">
        <xsl:if test="@xml:id mod 2 = 1">
            <xsl:if test="@xml:id &lt;= 4">
                <div class="reference_block">
                    <xsl:apply-templates
                        select=". | following-sibling::tei:div[@type = 'reference'][1]" mode="group"
                    />
                </div>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="tei:div" mode="group">

        <div class="reference">
            <xsl:apply-templates/>
        </div>

    </xsl:template>

    <xsl:template match="tei:div[@n = 'organization']">
        <div class="organization">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@n = 'workshop']">
        <div class="workshop">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'seminar']">
        <span class="seminar">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'course_number']"/>
    <xsl:template match="tei:p[@n = 'semester']"/>
    <xsl:template match="tei:p[@n = 'description']"/>
    <xsl:template match="tei:address">
        <div class="address">
            <xsl:apply-templates/>
        </div>

    </xsl:template>
    <xsl:template match="tei:email">
        <div class="email">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:p[@n = 'campus']">
        <div class="campus">
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:num[@n = 'telephone']">
        <xsl:value-of select="*"/>
        <xsl:choose>
            <xsl:when test="../tei:div[@type = 'reference']"/>
            <xsl:otherwise>
                <div class="telephone">
                    <xsl:apply-templates/>
                </div>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <xsl:template name="siteHeader">
        <h1 id="siteHeader" class="col-12 col-s-12">
            <!--   <xsl:if test="not(name() = 'surface')">
                <xsl:attribute name="id">
                    <xsl:text>paratext</xsl:text>
                </xsl:attribute>
            </xsl:if>-->
            <span class="siteitem">
                <a class="nav_link" id="home" href="../../index.html">Home</a>
            </span>
            <span class="siteitem">
                <a class="nav_link" id="archive" href="../../archive.html">About the Archive</a>
            </span>
            <span class="siteitem">
                <a class="nav_link" id="lydgate" href="../../lydgate.html">About John Lydgate</a>
            </span>
            <span class="siteitem">
                <a class="nav_link" id="works" href="../../works.html">Works</a>
            </span>
            <span class="siteitem">
                <a class="nav_link" id="manuscripts" href="../../manuscripts.html">Manuscripts</a>
            </span>
            <xsl:choose>
                <xsl:when test="/tei:TEI/tei:text/@xml:id = 'GeneralEditorial'">
                    <span class="siteitem">
                        <a class="nav_link" id="description">
                            <xsl:attribute name="href"><xsl:value-of
                                    select="concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/@xml:id, concat('_', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id), '_description.html')"
                                /></xsl:attribute>About this Manuscript</a>
                    </span>
                    <span class="siteitem">
                        <a class="nav_link" id="return" onclick="history.go(-1)"
                            onmouseover="this.style.cursor='pointer'">Return to Text</a>
                    </span>
                </xsl:when>

                <xsl:when test="name() = 'fileDesc'">
                    <span class="siteitem">
                        <a class="nav_link" id="return" onclick="history.go(-1)"
                            onmouseover="this.style.cursor='pointer'">Return to Text</a>
                    </span>
                    <span class="siteitem">
                        <!--                        <a class="nav_link" id="apparatus">
                            <xsl:attribute name="href"><xsl:value-of
                                    select="concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/@xml:id, concat('_', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id), '_Editorial.html')"
                                /></xsl:attribute>Editorial Apparatus</a> -->
                        <a class="nav_link" id="apparatus">
                            <xsl:attribute name="href">../../apparatus.html</xsl:attribute>Editorial
                            Apparatus</a>

                    </span>
                </xsl:when>
                <xsl:when test="name() = 'surface'">
                    <span class="siteitem">
                        <a class="nav_link" id="description">
                            <xsl:attribute name="href"><xsl:value-of
                                    select="concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/@xml:id, concat('_', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id), '_description.html')"
                                /></xsl:attribute>About this Manuscript</a>
                    </span>
                    <span class="siteitem">
                        <!-- <a class="nav_link" id="apparatus">
                            <xsl:attribute name="href"><xsl:value-of
                                    select="concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/@xml:id, concat('_', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id), '_Editorial.html')"
                                /></xsl:attribute>Editorial Apparatus</a> -->
                        <a class="nav_link" id="apparatus" href="../../apparatus.html">Editorial
                            Apparatus</a>
                    </span>
                </xsl:when>
                <xsl:when test="name() = 'body'">
                    <xsl:choose>
                        <xsl:when
                            test="not(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc)">
                            <xsl:choose>
                                <xsl:when test="@xml:id = 'include'">
                                    <span class="siteitem">
                                        <a class="nav_link" id="description">
                                            <xsl:attribute name="href"><xsl:value-of
                                                  select="concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@n, '_description.html')"
                                                /></xsl:attribute>About this Manuscript</a>
                                    </span>
                                    <span class="siteitem">
                                        <a class="nav_link" id="apparatus">
                                            <xsl:attribute name="href"><xsl:value-of
                                                  select="concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/@n, '_apparatus.html')"
                                                /></xsl:attribute>Editorial Apparatus</a>
                                    </span>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:choose>
                                <xsl:when test="@xml:id = 'include'">
                                    <span class="siteitem">
                                        <a class="nav_link" id="description">
                                            <xsl:attribute name="href"><xsl:value-of
                                                  select="concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/@xml:id, concat('_', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id), '_description.html')"
                                                /></xsl:attribute>About this Manuscript</a>
                                    </span>
                                    <span class="siteitem">
                                        <a class="nav_link" id="apparatus">
                                            <xsl:attribute name="href"><xsl:value-of
                                                  select="concat(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/@xml:id, concat('_', /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id), '_Editorial.html')"
                                                /></xsl:attribute>Editorial Apparatus</a>
                                    </span>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:when test="name() = 'msDesc/@xml:id'">
                    <xsl:apply-templates/>
                </xsl:when>
            </xsl:choose>
            <span class="siteitem">
                <a class="nav_link" id="contact" href="../../contact.html">Contact</a>
            </span>
            <span class="siteitem">
                <a class="nav_link" id="visualization" href="../../visualization.html"
                    >Visualization</a>
            </span>
        </h1>
    </xsl:template>

    <xsl:template match="msDesc[@xml:id]">
        <span class="menuitem siteitem">
            <a class="nav_link">
                <xsl:attribute name="href"><xsl:value-of
                        select="concat($witness, '_description.html')"/></xsl:attribute>About this
                Manuscript</a>
        </span>
        <span class="menuitem siteitem">
            <a class="nav_link">
                <xsl:attribute name="href"><xsl:value-of
                        select="concat($witness, '_apparatus.html')"/></xsl:attribute>Editorial
                Apparatus</a>
        </span>
    </xsl:template>


    <!--   <xsl:template name="menuWidth">
        <xsl:choose>
            <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Clopton_Chantry_Chapel'">
                <xsl:attribute name="id">panel</xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="id">page</xsl:attribute>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->




    <xsl:template name="menuHeader">
        <xsl:variable name="filename_length" select="string-length(tei:graphic/@url)"/>
        <h1 id="menuHeader" class="col-10 col-s-10">
            <!--<xsl:call-template name="menuWidth"/> -->
            <div id="leftMenu">
                <span class="menuitem groupLabel">
                    <xsl:choose>
                        <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Clopton_Chantry_Chapel'">
                            <xsl:value-of select="../@n"/>
                            <xsl:text> </xsl:text>
                            <span id="modelViewer">
                                <a href="../../Model/three/examples/chantry_chapel.html">
                                    <!--                    <a href="javascript: void(0)" onclick="document.getElementById('model').src='../../Model/three/examples/chantry_chapel.html';">-->
                                    <xsl:text>(View Model)</xsl:text>
                                </a>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:call-template name="gathering"/>
                            <xsl:value-of select="concat(../@xml:id, ' ', @n)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </div>
            <div id="gathering">
                <xsl:choose>
                    <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Clopton_Chantry_Chapel'">
                        <xsl:apply-templates select="..//tei:graphic" mode="list"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="../..//tei:graphic" mode="list"/>
                    </xsl:otherwise>
                </xsl:choose>
            </div>
            <xsl:variable name="last_block" as="xs:integer">
                <xsl:choose>
                    <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Clopton_Chantry_Chapel'">
                        <xsl:value-of select="count(../preceding-sibling::tei:surfaceGrp)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="count(../../preceding-sibling::tei:surfaceGrp)"/>
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:variable>
            <xsl:variable name="next_block" as="xs:integer">
                <xsl:choose>
                    <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Clopton_Chantry_Chapel'">
                        <xsl:value-of select="count(../following-sibling::tei:surfaceGrp)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="count(../../following-sibling::tei:surfaceGrp)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="total_blocks">
                <xsl:value-of select="../last()"/>
            </xsl:variable>
            <xsl:variable name="group_position" as="xs:integer">
                <xsl:choose>
                    <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Clopton_Chantry_Chapel'">
                        <xsl:value-of
                            select="../../count(tei:surfaceGrp) - count(../following-sibling::node()/position())"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="../../../count(tei:surfaceGrp) - count(../following-sibling::node()/position())"
                        />
                    </xsl:otherwise>
                </xsl:choose>

            </xsl:variable>
            <xsl:variable name="last_item_id">
                <xsl:choose>
                    <xsl:when test="//tei:sourceDesc[1]/@xml:id = 'Clopton_Chantry_Chapel'">
                        <xsl:value-of
                            select="../../tei:surfaceGrp[last()]/tei:surface[last()]/@xml:id"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of
                            select="../../../tei:surfaceGrp[last()]/tei:surfaceGrp[last()]/tei:surface[last()]/@xml:id"
                        />
                    </xsl:otherwise>
                </xsl:choose>


            </xsl:variable>

            <xsl:variable name="next_surface">
                <xsl:value-of
                    select="concat(substring(../following-sibling::*[1]/tei:surface[1]/tei:graphic/@url, 1, ($filename_length - 4)), '.html')"
                />
            </xsl:variable>

            <xsl:variable name="last_surface">
                <xsl:value-of
                    select="concat(substring(../preceding-sibling::*[1]/tei:surface[last()]/tei:graphic/@url, 1, ($filename_length - 4)), '.html')"
                />
            </xsl:variable>

            <xsl:variable name="next_item">
                <xsl:value-of
                    select="concat(substring(following-sibling::*[1]/tei:graphic/@url, 1, ($filename_length - 4)), '.html')"
                />
            </xsl:variable>

            <xsl:variable name="last_item">
                <xsl:value-of
                    select="concat(substring(preceding-sibling::*[1]/tei:graphic/@url, 1, ($filename_length - 4)), '.html')"
                />
            </xsl:variable>

            <xsl:variable name="next_choose">
                <xsl:choose>
                    <xsl:when test="$next_item = '.html'">
                        <xsl:choose>
                            <xsl:when test="$next_surface = '.html'"/>
                            <xsl:otherwise>
                                <xsl:value-of select="$next_surface"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$next_item"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <xsl:variable name="last_choose">
                <xsl:choose>
                    <xsl:when test="$last_item = '.html'">
                        <xsl:choose>
                            <xsl:when test="$last_surface = '.html'"/>
                            <xsl:otherwise>
                                <xsl:value-of select="$last_surface"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$last_item"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <div id="rightMenu">
                <span class="menuitem groupLabel">
                    <xsl:choose>
                        <xsl:when test="$last_choose = ''">
                            <xsl:choose>
                                <xsl:when test="$last_block > 0">
                                    <xsl:choose>
                                        <xsl:when test="../../@n = 'gathering'">
                                            <span class="menuitem" id="previousItem">
                                                <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat(substring(../../preceding-sibling::node()/tei:surfaceGrp[last()]/tei:surface[last()]/tei:graphic/@url, 1, ($filename_length - 4)), '.html')"
                                                  />
                                                  </xsl:attribute>
                                                  <xsl:text>Previous</xsl:text>
                                                </a>
                                            </span>
                                        </xsl:when>
                                        <xsl:otherwise/>
                                    </xsl:choose>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="menuitem" id="previousItem">
                                <a href="{$last_choose}">Previous</a>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                    <xsl:choose>
                        <xsl:when test="$next_choose = ''">
                            <xsl:choose>
                                <xsl:when test="$next_block > 0">
                                    <xsl:choose>
                                        <xsl:when test="../../@n = 'gathering'">
                                            <span class="menuitem" id="nextItem">
                                                <a>
                                                  <xsl:attribute name="href">
                                                  <xsl:value-of
                                                  select="concat(substring(../../following-sibling::node()/tei:surfaceGrp[1]/tei:surface[1]/tei:graphic[1]/@url, 1, ($filename_length - 4)), '.html')"
                                                  />
                                                  </xsl:attribute>
                                                  <xsl:text>Next</xsl:text>
                                                </a>
                                            </span>
                                        </xsl:when>
                                        <xsl:otherwise/>
                                    </xsl:choose>
                                </xsl:when>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="menuitem" id="nextItem">
                                <a href="{$next_choose}">Next</a>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </div>
        </h1>
    </xsl:template>

    <xsl:template match="tei:graphic"/>

    <xsl:template match="tei:p/tei:graphic[@n = 'standalone']">
        <div class="standalone_image">
            <img>
                <xsl:attribute name="src">
                    <xsl:value-of select="@url"/>
                </xsl:attribute>
            </img>
        </div>
    </xsl:template>

    <xsl:template match="tei:anchor">
        <a>
            <xsl:attribute name="class">
                <xsl:text>anchor</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="id">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
        </a>
    </xsl:template>

    <xsl:template match="tei:ref/tei:graphic">
        <img>
            <xsl:attribute name="src">
                <xsl:value-of select="@url"/>
            </xsl:attribute>
        </img>
    </xsl:template>

    <xsl:template match="tei:figure/tei:p">
        <xsl:choose>
            <xsl:when test="@xml:id = 'caption'">
                <figcaption>
                    <xsl:apply-templates/>
                </figcaption>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:figure">
        <div class="figure_image">
            <figure>
                <xsl:apply-templates/>
            </figure>
        </div>
    </xsl:template>

    <xsl:template name="IIIF_call">
        <xsl:param name="level"/>
        <xsl:choose>
        <xsl:when
            test="//tei:titleStmt/@xml:id = 'Mumming_Eltham'">
            <xsl:choose>
                <xsl:when test="number(substring-after($level, 'p.')) &lt; 100">
                    <xsl:text>https://mss-cat.trin.cam.ac.uk:8183/iiif/2/R.3.20%2F0</xsl:text>
                    <xsl:choose>
                        <xsl:when test="number(substring-after($level, 'p.')) = 37">
                            <xsl:text>54</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 38">
                            <xsl:text>55</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 39">
                            <xsl:text>56</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 40">
                            <xsl:text>57</xsl:text>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                    <xsl:text>_R.3.20_p0</xsl:text>
                    <xsl:value-of select="substring-after($level, 'p.')"/>
                    <xsl:text>.jp2</xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:when>
        <xsl:when
            test="//tei:titleStmt/@xml:id = 'Mumming_London'">
            <xsl:choose>
                <xsl:when test="number(substring-after($level, 'p.')) &lt; 100">
                    <xsl:text>https://mss-cat.trin.cam.ac.uk:8183/iiif/2/R.3.20%2F0</xsl:text>
                    <xsl:choose>
                        <xsl:when test="number(substring-after($level, 'p.')) = 55">
                            <xsl:text>72</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 56">
                            <xsl:text>73</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 57">
                            <xsl:text>74</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 58">
                            <xsl:text>75</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 59">
                            <xsl:text>76</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 60">
                            <xsl:text>77</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 61">
                            <xsl:text>78</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 62">
                            <xsl:text>79</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 63">
                            <xsl:text>80</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 64">
                            <xsl:text>81</xsl:text>
                        </xsl:when>
                        <xsl:when test="number(substring-after($level, 'p.')) = 65">
                            <xsl:text>82</xsl:text>
                        </xsl:when>
                        <xsl:otherwise/>
                    </xsl:choose>
                    <xsl:text>_R.3.20_p0</xsl:text>
                    <xsl:value-of select="substring-after($level, 'p.')"/>
                    <xsl:text>.jp2</xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:when>
        <xsl:when
            test="//tei:titleStmt/@xml:id = 'Mumming_Windsor'">
            <xsl:text>https://mss-cat.trin.cam.ac.uk:8183/iiif/2/R.3.20%2F0</xsl:text>
            <xsl:choose>
                <xsl:when test="number(substring-after($level, 'p.')) = 71">
                    <xsl:text>88</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 72">
                    <xsl:text>89</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 73">
                    <xsl:text>90</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 74">
                    <xsl:text>91</xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:text>_R.3.20_p0</xsl:text>
            <xsl:value-of select="substring-after($level, 'p.')"/>
            <xsl:text>.jp2</xsl:text>
        </xsl:when>
        <xsl:when
            test="//tei:titleStmt/@xml:id = 'Mumming_Mercers_London'">
            <xsl:text>https://mss-cat.trin.cam.ac.uk:8183/iiif/2/R.3.20%2F</xsl:text>
            <xsl:choose>
                <xsl:when test="number(substring-after($level, 'p.')) = 171">
                    <xsl:text>188</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 172">
                    <xsl:text>189</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 173">
                    <xsl:text>190</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 174">
                    <xsl:text>191</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 175">
                    <xsl:text>192</xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:text>_R.3.20_p</xsl:text>
            <xsl:value-of select="substring-after($level, 'p.')"/>
            <xsl:text>.jp2</xsl:text>
        </xsl:when>
        <xsl:when
            test="//tei:titleStmt/@xml:id = 'Mumming_Hertford'">
            <xsl:text>https://mss-cat.trin.cam.ac.uk:8183/iiif/2/R.3.20%2F0</xsl:text>
            <xsl:choose>
                <xsl:when test="number(substring-after($level, 'p.')) = 40">
                    <xsl:text>57</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 41">
                    <xsl:text>58</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 42">
                    <xsl:text>59</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 43">
                    <xsl:text>60</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 44">
                    <xsl:text>61</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 45">
                    <xsl:text>62</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 46">
                    <xsl:text>63</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 47">
                    <xsl:text>64</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 48">
                    <xsl:text>65</xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:text>_R.3.20_p0</xsl:text>
            <xsl:value-of select="substring-after($level, 'p.')"/>
            <xsl:text>.jp2</xsl:text>
        </xsl:when>
        <xsl:when
            test="//tei:titleStmt/@xml:id = 'Mumming_Goldsmiths_London'">
            <xsl:text>https://mss-cat.trin.cam.ac.uk:8183/iiif/2/R.3.20%2F</xsl:text>
            <xsl:choose>
                <xsl:when test="number(substring-after($level, 'p.')) = 175">
                    <xsl:text>192</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 176">
                    <xsl:text>193</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 177">
                    <xsl:text>194</xsl:text>
                </xsl:when>
                <xsl:when test="number(substring-after($level, 'p.')) = 178">
                    <xsl:text>195</xsl:text>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
            <xsl:text>_R.3.20_p</xsl:text>
            <xsl:value-of select="substring-after($level, 'p.')"/>
            <xsl:text>.jp2</xsl:text>
        </xsl:when>
        <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:graphic" mode="list">
        <xsl:param name="image_preload" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$image_preload = 'Yes'">
                <link>
                    <xsl:attribute name="rel">preload</xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:value-of
                            select="concat('../../', $title_folder, '/', $witness, '/', $thumbnail_folder, '/', substring(@url, 1, string-length(@url) - 4), '-thumbnail.jpg')"
                        />
                    </xsl:attribute>
                    <xsl:attribute name="as">image</xsl:attribute>
                </link>
            </xsl:when>
            <xsl:otherwise>
                <span class="menuitem image_thumbnail">
                    <a class="nav_link">
                        <xsl:attribute name="href">
                            <xsl:value-of
                                select="concat(substring(@url, 1, string-length(@url) - 4), '.html')"
                            />
                        </xsl:attribute>
                        <xsl:comment>
                            <xsl:value-of select="name"/>
                        </xsl:comment>
                        <img class="thumbnail">
                            <xsl:attribute name="src">
                                <xsl:choose>
                                    <xsl:when
                                        test="//tei:sourceDesc/@xml:id = 'Trinity_R_3_20'">
                                                <xsl:call-template name="IIIF_call">
                                                    <xsl:with-param name="level" select="../@xml:id"/>
                                                </xsl:call-template>
                                                <xsl:text>/full/150,/0/default.jpg</xsl:text>
                                    </xsl:when>
                                    <xsl:otherwise>

                                        <xsl:value-of
                                            select="concat('../../', $title_folder, '/', $witness, '/', $thumbnail_folder, '/', substring(@url, 1, string-length(@url) - 4), '-thumbnail.jpg')"/>

                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:attribute>
                            <xsl:attribute name="alt">
                                <xsl:value-of select="../tei:label/text()[1]"/>
                            </xsl:attribute>
                        </img>
                    </a>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>



    <xsl:template match="tei:list[@type = 'index']">
        <ul class="index">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="tei:list[@type = 'ordered']">
        <ol>
            <xsl:apply-templates/>
        </ol>
    </xsl:template>
    <xsl:template match="tei:list[@type = 'simple']">
        <ul class="nodisplay">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="tei:list[@xml:id = 'compare']">
        <ul class="nodisplay">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="tei:list[@type = 'bibliography']">
        <ul class="nodisplay bibliography">
            <xsl:apply-templates/>
        </ul>
    </xsl:template>

    <xsl:template match="tei:item">
        <li>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="tei:item[@xml:id]">
        <li>
            <a>
                <xsl:attribute name="name">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
                <xsl:attribute name="class">
                    <xsl:text>anchor</xsl:text>
                </xsl:attribute>
                <xsl:apply-templates/>
            </a>
        </li>
    </xsl:template>

    <xsl:template match="tei:list">
        <ul>
            <xsl:apply-templates/>
        </ul>
    </xsl:template>
    <xsl:template match="tei:list[@rend = 'ordered']">
        <ol>
            <xsl:apply-templates/>
        </ol>
    </xsl:template>
    <xsl:template match="tei:item[@xml:id = 'compare']/tei:orig">
        <xsl:call-template name="makeRendition"/>
        <xsl:call-template name="checkfacs"/>
        <xsl:apply-templates select="text() | *[not(self::tei:graphic)]"/>
    </xsl:template>
    <xsl:template match="tei:list[@xml:id = 'bullet_list']/tei:item">
        <li>
            <xsl:attribute name="class">
                <xsl:text>bullet_list</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
        </li>
    </xsl:template>

    <xsl:template match="tei:gap">
        <xsl:variable name="max" select="@quantity"/>
        <xsl:for-each select="1 to $max">
            <xsl:text>.</xsl:text>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="tei:damage/tei:gap">
        <xsl:text>[</xsl:text>
        <xsl:variable name="max" select="@quantity"/>
        <xsl:for-each select="1 to $max">
            <xsl:text>.</xsl:text>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template match="tei:line/tei:gap">
        <xsl:text>[</xsl:text>
        <xsl:variable name="max" select="@quantity"/>
        <xsl:for-each select="1 to $max">
            <xsl:text>.</xsl:text>
        </xsl:for-each>
        <xsl:text>]</xsl:text>
    </xsl:template>

    <xsl:template name="gathering">
        <xsl:choose>
            <xsl:when test="not(../@xml:id)">
                <xsl:comment>xml:id does not exist. element is <xsl:value-of select="../name()"/></xsl:comment>
            </xsl:when>
            <xsl:when test="../@xml:id = ''">
                <xsl:comment>xml:id exists but is empty. element is <xsl:value-of select="../name()"/></xsl:comment>
            </xsl:when>
            <xsl:otherwise>
                <div class="gathering_layout">
                    <xsl:comment><xsl:value-of select="name()"/></xsl:comment>
                    <script>
                        <xsl:text>structure_model(</xsl:text>
                        <xsl:value-of select="substring(../@xml:id, 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:choose>
                            <xsl:when test="@n = 'recto'">1</xsl:when>
                            <xsl:when test="@n = 'verso'">2</xsl:when>
                            <xsl:otherwise/>
                        </xsl:choose>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="substring(../../@xml:id, 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="substring(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:p[@n = 'gathering']/@xml:id, 3)"/>
                        <xsl:text>,</xsl:text>
                        <xsl:value-of select="substring(/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:msDesc/tei:physDesc/tei:objectDesc/tei:layoutDesc/tei:layout/tei:p[@n = 'collation']/@xml:id, 3)"/>
                        <xsl:text>);</xsl:text>  
                    </script>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:p/tei:gap">
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

    <xsl:template match="tei:ref/tei:note"/>

    <!--    <xsl:template match="tei:label[@n='pdf']">
        <iframe name="curriculum_vitae">
            <xsl:attribute name="src">
                <xsl:value-of select="@xml:id"/>
            </xsl:attribute>
            <xsl:attribute name="seamless"/>
        </iframe>
    </xsl:template>
    <xsl:template match="tei:orig">
        <div>
            <xsl:call-template name="makeRendition"/>
            <xsl:call-template name="checkfacs"/>
            <xsl:apply-templates select="text()|*[not(self::tei:graphic)]"/>
        <xsl:for-each-group select="node()" group-adjacent="boolean(self::tei:gap)">
            <xsl:choose>
                <xsl:when test="current-grouping-key()">
                    <xsl:text>[</xsl:text>
                    <xsl:for-each select="current-group()">
                        <xsl:for-each select="1 to @quantity">
                            <xsl:text>.</xsl:text>
                        </xsl:for-each>
                        <xsl:if test="position()!=last()">
                            <xsl:text> </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                    <xsl:text>]</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="current-group()" separator=""/>
                </xsl:otherwise>  
            </xsl:choose>
        </xsl:for-each-group>
        </div>
    </xsl:template> -->


    <xsl:template match="tei:orig">
        <xsl:apply-templates/>
        <xsl:text> </xsl:text>
        <a class="compare">
            <xsl:attribute name="href">
                <xsl:text>javascript:void()</xsl:text>
                <!--<xsl:value-of select="concat('../../XML/XQuery/test_command_line.php?zone=',../../@n,'&amp;collection=',/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id,'&amp;line=',../@n)"/>-->
            </xsl:attribute>
            <xsl:attribute name="onclick">
                <xsl:text>compare_toggle_visibility('</xsl:text>
                <xsl:value-of select="../../@n"/>
                <xsl:text>', '</xsl:text>
                <xsl:value-of select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id"/>
                <xsl:text>', '</xsl:text>
                <xsl:value-of select="../@n"/>
                <xsl:text>')</xsl:text>
            </xsl:attribute>
            <span class="compare">
                <xsl:text>&#x2022;</xsl:text>
            </span>
        </a>
    </xsl:template>

    <xsl:template match="tei:label">
        <div class="label col-5 col-s-5">
            <xsl:apply-templates/>
        </div>
        <div class="compare_dot col-5 col-s-5"> Compare Witnesses: <span class="compare">
                <xsl:text>&#x2022;</xsl:text>
            </span>
        </div>
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

    <xsl:template match="tei:subst">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:add">
        <xsl:text>[</xsl:text>
        <xsl:apply-templates/>
        <xsl:text>]</xsl:text>
    </xsl:template>


    <xsl:template match="tei:zone">
        <div>
            <xsl:attribute name="ZoneNum">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:call-template name="makeRendition"/>
            <xsl:call-template name="checkfacs"/>
            <xsl:apply-templates select="text() | *[not(self::tei:graphic)]"/>
        </div>
        <xsl:choose>
            <xsl:when test="@n = 'text'"/>
            <xsl:when test="@n = 'marginalia'"/>
            <xsl:when test="@n = 'header'"/>
            <xsl:otherwise>
                <div class="comparison">
                    <xsl:choose>
                        <xsl:when test="@n = 'text'">
                            <xsl:attribute name="id">
                                <xsl:value-of select="../@n"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="@n = 'marginalia'">
                            <xsl:attribute name="id">
                                <xsl:value-of select="../@n"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:when test="@n = 'header'">
                            <xsl:attribute name="id">
                                <xsl:value-of select="../@n"/>
                            </xsl:attribute>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:attribute name="id">
                                <xsl:value-of select="@n"/>
                            </xsl:attribute>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="tei:line">
        <xsl:element name="div">
            <xsl:attribute name="lineNum">
                <xsl:value-of select="@n"/>
            </xsl:attribute>
            <xsl:call-template name="makeRendition"/>
            <xsl:call-template name="checkfacs"/>
            <xsl:apply-templates select="text() | *[not(self::tei:graphic)]"/>
            <xsl:text> </xsl:text>
            <xsl:if test="string(.)">
                <xsl:element name="a">
                    <xsl:attribute name="class">compare</xsl:attribute>
                    <xsl:attribute name="href">
                        <xsl:text>javascript:void()</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="onclick">
                        <xsl:text>compare_toggle_visibility('</xsl:text>
                        <xsl:choose>
                            <xsl:when test="../../name() = 'zone'">
                                <xsl:value-of select="../../@n"/>
                                <xsl:text>', '</xsl:text>
                                <xsl:value-of select="@n"/>
                                <xsl:text>', '</xsl:text>
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id"/>
                                <xsl:text>', '</xsl:text>
                                <xsl:value-of select="../@n"/>
                                <xsl:text>')</xsl:text>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="../@n"/>
                                <xsl:text>', '</xsl:text>
                                <xsl:value-of select="@n"/>
                                <xsl:text>', '</xsl:text>
                                <xsl:value-of
                                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/@xml:id"/>
                                <xsl:text>', '</xsl:text>
                                <xsl:value-of/>
                                <xsl:text>')</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:attribute>
                    <xsl:element name="span">
                        <xsl:attribute name="class">compare</xsl:attribute>
                        <xsl:text>&#x2022;</xsl:text>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:element>
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

    <xsl:template match="tei:ex">
        <xsl:element name="span">
            <xsl:attribute name="class">ex</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="tei:note">
        <xsl:variable name="num">
            <xsl:choose>
                <xsl:when test=".//body">
                    <xsl:number count="tei:note" level="any" from="tei:body"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:number count="tei:note" level="any" from="tei:surface"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:element name="span">
            <xsl:attribute name="class">
                <xsl:choose>
                    <xsl:when test="@n = 'explanatory'">
                        <xsl:text>footnote explanatory</xsl:text>
                    </xsl:when>
                    <xsl:when test="@n = 'informational'">
                        <xsl:text>footnote informational</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>footnote other</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:element name="sup">
                <xsl:element name="a">
                    <xsl:attribute name="href">
                        <xsl:value-of select="concat('#fn', $num)"/>
                    </xsl:attribute>
                    <xsl:attribute name="id"><xsl:value-of select="concat('fn', $num)"
                        />-ref</xsl:attribute>
                    <xsl:attribute name="title">link to footnote <xsl:value-of select="$num"
                        /></xsl:attribute>
                    <xsl:value-of select="$num"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
    </xsl:template>

    <xsl:template name="makeNotes">
        <xsl:variable name="num" select="count(.//tei:note[@n != 'dummy'])"/>
        <xsl:variable name="type" select="name()"/>
        <xsl:choose>
            <xsl:when test="$num > 0">
                <div class="notes col-10 col-s-10">
                    <div>
                        <xsl:choose>
                            <xsl:when test="$type = 'body'">
                                <xsl:attribute name="class">noteHeading paratext</xsl:attribute>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:attribute name="class">noteHeading</xsl:attribute>
                            </xsl:otherwise>
                        </xsl:choose> Notes </div>
                    <ol>
                        <xsl:for-each select=".//tei:note[@n != 'dummy']">
                            <xsl:choose>
                                <xsl:when test="@n = 'dummy'"/>
                                <xsl:otherwise>
                                    <div>
                                        <xsl:choose>
                                            <xsl:when test="$type = 'body'">
                                                <xsl:attribute name="class">note</xsl:attribute>
                                                <xsl:attribute name="id">paratext</xsl:attribute>
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <xsl:attribute name="class">note</xsl:attribute>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                        <li>
                                            <xsl:attribute name="id">
                                                <xsl:value-of select="concat('fn', position())"/>
                                            </xsl:attribute>
                                            <xsl:attribute name="class">
                                                <xsl:choose>
                                                  <xsl:when test="@n = 'explanatory'">
                                                  <xsl:text>explanatory</xsl:text>
                                                  </xsl:when>
                                                  <xsl:when test="@n = 'informational'">
                                                  <xsl:text>informational</xsl:text>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:text>other</xsl:text>
                                                  </xsl:otherwise>
                                                </xsl:choose>
                                                <xsl:text> footnote</xsl:text>
                                            </xsl:attribute>
                                            <div class="noteBody">
                                                <xsl:apply-templates/>
                                                <a>
                                                  <xsl:attribute name="href"><xsl:value-of
                                                  select="concat('#fn', position())"
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

    <xsl:template match="tei:emph">
        <xsl:choose>
            <xsl:when test="@rend = 'italic'">
                <i>
                    <xsl:apply-templates/>
                </i>
            </xsl:when>
            <xsl:when test="@rend = 'bold'">
                <b>
                    <xsl:apply-templates/>
                </b>
            </xsl:when>
            <xsl:when test="@rend = 'hidden'"/>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tei:teiHeader">
        <xsl:apply-templates/>
    </xsl:template>


    <xsl:template name="makeRendition">
        <xsl:param name="default"/>
        <xsl:param name="auto"/>
        <xsl:call-template name="makeLang"/>
        <xsl:choose>
            <xsl:when test="
                    (self::tei:q or self::tei:said or
                    self::tei:quote) and (@rend = 'inline' or
                    @rend = 'display') and
                    not(@rendition) and not(key('TAGREND', local-name(.)))">
                <xsl:sequence select="tei:processClass(local-name(), '', '')"/>
            </xsl:when>
            <xsl:when test="@rend">
                <xsl:sequence select="tei:processRend(@rend, $auto, .)"/>
            </xsl:when>
            <xsl:when test="@rendition or @style">
                <xsl:for-each select="@rendition">
                    <xsl:sequence select="tei:processRendition(., $auto)"/>
                </xsl:for-each>
                <xsl:for-each select="@style">
                    <xsl:sequence select="tei:processStyle(.)"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="key('TAGREND', local-name(.))">
                <xsl:for-each select="key('TAGREND', local-name(.))">
                    <xsl:sequence select="tei:processRendition(@render, $auto)"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="$default = 'false'"/>
            <xsl:when test="not($default = '')">
                <xsl:sequence select="tei:processClass($default, '', $auto)"/>
            </xsl:when>
            <xsl:when test="parent::tei:item/parent::tei:list[@rend]">
                <xsl:sequence
                    select="tei:processClass(parent::tei:item/parent::tei:list/@rend, '', $auto)"/>
            </xsl:when>
            <xsl:when test="parent::tei:item[@rend]">
                <xsl:sequence select="tei:processClass(parent::tei:item/@rend, '', $auto)"/>
            </xsl:when>
            <!--          <xsl:when test="self::tei:zone">
                <xsl:element name="div">
                    <xsl:attribute name="class">
                        <xsl:value-of select="zonewrapper"/>
                    </xsl:attribute>
                    <xsl:sequence select="tei:processClass(local-name(),'','')"/>
                    <xsl:sequence select="tei:processId(local-name(),'')"/>                    
                </xsl:element>
            </xsl:when> -->
            <xsl:when test="self::tei:line/@n">
                <xsl:sequence select="tei:processClass(local-name(), '', '')"/>
                <xsl:sequence select="tei:processId(@n, '')"/>
            </xsl:when>
            <xsl:when test="self::tei:zone/@n and self::tei:zone/@type">
                <xsl:sequence select="tei:processClass(@type, '')"/>
                <xsl:sequence select="tei:processId(@n, '')"/>
            </xsl:when>
            <xsl:when test="self::tei:zone/@n">
                <xsl:sequence select="tei:processClass(local-name(), @n, '')"/>
                <xsl:sequence select="tei:processId(@n, '')"/>
            </xsl:when>
            <xsl:when
                test="self::tei:surface and //tei:sourceDesc[1]/@xml:id = 'Clopton_Chantry_Chapel'">
                <xsl:sequence select="tei:processClass(local-name(), '', '')"/>
                <xsl:sequence select="tei:processId(//tei:surface[1]/@n, '')"/>
            </xsl:when>
            <xsl:when test="self::tei:surface">
                <xsl:sequence select="tei:processClass(local-name(), '', '')"/>
                <xsl:sequence select="tei:processId(//tei:surface[1]/@n, '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="tei:processClass(local-name(), '', '')"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="$outputTarget = 'html5'">
            <xsl:call-template name="microdata"/>
        </xsl:if>
    </xsl:template>


    <xsl:function name="tei:processClass" as="node()*">
        <xsl:param name="value"/>
        <xsl:param name="value2"/>
        <xsl:param name="auto"/>
        <xsl:attribute name="class">
            <xsl:if test="not($auto = '')">
                <xsl:value-of select="$auto"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$value = 'surface'">
                    <xsl:value-of select="concat($value, ' col-10 col-s-10')"/>
                </xsl:when>
                <xsl:when test="$value = 'zone'">
                    <xsl:choose>
                        <xsl:when test="$value2 = 'text'">
                            <xsl:value-of select="concat($value, ' text col-5 col-s-5')"/>
                        </xsl:when>
                        <xsl:when test="$value2 = 'marginalia'">
                            <xsl:value-of select="concat($value, ' marginalia col-5 col-s-5')"/>
                        </xsl:when>
                        <xsl:when test="$value2 = 'header'">
                            <xsl:value-of select="concat($value, ' page_header col-5 col-s-5')"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="concat($value, ' col-5 col-s-5')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:function>

    <xsl:function name="tei:processId" as="node()*">
        <xsl:param name="value"/>
        <xsl:param name="auto"/>

        <!-- <xsl:attribute name="id">
            <xsl:choose>
                <xsl:when test="$value = 'line'">
                    <xsl:value-of select="$value"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="not($auto = '')">
                        <xsl:value-of select="$auto"/>
                        <xsl:text> </xsl:text>
                    </xsl:if>
                    <xsl:value-of select="$value"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute> -->
    </xsl:function>

    <xsl:function name="tei:processTitle" as="node()*">
        <xsl:param name="value"/>
        <xsl:param name="auto"/>
        <xsl:attribute name="title">
            <xsl:if test="not($auto = '')">
                <xsl:value-of select="$auto"/>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:value-of select="$value"/>
        </xsl:attribute>
    </xsl:function>

    <xsl:function name="tei:processRend" as="node()*">
        <xsl:param name="value"/>
        <xsl:param name="auto"/>
        <xsl:param name="context"/>
        <xsl:variable name="values">
            <values xmlns="">
                <xsl:if test="not($auto = '')">
                    <c>
                        <xsl:value-of select="$auto"/>
                    </c>
                </xsl:if>
                <xsl:for-each select="tokenize($context/@style, ';')">
                    <s>
                        <xsl:value-of select="."/>
                    </s>
                </xsl:for-each>
                <xsl:for-each select="tokenize(normalize-space($value), ' ')">
                    <xsl:choose>
                        <xsl:when test=". = 'calligraphic' or . = 'cursive'">
                            <s>font-family:cursive</s>
                        </xsl:when>
                        <xsl:when test=". = 'center' or . = 'centered' or . = 'centred'">
                            <s>text-align: center</s>
                        </xsl:when>
                        <xsl:when test=". = 'expanded'">
                            <s>letter-spacing: 0.15em</s>
                        </xsl:when>
                        <xsl:when test=". = 'gothic'">
                            <s>font-family: Papyrus, fantasy</s>
                        </xsl:when>
                        <xsl:when test=". = 'indent'">
                            <s>text-indent: 5em</s>
                        </xsl:when>
                        <xsl:when test=". = 'large'">
                            <s>font-size: 130%</s>
                        </xsl:when>
                        <xsl:when test=". = 'larger'">
                            <s>font-size: 200%</s>
                        </xsl:when>
                        <xsl:when test=". = 'overbar'">
                            <s>text-decoration:overline</s>
                        </xsl:when>
                        <xsl:when test=". = 'plain'"/>
                        <xsl:when test=". = 'ro' or . = 'roman'">
                            <s>font-style: normal</s>
                        </xsl:when>
                        <xsl:when test=". = 'sc' or . = 'smcap' or . = 'smallcaps'">
                            <s>font-variant: small-caps</s>
                        </xsl:when>
                        <xsl:when test=". = 'small'">
                            <s>font-size: 75%</s>
                        </xsl:when>
                        <xsl:when test=". = 'smaller'">
                            <s>font-size: 50%</s>
                        </xsl:when>
                        <xsl:when test=". = 'spaced'">
                            <s>letter-spacing: 0.15em</s>
                        </xsl:when>
                        <xsl:when
                            test=". = 'sub' or . = 'sup' or . = 'code' or . = 'superscript' or . = 'subscript'"/>
                        <xsl:when test="starts-with(., 'background(')">
                            <s>
                                <xsl:text>background-color:</xsl:text>
                                <xsl:value-of
                                    select="substring-before(substring-after(., '('), ')')"/>
                            </s>
                        </xsl:when>
                        <xsl:when test="starts-with(., 'align(')">
                            <s>
                                <xsl:text>text-align:</xsl:text>
                                <xsl:value-of
                                    select="substring-before(substring-after(., '('), ')')"/>
                            </s>
                        </xsl:when>
                        <xsl:when test="starts-with(., 'color(')">
                            <s>
                                <xsl:text>color:</xsl:text>
                                <xsl:value-of
                                    select="substring-before(substring-after(., '('), ')')"/>
                            </s>
                        </xsl:when>
                        <xsl:when test="starts-with(., 'post(')">
                            <xsl:message terminate="yes">no support for post() pattern in
                                @rend</xsl:message>
                        </xsl:when>
                        <xsl:when test="starts-with(., 'pre(')">
                            <xsl:message terminate="yes">no support for pre() pattern in
                                @rend</xsl:message>
                        </xsl:when>
                        <xsl:when test=". = 'bold' or . = 'b'">
                            <s>font-weight:bold</s>
                        </xsl:when>
                        <xsl:when test=". = 'italic' or . = 'i'">
                            <s>font-style:italic</s>
                        </xsl:when>
                        <xsl:when test=". = 'strikethrough' or . = 'strike'">
                            <s>text-decoration: line-through</s>
                        </xsl:when>
                        <xsl:when test=". = 'underline'">
                            <s>text-decoration:underline</s>
                        </xsl:when>
                        <xsl:otherwise>
                            <c>
                                <xsl:value-of select="."/>
                            </c>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </values>
        </xsl:variable>
        <xsl:if test="$values/values/c">
            <xsl:attribute name="class">
                <xsl:value-of select="$values/values/c" separator=" "/>
            </xsl:attribute>
        </xsl:if>
        <xsl:if test="$values/values/s">
            <xsl:attribute name="style">
                <xsl:value-of select="$values/values/s" separator=";"/>
            </xsl:attribute>
        </xsl:if>
    </xsl:function>

</xsl:stylesheet>
