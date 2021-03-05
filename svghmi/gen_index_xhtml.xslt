<?xml version="1.0"?>
<xsl:stylesheet xmlns:ns="beremiz" xmlns:definitions="definitions" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:func="http://exslt.org/functions" xmlns:epilogue="epilogue" xmlns:preamble="preamble" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:sodipodi="http://sodipodi.sourceforge.net/DTD/sodipodi-0.dtd" xmlns:inkscape="http://www.inkscape.org/namespaces/inkscape" xmlns:svg="http://www.w3.org/2000/svg" xmlns:cc="http://creativecommons.org/ns#" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:str="http://exslt.org/strings" xmlns:regexp="http://exslt.org/regular-expressions" xmlns:exsl="http://exslt.org/common" xmlns:declarations="declarations" xmlns:debug="debug" exclude-result-prefixes="ns func exsl regexp str dyn debug preamble epilogue declarations definitions" extension-element-prefixes="ns func exsl regexp str dyn" version="1.0">
  <xsl:output method="xml" cdata-section-elements="xhtml:script"/>
  <xsl:variable name="svg" select="/svg:svg"/>
  <xsl:variable name="hmi_elements" select="//svg:*[starts-with(@inkscape:label, 'HMI:')]"/>
  <xsl:variable name="hmitree" select="ns:GetHMITree()"/>
  <xsl:variable name="_categories">
    <noindex>
      <xsl:text>HMI_PLC_STATUS</xsl:text>
    </noindex>
    <noindex>
      <xsl:text>HMI_CURRENT_PAGE</xsl:text>
    </noindex>
  </xsl:variable>
  <xsl:variable name="categories" select="exsl:node-set($_categories)"/>
  <xsl:variable name="_indexed_hmitree">
    <xsl:apply-templates mode="index" select="$hmitree"/>
  </xsl:variable>
  <xsl:variable name="indexed_hmitree" select="exsl:node-set($_indexed_hmitree)"/>
  <preamble:hmi-tree/>
  <xsl:template match="preamble:hmi-tree">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>var hmi_hash = [</xsl:text>
    <xsl:value-of select="$hmitree/@hash"/>
    <xsl:text>];
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>var heartbeat_index = </xsl:text>
    <xsl:value-of select="$indexed_hmitree/*[@hmipath = '/HEARTBEAT']/@index"/>
    <xsl:text>;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>var hmitree_types = [
</xsl:text>
    <xsl:for-each select="$indexed_hmitree/*">
      <xsl:text>    /* </xsl:text>
      <xsl:value-of select="@index"/>
      <xsl:text>  </xsl:text>
      <xsl:value-of select="@hmipath"/>
      <xsl:text> */ "</xsl:text>
      <xsl:value-of select="substring(local-name(), 5)"/>
      <xsl:text>"</xsl:text>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>];
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template mode="index" match="*">
    <xsl:param name="index" select="0"/>
    <xsl:param name="parentpath" select="''"/>
    <xsl:variable name="content">
      <xsl:variable name="path">
        <xsl:choose>
          <xsl:when test="count(ancestor::*)=0">
            <xsl:text>/</xsl:text>
          </xsl:when>
          <xsl:when test="count(ancestor::*)=1">
            <xsl:text>/</xsl:text>
            <xsl:value-of select="@name"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$parentpath"/>
            <xsl:text>/</xsl:text>
            <xsl:value-of select="@name"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:choose>
        <xsl:when test="not(local-name() = $categories/noindex)">
          <xsl:copy>
            <xsl:attribute name="index">
              <xsl:value-of select="$index"/>
            </xsl:attribute>
            <xsl:attribute name="hmipath">
              <xsl:value-of select="$path"/>
            </xsl:attribute>
            <xsl:for-each select="@*">
              <xsl:copy/>
            </xsl:for-each>
          </xsl:copy>
          <xsl:apply-templates mode="index" select="*[1]">
            <xsl:with-param name="index" select="$index + 1"/>
            <xsl:with-param name="parentpath">
              <xsl:value-of select="$path"/>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="index" select="*[1]">
            <xsl:with-param name="index" select="$index"/>
            <xsl:with-param name="parentpath">
              <xsl:value-of select="$path"/>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:copy-of select="$content"/>
    <xsl:apply-templates mode="index" select="following-sibling::*[1]">
      <xsl:with-param name="index" select="$index + count(exsl:node-set($content)/*)"/>
      <xsl:with-param name="parentpath">
        <xsl:value-of select="$parentpath"/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template mode="parselabel" match="*">
    <xsl:variable name="label" select="@inkscape:label"/>
    <xsl:variable name="id" select="@id"/>
    <xsl:variable name="description" select="substring-after($label,'HMI:')"/>
    <xsl:variable name="_args" select="substring-before($description,'@')"/>
    <xsl:variable name="args">
      <xsl:choose>
        <xsl:when test="$_args">
          <xsl:value-of select="$_args"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$description"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="_type" select="substring-before($args,':')"/>
    <xsl:variable name="type">
      <xsl:choose>
        <xsl:when test="$_type">
          <xsl:value-of select="$_type"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$args"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$type">
      <widget>
        <xsl:attribute name="id">
          <xsl:value-of select="$id"/>
        </xsl:attribute>
        <xsl:attribute name="type">
          <xsl:value-of select="$type"/>
        </xsl:attribute>
        <xsl:for-each select="str:split(substring-after($args, ':'), ':')">
          <arg>
            <xsl:attribute name="value">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </arg>
        </xsl:for-each>
        <xsl:variable name="paths" select="substring-after($description,'@')"/>
        <xsl:for-each select="str:split($paths, '@')">
          <xsl:if test="string-length(.) &gt; 0">
            <path>
              <xsl:variable name="pathminmax" select="str:split(.,',')"/>
              <xsl:variable name="path" select="$pathminmax[1]"/>
              <xsl:variable name="pathminmaxcount" select="count($pathminmax)"/>
              <xsl:attribute name="value">
                <xsl:value-of select="$path"/>
              </xsl:attribute>
              <xsl:choose>
                <xsl:when test="$pathminmaxcount = 3">
                  <xsl:attribute name="min">
                    <xsl:value-of select="$pathminmax[2]"/>
                  </xsl:attribute>
                  <xsl:attribute name="max">
                    <xsl:value-of select="$pathminmax[3]"/>
                  </xsl:attribute>
                </xsl:when>
                <xsl:when test="$pathminmaxcount = 2">
                  <xsl:message terminate="yes">
                    <xsl:text>Widget id:</xsl:text>
                    <xsl:value-of select="$id"/>
                    <xsl:text> label:</xsl:text>
                    <xsl:value-of select="$label"/>
                    <xsl:text> has wrong syntax of path section </xsl:text>
                    <xsl:value-of select="$pathminmax"/>
                  </xsl:message>
                </xsl:when>
              </xsl:choose>
              <xsl:choose>
                <xsl:when test="regexp:test($path,'^\.[a-zA-Z0-9_]+$')">
                  <xsl:attribute name="type">
                    <xsl:text>PAGE_LOCAL</xsl:text>
                  </xsl:attribute>
                </xsl:when>
                <xsl:when test="regexp:test($path,'^[a-zA-Z0-9_]+$')">
                  <xsl:attribute name="type">
                    <xsl:text>HMI_LOCAL</xsl:text>
                  </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:variable name="item" select="$indexed_hmitree/*[@hmipath = $path]"/>
                  <xsl:variable name="pathtype" select="local-name($item)"/>
                  <xsl:if test="$pathminmaxcount = 3 and not($pathtype = 'HMI_INT' or $pathtype = 'HMI_REAL')">
                    <xsl:message terminate="yes">
                      <xsl:text>Widget id:</xsl:text>
                      <xsl:value-of select="$id"/>
                      <xsl:text> label:</xsl:text>
                      <xsl:value-of select="$label"/>
                      <xsl:text> path section </xsl:text>
                      <xsl:value-of select="$pathminmax"/>
                      <xsl:text> use min and max on non mumeric value</xsl:text>
                    </xsl:message>
                  </xsl:if>
                  <xsl:if test="count($item) = 1">
                    <xsl:attribute name="index">
                      <xsl:value-of select="$item/@index"/>
                    </xsl:attribute>
                    <xsl:attribute name="type">
                      <xsl:value-of select="$pathtype"/>
                    </xsl:attribute>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
            </path>
          </xsl:if>
        </xsl:for-each>
      </widget>
    </xsl:if>
  </xsl:template>
  <xsl:variable name="_parsed_widgets">
    <widget type="VarInitPersistent">
      <arg value="0"/>
      <path value="lang"/>
    </widget>
    <xsl:apply-templates mode="parselabel" select="$hmi_elements"/>
  </xsl:variable>
  <xsl:variable name="parsed_widgets" select="exsl:node-set($_parsed_widgets)"/>
  <func:function name="func:widget">
    <xsl:param name="id"/>
    <func:result select="$parsed_widgets/widget[@id = $id]"/>
  </func:function>
  <func:function name="func:is_descendant_path">
    <xsl:param name="descend"/>
    <xsl:param name="ancest"/>
    <func:result select="string-length($ancest) &gt; 0 and starts-with($descend,$ancest)"/>
  </func:function>
  <func:function name="func:same_class_paths">
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:variable name="class_a" select="$indexed_hmitree/*[@hmipath = $a]/@class"/>
    <xsl:variable name="class_b" select="$indexed_hmitree/*[@hmipath = $b]/@class"/>
    <func:result select="$class_a and $class_b and $class_a = $class_b"/>
  </func:function>
  <xsl:template mode="testtree" match="*">
    <xsl:param name="indent" select="''"/>
    <xsl:value-of select="$indent"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> </xsl:text>
    <xsl:for-each select="@*">
      <xsl:value-of select="local-name()"/>
      <xsl:text>="</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>" </xsl:text>
    </xsl:for-each>
    <xsl:text>
</xsl:text>
    <xsl:apply-templates mode="testtree" select="*">
      <xsl:with-param name="indent">
        <xsl:value-of select="concat($indent,'&gt;')"/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>
  <debug:hmi-tree/>
  <xsl:template match="debug:hmi-tree">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>Raw HMI tree
</xsl:text>
    <xsl:apply-templates mode="testtree" select="$hmitree"/>
    <xsl:text>
</xsl:text>
    <xsl:text>Indexed HMI tree
</xsl:text>
    <xsl:apply-templates mode="testtree" select="$indexed_hmitree"/>
    <xsl:text>
</xsl:text>
    <xsl:text>Parsed Widgets
</xsl:text>
    <xsl:copy-of select="_parsed_widgets"/>
    <xsl:apply-templates mode="testtree" select="$parsed_widgets"/>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:variable name="geometry" select="ns:GetSVGGeometry()"/>
  <debug:geometry/>
  <xsl:template match="debug:geometry">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>ID, x, y, w, h
</xsl:text>
    <xsl:for-each select="$geometry">
      <xsl:text> </xsl:text>
      <xsl:value-of select="@Id"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@x"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@y"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@w"/>
      <xsl:text> </xsl:text>
      <xsl:value-of select="@h"/>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <func:function name="func:intersect_1d">
    <xsl:param name="a0"/>
    <xsl:param name="a1"/>
    <xsl:param name="b0"/>
    <xsl:param name="b1"/>
    <xsl:variable name="d0" select="$a0 &gt;= $b0"/>
    <xsl:variable name="d1" select="$a1 &gt;= $b1"/>
    <xsl:choose>
      <xsl:when test="not($d0) and $d1">
        <func:result select="3"/>
      </xsl:when>
      <xsl:when test="$d0 and not($d1)">
        <func:result select="2"/>
      </xsl:when>
      <xsl:when test="$d0 and $d1 and $a0 &lt; $b1">
        <func:result select="1"/>
      </xsl:when>
      <xsl:when test="not($d0) and not($d1) and $b0 &lt; $a1">
        <func:result select="1"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </func:function>
  <func:function name="func:intersect">
    <xsl:param name="a"/>
    <xsl:param name="b"/>
    <xsl:variable name="x_intersect" select="func:intersect_1d($a/@x, $a/@x+$a/@w, $b/@x, $b/@x+$b/@w)"/>
    <xsl:choose>
      <xsl:when test="$x_intersect != 0">
        <xsl:variable name="y_intersect" select="func:intersect_1d($a/@y, $a/@y+$a/@h, $b/@y, $b/@y+$b/@h)"/>
        <func:result select="$x_intersect * $y_intersect"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="0"/>
      </xsl:otherwise>
    </xsl:choose>
  </func:function>
  <xsl:variable name="groups" select="/svg:svg | //svg:g"/>
  <func:function name="func:overlapping_geometry">
    <xsl:param name="elt"/>
    <xsl:variable name="g" select="$geometry[@Id = $elt/@id]"/>
    <xsl:variable name="candidates" select="$geometry[@Id != $elt/@id]"/>
    <func:result select="$candidates[(@Id = $groups/@id and (func:intersect($g, .) = 9)) or &#10;                          (not(@Id = $groups/@id) and (func:intersect($g, .) &gt; 0 ))]"/>
  </func:function>
  <xsl:variable name="hmi_pages_descs" select="$parsed_widgets/widget[@type = 'Page']"/>
  <xsl:variable name="hmi_pages" select="$hmi_elements[@id = $hmi_pages_descs/@id]"/>
  <xsl:variable name="default_page">
    <xsl:choose>
      <xsl:when test="count($hmi_pages) &gt; 1">
        <xsl:choose>
          <xsl:when test="$hmi_pages_descs/arg[1]/@value = 'Home'">
            <xsl:text>Home</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:message terminate="yes">
              <xsl:text>No Home page defined!</xsl:text>
            </xsl:message>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="count($hmi_pages) = 0">
        <xsl:message terminate="yes">
          <xsl:text>No page defined!</xsl:text>
        </xsl:message>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="func:widget($hmi_pages/@id)/arg[1]/@value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <preamble:default-page/>
  <xsl:template match="preamble:default-page">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>var default_page = "</xsl:text>
    <xsl:value-of select="$default_page"/>
    <xsl:text>";
</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:variable name="keypads_descs" select="$parsed_widgets/widget[@type = 'Keypad']"/>
  <xsl:variable name="keypads" select="$hmi_elements[@id = $keypads_descs/@id]"/>
  <func:function name="func:refered_elements">
    <xsl:param name="elems"/>
    <xsl:variable name="descend" select="$elems/descendant-or-self::svg:*"/>
    <xsl:variable name="clones" select="$descend[self::svg:use]"/>
    <xsl:variable name="originals" select="//svg:*[concat('#',@id) = $clones/@xlink:href]"/>
    <xsl:choose>
      <xsl:when test="$originals">
        <func:result select="$descend | func:refered_elements($originals)"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="$descend"/>
      </xsl:otherwise>
    </xsl:choose>
  </func:function>
  <xsl:variable name="_overlapping_geometry">
    <xsl:for-each select="$hmi_pages | $keypads">
      <xsl:variable name="k" select="concat('overlapping:', @id)"/>
      <xsl:value-of select="ns:ProgressStart($k, concat('collecting membership of ', @inkscape:label))"/>
      <elt>
        <xsl:attribute name="id">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
        <xsl:copy-of select="func:overlapping_geometry(.)"/>
      </elt>
      <xsl:value-of select="ns:ProgressEnd($k)"/>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="overlapping_geometry" select="exsl:node-set($_overlapping_geometry)"/>
  <func:function name="func:all_related_elements">
    <xsl:param name="page"/>
    <xsl:variable name="page_overlapping_geometry" select="$overlapping_geometry/elt[@id = $page/@id]/*"/>
    <xsl:variable name="page_overlapping_elements" select="//svg:*[@id = $page_overlapping_geometry/@Id]"/>
    <xsl:variable name="page_sub_elements" select="func:refered_elements($page | $page_overlapping_elements)"/>
    <func:result select="$page_sub_elements"/>
  </func:function>
  <func:function name="func:required_elements">
    <xsl:param name="pages"/>
    <xsl:choose>
      <xsl:when test="$pages">
        <func:result select="func:all_related_elements($pages[1])&#10;                      | func:required_elements($pages[position()!=1])"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="/.."/>
      </xsl:otherwise>
    </xsl:choose>
  </func:function>
  <xsl:variable name="required_elements" select="//svg:defs/descendant-or-self::svg:*&#10;       | func:required_elements($hmi_pages | $keypads)/ancestor-or-self::svg:*"/>
  <xsl:variable name="discardable_elements" select="//svg:*[not(@id = $required_elements/@id)]"/>
  <func:function name="func:sumarized_elements">
    <xsl:param name="elements"/>
    <xsl:variable name="short_list" select="$elements[not(ancestor::*/@id = $elements/@id)]"/>
    <xsl:variable name="filled_groups" select="$short_list/parent::*[&#10;        not(child::*[&#10;            not(@id = $discardable_elements/@id) and&#10;            not(@id = $short_list/@id)&#10;        ])]"/>
    <xsl:variable name="groups_to_add" select="$filled_groups[not(ancestor::*/@id = $filled_groups/@id)]"/>
    <func:result select="$groups_to_add | $short_list[not(ancestor::*/@id = $filled_groups/@id)]"/>
  </func:function>
  <func:function name="func:detachable_elements">
    <xsl:param name="pages"/>
    <xsl:choose>
      <xsl:when test="$pages">
        <func:result select="func:sumarized_elements(func:all_related_elements($pages[1]))&#10;                      | func:detachable_elements($pages[position()!=1])"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="/.."/>
      </xsl:otherwise>
    </xsl:choose>
  </func:function>
  <xsl:variable name="_detachable_elements" select="func:detachable_elements($hmi_pages | $keypads)"/>
  <xsl:variable name="detachable_elements" select="$_detachable_elements[not(ancestor::*/@id = $_detachable_elements/@id)]"/>
  <declarations:detachable-elements/>
  <xsl:template match="declarations:detachable-elements">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>var detachable_elements = {
</xsl:text>
    <xsl:for-each select="$detachable_elements">
      <xsl:text>    "</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>":[id("</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>"), id("</xsl:text>
      <xsl:value-of select="../@id"/>
      <xsl:text>")]</xsl:text>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>}
</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:variable name="forEach_widgets_ids" select="$parsed_widgets/widget[@type = 'ForEach']/@id"/>
  <xsl:variable name="forEach_widgets" select="$hmi_widgets[@id = $forEach_widgets_ids]"/>
  <xsl:variable name="in_forEach_widget_ids" select="func:refered_elements($forEach_widgets)[not(@id = $forEach_widgets_ids)]/@id"/>
  <xsl:template mode="page_desc" match="svg:*">
    <xsl:if test="ancestor::*[@id = $hmi_pages/@id]">
      <xsl:message terminate="yes">
        <xsl:text>HMI:Page </xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text> is nested in another HMI:Page</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="desc" select="func:widget(@id)"/>
    <xsl:variable name="pagename" select="$desc/arg[1]/@value"/>
    <xsl:variable name="msg" select="concat('generating page description ', $pagename)"/>
    <xsl:value-of select="ns:ProgressStart($pagename, $msg)"/>
    <xsl:variable name="page" select="."/>
    <xsl:variable name="p" select="$geometry[@Id = $page/@id]"/>
    <xsl:variable name="page_all_elements" select="func:all_related_elements($page)"/>
    <xsl:variable name="all_page_widgets" select="$hmi_widgets[@id = $page_all_elements/@id and @id != $page/@id]"/>
    <xsl:variable name="page_managed_widgets" select="$all_page_widgets[not(@id=$in_forEach_widget_ids)]"/>
    <xsl:variable name="page_relative_widgets" select="$page_managed_widgets[func:is_descendant_path(func:widget(@id)/path/@value, $desc/path/@value)]"/>
    <xsl:variable name="sumarized_page" select="func:sumarized_elements($page_all_elements)"/>
    <xsl:variable name="required_detachables" select="$sumarized_page/&#10;           ancestor-or-self::*[@id = $detachable_elements/@id]"/>
    <xsl:text>  "</xsl:text>
    <xsl:value-of select="$pagename"/>
    <xsl:text>": {
</xsl:text>
    <xsl:text>    bbox: [</xsl:text>
    <xsl:value-of select="$p/@x"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$p/@y"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$p/@w"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$p/@h"/>
    <xsl:text>],
</xsl:text>
    <xsl:if test="$desc/path/@value">
      <xsl:if test="count($desc/path/@index)=0">
        <xsl:message terminate="no">
          <xsl:text>Page id="</xsl:text>
          <xsl:value-of select="$page/@id"/>
          <xsl:text>" : No match for path "</xsl:text>
          <xsl:value-of select="$desc/path/@value"/>
          <xsl:text>" in HMI tree</xsl:text>
        </xsl:message>
      </xsl:if>
      <xsl:text>    page_index: </xsl:text>
      <xsl:value-of select="$desc/path/@index"/>
      <xsl:text>,
</xsl:text>
    </xsl:if>
    <xsl:text>    widgets: [
</xsl:text>
    <xsl:for-each select="$page_managed_widgets">
      <xsl:variable name="widget_paths_relativeness">
        <xsl:for-each select="func:widget(@id)/path">
          <xsl:value-of select="func:is_descendant_path(@value, $desc/path/@value)"/>
          <xsl:if test="position()!=last()">
            <xsl:text>,</xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:variable>
      <xsl:text>        [hmi_widgets["</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>"], [</xsl:text>
      <xsl:value-of select="$widget_paths_relativeness"/>
      <xsl:text>]]</xsl:text>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>    ],
</xsl:text>
    <xsl:text>    jumps: [
</xsl:text>
    <xsl:for-each select="$parsed_widgets/widget[@id = $all_page_widgets/@id and @type='Jump']">
      <xsl:text>        hmi_widgets["</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>"]</xsl:text>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>    ],
</xsl:text>
    <xsl:text>    required_detachables: {
</xsl:text>
    <xsl:for-each select="$required_detachables">
      <xsl:text>        "</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>": detachable_elements["</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>"]</xsl:text>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>    }
</xsl:text>
    <xsl:apply-templates mode="per_page_widget_template" select="$parsed_widgets/widget[@id = $all_page_widgets/@id]">
      <xsl:with-param name="page_desc" select="$desc"/>
    </xsl:apply-templates>
    <xsl:text>  }</xsl:text>
    <xsl:if test="position()!=last()">
      <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:text>
</xsl:text>
    <xsl:value-of select="ns:ProgressEnd($pagename)"/>
  </xsl:template>
  <definitions:page-desc/>
  <xsl:template match="definitions:page-desc">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>var page_desc = {
</xsl:text>
    <xsl:apply-templates mode="page_desc" select="$hmi_pages"/>
    <xsl:text>}
</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template mode="per_page_widget_template" match="*"/>
  <debug:detachable-pages/>
  <xsl:template match="debug:detachable-pages">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>DETACHABLES:
</xsl:text>
    <xsl:for-each select="$detachable_elements">
      <xsl:text> </xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>In Foreach:
</xsl:text>
    <xsl:for-each select="$in_forEach_widget_ids">
      <xsl:text> </xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>Overlapping 
</xsl:text>
    <xsl:apply-templates mode="testtree" select="$overlapping_geometry"/>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template xmlns="http://www.w3.org/2000/svg" mode="inline_svg" match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template mode="inline_svg" match="node()">
    <xsl:if test="not(@id = $discardable_elements/@id)">
      <xsl:copy>
        <xsl:apply-templates mode="inline_svg" select="@* | node()"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>
  <xsl:template mode="inline_svg" match="svg:svg/@width"/>
  <xsl:template mode="inline_svg" match="svg:svg/@height"/>
  <xsl:template xmlns="http://www.w3.org/2000/svg" mode="inline_svg" match="svg:svg">
    <svg>
      <xsl:attribute name="preserveAspectRatio">
        <xsl:text>none</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="height">
        <xsl:text>100vh</xsl:text>
      </xsl:attribute>
      <xsl:attribute name="width">
        <xsl:text>100vw</xsl:text>
      </xsl:attribute>
      <xsl:apply-templates mode="inline_svg" select="@* | node()"/>
    </svg>
  </xsl:template>
  <xsl:template mode="inline_svg" match="svg:svg[@viewBox!=concat('0 0 ', @width, ' ', @height)]">
    <xsl:message terminate="yes">
      <xsl:text>ViewBox settings other than X=0, Y=0 and Scale=1 are not supported</xsl:text>
    </xsl:message>
  </xsl:template>
  <xsl:template mode="inline_svg" match="sodipodi:namedview[@units!='px' or @inkscape:document-units!='px']">
    <xsl:message terminate="yes">
      <xsl:text>All units must be set to "px" in Inkscape's document properties</xsl:text>
    </xsl:message>
  </xsl:template>
  <xsl:template xmlns="http://www.w3.org/2000/svg" mode="inline_svg" match="svg:text/@inkscape:label[starts-with(., '_')]">
    <xsl:attribute name="{name()}">
      <xsl:value-of select="substring(., 2)"/>
    </xsl:attribute>
  </xsl:template>
  <xsl:variable name="hmi_lists_descs" select="$parsed_widgets/widget[@type = 'List']"/>
  <xsl:variable name="hmi_lists" select="$hmi_elements[@id = $hmi_lists_descs/@id]"/>
  <xsl:variable name="targets_not_to_unlink" select="$hmi_lists/descendant-or-self::svg:*"/>
  <xsl:variable name="to_unlink" select="$hmi_elements[not(@id = $hmi_pages/@id)]/descendant-or-self::svg:use"/>
  <func:function name="func:is_unlinkable">
    <xsl:param name="targetid"/>
    <xsl:param name="eltid"/>
    <func:result select="$eltid = $to_unlink/@id and not($targetid = $targets_not_to_unlink/@id)"/>
  </func:function>
  <xsl:template xmlns="http://www.w3.org/2000/svg" mode="inline_svg" match="svg:use">
    <xsl:variable name="targetid" select="substring-after(@xlink:href,'#')"/>
    <xsl:choose>
      <xsl:when test="func:is_unlinkable($targetid, @id)">
        <xsl:call-template name="unlink_clone">
          <xsl:with-param name="targetid" select="$targetid"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="inline_svg" select="@*"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:variable name="_excluded_use_attrs">
    <name>
      <xsl:text>href</xsl:text>
    </name>
    <name>
      <xsl:text>width</xsl:text>
    </name>
    <name>
      <xsl:text>height</xsl:text>
    </name>
    <name>
      <xsl:text>x</xsl:text>
    </name>
    <name>
      <xsl:text>y</xsl:text>
    </name>
    <name>
      <xsl:text>id</xsl:text>
    </name>
  </xsl:variable>
  <xsl:variable name="excluded_use_attrs" select="exsl:node-set($_excluded_use_attrs)"/>
  <xsl:variable name="_merge_use_attrs">
    <name>
      <xsl:text>transform</xsl:text>
    </name>
    <name>
      <xsl:text>style</xsl:text>
    </name>
  </xsl:variable>
  <xsl:variable name="merge_use_attrs" select="exsl:node-set($_merge_use_attrs)"/>
  <xsl:template xmlns="http://www.w3.org/2000/svg" name="unlink_clone">
    <xsl:param name="targetid"/>
    <xsl:param name="seed" select="''"/>
    <xsl:variable name="target" select="//svg:*[@id = $targetid]"/>
    <xsl:variable name="seeded_id">
      <xsl:choose>
        <xsl:when test="string-length($seed) &gt; 0">
          <xsl:value-of select="$seed"/>
          <xsl:text>_</xsl:text>
          <xsl:value-of select="@id"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <g>
      <xsl:attribute name="id">
        <xsl:value-of select="$seeded_id"/>
      </xsl:attribute>
      <xsl:attribute name="original">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$target[self::svg:g]">
          <xsl:for-each select="@*[not(local-name() = $excluded_use_attrs/name | $merge_use_attrs)]">
            <xsl:attribute name="{name()}">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:if test="@style | $target/@style">
            <xsl:attribute name="style">
              <xsl:value-of select="@style"/>
              <xsl:if test="@style and $target/@style">
                <xsl:text>;</xsl:text>
              </xsl:if>
              <xsl:value-of select="$target/@style"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="@transform | $target/@transform">
            <xsl:attribute name="transform">
              <xsl:value-of select="@transform"/>
              <xsl:if test="@transform and $target/@transform">
                <xsl:text> </xsl:text>
              </xsl:if>
              <xsl:value-of select="$target/@transform"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates mode="unlink_clone" select="$target/*">
            <xsl:with-param name="seed" select="$seeded_id"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="@*[not(local-name() = $excluded_use_attrs/name)]">
            <xsl:attribute name="{name()}">
              <xsl:value-of select="."/>
            </xsl:attribute>
          </xsl:for-each>
          <xsl:apply-templates mode="unlink_clone" select="$target">
            <xsl:with-param name="seed" select="$seeded_id"/>
          </xsl:apply-templates>
        </xsl:otherwise>
      </xsl:choose>
    </g>
  </xsl:template>
  <xsl:template xmlns="http://www.w3.org/2000/svg" mode="unlink_clone" match="@id">
    <xsl:param name="seed"/>
    <xsl:attribute name="id">
      <xsl:value-of select="$seed"/>
      <xsl:text>_</xsl:text>
      <xsl:value-of select="."/>
    </xsl:attribute>
    <xsl:attribute name="original">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>
  <xsl:template xmlns="http://www.w3.org/2000/svg" mode="unlink_clone" match="@*">
    <xsl:copy/>
  </xsl:template>
  <xsl:template xmlns="http://www.w3.org/2000/svg" mode="unlink_clone" match="svg:use">
    <xsl:param name="seed"/>
    <xsl:variable name="targetid" select="substring-after(@xlink:href,'#')"/>
    <xsl:choose>
      <xsl:when test="func:is_unlinkable($targetid, @id)">
        <xsl:call-template name="unlink_clone">
          <xsl:with-param name="targetid" select="$targetid"/>
          <xsl:with-param name="seed" select="$seed"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="unlink_clone" select="@*">
            <xsl:with-param name="seed" select="$seed"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template xmlns="http://www.w3.org/2000/svg" mode="unlink_clone" match="svg:*">
    <xsl:param name="seed"/>
    <xsl:choose>
      <xsl:when test="@id = $hmi_elements/@id">
        <use>
          <xsl:attribute name="xlink:href">
            <xsl:value-of select="concat('#',@id)"/>
          </xsl:attribute>
        </use>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:apply-templates mode="unlink_clone" select="@* | node()">
            <xsl:with-param name="seed" select="$seed"/>
          </xsl:apply-templates>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:variable name="result_svg">
    <xsl:apply-templates mode="inline_svg" select="/"/>
  </xsl:variable>
  <xsl:variable name="result_svg_ns" select="exsl:node-set($result_svg)"/>
  <preamble:inline-svg/>
  <xsl:template match="preamble:inline-svg">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>let id = document.getElementById.bind(document);
</xsl:text>
    <xsl:text>var svg_root = id("</xsl:text>
    <xsl:value-of select="$svg/@id"/>
    <xsl:text>");
</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <debug:clone-unlinking/>
  <xsl:template match="debug:clone-unlinking">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>Unlinked :
</xsl:text>
    <xsl:for-each select="$to_unlink">
      <xsl:value-of select="@id"/>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>Not to unlink :
</xsl:text>
    <xsl:for-each select="$targets_not_to_unlink">
      <xsl:value-of select="@id"/>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template mode="extract_i18n" match="svg:tspan">
    <xsl:if test="string-length(.) &gt; 0">
      <line>
        <xsl:value-of select="."/>
      </line>
    </xsl:if>
  </xsl:template>
  <xsl:template mode="extract_i18n" match="svg:text">
    <msg>
      <xsl:attribute name="id">
        <xsl:value-of select="@id"/>
      </xsl:attribute>
      <xsl:attribute name="label">
        <xsl:value-of select="substring(@inkscape:label,2)"/>
      </xsl:attribute>
      <xsl:apply-templates mode="extract_i18n" select="svg:*"/>
    </msg>
  </xsl:template>
  <xsl:variable name="translatable_texts" select="//svg:text[starts-with(@inkscape:label, '_')]"/>
  <xsl:variable name="translatable_strings">
    <xsl:apply-templates mode="extract_i18n" select="$translatable_texts"/>
  </xsl:variable>
  <preamble:i18n/>
  <xsl:template match="preamble:i18n">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:variable name="translations" select="ns:GetTranslations($translatable_strings)"/>
    <xsl:text>var langs = [ ["Default", "C"],</xsl:text>
    <xsl:for-each select="$translations/langs/lang">
      <xsl:text>["</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>","</xsl:text>
      <xsl:value-of select="@code"/>
      <xsl:text>"]</xsl:text>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>];
</xsl:text>
    <xsl:text>var translations = [
</xsl:text>
    <xsl:for-each select="$translatable_texts">
      <xsl:variable name="n" select="position()"/>
      <xsl:variable name="current_id" select="@id"/>
      <xsl:variable name="text_unlinked_uses" select="$result_svg_ns//svg:text[@original = $current_id]/@id"/>
      <xsl:text>  [[</xsl:text>
      <xsl:for-each select="@id | $text_unlinked_uses">
        <xsl:text>id("</xsl:text>
        <xsl:value-of select="."/>
        <xsl:text>")</xsl:text>
        <xsl:if test="position()!=last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>],[</xsl:text>
      <xsl:for-each select="$translations/messages/msgid[$n]/msg">
        <xsl:text>"</xsl:text>
        <xsl:for-each select="line">
          <xsl:value-of select="."/>
          <xsl:if test="position()!=last()">
            <xsl:text>\n</xsl:text>
          </xsl:if>
        </xsl:for-each>
        <xsl:text>"</xsl:text>
        <xsl:if test="position()!=last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>]]</xsl:text>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>]
</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template mode="hmi_widgets" match="svg:*">
    <xsl:variable name="widget" select="func:widget(@id)"/>
    <xsl:variable name="eltid" select="@id"/>
    <xsl:variable name="args">
      <xsl:for-each select="$widget/arg">
        <xsl:text>"</xsl:text>
        <xsl:value-of select="func:escape_quotes(@value)"/>
        <xsl:text>"</xsl:text>
        <xsl:if test="position()!=last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="indexes">
      <xsl:for-each select="$widget/path">
        <xsl:choose>
          <xsl:when test="not(@index)">
            <xsl:choose>
              <xsl:when test="not(@type)">
                <xsl:message terminate="no">
                  <xsl:text>Widget </xsl:text>
                  <xsl:value-of select="$widget/@type"/>
                  <xsl:text> id="</xsl:text>
                  <xsl:value-of select="$eltid"/>
                  <xsl:text>" : No match for path "</xsl:text>
                  <xsl:value-of select="@value"/>
                  <xsl:text>" in HMI tree</xsl:text>
                </xsl:message>
                <xsl:text>undefined</xsl:text>
              </xsl:when>
              <xsl:when test="@type = 'PAGE_LOCAL'">
                <xsl:text>"</xsl:text>
                <xsl:value-of select="@value"/>
                <xsl:text>"</xsl:text>
              </xsl:when>
              <xsl:when test="@type = 'HMI_LOCAL'">
                <xsl:text>hmi_local_index("</xsl:text>
                <xsl:value-of select="@value"/>
                <xsl:text>")</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:message terminate="yes">
                  <xsl:text>Internal error while processing widget's non indexed HMI tree path : unknown type</xsl:text>
                </xsl:message>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@index"/>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="position()!=last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:variable name="minmaxes">
      <xsl:for-each select="$widget/path">
        <xsl:choose>
          <xsl:when test="@min and @max">
            <xsl:text>[</xsl:text>
            <xsl:value-of select="@min"/>
            <xsl:text>,</xsl:text>
            <xsl:value-of select="@max"/>
            <xsl:text>]</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>undefined</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="position()!=last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:text>  "</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>": new </xsl:text>
    <xsl:value-of select="$widget/@type"/>
    <xsl:text>Widget ("</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>",[</xsl:text>
    <xsl:value-of select="$args"/>
    <xsl:text>],[</xsl:text>
    <xsl:value-of select="$indexes"/>
    <xsl:text>],[</xsl:text>
    <xsl:value-of select="$minmaxes"/>
    <xsl:text>],{
</xsl:text>
    <xsl:apply-templates mode="widget_defs" select="$widget">
      <xsl:with-param name="hmi_element" select="."/>
    </xsl:apply-templates>
    <xsl:text>  })</xsl:text>
    <xsl:if test="position()!=last()">
      <xsl:text>,</xsl:text>
    </xsl:if>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <preamble:local-variable-indexes/>
  <xsl:template match="preamble:local-variable-indexes">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>let hmi_locals = {};
</xsl:text>
    <xsl:text>var last_remote_index = hmitree_types.length - 1;
</xsl:text>
    <xsl:text>var next_available_index = hmitree_types.length;
</xsl:text>
    <xsl:text>let cookies = new Map(document.cookie.split("; ").map(s=&gt;s.split("=")));
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>const local_defaults = {
</xsl:text>
    <xsl:for-each select="$parsed_widgets/widget[starts-with(@type,'VarInit')]">
      <xsl:if test="count(path) != 1">
        <xsl:message terminate="yes">
          <xsl:text>VarInit </xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text> must have only one variable given.</xsl:text>
        </xsl:message>
      </xsl:if>
      <xsl:if test="path/@type != 'PAGE_LOCAL' and path/@type != 'HMI_LOCAL'">
        <xsl:message terminate="yes">
          <xsl:text>VarInit </xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text> only applies to HMI variable.</xsl:text>
        </xsl:message>
      </xsl:if>
      <xsl:text>    "</xsl:text>
      <xsl:value-of select="path/@value"/>
      <xsl:text>":</xsl:text>
      <xsl:choose>
        <xsl:when test="@type = 'VarInitPersistent'">
          <xsl:text>cookies.has("</xsl:text>
          <xsl:value-of select="path/@value"/>
          <xsl:text>")?cookies.get("</xsl:text>
          <xsl:value-of select="path/@value"/>
          <xsl:text>"):</xsl:text>
          <xsl:value-of select="arg[1]/@value"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="arg[1]/@value"/>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:text>
</xsl:text>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text>};
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>const persistent_locals = new Set([
</xsl:text>
    <xsl:for-each select="$parsed_widgets/widget[@type='VarInitPersistent']">
      <xsl:text>   "</xsl:text>
      <xsl:value-of select="path/@value"/>
      <xsl:text>"</xsl:text>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>]);
</xsl:text>
    <xsl:text>var persistent_indexes = new Map();
</xsl:text>
    <xsl:text>var cache = hmitree_types.map(_ignored =&gt; undefined);
</xsl:text>
    <xsl:text>var updates = new Map();
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>function page_local_index(varname, pagename){
</xsl:text>
    <xsl:text>    let pagevars = hmi_locals[pagename];
</xsl:text>
    <xsl:text>    let new_index;
</xsl:text>
    <xsl:text>    if(pagevars == undefined){
</xsl:text>
    <xsl:text>        new_index = next_available_index++;
</xsl:text>
    <xsl:text>        hmi_locals[pagename] = {[varname]:new_index}
</xsl:text>
    <xsl:text>    } else {
</xsl:text>
    <xsl:text>        let result = pagevars[varname];
</xsl:text>
    <xsl:text>        if(result != undefined) {
</xsl:text>
    <xsl:text>            return result;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        new_index = next_available_index++;
</xsl:text>
    <xsl:text>        pagevars[varname] = new_index;
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    let defaultval = local_defaults[varname];
</xsl:text>
    <xsl:text>    if(defaultval != undefined) {
</xsl:text>
    <xsl:text>        cache[new_index] = defaultval; 
</xsl:text>
    <xsl:text>        updates.set(new_index, defaultval);
</xsl:text>
    <xsl:text>        if(persistent_locals.has(varname))
</xsl:text>
    <xsl:text>            persistent_indexes.set(new_index, varname);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    return new_index;
</xsl:text>
    <xsl:text>}
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>function hmi_local_index(varname){
</xsl:text>
    <xsl:text>    return page_local_index(varname, "HMI_LOCAL");
</xsl:text>
    <xsl:text>}
</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <preamble:widget-base-class/>
  <xsl:template match="preamble:widget-base-class">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>var pending_widget_animates = [];
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>class Widget {
</xsl:text>
    <xsl:text>    offset = 0;
</xsl:text>
    <xsl:text>    frequency = 10; /* FIXME arbitrary default max freq. Obtain from config ? */
</xsl:text>
    <xsl:text>    unsubscribable = false;
</xsl:text>
    <xsl:text>    pending_animate = false;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    constructor(elt_id,args,indexes,minmaxes,members){
</xsl:text>
    <xsl:text>        this.element_id = elt_id;
</xsl:text>
    <xsl:text>        this.element = id(elt_id);
</xsl:text>
    <xsl:text>        this.args = args;
</xsl:text>
    <xsl:text>        this.indexes = indexes;
</xsl:text>
    <xsl:text>        this.minmaxes = minmaxes;
</xsl:text>
    <xsl:text>        Object.keys(members).forEach(prop =&gt; this[prop]=members[prop]);
</xsl:text>
    <xsl:text>        this.lastapply = indexes.map(() =&gt; undefined);
</xsl:text>
    <xsl:text>        this.inhibit = indexes.map(() =&gt; undefined);
</xsl:text>
    <xsl:text>        this.pending = indexes.map(() =&gt; undefined);
</xsl:text>
    <xsl:text>        this.bound_unhinibit = this.unhinibit.bind(this);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    unsub(){
</xsl:text>
    <xsl:text>        /* remove subsribers */
</xsl:text>
    <xsl:text>        if(!this.unsubscribable)
</xsl:text>
    <xsl:text>            for(let i = 0; i &lt; this.indexes.length; i++) {
</xsl:text>
    <xsl:text>                /* flush updates pending because of inhibition */
</xsl:text>
    <xsl:text>                let inhibition = this.inhibit[i];
</xsl:text>
    <xsl:text>                if(inhibition != undefined){
</xsl:text>
    <xsl:text>                    clearTimeout(inhibition);
</xsl:text>
    <xsl:text>                    this.lastapply[i] = undefined;
</xsl:text>
    <xsl:text>                    this.unhinibit(i);
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                let index = this.indexes[i];
</xsl:text>
    <xsl:text>                if(this.relativeness[i])
</xsl:text>
    <xsl:text>                    index += this.offset;
</xsl:text>
    <xsl:text>                subscribers(index).delete(this);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        this.offset = 0;
</xsl:text>
    <xsl:text>        this.relativeness = undefined;
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    sub(new_offset=0, relativeness, container_id){
</xsl:text>
    <xsl:text>        this.offset = new_offset;
</xsl:text>
    <xsl:text>        this.relativeness = relativeness;
</xsl:text>
    <xsl:text>        this.container_id = container_id ;
</xsl:text>
    <xsl:text>        /* add this's subsribers */
</xsl:text>
    <xsl:text>        if(!this.unsubscribable)
</xsl:text>
    <xsl:text>            for(let i = 0; i &lt; this.indexes.length; i++) {
</xsl:text>
    <xsl:text>                let index = this.get_variable_index(i);
</xsl:text>
    <xsl:text>                if(index == undefined) continue;
</xsl:text>
    <xsl:text>                subscribers(index).add(this);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        need_cache_apply.push(this); 
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    apply_cache() {
</xsl:text>
    <xsl:text>        if(!this.unsubscribable) for(let index in this.indexes){
</xsl:text>
    <xsl:text>            /* dispatch current cache in newly opened page widgets */
</xsl:text>
    <xsl:text>            let realindex = this.get_variable_index(index);
</xsl:text>
    <xsl:text>            if(realindex == undefined) continue;
</xsl:text>
    <xsl:text>            let cached_val = cache[realindex];
</xsl:text>
    <xsl:text>            if(cached_val != undefined)
</xsl:text>
    <xsl:text>                this._dispatch(cached_val, cached_val, index);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    get_variable_index(varnum) {
</xsl:text>
    <xsl:text>        let index = this.indexes[varnum];
</xsl:text>
    <xsl:text>        if(typeof(index) == "string"){
</xsl:text>
    <xsl:text>            index = page_local_index(index, this.container_id);
</xsl:text>
    <xsl:text>        } else {
</xsl:text>
    <xsl:text>            if(this.relativeness[varnum]){
</xsl:text>
    <xsl:text>                index += this.offset;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        return index;
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    overshot(new_val, max) {
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    undershot(new_val, min) {
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    clip_min_max(index, new_val) {
</xsl:text>
    <xsl:text>        let minmax = this.minmaxes[index];
</xsl:text>
    <xsl:text>        if(minmax !== undefined &amp;&amp; typeof new_val == "number") {
</xsl:text>
    <xsl:text>            let [min,max] = minmax;
</xsl:text>
    <xsl:text>            if(new_val &lt; min){
</xsl:text>
    <xsl:text>                this.undershot(new_val, min);
</xsl:text>
    <xsl:text>                return min;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            if(new_val &gt; max){
</xsl:text>
    <xsl:text>                this.overshot(new_val, max);
</xsl:text>
    <xsl:text>                return max;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        return new_val;
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    change_hmi_value(index, opstr) {
</xsl:text>
    <xsl:text>        let realindex = this.get_variable_index(index);
</xsl:text>
    <xsl:text>        if(realindex == undefined) return undefined;
</xsl:text>
    <xsl:text>        let old_val = cache[realindex];
</xsl:text>
    <xsl:text>        let new_val = eval_operation_string(old_val, opstr);
</xsl:text>
    <xsl:text>        new_val = this.clip_min_max(index, new_val);
</xsl:text>
    <xsl:text>        return apply_hmi_value(realindex, new_val);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    _apply_hmi_value(index, new_val) {
</xsl:text>
    <xsl:text>        let realindex = this.get_variable_index(index);
</xsl:text>
    <xsl:text>        if(realindex == undefined) return undefined;
</xsl:text>
    <xsl:text>        new_val = this.clip_min_max(index, new_val);
</xsl:text>
    <xsl:text>        return apply_hmi_value(realindex, new_val);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    unhinibit(index){
</xsl:text>
    <xsl:text>        this.inhibit[index] = undefined;
</xsl:text>
    <xsl:text>        let new_val = this.pending[index];
</xsl:text>
    <xsl:text>        this.pending[index] = undefined;
</xsl:text>
    <xsl:text>        return this.apply_hmi_value(index, new_val);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    apply_hmi_value(index, new_val) {
</xsl:text>
    <xsl:text>        if(this.inhibit[index] == undefined){
</xsl:text>
    <xsl:text>            let now = Date.now();
</xsl:text>
    <xsl:text>            let min_interval = 1000/this.frequency;
</xsl:text>
    <xsl:text>            let lastapply = this.lastapply[index];
</xsl:text>
    <xsl:text>            if(lastapply == undefined || now &gt; lastapply + min_interval){
</xsl:text>
    <xsl:text>                this.lastapply[index] = now;
</xsl:text>
    <xsl:text>                return this._apply_hmi_value(index, new_val);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else {
</xsl:text>
    <xsl:text>                let elapsed = now - lastapply;
</xsl:text>
    <xsl:text>                this.pending[index] = new_val;
</xsl:text>
    <xsl:text>                this.inhibit[index] = setTimeout(this.bound_unhinibit, min_interval - elapsed, index);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else {
</xsl:text>
    <xsl:text>            this.pending[index] = new_val;
</xsl:text>
    <xsl:text>            return new_val;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    new_hmi_value(index, value, oldval) {
</xsl:text>
    <xsl:text>        // TODO avoid searching, store index at sub()
</xsl:text>
    <xsl:text>        for(let i = 0; i &lt; this.indexes.length; i++) {
</xsl:text>
    <xsl:text>            let refindex = this.get_variable_index(i);
</xsl:text>
    <xsl:text>            if(refindex == undefined) continue;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            if(index == refindex) {
</xsl:text>
    <xsl:text>                this._dispatch(value, oldval, i);
</xsl:text>
    <xsl:text>                break;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    
</xsl:text>
    <xsl:text>    _dispatch(value, oldval, varnum) {
</xsl:text>
    <xsl:text>        let dispatch = this.dispatch;
</xsl:text>
    <xsl:text>        if(dispatch != undefined){
</xsl:text>
    <xsl:text>            try {
</xsl:text>
    <xsl:text>                dispatch.call(this, value, oldval, varnum);
</xsl:text>
    <xsl:text>            } catch(err) {
</xsl:text>
    <xsl:text>                console.log(err);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    _animate(){
</xsl:text>
    <xsl:text>        this.animate();
</xsl:text>
    <xsl:text>        this.pending_animate = false;
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    request_animate(){
</xsl:text>
    <xsl:text>        if(!this.pending_animate){
</xsl:text>
    <xsl:text>            pending_widget_animates.push(this);
</xsl:text>
    <xsl:text>            this.pending_animate = true;
</xsl:text>
    <xsl:text>            requestHMIAnimation();
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    activate_activable(eltsub) {
</xsl:text>
    <xsl:text>        eltsub.inactive.style.display = "none";
</xsl:text>
    <xsl:text>        eltsub.active.style.display = "";
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    inactivate_activable(eltsub) {
</xsl:text>
    <xsl:text>        eltsub.active.style.display = "none";
</xsl:text>
    <xsl:text>        eltsub.inactive.style.display = "";
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:variable name="excluded_types" select="str:split('Page VarInit VarInitPersistent')"/>
  <xsl:key use="@type" name="TypesKey" match="widget"/>
  <declarations:hmi-classes/>
  <xsl:template match="declarations:hmi-classes">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:variable name="used_widget_types" select="$parsed_widgets/widget[&#10;                                    generate-id() = generate-id(key('TypesKey', @type)) and &#10;                                    not(@type = $excluded_types)]"/>
    <xsl:apply-templates mode="widget_class" select="$used_widget_types"/>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget">
    <xsl:text>class </xsl:text>
    <xsl:value-of select="@type"/>
    <xsl:text>Widget extends Widget{
</xsl:text>
    <xsl:text>    /* empty class, as </xsl:text>
    <xsl:value-of select="@type"/>
    <xsl:text> widget didn't provide any */
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:variable name="included_ids" select="$parsed_widgets/widget[not(@type = $excluded_types) and not(@id = $discardable_elements/@id)]/@id"/>
  <xsl:variable name="hmi_widgets" select="$hmi_elements[@id = $included_ids]"/>
  <xsl:variable name="result_widgets" select="$result_svg_ns//*[@id = $hmi_widgets/@id]"/>
  <declarations:hmi-elements/>
  <xsl:template match="declarations:hmi-elements">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>var hmi_widgets = {
</xsl:text>
    <xsl:apply-templates mode="hmi_widgets" select="$hmi_widgets"/>
    <xsl:text>}
</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template name="defs_by_labels">
    <xsl:param name="labels" select="''"/>
    <xsl:param name="mandatory" select="'yes'"/>
    <xsl:param name="subelements" select="/.."/>
    <xsl:param name="hmi_element"/>
    <xsl:variable name="widget_type" select="@type"/>
    <xsl:for-each select="str:split($labels)">
      <xsl:variable name="name" select="."/>
      <xsl:variable name="elt" select="$result_widgets[@id = $hmi_element/@id]//*[@inkscape:label=$name][1]"/>
      <xsl:choose>
        <xsl:when test="not($elt/@id)">
          <xsl:if test="$mandatory='yes'">
            <xsl:message terminate="yes">
              <xsl:value-of select="$widget_type"/>
              <xsl:text> widget must have a </xsl:text>
              <xsl:value-of select="$name"/>
              <xsl:text> element</xsl:text>
            </xsl:message>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>    </xsl:text>
          <xsl:value-of select="$name"/>
          <xsl:text>_elt: id("</xsl:text>
          <xsl:value-of select="$elt/@id"/>
          <xsl:text>"),
</xsl:text>
          <xsl:if test="$subelements">
            <xsl:text>    </xsl:text>
            <xsl:value-of select="$name"/>
            <xsl:text>_sub: {
</xsl:text>
            <xsl:for-each select="str:split($subelements)">
              <xsl:variable name="subname" select="."/>
              <xsl:variable name="subelt" select="$elt/*[@inkscape:label=$subname][1]"/>
              <xsl:choose>
                <xsl:when test="not($subelt/@id)">
                  <xsl:if test="$mandatory='yes'">
                    <xsl:message terminate="yes">
                      <xsl:value-of select="$widget_type"/>
                      <xsl:text> widget must have a </xsl:text>
                      <xsl:value-of select="$name"/>
                      <xsl:text>/</xsl:text>
                      <xsl:value-of select="$subname"/>
                      <xsl:text> element</xsl:text>
                    </xsl:message>
                  </xsl:if>
                  <xsl:text>        /* missing </xsl:text>
                  <xsl:value-of select="$name"/>
                  <xsl:text>/</xsl:text>
                  <xsl:value-of select="$subname"/>
                  <xsl:text> element */
</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>        "</xsl:text>
                  <xsl:value-of select="$subname"/>
                  <xsl:text>": id("</xsl:text>
                  <xsl:value-of select="$subelt/@id"/>
                  <xsl:text>")</xsl:text>
                  <xsl:if test="position()!=last()">
                    <xsl:text>,</xsl:text>
                  </xsl:if>
                  <xsl:text>
</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
            <xsl:text>    },
</xsl:text>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>
  <func:function name="func:escape_quotes">
    <xsl:param name="txt"/>
    <xsl:choose>
      <xsl:when test="contains($txt,'&quot;')">
        <func:result select="concat(substring-before($txt,'&quot;'),'\&quot;',func:escape_quotes(substring-after($txt,'&quot;')))"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="$txt"/>
      </xsl:otherwise>
    </xsl:choose>
  </func:function>
  <xsl:template mode="widget_class" match="widget[@type='Animate']">
    <xsl:text>class AnimateWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 5;
</xsl:text>
    <xsl:text>    speed = 0;
</xsl:text>
    <xsl:text>    start = false;
</xsl:text>
    <xsl:text>    widget_center = undefined;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    dispatch(value) {
</xsl:text>
    <xsl:text>        this.speed = value / 5;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //reconfigure animation
</xsl:text>
    <xsl:text>        this.request_animate();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    animate(){
</xsl:text>
    <xsl:text>       // change animation properties
</xsl:text>
    <xsl:text>       for(let child of this.element.children){
</xsl:text>
    <xsl:text>            if(child.nodeName.startsWith("animate")){
</xsl:text>
    <xsl:text>                if(this.speed != 0 &amp;&amp; !this.start){
</xsl:text>
    <xsl:text>                    this.start = true;
</xsl:text>
    <xsl:text>                    this.element.beginElement();
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>                if(this.speed &gt; 0){
</xsl:text>
    <xsl:text>                    child.setAttribute("dur", this.speed+"s");
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                else if(this.speed &lt; 0){
</xsl:text>
    <xsl:text>                    child.setAttribute("dur", (-1)*this.speed+"s");
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                else{
</xsl:text>
    <xsl:text>                    this.start = false;
</xsl:text>
    <xsl:text>                    this.element.endElement();
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>       }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    init() {
</xsl:text>
    <xsl:text>        let widget_pos = this.element.getBBox();
</xsl:text>
    <xsl:text>        this.widget_center = [(widget_pos.x+widget_pos.width/2), (widget_pos.y+widget_pos.height/2)];
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='Animate']">
    <xsl:param name="hmi_element"/>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='AnimateRotation']">
    <xsl:text>class AnimateRotationWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 5;
</xsl:text>
    <xsl:text>    speed = 0;
</xsl:text>
    <xsl:text>    widget_center = undefined;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    dispatch(value) {
</xsl:text>
    <xsl:text>        this.speed = value / 5;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //reconfigure animation
</xsl:text>
    <xsl:text>        this.request_animate();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    animate(){
</xsl:text>
    <xsl:text>       // change animation properties
</xsl:text>
    <xsl:text>       for(let child of this.element.children){
</xsl:text>
    <xsl:text>            if(child.nodeName == "animateTransform"){
</xsl:text>
    <xsl:text>                if(this.speed &gt; 0){
</xsl:text>
    <xsl:text>                    child.setAttribute("dur", this.speed+"s");
</xsl:text>
    <xsl:text>                    child.setAttribute("from", "0 "+this.widget_center[0]+" "+this.widget_center[1]);
</xsl:text>
    <xsl:text>                    child.setAttribute("to", "360 "+this.widget_center[0]+" "+this.widget_center[1]);
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                else if(this.speed &lt; 0){
</xsl:text>
    <xsl:text>                    child.setAttribute("dur", (-1)*this.speed+"s");
</xsl:text>
    <xsl:text>                    child.setAttribute("from", "360 "+this.widget_center[0]+" "+this.widget_center[1]);
</xsl:text>
    <xsl:text>                    child.setAttribute("to", "0 "+this.widget_center[0]+" "+this.widget_center[1]);
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                else{
</xsl:text>
    <xsl:text>                    child.setAttribute("from", "0 "+this.widget_center[0]+" "+this.widget_center[1]);
</xsl:text>
    <xsl:text>                    child.setAttribute("to", "0 "+this.widget_center[0]+" "+this.widget_center[1]);
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>       }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    init() {
</xsl:text>
    <xsl:text>        let widget_pos = this.element.getBBox();
</xsl:text>
    <xsl:text>        this.widget_center = [(widget_pos.x+widget_pos.width/2), (widget_pos.y+widget_pos.height/2)];
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='AnimateRotation']">
    <xsl:param name="hmi_element"/>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='Back']">
    <xsl:text>class BackWidget extends Widget{
</xsl:text>
    <xsl:text>    on_click(evt) {
</xsl:text>
    <xsl:text>        if(jump_history.length &gt; 1){
</xsl:text>
    <xsl:text>           jump_history.pop();
</xsl:text>
    <xsl:text>           let [page_name, index] = jump_history.pop();
</xsl:text>
    <xsl:text>           switch_page(page_name, index);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    init() {
</xsl:text>
    <xsl:text>        this.element.setAttribute("onclick", "hmi_widgets['"+this.element_id+"'].on_click(evt)");
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:variable name="_button_fsm">
    <fsm>
      <state name="init">
        <on-dispatch value="false">
          <jump state="released"/>
        </on-dispatch>
        <on-dispatch value="true">
          <jump state="pressed"/>
        </on-dispatch>
      </state>
      <state name="pressing">
        <hmi-value value="true"/>
        <on-dispatch value="true">
          <jump state="pressed"/>
        </on-dispatch>
        <on-mouse position="up">
          <jump state="shortpress"/>
        </on-mouse>
      </state>
      <state name="pressed">
        <show eltname="active"/>
        <on-mouse position="up">
          <jump state="releasing"/>
        </on-mouse>
        <on-dispatch value="false">
          <jump state="released"/>
        </on-dispatch>
      </state>
      <state name="shortpress">
        <on-dispatch value="true">
          <jump state="releasing"/>
        </on-dispatch>
        <on-mouse position="down">
          <jump state="pressing"/>
        </on-mouse>
      </state>
      <state name="releasing">
        <hmi-value value="false"/>
        <on-dispatch value="false">
          <jump state="released"/>
        </on-dispatch>
        <on-mouse position="down">
          <jump state="shortrelease"/>
        </on-mouse>
      </state>
      <state name="released">
        <show eltname="inactive"/>
        <on-mouse position="down">
          <jump state="pressing"/>
        </on-mouse>
        <on-dispatch value="true">
          <jump state="pressed"/>
        </on-dispatch>
      </state>
      <state name="shortrelease">
        <on-dispatch value="false">
          <jump state="pressing"/>
        </on-dispatch>
        <on-mouse position="up">
          <jump state="releasing"/>
        </on-mouse>
      </state>
    </fsm>
  </xsl:variable>
  <xsl:template mode="dispatch_transition" match="fsm">
    <xsl:text>        switch (this.state) {
</xsl:text>
    <xsl:apply-templates mode="dispatch_transition" select="state"/>
    <xsl:text>        }
</xsl:text>
  </xsl:template>
  <xsl:template mode="dispatch_transition" match="state">
    <xsl:text>          case "</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>":
</xsl:text>
    <xsl:apply-templates select="on-dispatch"/>
    <xsl:text>            break;
</xsl:text>
  </xsl:template>
  <xsl:template match="on-dispatch">
    <xsl:text>            if(value ==  </xsl:text>
    <xsl:value-of select="@value"/>
    <xsl:text>) {
</xsl:text>
    <xsl:apply-templates mode="transition" select="jump"/>
    <xsl:text>            }
</xsl:text>
  </xsl:template>
  <xsl:template mode="mouse_transition" match="fsm">
    <xsl:param name="position"/>
    <xsl:text>        switch (this.state) {
</xsl:text>
    <xsl:apply-templates mode="mouse_transition" select="state">
      <xsl:with-param name="position" select="$position"/>
    </xsl:apply-templates>
    <xsl:text>        }
</xsl:text>
  </xsl:template>
  <xsl:template mode="mouse_transition" match="state">
    <xsl:param name="position"/>
    <xsl:text>          case "</xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>":
</xsl:text>
    <xsl:apply-templates select="on-mouse[@position = $position]"/>
    <xsl:text>            break;
</xsl:text>
  </xsl:template>
  <xsl:template match="on-mouse">
    <xsl:apply-templates mode="transition" select="jump"/>
  </xsl:template>
  <xsl:template mode="transition" match="jump">
    <xsl:text>            this.state = "</xsl:text>
    <xsl:value-of select="@state"/>
    <xsl:text>";
</xsl:text>
    <xsl:text>            this.</xsl:text>
    <xsl:value-of select="@state"/>
    <xsl:text>_action();
</xsl:text>
  </xsl:template>
  <xsl:template mode="actions" match="fsm">
    <xsl:apply-templates mode="actions" select="state"/>
  </xsl:template>
  <xsl:template mode="actions" match="state">
    <xsl:text>    </xsl:text>
    <xsl:value-of select="@name"/>
    <xsl:text>_action(){
</xsl:text>
    <xsl:apply-templates mode="actions" select="*"/>
    <xsl:text>    }
</xsl:text>
  </xsl:template>
  <xsl:template mode="actions" match="show">
    <xsl:text>        this.display = "</xsl:text>
    <xsl:value-of select="@eltname"/>
    <xsl:text>";
</xsl:text>
    <xsl:text>        this.request_animate();
</xsl:text>
  </xsl:template>
  <xsl:template mode="actions" match="hmi-value">
    <xsl:text>        this.apply_hmi_value(0, </xsl:text>
    <xsl:value-of select="@value"/>
    <xsl:text>);
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='Button']">
    <xsl:variable name="fsm" select="exsl:node-set($_button_fsm)"/>
    <xsl:text>class ButtonWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 5;
</xsl:text>
    <xsl:text>    display = "inactive";
</xsl:text>
    <xsl:text>    state = "init";
</xsl:text>
    <xsl:text>    dispatch(value) {
</xsl:text>
    <xsl:apply-templates mode="dispatch_transition" select="$fsm"/>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    onmouseup(evt) {
</xsl:text>
    <xsl:text>        svg_root.removeEventListener("pointerup", this.bound_onmouseup, true);
</xsl:text>
    <xsl:apply-templates mode="mouse_transition" select="$fsm">
      <xsl:with-param name="position" select="'up'"/>
    </xsl:apply-templates>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    onmousedown(evt) {
</xsl:text>
    <xsl:text>        svg_root.addEventListener("pointerup", this.bound_onmouseup, true);
</xsl:text>
    <xsl:apply-templates mode="mouse_transition" select="$fsm">
      <xsl:with-param name="position" select="'down'"/>
    </xsl:apply-templates>
    <xsl:text>    }
</xsl:text>
    <xsl:apply-templates mode="actions" select="$fsm"/>
    <xsl:text>    animate(){
</xsl:text>
    <xsl:text>        if (this.active_elt &amp;&amp; this.inactive_elt) {
</xsl:text>
    <xsl:for-each select="str:split('active inactive')">
      <xsl:text>            if(this.display == "</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>")
</xsl:text>
      <xsl:text>                this.</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>_elt.style.display = "";
</xsl:text>
      <xsl:text>            else
</xsl:text>
      <xsl:text>                this.</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>_elt.style.display = "none";
</xsl:text>
    </xsl:for-each>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    init() {
</xsl:text>
    <xsl:text>        this.bound_onmouseup = this.onmouseup.bind(this);
</xsl:text>
    <xsl:text>        this.element.addEventListener("pointerdown", this.onmousedown.bind(this));
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='Button']">
    <xsl:param name="hmi_element"/>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>active inactive</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="mandatory" select="'no'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='CircularBar']">
    <xsl:text>class CircularBarWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 10;
</xsl:text>
    <xsl:text>    range = undefined;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    dispatch(value) {
</xsl:text>
    <xsl:text>        this.display_val = value;
</xsl:text>
    <xsl:text>        this.request_animate();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    animate(){
</xsl:text>
    <xsl:text>        if(this.value_elt)
</xsl:text>
    <xsl:text>            this.value_elt.textContent = String(this.display_val);
</xsl:text>
    <xsl:text>        let [min,max,start,end] = this.range;
</xsl:text>
    <xsl:text>        let [cx,cy] = this.center;
</xsl:text>
    <xsl:text>        let [rx,ry] = this.proportions;
</xsl:text>
    <xsl:text>        let tip = start + (end-start)*Number(this.display_val)/(max-min);
</xsl:text>
    <xsl:text>        let size = 0;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        if (tip-start &gt; Math.PI)
</xsl:text>
    <xsl:text>            size = 1;
</xsl:text>
    <xsl:text>        else
</xsl:text>
    <xsl:text>            size = 0;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        this.path_elt.setAttribute('d', "M "+(cx+rx*Math.cos(start))+","+(cy+ry*Math.sin(start))+
</xsl:text>
    <xsl:text>                                        " A "+rx+","+ry+
</xsl:text>
    <xsl:text>                                        " 0 "+size+
</xsl:text>
    <xsl:text>                                        " 1 "+(cx+rx*Math.cos(tip))+","+(cy+ry*Math.sin(tip)));
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    init() {
</xsl:text>
    <xsl:text>        let [start, end, cx, cy, rx, ry] = ["start", "end", "cx", "cy", "rx", "ry"].
</xsl:text>
    <xsl:text>            map(tag=&gt;Number(this.path_elt.getAttribute('sodipodi:'+tag)))
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        if (ry == 0) 
</xsl:text>
    <xsl:text>            ry = rx;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        if (start &gt; end)
</xsl:text>
    <xsl:text>            end = end + 2*Math.PI;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        let [min,max] = [[this.min_elt,0],[this.max_elt,100]].map(([elt,def],i)=&gt;elt?
</xsl:text>
    <xsl:text>            Number(elt.textContent) :
</xsl:text>
    <xsl:text>            this.args.length &gt;= i+1 ? this.args[i] : def);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        this.range = [min, max, start, end];
</xsl:text>
    <xsl:text>        this.center = [cx, cy];
</xsl:text>
    <xsl:text>        this.proportions = [rx, ry];
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='CircularBar']">
    <xsl:param name="hmi_element"/>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>path</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>value min max</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="mandatory" select="'no'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='CircularSlider']">
    <xsl:text>class CircularSliderWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 5;
</xsl:text>
    <xsl:text>    range = undefined;
</xsl:text>
    <xsl:text>    circle = undefined;
</xsl:text>
    <xsl:text>    handle_pos = undefined;
</xsl:text>
    <xsl:text>    curr_value = 0;
</xsl:text>
    <xsl:text>    drag = false;
</xsl:text>
    <xsl:text>    enTimer = false;
</xsl:text>
    <xsl:text>    last_drag = false;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    dispatch(value) {
</xsl:text>
    <xsl:text>        let [min,max,start,totallength] = this.range;
</xsl:text>
    <xsl:text>        //save current value inside widget
</xsl:text>
    <xsl:text>        this.curr_value = value;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //check if in range
</xsl:text>
    <xsl:text>        if (this.curr_value &gt; max){
</xsl:text>
    <xsl:text>            this.curr_value = max;
</xsl:text>
    <xsl:text>            this.apply_hmi_value(0, this.curr_value);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else if (this.curr_value &lt; min){
</xsl:text>
    <xsl:text>            this.curr_value = min;
</xsl:text>
    <xsl:text>            this.apply_hmi_value(0, this.curr_value);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        if(this.value_elt)
</xsl:text>
    <xsl:text>            this.value_elt.textContent = String(value);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //don't update if draging and setpoint ghost doesn't exist
</xsl:text>
    <xsl:text>        if(!this.drag || (this.setpoint_elt != undefined)){
</xsl:text>
    <xsl:text>            this.update_DOM(value, this.handle_elt);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    update_DOM(value, elt){
</xsl:text>
    <xsl:text>        let [min,max,totalDistance] = this.range;
</xsl:text>
    <xsl:text>        let length = Math.max(0,Math.min((totalDistance),(Number(value)-min)/(max-min)*(totalDistance)));
</xsl:text>
    <xsl:text>        let tip = this.range_elt.getPointAtLength(length);
</xsl:text>
    <xsl:text>        elt.setAttribute('transform',"translate("+(tip.x-this.handle_pos.x)+","+(tip.y-this.handle_pos.y)+")");
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        // show or hide ghost if exists
</xsl:text>
    <xsl:text>        if(this.setpoint_elt != undefined){
</xsl:text>
    <xsl:text>            if(this.last_drag!= this.drag){
</xsl:text>
    <xsl:text>                if(this.drag){
</xsl:text>
    <xsl:text>                    this.setpoint_elt.setAttribute("style", this.setpoint_style);
</xsl:text>
    <xsl:text>                }else{
</xsl:text>
    <xsl:text>                    this.setpoint_elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                this.last_drag = this.drag;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    on_release(evt) {
</xsl:text>
    <xsl:text>        //unbind events
</xsl:text>
    <xsl:text>        window.removeEventListener("touchmove", this.on_bound_drag, true);
</xsl:text>
    <xsl:text>        window.removeEventListener("mousemove", this.on_bound_drag, true);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        window.removeEventListener("mouseup", this.bound_on_release, true)
</xsl:text>
    <xsl:text>        window.removeEventListener("touchend", this.bound_on_release, true);
</xsl:text>
    <xsl:text>        window.removeEventListener("touchcancel", this.bound_on_release, true);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //reset drag flag
</xsl:text>
    <xsl:text>        if(this.drag){
</xsl:text>
    <xsl:text>            this.drag = false;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        // get final position
</xsl:text>
    <xsl:text>        this.update_position(evt);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    on_drag(evt){
</xsl:text>
    <xsl:text>        //ignore drag event for X amount of time and if not selected
</xsl:text>
    <xsl:text>        if(this.enTimer &amp;&amp; this.drag){
</xsl:text>
    <xsl:text>            this.update_position(evt);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            //reset timer
</xsl:text>
    <xsl:text>            this.enTimer = false;
</xsl:text>
    <xsl:text>            setTimeout("{hmi_widgets['"+this.element_id+"'].enTimer = true;}", 100);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    update_position(evt){
</xsl:text>
    <xsl:text>        if(this.drag &amp;&amp; this.enTimer){
</xsl:text>
    <xsl:text>            var svg_dist = 0;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            //calculate center of widget in html
</xsl:text>
    <xsl:text>            // --TODO maybe it would be better to bind this part to window change size event ???
</xsl:text>
    <xsl:text>            let [xdest,ydest,svgWidth,svgHeight] = page_desc[current_visible_page].bbox;
</xsl:text>
    <xsl:text>            let [cX, cY,fiStart,fiEnd,minMax,x1,y1,width,height] = this.circle;
</xsl:text>
    <xsl:text>            let htmlCirc = this.range_elt.getBoundingClientRect();
</xsl:text>
    <xsl:text>            let cxHtml = ((htmlCirc.right-htmlCirc.left)/(width)*(cX-x1))+htmlCirc.left;
</xsl:text>
    <xsl:text>            let cyHtml = ((htmlCirc.bottom-htmlCirc.top)/(height)*(cY-y1))+htmlCirc.top;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            //get mouse coordinates
</xsl:text>
    <xsl:text>            let mouseX = undefined;
</xsl:text>
    <xsl:text>            let mouseY = undefined;
</xsl:text>
    <xsl:text>            if (evt.type.startsWith("touch")){
</xsl:text>
    <xsl:text>                mouseX = Math.ceil(evt.touches[0].clientX);
</xsl:text>
    <xsl:text>                mouseY = Math.ceil(evt.touches[0].clientY);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else{
</xsl:text>
    <xsl:text>                mouseX = evt.pageX;
</xsl:text>
    <xsl:text>                mouseY = evt.pageY;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            //calculate angle
</xsl:text>
    <xsl:text>            let fi = Math.atan2(cyHtml-mouseY, mouseX-cxHtml);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            // transform from 0 to 2PI
</xsl:text>
    <xsl:text>            if (fi &gt; 0){
</xsl:text>
    <xsl:text>                fi = 2*Math.PI-fi;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else{
</xsl:text>
    <xsl:text>                fi = -fi;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            //offset it to 0
</xsl:text>
    <xsl:text>            fi = fi - fiStart;
</xsl:text>
    <xsl:text>            if (fi &lt; 0){
</xsl:text>
    <xsl:text>                fi = fi + 2*Math.PI;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            //get handle distance from mouse position
</xsl:text>
    <xsl:text>            if(fi&lt;fiEnd){
</xsl:text>
    <xsl:text>               this.curr_value=(fi)/(fiEnd)*(this.range[1]-this.range[0]);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else if(fiEnd&lt;fi &amp;&amp; fi&lt;fiEnd+minMax){
</xsl:text>
    <xsl:text>                this.curr_value = this.range[1];
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else{
</xsl:text>
    <xsl:text>                this.curr_value = this.range[0];
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            //apply value to hmi
</xsl:text>
    <xsl:text>            this.apply_hmi_value(0, Math.ceil(this.curr_value));
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            //redraw handle
</xsl:text>
    <xsl:text>            this.request_animate();
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    animate(){
</xsl:text>
    <xsl:text>        // redraw handle on screen refresh
</xsl:text>
    <xsl:text>        // check if setpoint(ghost) handle exsist otherwise update main handle
</xsl:text>
    <xsl:text>        if(this.setpoint_elt != undefined){
</xsl:text>
    <xsl:text>            this.update_DOM(this.curr_value, this.setpoint_elt);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else{
</xsl:text>
    <xsl:text>            this.update_DOM(this.curr_value, this.handle_elt);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    on_select(evt){
</xsl:text>
    <xsl:text>        //enable drag flag and timer
</xsl:text>
    <xsl:text>        this.drag = true;
</xsl:text>
    <xsl:text>        this.enTimer = true;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //bind events
</xsl:text>
    <xsl:text>        window.addEventListener("touchmove", this.on_bound_drag, true);
</xsl:text>
    <xsl:text>        window.addEventListener("mousemove", this.on_bound_drag, true);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        window.addEventListener("mouseup", this.bound_on_release, true);
</xsl:text>
    <xsl:text>        window.addEventListener("touchend", this.bound_on_release, true);
</xsl:text>
    <xsl:text>        window.addEventListener("touchcancel", this.bound_on_release, true);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //update postion on mouse press
</xsl:text>
    <xsl:text>        this.update_position(evt);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //prevent next events
</xsl:text>
    <xsl:text>        evt.stopPropagation();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    init() {
</xsl:text>
    <xsl:text>        //get min max
</xsl:text>
    <xsl:text>        let min = this.min_elt ?
</xsl:text>
    <xsl:text>                    Number(this.min_elt.textContent) :
</xsl:text>
    <xsl:text>                    this.args.length &gt;= 1 ? this.args[0] : 0;
</xsl:text>
    <xsl:text>        let max = this.max_elt ?
</xsl:text>
    <xsl:text>                    Number(this.max_elt.textContent) :
</xsl:text>
    <xsl:text>                    this.args.length &gt;= 2 ? this.args[1] : 100;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //fiStart ==&gt; offset
</xsl:text>
    <xsl:text>        let fiStart = Number(this.range_elt.getAttribute('sodipodi:start'));
</xsl:text>
    <xsl:text>        let fiEnd = Number(this.range_elt.getAttribute('sodipodi:end'));
</xsl:text>
    <xsl:text>        fiEnd = fiEnd - fiStart;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //fiEnd ==&gt; size of angle
</xsl:text>
    <xsl:text>        if (fiEnd &lt; 0){
</xsl:text>
    <xsl:text>            fiEnd = 2*Math.PI + fiEnd;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //min max barrier angle
</xsl:text>
    <xsl:text>        let minMax = (2*Math.PI - fiEnd)/2;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //get parameters from svg
</xsl:text>
    <xsl:text>        let cX = Number(this.range_elt.getAttribute('sodipodi:cx'));
</xsl:text>
    <xsl:text>        let cY = Number(this.range_elt.getAttribute('sodipodi:cy'));
</xsl:text>
    <xsl:text>        this.range_elt.style.strokeMiterlimit="0"; //eliminates some weird border around html object
</xsl:text>
    <xsl:text>        this.range = [min, max,this.range_elt.getTotalLength()];
</xsl:text>
    <xsl:text>        let cPos = this.range_elt.getBBox();
</xsl:text>
    <xsl:text>        this.handle_pos = this.range_elt.getPointAtLength(0);
</xsl:text>
    <xsl:text>        this.circle = [cX, cY,fiStart,fiEnd,minMax,cPos.x,cPos.y,cPos.width,cPos.height];
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //bind functions
</xsl:text>
    <xsl:text>        this.bound_on_select = this.on_select.bind(this);
</xsl:text>
    <xsl:text>        this.bound_on_release = this.on_release.bind(this);
</xsl:text>
    <xsl:text>        this.on_bound_drag = this.on_drag.bind(this);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        this.handle_elt.addEventListener("mousedown", this.bound_on_select);
</xsl:text>
    <xsl:text>        this.element.addEventListener("mousedown", this.bound_on_select);
</xsl:text>
    <xsl:text>        this.element.addEventListener("touchstart", this.bound_on_select);
</xsl:text>
    <xsl:text>        //touch recognised as page drag without next command
</xsl:text>
    <xsl:text>        document.body.addEventListener("touchstart", function(e){}, false);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //save ghost style
</xsl:text>
    <xsl:text>        //save ghost style
</xsl:text>
    <xsl:text>        if(this.setpoint_elt != undefined){
</xsl:text>
    <xsl:text>            this.setpoint_style = this.setpoint_elt.getAttribute("style");
</xsl:text>
    <xsl:text>            this.setpoint_elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='CircularSlider']">
    <xsl:param name="hmi_element"/>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>handle range</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>value min max setpoint</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="mandatory" select="'no'"/>
    </xsl:call-template>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='CustomHtml']">
    <xsl:text>class CustomHtmlWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 5;
</xsl:text>
    <xsl:text>    widget_size = undefined;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    dispatch(value) {
</xsl:text>
    <xsl:text>        this.request_animate();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    animate(){
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    init() {
</xsl:text>
    <xsl:text>        this.widget_size = this.container_elt.getBBox();
</xsl:text>
    <xsl:text>        this.element.innerHTML ='&lt;foreignObject x="'+
</xsl:text>
    <xsl:text>            this.widget_size.x+'" y="'+this.widget_size.y+
</xsl:text>
    <xsl:text>            '" width="'+this.widget_size.width+'" height="'+this.widget_size.height+'"&gt; '+
</xsl:text>
    <xsl:text>            this.code_elt.textContent+
</xsl:text>
    <xsl:text>            ' &lt;/foreignObject&gt;';
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='CustomHtml']">
    <xsl:param name="hmi_element"/>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>container code</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='Display']">
    <xsl:text>class DisplayWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 5;
</xsl:text>
    <xsl:text>    dispatch(value, oldval, index) {
</xsl:text>
    <xsl:text>        this.fields[index] = value;    
</xsl:text>
    <xsl:text>        this.request_animate();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='Display']">
    <xsl:param name="hmi_element"/>
    <xsl:variable name="format">
      <xsl:call-template name="defs_by_labels">
        <xsl:with-param name="hmi_element" select="$hmi_element"/>
        <xsl:with-param name="labels">
          <xsl:text>format</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="mandatory" select="'no'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="has_format" select="string-length($format)&gt;0"/>
    <xsl:value-of select="$format"/>
    <xsl:if test="$hmi_element[not(self::svg:text)] and not($has_format)">
      <xsl:message terminate="yes">
        <xsl:text>Display Widget id="</xsl:text>
        <xsl:value-of select="$hmi_element/@id"/>
        <xsl:text>" must be a svg::text element itself or a group containing a svg:text element labelled "format"</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="field_initializer">
      <xsl:for-each select="path">
        <xsl:choose>
          <xsl:when test="@type='HMI_STRING'">
            <xsl:text>""</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>0</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="position()!=last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>
    <xsl:text>    fields: [</xsl:text>
    <xsl:value-of select="$field_initializer"/>
    <xsl:text>],
</xsl:text>
    <xsl:text>    animate: function(){
</xsl:text>
    <xsl:choose>
      <xsl:when test="$has_format">
        <xsl:text>      if(this.format_elt.getAttribute("lang")) {
</xsl:text>
        <xsl:text>          this.format = svg_text_to_multiline(this.format_elt);
</xsl:text>
        <xsl:text>          this.format_elt.removeAttribute("lang");
</xsl:text>
        <xsl:text>      }
</xsl:text>
        <xsl:text>      let str = vsprintf(this.format,this.fields);
</xsl:text>
        <xsl:text>      multiline_to_svg_text(this.format_elt, str);
</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>      let str = this.args.length == 1 ? vsprintf(this.args[0],this.fields) : this.fields.join(' ');
</xsl:text>
        <xsl:text>      multiline_to_svg_text(this.element, str);
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>    },
</xsl:text>
    <xsl:text>    
</xsl:text>
    <xsl:if test="$has_format">
      <xsl:text>    init: function() {
</xsl:text>
      <xsl:text>      this.format = svg_text_to_multiline(this.format_elt);
</xsl:text>
      <xsl:text>    },
</xsl:text>
    </xsl:if>
  </xsl:template>
  <preamble:display/>
  <xsl:template match="preamble:display">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>/* https://github.com/alexei/sprintf.js/blob/master/src/sprintf.js */
</xsl:text>
    <xsl:text>/* global window, exports, define */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>!function() {
</xsl:text>
    <xsl:text>    'use strict'
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    var re = {
</xsl:text>
    <xsl:text>        not_string: /[^s]/,
</xsl:text>
    <xsl:text>        not_bool: /[^t]/,
</xsl:text>
    <xsl:text>        not_type: /[^T]/,
</xsl:text>
    <xsl:text>        not_primitive: /[^v]/,
</xsl:text>
    <xsl:text>        number: /[diefg]/,
</xsl:text>
    <xsl:text>        numeric_arg: /[bcdiefguxX]/,
</xsl:text>
    <xsl:text>        json: /[j]/,
</xsl:text>
    <xsl:text>        not_json: /[^j]/,
</xsl:text>
    <xsl:text>        text: /^[^%]+/,
</xsl:text>
    <xsl:text>        modulo: /^%{2}/,
</xsl:text>
    <xsl:text>        placeholder: /^%(?:([1-9]\d*)\$|\(([^)]+)\))?(\+)?(0|'[^$])?(-)?(\d+)?(?:\.(\d+))?([b-gijostTuvxX])/,
</xsl:text>
    <xsl:text>        key: /^([a-z_][a-z_\d]*)/i,
</xsl:text>
    <xsl:text>        key_access: /^\.([a-z_][a-z_\d]*)/i,
</xsl:text>
    <xsl:text>        index_access: /^\[(\d+)\]/,
</xsl:text>
    <xsl:text>        sign: /^[+-]/
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    function sprintf(key) {
</xsl:text>
    <xsl:text>        // </xsl:text>
    <arguments/>
    <xsl:text> is not an array, but should be fine for this call
</xsl:text>
    <xsl:text>        return sprintf_format(sprintf_parse(key), arguments)
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    function vsprintf(fmt, argv) {
</xsl:text>
    <xsl:text>        return sprintf.apply(null, [fmt].concat(argv || []))
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    function sprintf_format(parse_tree, argv) {
</xsl:text>
    <xsl:text>        var cursor = 1, tree_length = parse_tree.length, arg, output = '', i, k, ph, pad, pad_character, pad_length, is_positive, sign
</xsl:text>
    <xsl:text>        for (i = 0; i &lt; tree_length; i++) {
</xsl:text>
    <xsl:text>            if (typeof parse_tree[i] === 'string') {
</xsl:text>
    <xsl:text>                output += parse_tree[i]
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else if (typeof parse_tree[i] === 'object') {
</xsl:text>
    <xsl:text>                ph = parse_tree[i] // convenience purposes only
</xsl:text>
    <xsl:text>                if (ph.keys) { // keyword argument
</xsl:text>
    <xsl:text>                    arg = argv[cursor]
</xsl:text>
    <xsl:text>                    for (k = 0; k &lt; ph.keys.length; k++) {
</xsl:text>
    <xsl:text>                        if (arg == undefined) {
</xsl:text>
    <xsl:text>                            throw new Error(sprintf('[sprintf] Cannot access property "%s" of undefined value "%s"', ph.keys[k], ph.keys[k-1]))
</xsl:text>
    <xsl:text>                        }
</xsl:text>
    <xsl:text>                        arg = arg[ph.keys[k]]
</xsl:text>
    <xsl:text>                    }
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                else if (ph.param_no) { // positional argument (explicit)
</xsl:text>
    <xsl:text>                    arg = argv[ph.param_no]
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                else { // positional argument (implicit)
</xsl:text>
    <xsl:text>                    arg = argv[cursor++]
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>                if (re.not_type.test(ph.type) &amp;&amp; re.not_primitive.test(ph.type) &amp;&amp; arg instanceof Function) {
</xsl:text>
    <xsl:text>                    arg = arg()
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>                if (re.numeric_arg.test(ph.type) &amp;&amp; (typeof arg !== 'number' &amp;&amp; isNaN(arg))) {
</xsl:text>
    <xsl:text>                    throw new TypeError(sprintf('[sprintf] expecting number but found %T', arg))
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>                if (re.number.test(ph.type)) {
</xsl:text>
    <xsl:text>                    is_positive = arg &gt;= 0
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>                switch (ph.type) {
</xsl:text>
    <xsl:text>                    case 'b':
</xsl:text>
    <xsl:text>                        arg = parseInt(arg, 10).toString(2)
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 'c':
</xsl:text>
    <xsl:text>                        arg = String.fromCharCode(parseInt(arg, 10))
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 'd':
</xsl:text>
    <xsl:text>                    case 'i':
</xsl:text>
    <xsl:text>                        arg = parseInt(arg, 10)
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 'j':
</xsl:text>
    <xsl:text>                        arg = JSON.stringify(arg, null, ph.width ? parseInt(ph.width) : 0)
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 'e':
</xsl:text>
    <xsl:text>                        arg = ph.precision ? parseFloat(arg).toExponential(ph.precision) : parseFloat(arg).toExponential()
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 'f':
</xsl:text>
    <xsl:text>                        arg = ph.precision ? parseFloat(arg).toFixed(ph.precision) : parseFloat(arg)
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 'g':
</xsl:text>
    <xsl:text>                        arg = ph.precision ? String(Number(arg.toPrecision(ph.precision))) : parseFloat(arg)
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 'o':
</xsl:text>
    <xsl:text>                        arg = (parseInt(arg, 10) &gt;&gt;&gt; 0).toString(8)
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 's':
</xsl:text>
    <xsl:text>                        arg = String(arg)
</xsl:text>
    <xsl:text>                        arg = (ph.precision ? arg.substring(0, ph.precision) : arg)
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 't':
</xsl:text>
    <xsl:text>                        arg = String(!!arg)
</xsl:text>
    <xsl:text>                        arg = (ph.precision ? arg.substring(0, ph.precision) : arg)
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 'T':
</xsl:text>
    <xsl:text>                        arg = Object.prototype.toString.call(arg).slice(8, -1).toLowerCase()
</xsl:text>
    <xsl:text>                        arg = (ph.precision ? arg.substring(0, ph.precision) : arg)
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 'u':
</xsl:text>
    <xsl:text>                        arg = parseInt(arg, 10) &gt;&gt;&gt; 0
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 'v':
</xsl:text>
    <xsl:text>                        arg = arg.valueOf()
</xsl:text>
    <xsl:text>                        arg = (ph.precision ? arg.substring(0, ph.precision) : arg)
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 'x':
</xsl:text>
    <xsl:text>                        arg = (parseInt(arg, 10) &gt;&gt;&gt; 0).toString(16)
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                    case 'X':
</xsl:text>
    <xsl:text>                        arg = (parseInt(arg, 10) &gt;&gt;&gt; 0).toString(16).toUpperCase()
</xsl:text>
    <xsl:text>                        break
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                if (re.json.test(ph.type)) {
</xsl:text>
    <xsl:text>                    output += arg
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                else {
</xsl:text>
    <xsl:text>                    if (re.number.test(ph.type) &amp;&amp; (!is_positive || ph.sign)) {
</xsl:text>
    <xsl:text>                        sign = is_positive ? '+' : '-'
</xsl:text>
    <xsl:text>                        arg = arg.toString().replace(re.sign, '')
</xsl:text>
    <xsl:text>                    }
</xsl:text>
    <xsl:text>                    else {
</xsl:text>
    <xsl:text>                        sign = ''
</xsl:text>
    <xsl:text>                    }
</xsl:text>
    <xsl:text>                    pad_character = ph.pad_char ? ph.pad_char === '0' ? '0' : ph.pad_char.charAt(1) : ' '
</xsl:text>
    <xsl:text>                    pad_length = ph.width - (sign + arg).length
</xsl:text>
    <xsl:text>                    pad = ph.width ? (pad_length &gt; 0 ? pad_character.repeat(pad_length) : '') : ''
</xsl:text>
    <xsl:text>                    output += ph.align ? sign + arg + pad : (pad_character === '0' ? sign + pad + arg : pad + sign + arg)
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        return output
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    var sprintf_cache = Object.create(null)
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    function sprintf_parse(fmt) {
</xsl:text>
    <xsl:text>        if (sprintf_cache[fmt]) {
</xsl:text>
    <xsl:text>            return sprintf_cache[fmt]
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        var _fmt = fmt, match, parse_tree = [], arg_names = 0
</xsl:text>
    <xsl:text>        while (_fmt) {
</xsl:text>
    <xsl:text>            if ((match = re.text.exec(_fmt)) !== null) {
</xsl:text>
    <xsl:text>                parse_tree.push(match[0])
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else if ((match = re.modulo.exec(_fmt)) !== null) {
</xsl:text>
    <xsl:text>                parse_tree.push('%')
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else if ((match = re.placeholder.exec(_fmt)) !== null) {
</xsl:text>
    <xsl:text>                if (match[2]) {
</xsl:text>
    <xsl:text>                    arg_names |= 1
</xsl:text>
    <xsl:text>                    var field_list = [], replacement_field = match[2], field_match = []
</xsl:text>
    <xsl:text>                    if ((field_match = re.key.exec(replacement_field)) !== null) {
</xsl:text>
    <xsl:text>                        field_list.push(field_match[1])
</xsl:text>
    <xsl:text>                        while ((replacement_field = replacement_field.substring(field_match[0].length)) !== '') {
</xsl:text>
    <xsl:text>                            if ((field_match = re.key_access.exec(replacement_field)) !== null) {
</xsl:text>
    <xsl:text>                                field_list.push(field_match[1])
</xsl:text>
    <xsl:text>                            }
</xsl:text>
    <xsl:text>                            else if ((field_match = re.index_access.exec(replacement_field)) !== null) {
</xsl:text>
    <xsl:text>                                field_list.push(field_match[1])
</xsl:text>
    <xsl:text>                            }
</xsl:text>
    <xsl:text>                            else {
</xsl:text>
    <xsl:text>                                throw new SyntaxError('[sprintf] failed to parse named argument key')
</xsl:text>
    <xsl:text>                            }
</xsl:text>
    <xsl:text>                        }
</xsl:text>
    <xsl:text>                    }
</xsl:text>
    <xsl:text>                    else {
</xsl:text>
    <xsl:text>                        throw new SyntaxError('[sprintf] failed to parse named argument key')
</xsl:text>
    <xsl:text>                    }
</xsl:text>
    <xsl:text>                    match[2] = field_list
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                else {
</xsl:text>
    <xsl:text>                    arg_names |= 2
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                if (arg_names === 3) {
</xsl:text>
    <xsl:text>                    throw new Error('[sprintf] mixing positional and named placeholders is not (yet) supported')
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>                parse_tree.push(
</xsl:text>
    <xsl:text>                    {
</xsl:text>
    <xsl:text>                        placeholder: match[0],
</xsl:text>
    <xsl:text>                        param_no:    match[1],
</xsl:text>
    <xsl:text>                        keys:        match[2],
</xsl:text>
    <xsl:text>                        sign:        match[3],
</xsl:text>
    <xsl:text>                        pad_char:    match[4],
</xsl:text>
    <xsl:text>                        align:       match[5],
</xsl:text>
    <xsl:text>                        width:       match[6],
</xsl:text>
    <xsl:text>                        precision:   match[7],
</xsl:text>
    <xsl:text>                        type:        match[8]
</xsl:text>
    <xsl:text>                    }
</xsl:text>
    <xsl:text>                )
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else {
</xsl:text>
    <xsl:text>                throw new SyntaxError('[sprintf] unexpected placeholder')
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            _fmt = _fmt.substring(match[0].length)
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        return sprintf_cache[fmt] = parse_tree
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    /**
</xsl:text>
    <xsl:text>     * export to either browser or node.js
</xsl:text>
    <xsl:text>     */
</xsl:text>
    <xsl:text>    /* eslint-disable quote-props */
</xsl:text>
    <xsl:text>    if (typeof exports !== 'undefined') {
</xsl:text>
    <xsl:text>        exports['sprintf'] = sprintf
</xsl:text>
    <xsl:text>        exports['vsprintf'] = vsprintf
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    if (typeof window !== 'undefined') {
</xsl:text>
    <xsl:text>        window['sprintf'] = sprintf
</xsl:text>
    <xsl:text>        window['vsprintf'] = vsprintf
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        if (typeof define === 'function' &amp;&amp; define['amd']) {
</xsl:text>
    <xsl:text>            define(function() {
</xsl:text>
    <xsl:text>                return {
</xsl:text>
    <xsl:text>                    'sprintf': sprintf,
</xsl:text>
    <xsl:text>                    'vsprintf': vsprintf
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>            })
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    /* eslint-enable quote-props */
</xsl:text>
    <xsl:text>}(); // eslint-disable-line    
</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='DropDown']">
    <xsl:text>    function numb_event(e) {
</xsl:text>
    <xsl:text>        e.stopPropagation();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    class DropDownWidget extends Widget{
</xsl:text>
    <xsl:text>        dispatch(value) {
</xsl:text>
    <xsl:text>            if(!this.opened) this.set_selection(value);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        init() {
</xsl:text>
    <xsl:text>            this.button_elt.onclick = this.on_button_click.bind(this);
</xsl:text>
    <xsl:text>            // Save original size of rectangle
</xsl:text>
    <xsl:text>            this.box_bbox = this.box_elt.getBBox()
</xsl:text>
    <xsl:text>            this.highlight_bbox = this.highlight_elt.getBBox()
</xsl:text>
    <xsl:text>            this.highlight_elt.style.visibility = "hidden";
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            // Compute margins
</xsl:text>
    <xsl:text>            this.text_bbox = this.text_elt.getBBox();
</xsl:text>
    <xsl:text>            let lmargin = this.text_bbox.x - this.box_bbox.x;
</xsl:text>
    <xsl:text>            let tmargin = this.text_bbox.y - this.box_bbox.y;
</xsl:text>
    <xsl:text>            this.margins = [lmargin, tmargin].map(x =&gt; Math.max(x,0));
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            // Index of first visible element in the menu, when opened
</xsl:text>
    <xsl:text>            this.menu_offset = 0;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            // How mutch to lift the menu vertically so that it does not cross bottom border
</xsl:text>
    <xsl:text>            this.lift = 0;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            // Event handlers cannot be object method ('this' is unknown)
</xsl:text>
    <xsl:text>            // as a workaround, handler given to addEventListener is bound in advance.
</xsl:text>
    <xsl:text>            this.bound_close_on_click_elsewhere = this.close_on_click_elsewhere.bind(this);
</xsl:text>
    <xsl:text>            this.bound_on_selection_click = this.on_selection_click.bind(this);
</xsl:text>
    <xsl:text>            this.bound_on_backward_click = this.on_backward_click.bind(this);
</xsl:text>
    <xsl:text>            this.bound_on_forward_click = this.on_forward_click.bind(this);
</xsl:text>
    <xsl:text>            this.opened = false;
</xsl:text>
    <xsl:text>            this.clickables = [];
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        on_button_click() {
</xsl:text>
    <xsl:text>            this.open();
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        // Called when a menu entry is clicked
</xsl:text>
    <xsl:text>        on_selection_click(selection) {
</xsl:text>
    <xsl:text>            this.close();
</xsl:text>
    <xsl:text>            this.apply_hmi_value(0, selection);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        on_backward_click(){
</xsl:text>
    <xsl:text>            this.scroll(false);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        on_forward_click(){
</xsl:text>
    <xsl:text>            this.scroll(true);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        set_selection(value) {
</xsl:text>
    <xsl:text>            let display_str;
</xsl:text>
    <xsl:text>            if(value &gt;= 0 &amp;&amp; value &lt; this.content.length){
</xsl:text>
    <xsl:text>                // if valid selection resolve content
</xsl:text>
    <xsl:text>                display_str = this.content[value];
</xsl:text>
    <xsl:text>                this.last_selection = value;
</xsl:text>
    <xsl:text>            } else {
</xsl:text>
    <xsl:text>                // otherwise show problem
</xsl:text>
    <xsl:text>                display_str = "?"+String(value)+"?";
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            // It is assumed that first span always stays,
</xsl:text>
    <xsl:text>            // and contains selection when menu is closed
</xsl:text>
    <xsl:text>            this.text_elt.firstElementChild.textContent = display_str;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        grow_text(up_to) {
</xsl:text>
    <xsl:text>            let count = 1;
</xsl:text>
    <xsl:text>            let txt = this.text_elt;
</xsl:text>
    <xsl:text>            let first = txt.firstElementChild;
</xsl:text>
    <xsl:text>            // Real world (pixels) boundaries of current page
</xsl:text>
    <xsl:text>            let bounds = svg_root.getBoundingClientRect();
</xsl:text>
    <xsl:text>            this.lift = 0;
</xsl:text>
    <xsl:text>            while(count &lt; up_to) {
</xsl:text>
    <xsl:text>                let next = first.cloneNode();
</xsl:text>
    <xsl:text>                // relative line by line text flow instead of absolute y coordinate
</xsl:text>
    <xsl:text>                next.removeAttribute("y");
</xsl:text>
    <xsl:text>                next.setAttribute("dy", "1.1em");
</xsl:text>
    <xsl:text>                // default content to allow computing text element bbox
</xsl:text>
    <xsl:text>                next.textContent = "...";
</xsl:text>
    <xsl:text>                // append new span to text element
</xsl:text>
    <xsl:text>                txt.appendChild(next);
</xsl:text>
    <xsl:text>                // now check if text extended by one row fits to page
</xsl:text>
    <xsl:text>                // FIXME : exclude margins to be more accurate on box size
</xsl:text>
    <xsl:text>                let rect = txt.getBoundingClientRect();
</xsl:text>
    <xsl:text>                if(rect.bottom &gt; bounds.bottom){
</xsl:text>
    <xsl:text>                    // in case of overflow at the bottom, lift up one row
</xsl:text>
    <xsl:text>                    let backup = first.getAttribute("dy");
</xsl:text>
    <xsl:text>                    // apply lift as a dy added too first span (y attrib stays)
</xsl:text>
    <xsl:text>                    first.setAttribute("dy", "-"+String((this.lift+1)*1.1)+"em");
</xsl:text>
    <xsl:text>                    rect = txt.getBoundingClientRect();
</xsl:text>
    <xsl:text>                    if(rect.top &gt; bounds.top){
</xsl:text>
    <xsl:text>                        this.lift += 1;
</xsl:text>
    <xsl:text>                    } else {
</xsl:text>
    <xsl:text>                        // if it goes over the top, then backtrack
</xsl:text>
    <xsl:text>                        // restore dy attribute on first span
</xsl:text>
    <xsl:text>                        if(backup)
</xsl:text>
    <xsl:text>                            first.setAttribute("dy", backup);
</xsl:text>
    <xsl:text>                        else
</xsl:text>
    <xsl:text>                            first.removeAttribute("dy");
</xsl:text>
    <xsl:text>                        // remove unwanted child
</xsl:text>
    <xsl:text>                        txt.removeChild(next);
</xsl:text>
    <xsl:text>                        return count;
</xsl:text>
    <xsl:text>                    }
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                count++;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            return count;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        close_on_click_elsewhere(e) {
</xsl:text>
    <xsl:text>            // inhibit events not targetting spans (menu items)
</xsl:text>
    <xsl:text>            if([this.text_elt, this.element].indexOf(e.target.parentNode) == -1){
</xsl:text>
    <xsl:text>                e.stopPropagation();
</xsl:text>
    <xsl:text>                // close menu in case click is outside box
</xsl:text>
    <xsl:text>                if(e.target !== this.box_elt)
</xsl:text>
    <xsl:text>                    this.close();
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        close(){
</xsl:text>
    <xsl:text>            // Stop hogging all click events
</xsl:text>
    <xsl:text>            svg_root.removeEventListener("pointerdown", numb_event, true);
</xsl:text>
    <xsl:text>            svg_root.removeEventListener("pointerup", numb_event, true);
</xsl:text>
    <xsl:text>            svg_root.removeEventListener("click", this.bound_close_on_click_elsewhere, true);
</xsl:text>
    <xsl:text>            // Restore position and sixe of widget elements
</xsl:text>
    <xsl:text>            this.reset_text();
</xsl:text>
    <xsl:text>            this.reset_clickables();
</xsl:text>
    <xsl:text>            this.reset_box();
</xsl:text>
    <xsl:text>            this.reset_highlight();
</xsl:text>
    <xsl:text>            // Put the button back in place
</xsl:text>
    <xsl:text>            this.element.appendChild(this.button_elt);
</xsl:text>
    <xsl:text>            // Mark as closed (to allow dispatch)
</xsl:text>
    <xsl:text>            this.opened = false;
</xsl:text>
    <xsl:text>            // Dispatch last cached value
</xsl:text>
    <xsl:text>            this.apply_cache();
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        // Make item (text span) clickable by overlaying a rectangle on top of it
</xsl:text>
    <xsl:text>        make_clickable(span, func) {
</xsl:text>
    <xsl:text>            let txt = this.text_elt;
</xsl:text>
    <xsl:text>            let original_text_y = this.text_bbox.y;
</xsl:text>
    <xsl:text>            let highlight = this.highlight_elt;
</xsl:text>
    <xsl:text>            let original_h_y = this.highlight_bbox.y;
</xsl:text>
    <xsl:text>            let clickable = highlight.cloneNode();
</xsl:text>
    <xsl:text>            let yoffset = span.getBBox().y - original_text_y;
</xsl:text>
    <xsl:text>            clickable.y.baseVal.value = original_h_y + yoffset;
</xsl:text>
    <xsl:text>            clickable.style.pointerEvents = "bounding-box";
</xsl:text>
    <xsl:text>            //clickable.style.visibility = "hidden";
</xsl:text>
    <xsl:text>            //clickable.onclick = () =&gt; alert("love JS");
</xsl:text>
    <xsl:text>            clickable.onclick = func;
</xsl:text>
    <xsl:text>            this.element.appendChild(clickable);
</xsl:text>
    <xsl:text>            this.clickables.push(clickable)
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        reset_clickables() {
</xsl:text>
    <xsl:text>            while(this.clickables.length){
</xsl:text>
    <xsl:text>                this.element.removeChild(this.clickables.pop());
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        // Set text content when content is smaller than menu (no scrolling)
</xsl:text>
    <xsl:text>        set_complete_text(){
</xsl:text>
    <xsl:text>            let spans = this.text_elt.children;
</xsl:text>
    <xsl:text>            let c = 0;
</xsl:text>
    <xsl:text>            for(let item of this.content){
</xsl:text>
    <xsl:text>                let span=spans[c];
</xsl:text>
    <xsl:text>                span.textContent = item;
</xsl:text>
    <xsl:text>                let sel = c;
</xsl:text>
    <xsl:text>                this.make_clickable(span, (evt) =&gt; this.bound_on_selection_click(sel));
</xsl:text>
    <xsl:text>                c++;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        // Move partial view :
</xsl:text>
    <xsl:text>        // false : upward, lower value
</xsl:text>
    <xsl:text>        // true  : downward, higher value
</xsl:text>
    <xsl:text>        scroll(forward){
</xsl:text>
    <xsl:text>            let contentlength = this.content.length;
</xsl:text>
    <xsl:text>            let spans = this.text_elt.children;
</xsl:text>
    <xsl:text>            let spanslength = spans.length;
</xsl:text>
    <xsl:text>            // reduce accounted menu size according to prsence of scroll buttons
</xsl:text>
    <xsl:text>            // since we scroll there is necessarly one button
</xsl:text>
    <xsl:text>            spanslength--;
</xsl:text>
    <xsl:text>            if(forward){
</xsl:text>
    <xsl:text>                // reduce accounted menu size because of back button
</xsl:text>
    <xsl:text>                // in current view
</xsl:text>
    <xsl:text>                if(this.menu_offset &gt; 0) spanslength--;
</xsl:text>
    <xsl:text>                this.menu_offset = Math.min(
</xsl:text>
    <xsl:text>                    contentlength - spans.length + 1,
</xsl:text>
    <xsl:text>                    this.menu_offset + spanslength);
</xsl:text>
    <xsl:text>            }else{
</xsl:text>
    <xsl:text>                // reduce accounted menu size because of back button
</xsl:text>
    <xsl:text>                // in view once scrolled
</xsl:text>
    <xsl:text>                if(this.menu_offset - spanslength &gt; 0) spanslength--;
</xsl:text>
    <xsl:text>                this.menu_offset = Math.max(
</xsl:text>
    <xsl:text>                    0,
</xsl:text>
    <xsl:text>                    this.menu_offset - spanslength);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            if(this.menu_offset == 1)
</xsl:text>
    <xsl:text>                this.menu_offset = 0;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            this.reset_highlight();
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            this.reset_clickables();
</xsl:text>
    <xsl:text>            this.set_partial_text();
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            this.highlight_selection();
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        // Setup partial view text content
</xsl:text>
    <xsl:text>        // with jumps at first and last entry when appropriate
</xsl:text>
    <xsl:text>        set_partial_text(){
</xsl:text>
    <xsl:text>            let spans = this.text_elt.children;
</xsl:text>
    <xsl:text>            let contentlength = this.content.length;
</xsl:text>
    <xsl:text>            let spanslength = spans.length;
</xsl:text>
    <xsl:text>            let i = this.menu_offset, c = 0;
</xsl:text>
    <xsl:text>            let m = this.box_bbox;
</xsl:text>
    <xsl:text>            while(c &lt; spanslength){
</xsl:text>
    <xsl:text>                let span=spans[c];
</xsl:text>
    <xsl:text>                let onclickfunc;
</xsl:text>
    <xsl:text>                // backward jump only present if not exactly at start
</xsl:text>
    <xsl:text>                if(c == 0 &amp;&amp; i != 0){
</xsl:text>
    <xsl:text>                    span.textContent = "&#x25B2;";
</xsl:text>
    <xsl:text>                    onclickfunc = this.bound_on_backward_click;
</xsl:text>
    <xsl:text>                    let o = span.getBBox();
</xsl:text>
    <xsl:text>                    span.setAttribute("dx", (m.width - o.width)/2);
</xsl:text>
    <xsl:text>                // presence of forward jump when not right at the end
</xsl:text>
    <xsl:text>                }else if(c == spanslength-1 &amp;&amp; i &lt; contentlength - 1){
</xsl:text>
    <xsl:text>                    span.textContent = "&#x25BC;";
</xsl:text>
    <xsl:text>                    onclickfunc = this.bound_on_forward_click;
</xsl:text>
    <xsl:text>                    let o = span.getBBox();
</xsl:text>
    <xsl:text>                    span.setAttribute("dx", (m.width - o.width)/2);
</xsl:text>
    <xsl:text>                // otherwise normal content
</xsl:text>
    <xsl:text>                }else{
</xsl:text>
    <xsl:text>                    span.textContent = this.content[i];
</xsl:text>
    <xsl:text>                    let sel = i;
</xsl:text>
    <xsl:text>                    onclickfunc = (evt) =&gt; this.bound_on_selection_click(sel);
</xsl:text>
    <xsl:text>                    span.removeAttribute("dx");
</xsl:text>
    <xsl:text>                    i++;
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                this.make_clickable(span, onclickfunc);
</xsl:text>
    <xsl:text>                c++;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        open(){
</xsl:text>
    <xsl:text>            let length = this.content.length;
</xsl:text>
    <xsl:text>            // systematically reset text, to strip eventual whitespace spans
</xsl:text>
    <xsl:text>            this.reset_text();
</xsl:text>
    <xsl:text>            // grow as much as needed or possible
</xsl:text>
    <xsl:text>            let slots = this.grow_text(length);
</xsl:text>
    <xsl:text>            // Depending on final size
</xsl:text>
    <xsl:text>            if(slots == length) {
</xsl:text>
    <xsl:text>                // show all at once
</xsl:text>
    <xsl:text>                this.set_complete_text();
</xsl:text>
    <xsl:text>            } else {
</xsl:text>
    <xsl:text>                // eventualy align menu to current selection, compensating for lift
</xsl:text>
    <xsl:text>                let offset = this.last_selection - this.lift;
</xsl:text>
    <xsl:text>                if(offset &gt; 0)
</xsl:text>
    <xsl:text>                    this.menu_offset = Math.min(offset + 1, length - slots + 1);
</xsl:text>
    <xsl:text>                else
</xsl:text>
    <xsl:text>                    this.menu_offset = 0;
</xsl:text>
    <xsl:text>                // show surrounding values
</xsl:text>
    <xsl:text>                this.set_partial_text();
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            // Now that text size is known, we can set the box around it
</xsl:text>
    <xsl:text>            this.adjust_box_to_text();
</xsl:text>
    <xsl:text>            // Take button out until menu closed
</xsl:text>
    <xsl:text>            this.element.removeChild(this.button_elt);
</xsl:text>
    <xsl:text>            // Rise widget to top by moving it to last position among siblings
</xsl:text>
    <xsl:text>            this.element.parentNode.appendChild(this.element.parentNode.removeChild(this.element));
</xsl:text>
    <xsl:text>            // disable interaction with background
</xsl:text>
    <xsl:text>            svg_root.addEventListener("pointerdown", numb_event, true);
</xsl:text>
    <xsl:text>            svg_root.addEventListener("pointerup", numb_event, true);
</xsl:text>
    <xsl:text>            svg_root.addEventListener("click", this.bound_close_on_click_elsewhere, true);
</xsl:text>
    <xsl:text>            this.highlight_selection();
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            // mark as open
</xsl:text>
    <xsl:text>            this.opened = true;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        // Put text element in normalized state
</xsl:text>
    <xsl:text>        reset_text(){
</xsl:text>
    <xsl:text>            let txt = this.text_elt;
</xsl:text>
    <xsl:text>            let first = txt.firstElementChild;
</xsl:text>
    <xsl:text>            // remove attribute eventually added to first text line while opening
</xsl:text>
    <xsl:text>            first.onclick = null;
</xsl:text>
    <xsl:text>            first.removeAttribute("dy");
</xsl:text>
    <xsl:text>            first.removeAttribute("dx");
</xsl:text>
    <xsl:text>            // keep only the first line of text
</xsl:text>
    <xsl:text>            for(let span of Array.from(txt.children).slice(1)){
</xsl:text>
    <xsl:text>                txt.removeChild(span)
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        // Put rectangle element in saved original state
</xsl:text>
    <xsl:text>        reset_box(){
</xsl:text>
    <xsl:text>            let m = this.box_bbox;
</xsl:text>
    <xsl:text>            let b = this.box_elt;
</xsl:text>
    <xsl:text>            b.x.baseVal.value = m.x;
</xsl:text>
    <xsl:text>            b.y.baseVal.value = m.y;
</xsl:text>
    <xsl:text>            b.width.baseVal.value = m.width;
</xsl:text>
    <xsl:text>            b.height.baseVal.value = m.height;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        highlight_selection(){
</xsl:text>
    <xsl:text>            if(this.last_selection == undefined) return;
</xsl:text>
    <xsl:text>            let highlighted_row = this.last_selection - this.menu_offset;
</xsl:text>
    <xsl:text>            if(highlighted_row &lt; 0) return;
</xsl:text>
    <xsl:text>            let spans = this.text_elt.children;
</xsl:text>
    <xsl:text>            let spanslength = spans.length;
</xsl:text>
    <xsl:text>            let contentlength = this.content.length;
</xsl:text>
    <xsl:text>            if(this.menu_offset != 0) {
</xsl:text>
    <xsl:text>                spanslength--;
</xsl:text>
    <xsl:text>                highlighted_row++;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            if(this.menu_offset + spanslength &lt; contentlength - 1) spanslength--;
</xsl:text>
    <xsl:text>            if(highlighted_row &gt; spanslength) return;
</xsl:text>
    <xsl:text>            let original_text_y = this.text_bbox.y;
</xsl:text>
    <xsl:text>            let highlight = this.highlight_elt;
</xsl:text>
    <xsl:text>            let span = spans[highlighted_row];
</xsl:text>
    <xsl:text>            let yoffset = span.getBBox().y - original_text_y;
</xsl:text>
    <xsl:text>            highlight.y.baseVal.value = this.highlight_bbox.y + yoffset;
</xsl:text>
    <xsl:text>            highlight.style.visibility = "visible";
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        reset_highlight(){
</xsl:text>
    <xsl:text>            let highlight = this.highlight_elt;
</xsl:text>
    <xsl:text>            highlight.y.baseVal.value = this.highlight_bbox.y;
</xsl:text>
    <xsl:text>            highlight.style.visibility = "hidden";
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        // Use margin and text size to compute box size
</xsl:text>
    <xsl:text>        adjust_box_to_text(){
</xsl:text>
    <xsl:text>            let [lmargin, tmargin] = this.margins;
</xsl:text>
    <xsl:text>            let m = this.text_elt.getBBox();
</xsl:text>
    <xsl:text>            let b = this.box_elt;
</xsl:text>
    <xsl:text>            // b.x.baseVal.value = m.x - lmargin;
</xsl:text>
    <xsl:text>            b.y.baseVal.value = m.y - tmargin;
</xsl:text>
    <xsl:text>            // b.width.baseVal.value = 2 * lmargin + m.width;
</xsl:text>
    <xsl:text>            b.height.baseVal.value = 2 * tmargin + m.height;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='DropDown']">
    <xsl:param name="hmi_element"/>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>text box button highlight</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:text>  content:</xsl:text>
    <xsl:choose>
      <xsl:when test="count(arg) = 1 and arg[1]/@value = '#langs'">
        <xsl:text>langs</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>[
</xsl:text>
        <xsl:for-each select="arg">
          <xsl:text>"</xsl:text>
          <xsl:value-of select="@value"/>
          <xsl:text>",
</xsl:text>
        </xsl:for-each>
        <xsl:text>  ]</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>,
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='ForEach']">
    <xsl:param name="hmi_element"/>
    <xsl:if test="count(path) != 1">
      <xsl:message terminate="yes">
        <xsl:text>ForEach widget </xsl:text>
        <xsl:value-of select="$hmi_element/@id"/>
        <xsl:text> must have one HMI path given.</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:if test="count(arg) != 1">
      <xsl:message terminate="yes">
        <xsl:text>ForEach widget </xsl:text>
        <xsl:value-of select="$hmi_element/@id"/>
        <xsl:text> must have one argument given : a class name.</xsl:text>
      </xsl:message>
    </xsl:if>
    <xsl:variable name="class" select="arg[1]/@value"/>
    <xsl:variable name="base_path" select="path/@value"/>
    <xsl:variable name="hmi_index_base" select="$indexed_hmitree/*[@hmipath = $base_path]"/>
    <xsl:variable name="hmi_tree_base" select="$hmitree/descendant-or-self::*[@path = $hmi_index_base/@path]"/>
    <xsl:variable name="hmi_tree_items" select="$hmi_tree_base/*[@class = $class]"/>
    <xsl:variable name="hmi_index_items" select="$indexed_hmitree/*[@path = $hmi_tree_items/@path]"/>
    <xsl:variable name="items_paths" select="$hmi_index_items/@hmipath"/>
    <xsl:text>    index_pool: [
</xsl:text>
    <xsl:for-each select="$hmi_index_items">
      <xsl:text>      </xsl:text>
      <xsl:value-of select="@index"/>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>    ],
</xsl:text>
    <xsl:text>    init: function() {
</xsl:text>
    <xsl:variable name="prefix" select="concat($class,':')"/>
    <xsl:variable name="buttons_regex" select="concat('^',$prefix,'[+\-][0-9]+')"/>
    <xsl:variable name="buttons" select="$hmi_element/*[regexp:test(@inkscape:label, $buttons_regex)]"/>
    <xsl:for-each select="$buttons">
      <xsl:variable name="op" select="substring-after(@inkscape:label, $prefix)"/>
      <xsl:text>        id("</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>").setAttribute("onclick", "hmi_widgets['</xsl:text>
      <xsl:value-of select="$hmi_element/@id"/>
      <xsl:text>'].on_click('</xsl:text>
      <xsl:value-of select="$op"/>
      <xsl:text>', evt)");
</xsl:text>
    </xsl:for-each>
    <xsl:text>
</xsl:text>
    <xsl:text>        this.items = [
</xsl:text>
    <xsl:variable name="items_regex" select="concat('^',$prefix,'[0-9]+')"/>
    <xsl:variable name="unordered_items" select="$hmi_element//*[regexp:test(@inkscape:label, $items_regex)]"/>
    <xsl:for-each select="$unordered_items">
      <xsl:variable name="elt_label" select="concat($prefix, string(position()))"/>
      <xsl:variable name="elt" select="$unordered_items[@inkscape:label = $elt_label]"/>
      <xsl:variable name="pos" select="position()"/>
      <xsl:variable name="item_path" select="$items_paths[$pos]"/>
      <xsl:text>          [ /* item="</xsl:text>
      <xsl:value-of select="$elt_label"/>
      <xsl:text>" path="</xsl:text>
      <xsl:value-of select="$item_path"/>
      <xsl:text>" */
</xsl:text>
      <xsl:if test="count($elt)=0">
        <xsl:message terminate="yes">
          <xsl:text>Missing item labeled </xsl:text>
          <xsl:value-of select="$elt_label"/>
          <xsl:text> in ForEach widget </xsl:text>
          <xsl:value-of select="$hmi_element/@id"/>
        </xsl:message>
      </xsl:if>
      <xsl:for-each select="func:refered_elements($elt)[@id = $hmi_elements/@id][not(@id = $elt/@id)]">
        <xsl:if test="not(func:is_descendant_path(func:widget(@id)/path/@value, $item_path))">
          <xsl:message terminate="yes">
            <xsl:text>Widget id="</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>" label="</xsl:text>
            <xsl:value-of select="@inkscape:label"/>
            <xsl:text>" is having wrong path. Accroding to ForEach widget ancestor id="</xsl:text>
            <xsl:value-of select="$hmi_element/@id"/>
            <xsl:text>", path should be descendant of "</xsl:text>
            <xsl:value-of select="$item_path"/>
            <xsl:text>".</xsl:text>
          </xsl:message>
        </xsl:if>
        <xsl:text>            hmi_widgets["</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>"]</xsl:text>
        <xsl:if test="position()!=last()">
          <xsl:text>,</xsl:text>
        </xsl:if>
        <xsl:text>
</xsl:text>
      </xsl:for-each>
      <xsl:text>          ]</xsl:text>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>        ]
</xsl:text>
    <xsl:text>    },
</xsl:text>
    <xsl:text>    item_offset: 0,
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='ForEach']">
    <xsl:text>class ForEachWidget extends Widget{
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    unsub_items(){
</xsl:text>
    <xsl:text>        for(let item of this.items){
</xsl:text>
    <xsl:text>            for(let widget of item) {
</xsl:text>
    <xsl:text>                widget.unsub();
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    unsub(){
</xsl:text>
    <xsl:text>        this.unsub_items();
</xsl:text>
    <xsl:text>        this.offset = 0;
</xsl:text>
    <xsl:text>        this.relativeness = undefined;
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    sub_items(){
</xsl:text>
    <xsl:text>        for(let i = 0; i &lt; this.items.length; i++) {
</xsl:text>
    <xsl:text>            let item = this.items[i];
</xsl:text>
    <xsl:text>            let orig_item_index = this.index_pool[i];
</xsl:text>
    <xsl:text>            let item_index = this.index_pool[i+this.item_offset];
</xsl:text>
    <xsl:text>            let item_index_offset = item_index - orig_item_index;
</xsl:text>
    <xsl:text>            if(this.relativeness[0])
</xsl:text>
    <xsl:text>                item_index_offset += this.offset;
</xsl:text>
    <xsl:text>            for(let widget of item) {
</xsl:text>
    <xsl:text>                /* all variables of all widgets in a ForEach are all relative. 
</xsl:text>
    <xsl:text>                   Really.
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>                   TODO: allow absolute variables in ForEach widgets
</xsl:text>
    <xsl:text>                */
</xsl:text>
    <xsl:text>                widget.sub(item_index_offset, widget.indexes.map(_=&gt;true));
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    sub(new_offset=0, relativeness=[]){
</xsl:text>
    <xsl:text>        this.offset = new_offset;
</xsl:text>
    <xsl:text>        this.relativeness = relativeness;
</xsl:text>
    <xsl:text>        this.sub_items();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    apply_cache() {
</xsl:text>
    <xsl:text>        this.items.forEach(item=&gt;item.forEach(widget=&gt;widget.apply_cache()));
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    on_click(opstr, evt) {
</xsl:text>
    <xsl:text>        let new_item_offset = eval(String(this.item_offset)+opstr);
</xsl:text>
    <xsl:text>        if(new_item_offset + this.items.length &gt; this.index_pool.length) {
</xsl:text>
    <xsl:text>            if(this.item_offset + this.items.length == this.index_pool.length)
</xsl:text>
    <xsl:text>                new_item_offset = 0;
</xsl:text>
    <xsl:text>            else
</xsl:text>
    <xsl:text>                new_item_offset = this.index_pool.length - this.items.length;
</xsl:text>
    <xsl:text>        } else if(new_item_offset &lt; 0) {
</xsl:text>
    <xsl:text>            if(this.item_offset == 0)
</xsl:text>
    <xsl:text>                new_item_offset = this.index_pool.length - this.items.length;
</xsl:text>
    <xsl:text>            else
</xsl:text>
    <xsl:text>                new_item_offset = 0;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        this.item_offset = new_item_offset;
</xsl:text>
    <xsl:text>        this.unsub_items();
</xsl:text>
    <xsl:text>        this.sub_items();
</xsl:text>
    <xsl:text>        update_subscriptions();
</xsl:text>
    <xsl:text>        need_cache_apply.push(this);
</xsl:text>
    <xsl:text>        jumps_need_update = true;
</xsl:text>
    <xsl:text>        requestHMIAnimation();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='Input']">
    <xsl:text>    class InputWidget extends Widget{
</xsl:text>
    <xsl:text>         on_op_click(opstr) {
</xsl:text>
    <xsl:text>             this.change_hmi_value(0, opstr);
</xsl:text>
    <xsl:text>         }
</xsl:text>
    <xsl:text>         edit_callback(new_val) {
</xsl:text>
    <xsl:text>             this.apply_hmi_value(0, new_val);
</xsl:text>
    <xsl:text>         }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>         overshot(new_val, max) {
</xsl:text>
    <xsl:text>             this.last_display = "max: "+max;
</xsl:text>
    <xsl:text>             this.request_animate();
</xsl:text>
    <xsl:text>         }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>         undershot(new_val, min) {
</xsl:text>
    <xsl:text>             this.last_display = "min: "+min;
</xsl:text>
    <xsl:text>             this.request_animate();
</xsl:text>
    <xsl:text>         }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    }
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='Input']">
    <xsl:param name="hmi_element"/>
    <xsl:variable name="value_elt">
      <xsl:call-template name="defs_by_labels">
        <xsl:with-param name="hmi_element" select="$hmi_element"/>
        <xsl:with-param name="labels">
          <xsl:text>value</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="mandatory" select="'no'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="have_value" select="string-length($value_elt)&gt;0"/>
    <xsl:value-of select="$value_elt"/>
    <xsl:variable name="edit_elt">
      <xsl:call-template name="defs_by_labels">
        <xsl:with-param name="hmi_element" select="$hmi_element"/>
        <xsl:with-param name="labels">
          <xsl:text>edit</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="mandatory" select="'no'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="have_edit" select="string-length($edit_elt)&gt;0"/>
    <xsl:value-of select="$edit_elt"/>
    <xsl:if test="$have_value">
      <xsl:text>    frequency: 5,
</xsl:text>
    </xsl:if>
    <xsl:text>    dispatch: function(value) {
</xsl:text>
    <xsl:if test="$have_value or $have_edit">
      <xsl:choose>
        <xsl:when test="count(arg) = 1">
          <xsl:text>        this.last_display = vsprintf("</xsl:text>
          <xsl:value-of select="arg[1]/@value"/>
          <xsl:text>", [value]);
</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>        this.last_display = value;
</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
    <xsl:if test="$have_value">
      <xsl:text>        this.request_animate();
</xsl:text>
    </xsl:if>
    <xsl:text>    },
</xsl:text>
    <xsl:if test="$have_value">
      <xsl:text>    animate: function(){
</xsl:text>
      <xsl:text>        this.value_elt.textContent = String(this.last_display);
</xsl:text>
      <xsl:text>    },
</xsl:text>
    </xsl:if>
    <xsl:text>    init: function() {
</xsl:text>
    <xsl:if test="$have_edit">
      <xsl:text>        this.edit_elt.onclick = () =&gt; edit_value("</xsl:text>
      <xsl:value-of select="path/@value"/>
      <xsl:text>", "</xsl:text>
      <xsl:value-of select="path/@type"/>
      <xsl:text>", this, this.last_display);
</xsl:text>
      <xsl:if test="$have_value">
        <xsl:text>        this.value_elt.style.pointerEvents = "none";
</xsl:text>
      </xsl:if>
    </xsl:if>
    <xsl:for-each select="$hmi_element/*[regexp:test(@inkscape:label,'^[=+\-].+')]">
      <xsl:text>        id("</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>").onclick = () =&gt; this.on_op_click("</xsl:text>
      <xsl:value-of select="func:escape_quotes(@inkscape:label)"/>
      <xsl:text>");
</xsl:text>
    </xsl:for-each>
    <xsl:text>    },
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='JsonTable']">
    <xsl:text>class JsonTableWidget extends Widget{
</xsl:text>
    <xsl:text>    // arbitrary defaults to avoid missing entries in query
</xsl:text>
    <xsl:text>    cache = [0,100,50];
</xsl:text>
    <xsl:text>    init() {
</xsl:text>
    <xsl:text>        this.spread_json_data_bound = this.spread_json_data.bind(this);
</xsl:text>
    <xsl:text>        this.handle_http_response_bound = this.handle_http_response.bind(this);
</xsl:text>
    <xsl:text>        this.fetch_error_bound = this.fetch_error.bind(this);
</xsl:text>
    <xsl:text>        this.promised = false;
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    handle_http_response(response) {
</xsl:text>
    <xsl:text>        if (!response.ok) {
</xsl:text>
    <xsl:text>          console.log("HTTP error, status = " + response.status);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        return response.json();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    fetch_error(e){
</xsl:text>
    <xsl:text>        console.log("HTTP fetch error, message = " + e.message + "Widget:" + this.element_id);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    do_http_request(...opt) {
</xsl:text>
    <xsl:text>        this.abort_controller = new AbortController();
</xsl:text>
    <xsl:text>        const query = {
</xsl:text>
    <xsl:text>            args: this.args,
</xsl:text>
    <xsl:text>            range: this.cache[1],
</xsl:text>
    <xsl:text>            position: this.cache[2],
</xsl:text>
    <xsl:text>            visible: this.visible,
</xsl:text>
    <xsl:text>            extra: this.cache.slice(4),
</xsl:text>
    <xsl:text>            options: opt
</xsl:text>
    <xsl:text>        };
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        const options = {
</xsl:text>
    <xsl:text>             method: 'POST',
</xsl:text>
    <xsl:text>             body: JSON.stringify(query),
</xsl:text>
    <xsl:text>             headers: {'Content-Type': 'application/json'},
</xsl:text>
    <xsl:text>             signal: this.abort_controller.signal
</xsl:text>
    <xsl:text>        };
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        return fetch(this.args[0], options)
</xsl:text>
    <xsl:text>                .then(this.handle_http_response_bound)
</xsl:text>
    <xsl:text>                .then(this.spread_json_data_bound)
</xsl:text>
    <xsl:text>                .catch(this.fetch_error_bound);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    unsub(){
</xsl:text>
    <xsl:text>        this.abort_controller.abort();
</xsl:text>
    <xsl:text>        super.unsub();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    dispatch(value, oldval, index) {
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        if(this.cache[index] != value)
</xsl:text>
    <xsl:text>            this.cache[index] = value;
</xsl:text>
    <xsl:text>        else
</xsl:text>
    <xsl:text>            return;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        if(!this.promised){
</xsl:text>
    <xsl:text>            this.promised = true;
</xsl:text>
    <xsl:text>            this.do_http_request().finally(() =&gt; {
</xsl:text>
    <xsl:text>                this.promised = false;
</xsl:text>
    <xsl:text>            });
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    make_on_click(...options){
</xsl:text>
    <xsl:text>        let that = this;
</xsl:text>
    <xsl:text>        return function(evt){
</xsl:text>
    <xsl:text>            that.do_http_request(...options);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>    // on_click(evt, ...options) {
</xsl:text>
    <xsl:text>    //     this.do_http_request(...options);
</xsl:text>
    <xsl:text>    // }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="json_table_elt_render" match="svg:*">
    <xsl:message terminate="yes">
      <xsl:text>JsonTable Widget can't contain element of type </xsl:text>
      <xsl:value-of select="local-name()"/>
      <xsl:text>.</xsl:text>
    </xsl:message>
  </xsl:template>
  <xsl:variable name="hmi_textstylelists_descs" select="$parsed_widgets/widget[@type = 'TextStyleList']"/>
  <xsl:variable name="hmi_textstylelists" select="$hmi_elements[@id = $hmi_textstylelists_descs/@id]"/>
  <xsl:variable name="textstylelist_related">
    <xsl:for-each select="$hmi_textstylelists">
      <list>
        <xsl:attribute name="listid">
          <xsl:value-of select="@id"/>
        </xsl:attribute>
        <xsl:for-each select="func:refered_elements(.)">
          <elt>
            <xsl:attribute name="eltid">
              <xsl:value-of select="@id"/>
            </xsl:attribute>
          </elt>
        </xsl:for-each>
      </list>
    </xsl:for-each>
  </xsl:variable>
  <xsl:variable name="textstylelist_related_ns" select="exsl:node-set($textstylelist_related)"/>
  <func:function name="func:json_expressions">
    <xsl:param name="expressions"/>
    <xsl:param name="label"/>
    <xsl:choose>
      <xsl:when test="$label">
        <xsl:variable name="suffixes" select="str:split($label)"/>
        <xsl:variable name="res">
          <xsl:for-each select="$suffixes">
            <expression>
              <xsl:variable name="suffix" select="."/>
              <xsl:variable name="pos" select="position()"/>
              <xsl:variable name="expr" select="$expressions[position() &lt;= $pos][last()]/expression"/>
              <xsl:choose>
                <xsl:when test="contains($suffix,'=')">
                  <xsl:variable name="name" select="substring-before($suffix,'=')"/>
                  <xsl:if test="$expr/@name[. != $name]">
                    <xsl:message terminate="yes">
                      <xsl:text>JsonTable : missplaced '=' or inconsistent names in Json data expressions.</xsl:text>
                    </xsl:message>
                  </xsl:if>
                  <xsl:attribute name="name">
                    <xsl:value-of select="$name"/>
                  </xsl:attribute>
                  <xsl:attribute name="content">
                    <xsl:value-of select="$expr/@content"/>
                    <xsl:value-of select="substring-after($suffix,'=')"/>
                  </xsl:attribute>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:copy-of select="$expr/@name"/>
                  <xsl:attribute name="content">
                    <xsl:value-of select="$expr/@content"/>
                    <xsl:value-of select="$suffix"/>
                  </xsl:attribute>
                </xsl:otherwise>
              </xsl:choose>
            </expression>
          </xsl:for-each>
        </xsl:variable>
        <func:result select="exsl:node-set($res)"/>
      </xsl:when>
      <xsl:otherwise>
        <func:result select="$expressions"/>
      </xsl:otherwise>
    </xsl:choose>
  </func:function>
  <xsl:variable name="initexpr">
    <expression>
      <xsl:attribute name="content">
        <xsl:text>jdata</xsl:text>
      </xsl:attribute>
    </expression>
  </xsl:variable>
  <xsl:variable name="initexpr_ns" select="exsl:node-set($initexpr)"/>
  <xsl:template mode="json_table_elt_render" match="svg:use">
    <xsl:param name="expressions"/>
    <xsl:variable name="targetid" select="substring-after(@xlink:href,'#')"/>
    <xsl:variable name="from_list" select="$hmi_lists[(@id | */@id) = $targetid]"/>
    <xsl:choose>
      <xsl:when test="count($from_list) &gt; 0">
        <xsl:text>        id("</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>").setAttribute("xlink:href",
</xsl:text>
        <xsl:text>            "#"+hmi_widgets["</xsl:text>
        <xsl:value-of select="$from_list/@id"/>
        <xsl:text>"].items[</xsl:text>
        <xsl:value-of select="$expressions/expression[1]/@content"/>
        <xsl:text>]);
</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:message terminate="no">
          <xsl:text>Clones (svg:use) in JsonTable Widget must point to a valid HMI:List widget or item. Reference "</xsl:text>
          <xsl:value-of select="@xlink:href"/>
          <xsl:text>" is not valid and will not be updated.</xsl:text>
        </xsl:message>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template mode="json_table_elt_render" match="svg:text">
    <xsl:param name="expressions"/>
    <xsl:variable name="value_expr" select="$expressions/expression[1]/@content"/>
    <xsl:variable name="original" select="@original"/>
    <xsl:variable name="from_textstylelist" select="$textstylelist_related_ns/list[elt/@eltid = $original]"/>
    <xsl:choose>
      <xsl:when test="count($from_textstylelist) &gt; 0">
        <xsl:variable name="content_expr" select="$expressions/expression[2]/@content"/>
        <xsl:if test="string-length($content_expr) = 0 or $expressions/expression[2]/@name != 'textContent'">
          <xsl:message terminate="yes">
            <xsl:text>Clones (svg:use) in JsonTable Widget pointing to a HMI:TextStyleList widget or item must have a "textContent=.someVal" assignement following value expression in label.</xsl:text>
          </xsl:message>
        </xsl:if>
        <xsl:text>        {
</xsl:text>
        <xsl:text>          let elt = id("</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>");
</xsl:text>
        <xsl:text>          elt.textContent = String(</xsl:text>
        <xsl:value-of select="$content_expr"/>
        <xsl:text>);
</xsl:text>
        <xsl:text>          elt.style = hmi_widgets["</xsl:text>
        <xsl:value-of select="$from_textstylelist/@listid"/>
        <xsl:text>"].styles[</xsl:text>
        <xsl:value-of select="$value_expr"/>
        <xsl:text>];
</xsl:text>
        <xsl:text>        }
</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>        id("</xsl:text>
        <xsl:value-of select="@id"/>
        <xsl:text>").textContent = String(</xsl:text>
        <xsl:value-of select="$value_expr"/>
        <xsl:text>);
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <func:function name="func:filter_non_widget_label">
    <xsl:param name="elt"/>
    <xsl:param name="widget_elts"/>
    <xsl:variable name="eltid">
      <xsl:choose>
        <xsl:when test="$elt/@original">
          <xsl:value-of select="$elt/@original"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$elt/@id"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <func:result select="$widget_elts[@id=$eltid]/@inkscape:label"/>
  </func:function>
  <xsl:template mode="json_table_render_except_comments" match="svg:*">
    <xsl:param name="expressions"/>
    <xsl:param name="widget_elts"/>
    <xsl:variable name="label" select="func:filter_non_widget_label(., $widget_elts)"/>
    <xsl:if test="not(starts-with($label,'#'))">
      <xsl:apply-templates mode="json_table_render" select=".">
        <xsl:with-param name="expressions" select="$expressions"/>
        <xsl:with-param name="widget_elts" select="$widget_elts"/>
        <xsl:with-param name="label" select="$label"/>
      </xsl:apply-templates>
    </xsl:if>
  </xsl:template>
  <xsl:template mode="json_table_render" match="svg:*">
    <xsl:param name="expressions"/>
    <xsl:param name="widget_elts"/>
    <xsl:param name="label"/>
    <xsl:variable name="new_expressions" select="func:json_expressions($expressions, $label)"/>
    <xsl:variable name="elt" select="."/>
    <xsl:for-each select="$new_expressions/expression[position() &gt; 1][starts-with(@name,'onClick')]">
      <xsl:text>        id("</xsl:text>
      <xsl:value-of select="$elt/@id"/>
      <xsl:text>").onclick = this.make_on_click('</xsl:text>
      <xsl:value-of select="@name"/>
      <xsl:text>', </xsl:text>
      <xsl:value-of select="@content"/>
      <xsl:text>);
</xsl:text>
    </xsl:for-each>
    <xsl:apply-templates mode="json_table_elt_render" select=".">
      <xsl:with-param name="expressions" select="$new_expressions"/>
    </xsl:apply-templates>
  </xsl:template>
  <xsl:template mode="json_table_render" match="svg:g">
    <xsl:param name="expressions"/>
    <xsl:param name="widget_elts"/>
    <xsl:param name="label"/>
    <xsl:variable name="varprefix">
      <xsl:text>obj_</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>_</xsl:text>
    </xsl:variable>
    <xsl:text>        try {
</xsl:text>
    <xsl:for-each select="$expressions/expression">
      <xsl:text>         let </xsl:text>
      <xsl:value-of select="$varprefix"/>
      <xsl:value-of select="position()"/>
      <xsl:text> = </xsl:text>
      <xsl:value-of select="@content"/>
      <xsl:text>;
</xsl:text>
      <xsl:text>         if(</xsl:text>
      <xsl:value-of select="$varprefix"/>
      <xsl:value-of select="position()"/>
      <xsl:text> == undefined) {
</xsl:text>
      <xsl:text>              throw null;
</xsl:text>
      <xsl:text>         }
</xsl:text>
    </xsl:for-each>
    <xsl:variable name="new_expressions">
      <xsl:for-each select="$expressions/expression">
        <xsl:copy>
          <xsl:copy-of select="@name"/>
          <xsl:attribute name="content">
            <xsl:value-of select="$varprefix"/>
            <xsl:value-of select="position()"/>
          </xsl:attribute>
        </xsl:copy>
      </xsl:for-each>
    </xsl:variable>
    <xsl:text>          id("</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>").style = "</xsl:text>
    <xsl:value-of select="@style"/>
    <xsl:text>";
</xsl:text>
    <xsl:apply-templates mode="json_table_render_except_comments" select="*">
      <xsl:with-param name="expressions" select="func:json_expressions(exsl:node-set($new_expressions), $label)"/>
      <xsl:with-param name="widget_elts" select="$widget_elts"/>
    </xsl:apply-templates>
    <xsl:text>        } catch(err) {
</xsl:text>
    <xsl:text>          id("</xsl:text>
    <xsl:value-of select="@id"/>
    <xsl:text>").style = "display:none";
</xsl:text>
    <xsl:text>        }
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='JsonTable']">
    <xsl:param name="hmi_element"/>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>data</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>forward backward cursor</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="mandatory" select="'no'"/>
    </xsl:call-template>
    <xsl:variable name="data_elt" select="$result_svg_ns//*[@id = $hmi_element/@id]/*[@inkscape:label = 'data']"/>
    <xsl:text>    visible: </xsl:text>
    <xsl:value-of select="count($data_elt/*[@inkscape:label])"/>
    <xsl:text>,
</xsl:text>
    <xsl:text>    spread_json_data: function(janswer) {
</xsl:text>
    <xsl:text>        let [range,position,jdata] = janswer;
</xsl:text>
    <xsl:text>        [[1, range], [2, position], [3, this.visible]].map(([i,v]) =&gt; {
</xsl:text>
    <xsl:text>             this.apply_hmi_value(i,v);
</xsl:text>
    <xsl:text>             this.cache[i] = v;
</xsl:text>
    <xsl:text>        });
</xsl:text>
    <xsl:apply-templates mode="json_table_render_except_comments" select="$data_elt">
      <xsl:with-param name="expressions" select="$initexpr_ns"/>
      <xsl:with-param name="widget_elts" select="$hmi_element/*[@inkscape:label = 'data']/descendant::svg:*"/>
    </xsl:apply-templates>
    <xsl:text>    }
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='Jump']">
    <xsl:text>    class JumpWidget extends Widget{
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        activable = false;
</xsl:text>
    <xsl:text>        active = false;
</xsl:text>
    <xsl:text>        disabled = false;
</xsl:text>
    <xsl:text>        frequency = 2;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        update_activity() {
</xsl:text>
    <xsl:text>            if(this.active) {
</xsl:text>
    <xsl:text>                 /* show active */ 
</xsl:text>
    <xsl:text>                 this.active_elt.setAttribute("style", this.active_elt_style);
</xsl:text>
    <xsl:text>                 /* hide inactive */ 
</xsl:text>
    <xsl:text>                 this.inactive_elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>            } else {
</xsl:text>
    <xsl:text>                 /* show inactive */ 
</xsl:text>
    <xsl:text>                 this.inactive_elt.setAttribute("style", this.inactive_elt_style);
</xsl:text>
    <xsl:text>                 /* hide active */ 
</xsl:text>
    <xsl:text>                 this.active_elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        make_on_click() {
</xsl:text>
    <xsl:text>            let that = this;
</xsl:text>
    <xsl:text>            const name = this.args[0];
</xsl:text>
    <xsl:text>            return function(evt){
</xsl:text>
    <xsl:text>                /* TODO: suport path pointing to local variable whom value 
</xsl:text>
    <xsl:text>                   would be an HMI_TREE index to jump to a relative page */
</xsl:text>
    <xsl:text>                const index = that.indexes.length &gt; 0 ? that.indexes[0] + that.offset : undefined;
</xsl:text>
    <xsl:text>                switch_page(name, index);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        notify_page_change(page_name, index) {
</xsl:text>
    <xsl:text>            if(this.activable) {
</xsl:text>
    <xsl:text>                const ref_index = this.indexes.length &gt; 0 ? this.indexes[0] + this.offset : undefined;
</xsl:text>
    <xsl:text>                const ref_name = this.args[0];
</xsl:text>
    <xsl:text>                this.active = ((ref_name == undefined || ref_name == page_name) &amp;&amp; index == ref_index);
</xsl:text>
    <xsl:text>                this.update_activity();
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        dispatch(value) {
</xsl:text>
    <xsl:text>            this.disabled = !Number(value);
</xsl:text>
    <xsl:text>            if(this.disabled) {
</xsl:text>
    <xsl:text>              /* show disabled */ 
</xsl:text>
    <xsl:text>              this.disabled_elt.setAttribute("style", this.disabled_elt_style);
</xsl:text>
    <xsl:text>              /* hide inactive */ 
</xsl:text>
    <xsl:text>              this.inactive_elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>              /* hide active */ 
</xsl:text>
    <xsl:text>              this.active_elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>            } else {
</xsl:text>
    <xsl:text>              /* hide disabled */ 
</xsl:text>
    <xsl:text>              this.disabled_elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>              this.update_activity();
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='Jump']">
    <xsl:param name="hmi_element"/>
    <xsl:variable name="activity">
      <xsl:call-template name="defs_by_labels">
        <xsl:with-param name="hmi_element" select="$hmi_element"/>
        <xsl:with-param name="labels">
          <xsl:text>active inactive</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="mandatory" select="'no'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="have_activity" select="string-length($activity)&gt;0"/>
    <xsl:value-of select="$activity"/>
    <xsl:variable name="disability">
      <xsl:call-template name="defs_by_labels">
        <xsl:with-param name="hmi_element" select="$hmi_element"/>
        <xsl:with-param name="labels">
          <xsl:text>disabled</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="mandatory" select="'no'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="have_disability" select="$have_activity and string-length($disability)&gt;0"/>
    <xsl:value-of select="$disability"/>
    <xsl:text>    init: function() {
</xsl:text>
    <xsl:text>        this.element.onclick = this.make_on_click();
</xsl:text>
    <xsl:if test="$have_activity">
      <xsl:text>        this.active_elt_style = this.active_elt.getAttribute("style");
</xsl:text>
      <xsl:text>        this.inactive_elt_style = this.inactive_elt.getAttribute("style");
</xsl:text>
      <xsl:text>        this.activable = true;
</xsl:text>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="$have_disability">
        <xsl:text>        this.disabled_elt_style = this.disabled_elt.getAttribute("style");
</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>        this.unsubscribable = true;
</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text>    },
</xsl:text>
  </xsl:template>
  <xsl:template mode="per_page_widget_template" match="widget[@type='Jump']">
    <xsl:param name="page_desc"/>
    <xsl:if test="path">
      <xsl:variable name="target_page_name">
        <xsl:choose>
          <xsl:when test="arg">
            <xsl:value-of select="arg[1]/@value"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$page_desc/arg[1]/@value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:variable name="target_page_path">
        <xsl:choose>
          <xsl:when test="arg">
            <xsl:value-of select="$hmi_pages_descs[arg[1]/@value = $target_page_name]/path[1]/@value"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$page_desc/path[1]/@value"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="not(func:same_class_paths($target_page_path, path[1]/@value))">
        <xsl:message terminate="yes">
          <xsl:text>Jump id="</xsl:text>
          <xsl:value-of select="@id"/>
          <xsl:text>" to page "</xsl:text>
          <xsl:value-of select="$target_page_name"/>
          <xsl:text>" with incompatible path "</xsl:text>
          <xsl:value-of select="path[1]/@value"/>
          <xsl:text> (must be same class as "</xsl:text>
          <xsl:value-of select="$target_page_path"/>
          <xsl:text>")</xsl:text>
        </xsl:message>
      </xsl:if>
    </xsl:if>
  </xsl:template>
  <declarations:jump/>
  <xsl:template match="declarations:jump">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>var jumps_need_update = false;
</xsl:text>
    <xsl:text>var jump_history = [[default_page, undefined]];
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>function update_jumps() {
</xsl:text>
    <xsl:text>    page_desc[current_visible_page].jumps.map(w=&gt;w.notify_page_change(current_visible_page,current_page_index));
</xsl:text>
    <xsl:text>    jumps_need_update = false;
</xsl:text>
    <xsl:text>};
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <declarations:keypad/>
  <xsl:template match="declarations:keypad">
    <xsl:text>
</xsl:text>
    <xsl:text>/* </xsl:text>
    <xsl:value-of select="local-name()"/>
    <xsl:text> */
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>var keypads = {
</xsl:text>
    <xsl:for-each select="$keypads_descs">
      <xsl:variable name="keypad_id" select="@id"/>
      <xsl:for-each select="arg">
        <xsl:variable name="g" select="$geometry[@Id = $keypad_id]"/>
        <xsl:text>    "</xsl:text>
        <xsl:value-of select="@value"/>
        <xsl:text>":["</xsl:text>
        <xsl:value-of select="$keypad_id"/>
        <xsl:text>", </xsl:text>
        <xsl:value-of select="$g/@x"/>
        <xsl:text>, </xsl:text>
        <xsl:value-of select="$g/@y"/>
        <xsl:text>],
</xsl:text>
      </xsl:for-each>
    </xsl:for-each>
    <xsl:text>}
</xsl:text>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='Keypad']">
    <xsl:text>class KeypadWidget extends Widget{
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>     on_key_click(symbols) {
</xsl:text>
    <xsl:text>         var syms = symbols.split(" ");
</xsl:text>
    <xsl:text>         this.shift |= this.caps;
</xsl:text>
    <xsl:text>         this.editstr += syms[this.shift?syms.length-1:0];
</xsl:text>
    <xsl:text>         this.shift = false;
</xsl:text>
    <xsl:text>         this.update();
</xsl:text>
    <xsl:text>     }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>     on_Esc_click() {
</xsl:text>
    <xsl:text>         end_modal.call(this);
</xsl:text>
    <xsl:text>     }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>     on_Enter_click() {
</xsl:text>
    <xsl:text>         let coercedval = (typeof this.initial) == "number" ? Number(this.editstr) : this.editstr;
</xsl:text>
    <xsl:text>         if(typeof coercedval == 'number' &amp;&amp; isNaN(coercedval)){
</xsl:text>
    <xsl:text>             // revert to initial so it explicitely shows input was ignored
</xsl:text>
    <xsl:text>             this.editstr = String(this.initial);
</xsl:text>
    <xsl:text>             this.update();
</xsl:text>
    <xsl:text>         } else { 
</xsl:text>
    <xsl:text>             let callback_obj = this.result_callback_obj;
</xsl:text>
    <xsl:text>             end_modal.call(this);
</xsl:text>
    <xsl:text>             callback_obj.edit_callback(coercedval);
</xsl:text>
    <xsl:text>         }
</xsl:text>
    <xsl:text>     }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>     on_BackSpace_click() {
</xsl:text>
    <xsl:text>         this.editstr = this.editstr.slice(0,this.editstr.length-1);
</xsl:text>
    <xsl:text>         this.update();
</xsl:text>
    <xsl:text>     }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>     on_Sign_click() {
</xsl:text>
    <xsl:text>         if(this.editstr[0] == "-")
</xsl:text>
    <xsl:text>             this.editstr = this.editstr.slice(1,this.editstr.length);
</xsl:text>
    <xsl:text>         else
</xsl:text>
    <xsl:text>             this.editstr = "-" + this.editstr;
</xsl:text>
    <xsl:text>         this.update();
</xsl:text>
    <xsl:text>     }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>     on_NumDot_click() {
</xsl:text>
    <xsl:text>         if(this.editstr.indexOf(".") == "-1"){
</xsl:text>
    <xsl:text>             this.editstr += ".";
</xsl:text>
    <xsl:text>             this.update();
</xsl:text>
    <xsl:text>         }
</xsl:text>
    <xsl:text>     }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>     on_Space_click() {
</xsl:text>
    <xsl:text>         this.editstr += " ";
</xsl:text>
    <xsl:text>         this.update();
</xsl:text>
    <xsl:text>     }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>     caps = false;
</xsl:text>
    <xsl:text>     _caps = undefined;
</xsl:text>
    <xsl:text>     on_CapsLock_click() {
</xsl:text>
    <xsl:text>         this.caps = !this.caps;
</xsl:text>
    <xsl:text>         this.update();
</xsl:text>
    <xsl:text>     }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>     shift = false;
</xsl:text>
    <xsl:text>     _shift = undefined;
</xsl:text>
    <xsl:text>     on_Shift_click() {
</xsl:text>
    <xsl:text>         this.shift = !this.shift;
</xsl:text>
    <xsl:text>         this.caps = false;
</xsl:text>
    <xsl:text>         this.update();
</xsl:text>
    <xsl:text>     }
</xsl:text>
    <xsl:text>     editstr = "";
</xsl:text>
    <xsl:text>     _editstr = undefined;
</xsl:text>
    <xsl:text>     result_callback_obj = undefined;
</xsl:text>
    <xsl:text>     start_edit(info, valuetype, callback_obj, initial,size) {
</xsl:text>
    <xsl:text>         show_modal.call(this,size);
</xsl:text>
    <xsl:text>         this.editstr = String(initial);
</xsl:text>
    <xsl:text>         this.result_callback_obj = callback_obj;
</xsl:text>
    <xsl:text>         this.Info_elt.textContent = info;
</xsl:text>
    <xsl:text>         this.shift = false;
</xsl:text>
    <xsl:text>         this.caps = false;
</xsl:text>
    <xsl:text>         this.initial = initial;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>         this.update();
</xsl:text>
    <xsl:text>     }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>     update() {
</xsl:text>
    <xsl:text>         if(this.editstr != this._editstr){
</xsl:text>
    <xsl:text>             this._editstr = this.editstr;
</xsl:text>
    <xsl:text>             this.Value_elt.textContent = this.editstr;
</xsl:text>
    <xsl:text>         }
</xsl:text>
    <xsl:text>         if(this.Shift_sub &amp;&amp; this.shift != this._shift){
</xsl:text>
    <xsl:text>             this._shift = this.shift;
</xsl:text>
    <xsl:text>             (this.shift?this.activate_activable:this.inactivate_activable)(this.Shift_sub);
</xsl:text>
    <xsl:text>         }
</xsl:text>
    <xsl:text>         if(this.CapsLock_sub &amp;&amp; this.caps != this._caps){
</xsl:text>
    <xsl:text>             this._caps = this.caps;
</xsl:text>
    <xsl:text>             (this.caps?this.activate_activable:this.inactivate_activable)(this.CapsLock_sub);
</xsl:text>
    <xsl:text>         }
</xsl:text>
    <xsl:text>     }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='Keypad']">
    <xsl:param name="hmi_element"/>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>Esc Enter BackSpace Keys Info Value</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>Sign Space NumDot</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="mandatory" select="'no'"/>
    </xsl:call-template>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>CapsLock Shift</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="mandatory" select="'no'"/>
      <xsl:with-param name="subelements" select="'active inactive'"/>
    </xsl:call-template>
    <xsl:text>    init: function() {
</xsl:text>
    <xsl:for-each select="$hmi_element/*[@inkscape:label = 'Keys']/*">
      <xsl:text>        id("</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>").setAttribute("onclick", "hmi_widgets['</xsl:text>
      <xsl:value-of select="$hmi_element/@id"/>
      <xsl:text>'].on_key_click('</xsl:text>
      <xsl:value-of select="func:escape_quotes(@inkscape:label)"/>
      <xsl:text>')");
</xsl:text>
    </xsl:for-each>
    <xsl:for-each select="str:split('Esc Enter BackSpace Sign Space NumDot CapsLock Shift')">
      <xsl:text>        if(this.</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>_elt)
</xsl:text>
      <xsl:text>            this.</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>_elt.setAttribute("onclick", "hmi_widgets['</xsl:text>
      <xsl:value-of select="$hmi_element/@id"/>
      <xsl:text>'].on_</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>_click()");
</xsl:text>
    </xsl:for-each>
    <xsl:text>    },
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:variable name="g" select="$geometry[@Id = $hmi_element/@id]"/>
    <xsl:text>    coordinates: [</xsl:text>
    <xsl:value-of select="$g/@x"/>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$g/@y"/>
    <xsl:text>],
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='List']">
    <xsl:param name="hmi_element"/>
    <xsl:text>    items: {
</xsl:text>
    <xsl:for-each select="$hmi_element/*[@inkscape:label]">
      <xsl:text>        </xsl:text>
      <xsl:value-of select="@inkscape:label"/>
      <xsl:text>: "</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>",
</xsl:text>
    </xsl:for-each>
    <xsl:text>    },
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='TextStyleList']">
    <xsl:param name="hmi_element"/>
    <xsl:text>    styles: {
</xsl:text>
    <xsl:for-each select="$hmi_element/*[@inkscape:label]">
      <xsl:variable name="text" select="func:refered_elements(.)[self::svg:text][1]"/>
      <xsl:variable name="tspan" select="$text/svg:tspan[1]"/>
      <xsl:variable name="style">
        <xsl:choose>
          <xsl:when test="$text/@style and $tspan/@style">
            <xsl:value-of select="$text/@style"/>
            <xsl:text>;</xsl:text>
            <xsl:value-of select="$tspan/@style"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$text/@style"/>
            <xsl:value-of select="$tspan/@style"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:text>        </xsl:text>
      <xsl:value-of select="@inkscape:label"/>
      <xsl:text>: "</xsl:text>
      <xsl:value-of select="$style"/>
      <xsl:text>",
</xsl:text>
    </xsl:for-each>
    <xsl:text>    },
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='Meter']">
    <xsl:text>class MeterWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 10;
</xsl:text>
    <xsl:text>    origin = undefined;
</xsl:text>
    <xsl:text>    range = undefined;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    dispatch(value) {
</xsl:text>
    <xsl:text>        this.display_val = value;
</xsl:text>
    <xsl:text>        this.request_animate();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    animate(){
</xsl:text>
    <xsl:text>        if(this.value_elt)
</xsl:text>
    <xsl:text>            this.value_elt.textContent = String(this.display_val);
</xsl:text>
    <xsl:text>        let [min,max,totallength] = this.range;
</xsl:text>
    <xsl:text>        let length = Math.max(0,Math.min(totallength,(Number(this.display_val)-min)*totallength/(max-min)));
</xsl:text>
    <xsl:text>        let tip = this.range_elt.getPointAtLength(length);
</xsl:text>
    <xsl:text>        this.needle_elt.setAttribute('d', "M "+this.origin.x+","+this.origin.y+" "+tip.x+","+tip.y);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    init() {
</xsl:text>
    <xsl:text>        let [min,max] = [[this.min_elt,0],[this.max_elt,100]].map(([elt,def],i)=&gt;elt?
</xsl:text>
    <xsl:text>            Number(elt.textContent) :
</xsl:text>
    <xsl:text>            this.args.length &gt;= i+1 ? this.args[i] : def);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        this.range = [min, max, this.range_elt.getTotalLength()]
</xsl:text>
    <xsl:text>        this.origin = this.needle_elt.getPointAtLength(0);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='Meter']">
    <xsl:param name="hmi_element"/>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>needle range</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>value min max</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="mandatory" select="'no'"/>
    </xsl:call-template>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='MultiState']">
    <xsl:text>class MultiStateWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 5;
</xsl:text>
    <xsl:text>    state = 0;
</xsl:text>
    <xsl:text>    dispatch(value) {
</xsl:text>
    <xsl:text>        this.state = value;
</xsl:text>
    <xsl:text>        for(let choice of this.choices){
</xsl:text>
    <xsl:text>            if(this.state != choice.value){
</xsl:text>
    <xsl:text>                choice.elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>            } else {
</xsl:text>
    <xsl:text>                choice.elt.setAttribute("style", choice.style);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    on_click(evt) {
</xsl:text>
    <xsl:text>        //get current selected value
</xsl:text>
    <xsl:text>        let next_ind;
</xsl:text>
    <xsl:text>        for(next_ind=0; next_ind&lt;this.choices.length; next_ind++){
</xsl:text>
    <xsl:text>            if(this.state == this.choices[next_ind].value){
</xsl:text>
    <xsl:text>               next_ind = next_ind + 1;
</xsl:text>
    <xsl:text>               break;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //get next selected value
</xsl:text>
    <xsl:text>        if(this.choices.length &gt; next_ind){
</xsl:text>
    <xsl:text>            this.state = this.choices[next_ind].value;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else{
</xsl:text>
    <xsl:text>            this.state = this.choices[0].value;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //post value to plc
</xsl:text>
    <xsl:text>        this.apply_hmi_value(0, this.state);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    init() {
</xsl:text>
    <xsl:text>        this.element.setAttribute("onclick", "hmi_widgets['"+this.element_id+"'].on_click(evt)");
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='MultiState']">
    <xsl:param name="hmi_element"/>
    <xsl:text>    choices: [
</xsl:text>
    <xsl:variable name="regex" select="'^(&quot;[^&quot;].*&quot;|\-?[0-9]+|false|true)(#.*)?$'"/>
    <xsl:for-each select="$result_svg_ns//*[@id = $hmi_element/@id]//*[regexp:test(@inkscape:label,$regex)]">
      <xsl:variable name="literal" select="regexp:match(@inkscape:label,$regex)[2]"/>
      <xsl:text>        {
</xsl:text>
      <xsl:text>            elt:id("</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>"),
</xsl:text>
      <xsl:text>            style:"</xsl:text>
      <xsl:value-of select="@style"/>
      <xsl:text>",
</xsl:text>
      <xsl:text>            value:</xsl:text>
      <xsl:value-of select="$literal"/>
      <xsl:text>
</xsl:text>
      <xsl:text>        }</xsl:text>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>    ],
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='ScrollBar']">
    <xsl:text>class ScrollBarWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 10;
</xsl:text>
    <xsl:text>    position = undefined;
</xsl:text>
    <xsl:text>    range = undefined;
</xsl:text>
    <xsl:text>    size = undefined;
</xsl:text>
    <xsl:text>    mincursize = 0.1;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    dispatch(value,oldval, index) {
</xsl:text>
    <xsl:text>        switch(index) {
</xsl:text>
    <xsl:text>            case 0:
</xsl:text>
    <xsl:text>                this.range = Math.max(1,value);
</xsl:text>
    <xsl:text>                break;
</xsl:text>
    <xsl:text>            case 1:
</xsl:text>
    <xsl:text>                this.position = value;
</xsl:text>
    <xsl:text>                break;
</xsl:text>
    <xsl:text>            case 2:
</xsl:text>
    <xsl:text>                this.size = value;
</xsl:text>
    <xsl:text>                break;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        this.request_animate();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    get_ratios() {
</xsl:text>
    <xsl:text>        let range = this.range;
</xsl:text>
    <xsl:text>        let size = Math.max(this.range * this.mincursize, Math.min(this.size, range));
</xsl:text>
    <xsl:text>        let maxh = this.range_elt.height.baseVal.value;
</xsl:text>
    <xsl:text>        let pixels = maxh;
</xsl:text>
    <xsl:text>        let units = range;
</xsl:text>
    <xsl:text>        return [size, maxh, range, pixels, units];
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    animate(){
</xsl:text>
    <xsl:text>        if(this.position == undefined || this.range == undefined || this.size == undefined)
</xsl:text>
    <xsl:text>            return;
</xsl:text>
    <xsl:text>        let [size, maxh, range, pixels, units] = this.get_ratios();
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        let new_y = this.range_elt.y.baseVal.value + Math.round(Math.min(this.position,range-size) * pixels / units);
</xsl:text>
    <xsl:text>        let new_height = Math.round(maxh * size/range);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        this.cursor_elt.y.baseVal.value = new_y;
</xsl:text>
    <xsl:text>        this.cursor_elt.height.baseVal.value = new_height;
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    init_mandatory() {
</xsl:text>
    <xsl:text>        this.cursor_elt.onpointerdown = () =&gt; this.on_cursor_down();
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        this.bound_drag = this.drag.bind(this);
</xsl:text>
    <xsl:text>        this.bound_drop = this.drop.bind(this);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    apply_position(position){
</xsl:text>
    <xsl:text>        this.position = Math.round(Math.max(Math.min(position, this.range - this.size), 0));
</xsl:text>
    <xsl:text>        this.apply_hmi_value(1, this.position);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    on_page_click(is_up){
</xsl:text>
    <xsl:text>        this.apply_position(is_up ? this.position-this.size
</xsl:text>
    <xsl:text>                                  : this.position+this.size);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    on_cursor_down(e){
</xsl:text>
    <xsl:text>        // get scrollbar -&gt; root transform
</xsl:text>
    <xsl:text>        let ctm = this.range_elt.getCTM();
</xsl:text>
    <xsl:text>        // relative motion -&gt; discard translation
</xsl:text>
    <xsl:text>        ctm.e = 0;
</xsl:text>
    <xsl:text>        ctm.f = 0;
</xsl:text>
    <xsl:text>        // root -&gt; scrollbar transform
</xsl:text>
    <xsl:text>        this.invctm = ctm.inverse();
</xsl:text>
    <xsl:text>        svg_root.addEventListener("pointerup", this.bound_drop, true);
</xsl:text>
    <xsl:text>        svg_root.addEventListener("pointermove", this.bound_drag, true);
</xsl:text>
    <xsl:text>        this.dragpos = this.position;
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    drop(e) {
</xsl:text>
    <xsl:text>        svg_root.removeEventListener("pointerup", this.bound_drop, true);
</xsl:text>
    <xsl:text>        svg_root.removeEventListener("pointermove", this.bound_drag, true);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    drag(e) {
</xsl:text>
    <xsl:text>        let [size, maxh, range, pixels, units] = this.get_ratios();
</xsl:text>
    <xsl:text>        if(pixels == 0) return;
</xsl:text>
    <xsl:text>        let point = new DOMPoint(e.movementX, e.movementY);
</xsl:text>
    <xsl:text>        let movement = point.matrixTransform(this.invctm).y;
</xsl:text>
    <xsl:text>        this.dragpos += movement * units / pixels;
</xsl:text>
    <xsl:text>        this.apply_position(this.dragpos);
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='ScrollBar']">
    <xsl:param name="hmi_element"/>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>cursor range</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:variable name="pagebuttons">
      <xsl:call-template name="defs_by_labels">
        <xsl:with-param name="hmi_element" select="$hmi_element"/>
        <xsl:with-param name="labels">
          <xsl:text>pageup pagedown</xsl:text>
        </xsl:with-param>
        <xsl:with-param name="mandatory" select="'no'"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="have_pagebuttons" select="string-length($pagebuttons)&gt;0"/>
    <xsl:value-of select="$pagebuttons"/>
    <xsl:text>    init: function() {
</xsl:text>
    <xsl:text>        this.init_mandatory();
</xsl:text>
    <xsl:if test="$have_pagebuttons">
      <xsl:text>        this.pageup_elt.onclick = () =&gt; this.on_page_click(true);
</xsl:text>
      <xsl:text>        this.pagedown_elt.onclick = () =&gt; this.on_page_click(false);
</xsl:text>
    </xsl:if>
    <xsl:text>    },
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='Slider']">
    <xsl:text>class SliderWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 5;
</xsl:text>
    <xsl:text>    range = undefined;
</xsl:text>
    <xsl:text>    handle_orig = undefined;
</xsl:text>
    <xsl:text>    scroll_size = undefined;
</xsl:text>
    <xsl:text>    scroll_range = 0;
</xsl:text>
    <xsl:text>    scroll_visible = 7;
</xsl:text>
    <xsl:text>    min_size = 0.07;
</xsl:text>
    <xsl:text>    fi = undefined;
</xsl:text>
    <xsl:text>    curr_value = 0;
</xsl:text>
    <xsl:text>    drag = false;
</xsl:text>
    <xsl:text>    enTimer = false;
</xsl:text>
    <xsl:text>    handle_click = undefined;
</xsl:text>
    <xsl:text>    last_drag = false;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    dispatch(value,oldval, index) {
</xsl:text>
    <xsl:text>        if (index == 0){
</xsl:text>
    <xsl:text>            let [min,max,start,totallength] = this.range;
</xsl:text>
    <xsl:text>            //save current value inside widget
</xsl:text>
    <xsl:text>            this.curr_value = value;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            //check if in range
</xsl:text>
    <xsl:text>            if (this.curr_value &gt; max){
</xsl:text>
    <xsl:text>                this.curr_value = max;
</xsl:text>
    <xsl:text>                this.apply_hmi_value(0, this.curr_value);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else if (this.curr_value &lt; min){
</xsl:text>
    <xsl:text>                this.curr_value = min;
</xsl:text>
    <xsl:text>                this.apply_hmi_value(0, this.curr_value);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            if(this.value_elt)
</xsl:text>
    <xsl:text>                this.value_elt.textContent = String(value);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else if(index == 1){
</xsl:text>
    <xsl:text>            this.scroll_range = value;
</xsl:text>
    <xsl:text>            this.set_scroll();
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else if(index == 2){
</xsl:text>
    <xsl:text>            this.scroll_visible = value;
</xsl:text>
    <xsl:text>            this.set_scroll();
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //don't update if draging and setpoint ghost doesn't exist
</xsl:text>
    <xsl:text>        if(!this.drag || (this.setpoint_elt != undefined)){
</xsl:text>
    <xsl:text>            this.update_DOM(this.curr_value, this.handle_elt);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    set_scroll(){
</xsl:text>
    <xsl:text>        //check if range is bigger than visible and set scroll size
</xsl:text>
    <xsl:text>        if(this.scroll_range &gt; this.scroll_visible){
</xsl:text>
    <xsl:text>            this.scroll_size = this.scroll_range - this.scroll_visible;
</xsl:text>
    <xsl:text>            this.range[0] = 0;
</xsl:text>
    <xsl:text>            this.range[1] = this.scroll_size;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else{
</xsl:text>
    <xsl:text>            this.scroll_size = 1;
</xsl:text>
    <xsl:text>            this.range[0] = 0;
</xsl:text>
    <xsl:text>            this.range[1] = 1;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    update_DOM(value, elt){
</xsl:text>
    <xsl:text>        let [min,max,start,totallength] = this.range;
</xsl:text>
    <xsl:text>        // check if handle is resizeable
</xsl:text>
    <xsl:text>        if (this.scroll_size != undefined){ //size changes
</xsl:text>
    <xsl:text>            //get parameters
</xsl:text>
    <xsl:text>            let length = Math.max(min,Math.min(max,(Number(value)-min)*max/(max-min)));
</xsl:text>
    <xsl:text>            let tip = this.range_elt.getPointAtLength(length);
</xsl:text>
    <xsl:text>            let handle_min = totallength*this.min_size;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            let step = 1;
</xsl:text>
    <xsl:text>            //check if range is bigger than  max displayed and recalculate step
</xsl:text>
    <xsl:text>            if ((totallength/handle_min) &lt; (max-min+1)){
</xsl:text>
    <xsl:text>                step = (max-min+1)/(totallength/handle_min-1);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            let kx,ky,offseY,offseX = undefined;
</xsl:text>
    <xsl:text>            //scale on x or y axes
</xsl:text>
    <xsl:text>            if (this.fi &gt; 0.75){
</xsl:text>
    <xsl:text>                //get scale factor
</xsl:text>
    <xsl:text>                if(step &gt; 1){
</xsl:text>
    <xsl:text>                    ky = handle_min/this.handle_orig.height;
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                else{
</xsl:text>
    <xsl:text>                    ky = (totallength-handle_min*(max-min))/this.handle_orig.height;
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                kx = 1;
</xsl:text>
    <xsl:text>                //get 0 offset to stay inside range
</xsl:text>
    <xsl:text>                offseY = start.y - (this.handle_orig.height + this.handle_orig.y) * ky;
</xsl:text>
    <xsl:text>                offseX = 0;
</xsl:text>
    <xsl:text>                //get distance from value
</xsl:text>
    <xsl:text>                tip.y =this.range_elt.getPointAtLength(0).y - length/step *handle_min;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else{
</xsl:text>
    <xsl:text>                //get scale factor
</xsl:text>
    <xsl:text>                if(step &gt; 1){
</xsl:text>
    <xsl:text>                    kx = handle_min/this.handle_orig.width;
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                else{
</xsl:text>
    <xsl:text>                    kx = (totallength-handle_min*(max-min))/this.handle_orig.width;
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                ky = 1;
</xsl:text>
    <xsl:text>                //get 0 offset to stay inside range
</xsl:text>
    <xsl:text>                offseX = start.x - (this.handle_orig.x * kx);
</xsl:text>
    <xsl:text>                offseY = 0;
</xsl:text>
    <xsl:text>                //get distance from value
</xsl:text>
    <xsl:text>                tip.x =this.range_elt.getPointAtLength(0).x + length/step *handle_min;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            elt.setAttribute('transform',"matrix("+(kx)+" 0 0 "+(ky)+" "+(tip.x-start.x+offseX)+" "+(tip.y-start.y+offseY)+")");
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else{ //size stays the same
</xsl:text>
    <xsl:text>            let length = Math.max(0,Math.min(totallength,(Number(value)-min)*totallength/(max-min)));
</xsl:text>
    <xsl:text>            let tip = this.range_elt.getPointAtLength(length);
</xsl:text>
    <xsl:text>            elt.setAttribute('transform',"translate("+(tip.x-start.x)+","+(tip.y-start.y)+")");
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        // show or hide ghost if exists
</xsl:text>
    <xsl:text>        if(this.setpoint_elt != undefined){
</xsl:text>
    <xsl:text>            if(this.last_drag!= this.drag){
</xsl:text>
    <xsl:text>                if(this.drag){
</xsl:text>
    <xsl:text>                    this.setpoint_elt.setAttribute("style", this.setpoint_style);
</xsl:text>
    <xsl:text>                }else{
</xsl:text>
    <xsl:text>                    this.setpoint_elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                this.last_drag = this.drag;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    on_release(evt) {
</xsl:text>
    <xsl:text>        //unbind events
</xsl:text>
    <xsl:text>        window.removeEventListener("touchmove", this.on_bound_drag, true);
</xsl:text>
    <xsl:text>        window.removeEventListener("mousemove", this.on_bound_drag, true);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        window.removeEventListener("mouseup", this.bound_on_release, true);
</xsl:text>
    <xsl:text>        window.removeEventListener("touchend", this.bound_on_release, true);
</xsl:text>
    <xsl:text>        window.removeEventListener("touchcancel", this.bound_on_release, true);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //reset drag flag
</xsl:text>
    <xsl:text>        if(this.drag){
</xsl:text>
    <xsl:text>            this.drag = false;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        // get final position
</xsl:text>
    <xsl:text>        this.update_position(evt);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    on_drag(evt){
</xsl:text>
    <xsl:text>        //ignore drag event for X amount of time and if not selected
</xsl:text>
    <xsl:text>        if(this.enTimer &amp;&amp; this.drag){
</xsl:text>
    <xsl:text>            this.update_position(evt);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            //reset timer
</xsl:text>
    <xsl:text>            this.enTimer = false;
</xsl:text>
    <xsl:text>            setTimeout("{hmi_widgets['"+this.element_id+"'].enTimer = true;}", 100);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    update_position(evt){
</xsl:text>
    <xsl:text>        var html_dist = 0;
</xsl:text>
    <xsl:text>        let [min,max,start,totallength] = this.range;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //calculate size of widget in html
</xsl:text>
    <xsl:text>        var range_borders = this.range_elt.getBoundingClientRect();
</xsl:text>
    <xsl:text>        var [minX,minY,maxX,maxY] = [range_borders.left,range_borders.bottom,range_borders.right,range_borders.top];
</xsl:text>
    <xsl:text>        var range_length = Math.sqrt( range_borders.height*range_borders.height + range_borders.width*range_borders.width );
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //get range and mouse coordinates
</xsl:text>
    <xsl:text>        var mouseX = undefined;
</xsl:text>
    <xsl:text>        var mouseY = undefined;
</xsl:text>
    <xsl:text>        if (evt.type.startsWith("touch")){
</xsl:text>
    <xsl:text>            mouseX = Math.ceil(evt.touches[0].clientX);
</xsl:text>
    <xsl:text>            mouseY = Math.ceil(evt.touches[0].clientY);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else{
</xsl:text>
    <xsl:text>            mouseX = evt.pageX;
</xsl:text>
    <xsl:text>            mouseY = evt.pageY;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        // calculate position
</xsl:text>
    <xsl:text>        if (this.handle_click){ //if clicked on handle
</xsl:text>
    <xsl:text>            let moveDist = 0, resizeAdd = 0;
</xsl:text>
    <xsl:text>            let range_percent = 1;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            //set paramters for resizeable handle
</xsl:text>
    <xsl:text>            if (this.scroll_size != undefined){
</xsl:text>
    <xsl:text>                // add one more object to stay inside range
</xsl:text>
    <xsl:text>                resizeAdd = 1;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>                //chack if range is bigger than display option and
</xsl:text>
    <xsl:text>                // calculate percent of range with out handle
</xsl:text>
    <xsl:text>                if(((max/(max*this.min_size)) &lt; (max-min+1))){
</xsl:text>
    <xsl:text>                    range_percent = 1-this.min_size;
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                else{
</xsl:text>
    <xsl:text>                    range_percent = 1-(max-max*this.min_size*(max-min))/max;
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            //calculate value difference on x or y axis
</xsl:text>
    <xsl:text>            if(this.fi &gt; 0.7){
</xsl:text>
    <xsl:text>                moveDist = ((max-min+resizeAdd)/(range_length*range_percent))*((this.handle_click[1]-mouseY)/Math.sin(this.fi));
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else{
</xsl:text>
    <xsl:text>                moveDist = ((max-min+resizeAdd)/(range_length*range_percent))*((mouseX-this.handle_click[0])/Math.cos(this.fi));
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>            this.curr_value = Math.ceil(this.handle_click[2] + moveDist);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else{ //if clicked on widget
</xsl:text>
    <xsl:text>            //get handle distance from mouse position
</xsl:text>
    <xsl:text>            if (minX &gt; mouseX &amp;&amp; minY &lt; mouseY){
</xsl:text>
    <xsl:text>                html_dist = 0;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else if (maxX &lt; mouseX &amp;&amp; maxY &gt; mouseY){
</xsl:text>
    <xsl:text>                html_dist = range_length;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else{
</xsl:text>
    <xsl:text>                if(this.fi &gt; 0.7){
</xsl:text>
    <xsl:text>                    html_dist = (minY - mouseY)/Math.sin(this.fi);
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>                else{
</xsl:text>
    <xsl:text>                    html_dist = (mouseX - minX)/Math.cos(this.fi);
</xsl:text>
    <xsl:text>                }
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            //calculate distance
</xsl:text>
    <xsl:text>            this.curr_value=Math.ceil((html_dist/range_length)*(this.range[1]-this.range[0])+this.range[0]);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //check if in range and apply
</xsl:text>
    <xsl:text>        if (this.curr_value &gt; max){
</xsl:text>
    <xsl:text>            this.curr_value = max;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else if (this.curr_value &lt; min){
</xsl:text>
    <xsl:text>            this.curr_value = min;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        this.apply_hmi_value(0, this.curr_value);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //redraw handle
</xsl:text>
    <xsl:text>        this.request_animate();
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    animate(){
</xsl:text>
    <xsl:text>        // redraw handle on screen refresh
</xsl:text>
    <xsl:text>        // check if setpoint(ghost) handle exsist otherwise update main handle
</xsl:text>
    <xsl:text>        if(this.setpoint_elt != undefined){
</xsl:text>
    <xsl:text>            this.update_DOM(this.curr_value, this.setpoint_elt);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else{
</xsl:text>
    <xsl:text>            this.update_DOM(this.curr_value, this.handle_elt);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    on_select(evt){
</xsl:text>
    <xsl:text>        //enable drag flag and timer
</xsl:text>
    <xsl:text>        this.drag = true;
</xsl:text>
    <xsl:text>        this.enTimer = true;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //bind events
</xsl:text>
    <xsl:text>        window.addEventListener("touchmove", this.on_bound_drag, true);
</xsl:text>
    <xsl:text>        window.addEventListener("mousemove", this.on_bound_drag, true);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        window.addEventListener("mouseup", this.bound_on_release, true);
</xsl:text>
    <xsl:text>        window.addEventListener("touchend", this.bound_on_release, true);
</xsl:text>
    <xsl:text>        window.addEventListener("touchcancel", this.bound_on_release, true);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        // check if handle was pressed
</xsl:text>
    <xsl:text>        if (evt.currentTarget == this.handle_elt){
</xsl:text>
    <xsl:text>            //get mouse position on the handle
</xsl:text>
    <xsl:text>            let mouseX = undefined;
</xsl:text>
    <xsl:text>            let mouseY = undefined;
</xsl:text>
    <xsl:text>            if (evt.type.startsWith("touch")){
</xsl:text>
    <xsl:text>                mouseX = Math.ceil(evt.touches[0].clientX);
</xsl:text>
    <xsl:text>                mouseY = Math.ceil(evt.touches[0].clientY);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            else{
</xsl:text>
    <xsl:text>                mouseX = evt.pageX;
</xsl:text>
    <xsl:text>                mouseY = evt.pageY;
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>            //save coordinates and orig value
</xsl:text>
    <xsl:text>            this.handle_click = [mouseX,mouseY,this.curr_value];
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        else{
</xsl:text>
    <xsl:text>            // get new handle position and reset if handle was not pressed
</xsl:text>
    <xsl:text>            this.handle_click = undefined;
</xsl:text>
    <xsl:text>            this.update_position(evt);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //prevent next events
</xsl:text>
    <xsl:text>        evt.stopPropagation();
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    init() {
</xsl:text>
    <xsl:text>        //set min max value if not defined
</xsl:text>
    <xsl:text>        let min = this.min_elt ?
</xsl:text>
    <xsl:text>                    Number(this.min_elt.textContent) :
</xsl:text>
    <xsl:text>                    this.args.length &gt;= 1 ? this.args[0] : 0;
</xsl:text>
    <xsl:text>        let max = this.max_elt ?
</xsl:text>
    <xsl:text>                    Number(this.max_elt.textContent) :
</xsl:text>
    <xsl:text>                    this.args.length &gt;= 2 ? this.args[1] : 100;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        // save initial parameters
</xsl:text>
    <xsl:text>        this.range_elt.style.strokeMiterlimit="0";
</xsl:text>
    <xsl:text>        this.range = [min, max, this.range_elt.getPointAtLength(0),this.range_elt.getTotalLength()];
</xsl:text>
    <xsl:text>        let start = this.range_elt.getPointAtLength(0);
</xsl:text>
    <xsl:text>        let end = this.range_elt.getPointAtLength(this.range_elt.getTotalLength());
</xsl:text>
    <xsl:text>        this.fi = Math.atan2(start.y-end.y, end.x-start.x);
</xsl:text>
    <xsl:text>        this.handle_orig = this.handle_elt.getBBox();
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //bind functions
</xsl:text>
    <xsl:text>        this.bound_on_select = this.on_select.bind(this);
</xsl:text>
    <xsl:text>        this.bound_on_release = this.on_release.bind(this);
</xsl:text>
    <xsl:text>        this.on_bound_drag = this.on_drag.bind(this);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        this.handle_elt.addEventListener("mousedown", this.bound_on_select);
</xsl:text>
    <xsl:text>        this.element.addEventListener("mousedown", this.bound_on_select);
</xsl:text>
    <xsl:text>        this.element.addEventListener("touchstart", this.bound_on_select);
</xsl:text>
    <xsl:text>        //touch recognised as page drag without next command
</xsl:text>
    <xsl:text>        document.body.addEventListener("touchstart", function(e){}, false);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //save ghost style
</xsl:text>
    <xsl:text>        if(this.setpoint_elt != undefined){
</xsl:text>
    <xsl:text>            this.setpoint_style = this.setpoint_elt.getAttribute("style");
</xsl:text>
    <xsl:text>            this.setpoint_elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='Slider']">
    <xsl:param name="hmi_element"/>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>handle range</xsl:text>
      </xsl:with-param>
    </xsl:call-template>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>value min max setpoint</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="mandatory" select="'no'"/>
    </xsl:call-template>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='Switch']">
    <xsl:text>class SwitchWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 5;
</xsl:text>
    <xsl:text>    dispatch(value) {
</xsl:text>
    <xsl:text>        for(let choice of this.choices){
</xsl:text>
    <xsl:text>            if(value != choice.value){
</xsl:text>
    <xsl:text>                choice.elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>            } else {
</xsl:text>
    <xsl:text>                choice.elt.setAttribute("style", choice.style);
</xsl:text>
    <xsl:text>            }
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='Switch']">
    <xsl:param name="hmi_element"/>
    <xsl:text>    choices: [
</xsl:text>
    <xsl:variable name="regex" select="'^(&quot;[^&quot;].*&quot;|\-?[0-9]+|false|true)(#.*)?$'"/>
    <xsl:for-each select="$result_svg_ns//*[@id = $hmi_element/@id]//*[regexp:test(@inkscape:label,$regex)]">
      <xsl:variable name="literal" select="regexp:match(@inkscape:label,$regex)[2]"/>
      <xsl:text>        {
</xsl:text>
      <xsl:text>            elt:id("</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>"),
</xsl:text>
      <xsl:text>            style:"</xsl:text>
      <xsl:value-of select="@style"/>
      <xsl:text>",
</xsl:text>
      <xsl:text>            value:</xsl:text>
      <xsl:value-of select="$literal"/>
      <xsl:text>
</xsl:text>
      <xsl:text>        }</xsl:text>
      <xsl:if test="position()!=last()">
        <xsl:text>,</xsl:text>
      </xsl:if>
      <xsl:text>
</xsl:text>
    </xsl:for-each>
    <xsl:text>    ],
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_class" match="widget[@type='ToggleButton']">
    <xsl:text>class ToggleButtonWidget extends Widget{
</xsl:text>
    <xsl:text>    frequency = 5;
</xsl:text>
    <xsl:text>    state = 0;
</xsl:text>
    <xsl:text>    active_style = undefined;
</xsl:text>
    <xsl:text>    inactive_style = undefined;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    dispatch(value) {
</xsl:text>
    <xsl:text>        this.state = value;
</xsl:text>
    <xsl:text>        //redraw toggle button
</xsl:text>
    <xsl:text>        this.request_animate();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    on_click(evt) {
</xsl:text>
    <xsl:text>        //toggle state and apply
</xsl:text>
    <xsl:text>        if (this.state) {
</xsl:text>
    <xsl:text>            this.state = 0;
</xsl:text>
    <xsl:text>        } else {
</xsl:text>
    <xsl:text>            this.state = 1;
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>        this.apply_hmi_value(0, this.state);
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        //redraw toggle button
</xsl:text>
    <xsl:text>        this.request_animate();
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    animate(){
</xsl:text>
    <xsl:text>       // redraw toggle button on screen refresh
</xsl:text>
    <xsl:text>       if (this.state) {
</xsl:text>
    <xsl:text>           this.active_elt.setAttribute("style", this.active_style);
</xsl:text>
    <xsl:text>           this.inactive_elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>       } else {
</xsl:text>
    <xsl:text>           this.inactive_elt.setAttribute("style", this.inactive_style);
</xsl:text>
    <xsl:text>           this.active_elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>       }
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>    init() {
</xsl:text>
    <xsl:text>        this.active_style = this.active_elt ? this.active_elt.style.cssText : undefined;
</xsl:text>
    <xsl:text>        this.inactive_style = this.inactive_elt ? this.inactive_elt.style.cssText : undefined;
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        if (this.active_style &amp;&amp; this.inactive_style) {
</xsl:text>
    <xsl:text>            this.active_elt.setAttribute("style", "display:none");
</xsl:text>
    <xsl:text>            this.inactive_elt.setAttribute("style", this.inactive_style);
</xsl:text>
    <xsl:text>        }
</xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:text>        this.element.setAttribute("onclick", "hmi_widgets['"+this.element_id+"'].on_click(evt)");
</xsl:text>
    <xsl:text>    }
</xsl:text>
    <xsl:text>}
</xsl:text>
  </xsl:template>
  <xsl:template mode="widget_defs" match="widget[@type='ToggleButton']">
    <xsl:param name="hmi_element"/>
    <xsl:call-template name="defs_by_labels">
      <xsl:with-param name="hmi_element" select="$hmi_element"/>
      <xsl:with-param name="labels">
        <xsl:text>active inactive</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="mandatory" select="'no'"/>
    </xsl:call-template>
    <xsl:text>
</xsl:text>
  </xsl:template>
  <xsl:template match="/">
    <xsl:comment>
      <xsl:text>Made with SVGHMI. https://beremiz.org</xsl:text>
    </xsl:comment>
    <xsl:comment>
      <xsl:apply-templates select="document('')/*/debug:*"/>
    </xsl:comment>
    <html xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns="http://www.w3.org/1999/xhtml">
      <head/>
      <body style="margin:0;overflow:hidden;user-select:none;touch-action:none;">
        <xsl:copy-of select="$result_svg"/>
        <script>
          <xsl:text>
//
//
// Early independent declarations 
//
//
</xsl:text>
          <xsl:apply-templates select="document('')/*/preamble:*"/>
          <xsl:text>
//
//
// Declarations depending on preamble 
//
//
</xsl:text>
          <xsl:apply-templates select="document('')/*/declarations:*"/>
          <xsl:text>
//
//
// Order independent declaration and code 
//
//
</xsl:text>
          <xsl:apply-templates select="document('')/*/definitions:*"/>
          <xsl:text>
//
//
// Statements that needs to be at the end 
//
//
</xsl:text>
          <xsl:apply-templates select="document('')/*/epilogue:*"/>
          <xsl:text>// svghmi.js
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>var need_cache_apply = [];
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function dispatch_value(index, value) {
</xsl:text>
          <xsl:text>    let widgets = subscribers(index);
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    let oldval = cache[index];
</xsl:text>
          <xsl:text>    cache[index] = value;
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    if(widgets.size &gt; 0) {
</xsl:text>
          <xsl:text>        for(let widget of widgets){
</xsl:text>
          <xsl:text>            widget.new_hmi_value(index, value, oldval);
</xsl:text>
          <xsl:text>        }
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function init_widgets() {
</xsl:text>
          <xsl:text>    Object.keys(hmi_widgets).forEach(function(id) {
</xsl:text>
          <xsl:text>        let widget = hmi_widgets[id];
</xsl:text>
          <xsl:text>        let init = widget.init;
</xsl:text>
          <xsl:text>        if(typeof(init) == "function"){
</xsl:text>
          <xsl:text>            try {
</xsl:text>
          <xsl:text>                init.call(widget);
</xsl:text>
          <xsl:text>            } catch(err) {
</xsl:text>
          <xsl:text>                console.log(err);
</xsl:text>
          <xsl:text>            }
</xsl:text>
          <xsl:text>        }
</xsl:text>
          <xsl:text>    });
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>// Open WebSocket to relative "/ws" address
</xsl:text>
          <xsl:text>var ws = new WebSocket(window.location.href.replace(/^http(s?:\/\/[^\/]*)\/.*$/, 'ws$1/ws'));
</xsl:text>
          <xsl:text>ws.binaryType = 'arraybuffer';
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>const dvgetters = {
</xsl:text>
          <xsl:text>    INT: (dv,offset) =&gt; [dv.getInt16(offset, true), 2],
</xsl:text>
          <xsl:text>    BOOL: (dv,offset) =&gt; [dv.getInt8(offset, true), 1],
</xsl:text>
          <xsl:text>    NODE: (dv,offset) =&gt; [dv.getInt8(offset, true), 1],
</xsl:text>
          <xsl:text>    REAL: (dv,offset) =&gt; [dv.getFloat32(offset, true), 4],
</xsl:text>
          <xsl:text>    STRING: (dv, offset) =&gt; {
</xsl:text>
          <xsl:text>        const size = dv.getInt8(offset);
</xsl:text>
          <xsl:text>        return [
</xsl:text>
          <xsl:text>            String.fromCharCode.apply(null, new Uint8Array(
</xsl:text>
          <xsl:text>                dv.buffer, /* original buffer */
</xsl:text>
          <xsl:text>                offset + 1, /* string starts after size*/
</xsl:text>
          <xsl:text>                size /* size of string */
</xsl:text>
          <xsl:text>            )), size + 1]; /* total increment */
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>// Apply updates recieved through ws.onmessage to subscribed widgets
</xsl:text>
          <xsl:text>function apply_updates() {
</xsl:text>
          <xsl:text>    updates.forEach((value, index) =&gt; {
</xsl:text>
          <xsl:text>        dispatch_value(index, value);
</xsl:text>
          <xsl:text>    });
</xsl:text>
          <xsl:text>    updates.clear();
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>// Called on requestAnimationFrame, modifies DOM
</xsl:text>
          <xsl:text>var requestAnimationFrameID = null;
</xsl:text>
          <xsl:text>function animate() {
</xsl:text>
          <xsl:text>    // Do the page swith if any one pending
</xsl:text>
          <xsl:text>    if(current_subscribed_page != current_visible_page){
</xsl:text>
          <xsl:text>        switch_visible_page(current_subscribed_page);
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    while(widget = need_cache_apply.pop()){
</xsl:text>
          <xsl:text>        widget.apply_cache();
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    if(jumps_need_update) update_jumps();
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    apply_updates();
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    pending_widget_animates.forEach(widget =&gt; widget._animate());
</xsl:text>
          <xsl:text>    pending_widget_animates = [];
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    requestAnimationFrameID = null;
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function requestHMIAnimation() {
</xsl:text>
          <xsl:text>    if(requestAnimationFrameID == null){
</xsl:text>
          <xsl:text>        requestAnimationFrameID = window.requestAnimationFrame(animate);
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>// Message reception handler
</xsl:text>
          <xsl:text>// Hash is verified and HMI values updates resulting from binary parsing
</xsl:text>
          <xsl:text>// are stored until browser can compute next frame, DOM is left untouched
</xsl:text>
          <xsl:text>ws.onmessage = function (evt) {
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    let data = evt.data;
</xsl:text>
          <xsl:text>    let dv = new DataView(data);
</xsl:text>
          <xsl:text>    let i = 0;
</xsl:text>
          <xsl:text>    try {
</xsl:text>
          <xsl:text>        for(let hash_int of hmi_hash) {
</xsl:text>
          <xsl:text>            if(hash_int != dv.getUint8(i)){
</xsl:text>
          <xsl:text>                throw new Error("Hash doesn't match");
</xsl:text>
          <xsl:text>            };
</xsl:text>
          <xsl:text>            i++;
</xsl:text>
          <xsl:text>        };
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>        while(i &lt; data.byteLength){
</xsl:text>
          <xsl:text>            let index = dv.getUint32(i, true);
</xsl:text>
          <xsl:text>            i += 4;
</xsl:text>
          <xsl:text>            let iectype = hmitree_types[index];
</xsl:text>
          <xsl:text>            if(iectype != undefined){
</xsl:text>
          <xsl:text>                let dvgetter = dvgetters[iectype];
</xsl:text>
          <xsl:text>                let [value, bytesize] = dvgetter(dv,i);
</xsl:text>
          <xsl:text>                updates.set(index, value);
</xsl:text>
          <xsl:text>                i += bytesize;
</xsl:text>
          <xsl:text>            } else {
</xsl:text>
          <xsl:text>                throw new Error("Unknown index "+index);
</xsl:text>
          <xsl:text>            }
</xsl:text>
          <xsl:text>        };
</xsl:text>
          <xsl:text>        // register for rendering on next frame, since there are updates
</xsl:text>
          <xsl:text>        requestHMIAnimation();
</xsl:text>
          <xsl:text>    } catch(err) {
</xsl:text>
          <xsl:text>        // 1003 is for "Unsupported Data"
</xsl:text>
          <xsl:text>        // ws.close(1003, err.message);
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>        // TODO : remove debug alert ?
</xsl:text>
          <xsl:text>        alert("Error : "+err.message+"\nHMI will be reloaded.");
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>        // force reload ignoring cache
</xsl:text>
          <xsl:text>        location.reload(true);
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>hmi_hash_u8 = new Uint8Array(hmi_hash);
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function send_blob(data) {
</xsl:text>
          <xsl:text>    if(data.length &gt; 0) {
</xsl:text>
          <xsl:text>        ws.send(new Blob([hmi_hash_u8].concat(data)));
</xsl:text>
          <xsl:text>    };
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>const typedarray_types = {
</xsl:text>
          <xsl:text>    INT: (number) =&gt; new Int16Array([number]),
</xsl:text>
          <xsl:text>    BOOL: (truth) =&gt; new Int16Array([truth]),
</xsl:text>
          <xsl:text>    NODE: (truth) =&gt; new Int16Array([truth]),
</xsl:text>
          <xsl:text>    REAL: (number) =&gt; new Float32Array([number]),
</xsl:text>
          <xsl:text>    STRING: (str) =&gt; {
</xsl:text>
          <xsl:text>        // beremiz default string max size is 128
</xsl:text>
          <xsl:text>        str = str.slice(0,128);
</xsl:text>
          <xsl:text>        binary = new Uint8Array(str.length + 1);
</xsl:text>
          <xsl:text>        binary[0] = str.length;
</xsl:text>
          <xsl:text>        for(let i = 0; i &lt; str.length; i++){
</xsl:text>
          <xsl:text>            binary[i+1] = str.charCodeAt(i);
</xsl:text>
          <xsl:text>        }
</xsl:text>
          <xsl:text>        return binary;
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>    /* TODO */
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function send_reset() {
</xsl:text>
          <xsl:text>    send_blob(new Uint8Array([1])); /* reset = 1 */
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>var subscriptions = [];
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function subscribers(index) {
</xsl:text>
          <xsl:text>    let entry = subscriptions[index];
</xsl:text>
          <xsl:text>    let res;
</xsl:text>
          <xsl:text>    if(entry == undefined){
</xsl:text>
          <xsl:text>        res = new Set();
</xsl:text>
          <xsl:text>        subscriptions[index] = [res,0];
</xsl:text>
          <xsl:text>    }else{
</xsl:text>
          <xsl:text>        [res, _ign] = entry;
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>    return res
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function get_subscription_period(index) {
</xsl:text>
          <xsl:text>    let entry = subscriptions[index];
</xsl:text>
          <xsl:text>    if(entry == undefined)
</xsl:text>
          <xsl:text>        return 0;
</xsl:text>
          <xsl:text>    let [_ign, period] = entry;
</xsl:text>
          <xsl:text>    return period;
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function set_subscription_period(index, period) {
</xsl:text>
          <xsl:text>    let entry = subscriptions[index];
</xsl:text>
          <xsl:text>    if(entry == undefined){
</xsl:text>
          <xsl:text>        subscriptions[index] = [new Set(), period];
</xsl:text>
          <xsl:text>    } else {
</xsl:text>
          <xsl:text>        entry[1] = period;
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>// artificially subscribe the watchdog widget to "/heartbeat" hmi variable
</xsl:text>
          <xsl:text>// Since dispatch directly calls change_hmi_value,
</xsl:text>
          <xsl:text>// PLC will periodically send variable at given frequency
</xsl:text>
          <xsl:text>subscribers(heartbeat_index).add({
</xsl:text>
          <xsl:text>    /* type: "Watchdog", */
</xsl:text>
          <xsl:text>    frequency: 1,
</xsl:text>
          <xsl:text>    indexes: [heartbeat_index],
</xsl:text>
          <xsl:text>    new_hmi_value: function(index, value, oldval) {
</xsl:text>
          <xsl:text>        apply_hmi_value(heartbeat_index, value+1);
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>});
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function svg_text_to_multiline(elt) {
</xsl:text>
          <xsl:text>    return(Array.prototype.map.call(elt.children, x=&gt;x.textContent).join("\n")); 
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function multiline_to_svg_text(elt, str) {
</xsl:text>
          <xsl:text>    str.split('\n').map((line,i) =&gt; {elt.children[i].textContent = line;});
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function switch_langnum(langnum) {
</xsl:text>
          <xsl:text>    langnum = Math.max(0, Math.min(langs.length - 1, langnum));
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    for (let translation of translations) {
</xsl:text>
          <xsl:text>        let [objs, msgs] = translation;
</xsl:text>
          <xsl:text>        let msg = msgs[langnum];
</xsl:text>
          <xsl:text>        for (let obj of objs) {
</xsl:text>
          <xsl:text>            multiline_to_svg_text(obj, msg);
</xsl:text>
          <xsl:text>            obj.setAttribute("lang",langnum);
</xsl:text>
          <xsl:text>        }
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>    return langnum;
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>// backup original texts
</xsl:text>
          <xsl:text>for (let translation of translations) {
</xsl:text>
          <xsl:text>    let [objs, msgs] = translation;
</xsl:text>
          <xsl:text>    msgs.unshift(svg_text_to_multiline(objs[0])); 
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>var lang_local_index = hmi_local_index("lang");
</xsl:text>
          <xsl:text>var langcode_local_index = hmi_local_index("lang_code");
</xsl:text>
          <xsl:text>var langname_local_index = hmi_local_index("lang_name");
</xsl:text>
          <xsl:text>subscribers(lang_local_index).add({
</xsl:text>
          <xsl:text>    indexes: [lang_local_index],
</xsl:text>
          <xsl:text>    new_hmi_value: function(index, value, oldval) {
</xsl:text>
          <xsl:text>        let current_lang =  switch_langnum(value);
</xsl:text>
          <xsl:text>        let [langname,langcode] = langs[current_lang];
</xsl:text>
          <xsl:text>        apply_hmi_value(langcode_local_index, langcode);
</xsl:text>
          <xsl:text>        apply_hmi_value(langname_local_index, langname);
</xsl:text>
          <xsl:text>        switch_page();
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>});
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function setup_lang(){
</xsl:text>
          <xsl:text>    let current_lang = cache[lang_local_index];
</xsl:text>
          <xsl:text>    let new_lang = switch_langnum(current_lang);
</xsl:text>
          <xsl:text>    if(current_lang != new_lang){
</xsl:text>
          <xsl:text>        apply_hmi_value(lang_local_index, new_lang);
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>setup_lang();
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function update_subscriptions() {
</xsl:text>
          <xsl:text>    let delta = [];
</xsl:text>
          <xsl:text>    for(let index in subscriptions){
</xsl:text>
          <xsl:text>        let widgets = subscribers(index);
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>        // periods are in ms
</xsl:text>
          <xsl:text>        let previous_period = get_subscription_period(index);
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>        // subscribing with a zero period is unsubscribing
</xsl:text>
          <xsl:text>        let new_period = 0;
</xsl:text>
          <xsl:text>        if(widgets.size &gt; 0) {
</xsl:text>
          <xsl:text>            let maxfreq = 0;
</xsl:text>
          <xsl:text>            for(let widget of widgets){
</xsl:text>
          <xsl:text>                let wf = widget.frequency;
</xsl:text>
          <xsl:text>                if(wf != undefined &amp;&amp; maxfreq &lt; wf)
</xsl:text>
          <xsl:text>                    maxfreq = wf;
</xsl:text>
          <xsl:text>            }
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>            if(maxfreq != 0)
</xsl:text>
          <xsl:text>                new_period = 1000/maxfreq;
</xsl:text>
          <xsl:text>        }
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>        if(previous_period != new_period) {
</xsl:text>
          <xsl:text>            set_subscription_period(index, new_period);
</xsl:text>
          <xsl:text>            if(index &lt;= last_remote_index){
</xsl:text>
          <xsl:text>                delta.push(
</xsl:text>
          <xsl:text>                    new Uint8Array([2]), /* subscribe = 2 */
</xsl:text>
          <xsl:text>                    new Uint32Array([index]),
</xsl:text>
          <xsl:text>                    new Uint16Array([new_period]));
</xsl:text>
          <xsl:text>            }
</xsl:text>
          <xsl:text>        }
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>    send_blob(delta);
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function send_hmi_value(index, value) {
</xsl:text>
          <xsl:text>    if(index &gt; last_remote_index){
</xsl:text>
          <xsl:text>        updates.set(index, value);
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>        if(persistent_indexes.has(index)){
</xsl:text>
          <xsl:text>            let varname = persistent_indexes.get(index);
</xsl:text>
          <xsl:text>            document.cookie = varname+"="+value+"; max-age=3153600000";
</xsl:text>
          <xsl:text>        }
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>        requestHMIAnimation();
</xsl:text>
          <xsl:text>        return;
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    let iectype = hmitree_types[index];
</xsl:text>
          <xsl:text>    let tobinary = typedarray_types[iectype];
</xsl:text>
          <xsl:text>    send_blob([
</xsl:text>
          <xsl:text>        new Uint8Array([0]),  /* setval = 0 */
</xsl:text>
          <xsl:text>        new Uint32Array([index]),
</xsl:text>
          <xsl:text>        tobinary(value)]);
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    // DON'T DO THAT unless read_iterator in svghmi.c modifies wbuf as well, not only rbuf
</xsl:text>
          <xsl:text>    // cache[index] = value;
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function apply_hmi_value(index, new_val) {
</xsl:text>
          <xsl:text>    let old_val = cache[index]
</xsl:text>
          <xsl:text>    if(new_val != undefined &amp;&amp; old_val != new_val)
</xsl:text>
          <xsl:text>        send_hmi_value(index, new_val);
</xsl:text>
          <xsl:text>    return new_val;
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>const quotes = {"'":null, '"':null};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function eval_operation_string(old_val, opstr) {
</xsl:text>
          <xsl:text>    let op = opstr[0];
</xsl:text>
          <xsl:text>    let given_val;
</xsl:text>
          <xsl:text>    if(opstr.length &lt; 2) 
</xsl:text>
          <xsl:text>        return undefined;
</xsl:text>
          <xsl:text>    if(opstr[1] in quotes){
</xsl:text>
          <xsl:text>        if(opstr.length &lt; 3) 
</xsl:text>
          <xsl:text>            return undefined;
</xsl:text>
          <xsl:text>        if(opstr[opstr.length-1] == opstr[1]){
</xsl:text>
          <xsl:text>            given_val = opstr.slice(2,opstr.length-1);
</xsl:text>
          <xsl:text>        }
</xsl:text>
          <xsl:text>    } else {
</xsl:text>
          <xsl:text>        given_val = Number(opstr.slice(1));
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>    let new_val;
</xsl:text>
          <xsl:text>    switch(op){
</xsl:text>
          <xsl:text>      case "=":
</xsl:text>
          <xsl:text>        new_val = given_val;
</xsl:text>
          <xsl:text>        break;
</xsl:text>
          <xsl:text>      case "+":
</xsl:text>
          <xsl:text>        new_val = old_val + given_val;
</xsl:text>
          <xsl:text>        break;
</xsl:text>
          <xsl:text>      case "-":
</xsl:text>
          <xsl:text>        new_val = old_val - given_val;
</xsl:text>
          <xsl:text>        break;
</xsl:text>
          <xsl:text>      case "*":
</xsl:text>
          <xsl:text>        new_val = old_val * given_val;
</xsl:text>
          <xsl:text>        break;
</xsl:text>
          <xsl:text>      case "/":
</xsl:text>
          <xsl:text>        new_val = old_val / given_val;
</xsl:text>
          <xsl:text>        break;
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>    return new_val;
</xsl:text>
          <xsl:text>}
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>var current_visible_page;
</xsl:text>
          <xsl:text>var current_subscribed_page;
</xsl:text>
          <xsl:text>var current_page_index;
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function prepare_svg() {
</xsl:text>
          <xsl:text>    // prevents context menu from appearing on right click and long touch
</xsl:text>
          <xsl:text>    document.body.addEventListener('contextmenu', e =&gt; {
</xsl:text>
          <xsl:text>        e.preventDefault();
</xsl:text>
          <xsl:text>    });
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    for(let eltid in detachable_elements){
</xsl:text>
          <xsl:text>        let [element,parent] = detachable_elements[eltid];
</xsl:text>
          <xsl:text>        parent.removeChild(element);
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function switch_page(page_name, page_index) {
</xsl:text>
          <xsl:text>    if(current_subscribed_page != current_visible_page){
</xsl:text>
          <xsl:text>        /* page switch already going */
</xsl:text>
          <xsl:text>        /* TODO LOG ERROR */
</xsl:text>
          <xsl:text>        return false;
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    if(page_name == undefined)
</xsl:text>
          <xsl:text>        page_name = current_subscribed_page;
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    let old_desc = page_desc[current_subscribed_page];
</xsl:text>
          <xsl:text>    let new_desc = page_desc[page_name];
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    if(new_desc == undefined){
</xsl:text>
          <xsl:text>        /* TODO LOG ERROR */
</xsl:text>
          <xsl:text>        return false;
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    if(page_index == undefined){
</xsl:text>
          <xsl:text>        page_index = new_desc.page_index;
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    if(old_desc){
</xsl:text>
          <xsl:text>        old_desc.widgets.map(([widget,relativeness])=&gt;widget.unsub());
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>    const new_offset = page_index == undefined ? 0 : page_index - new_desc.page_index;
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    const container_id = page_name + (page_index != undefined ? page_index : "");
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    new_desc.widgets.map(([widget,relativeness])=&gt;widget.sub(new_offset,relativeness,container_id));
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    update_subscriptions();
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    current_subscribed_page = page_name;
</xsl:text>
          <xsl:text>    current_page_index = page_index;
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    jumps_need_update = true;
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    requestHMIAnimation();
</xsl:text>
          <xsl:text>    jump_history.push([page_name, page_index]);
</xsl:text>
          <xsl:text>    if(jump_history.length &gt; 42)
</xsl:text>
          <xsl:text>        jump_history.shift();
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    return true;
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function switch_visible_page(page_name) {
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    let old_desc = page_desc[current_visible_page];
</xsl:text>
          <xsl:text>    let new_desc = page_desc[page_name];
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    if(old_desc){
</xsl:text>
          <xsl:text>        for(let eltid in old_desc.required_detachables){
</xsl:text>
          <xsl:text>            if(!(eltid in new_desc.required_detachables)){
</xsl:text>
          <xsl:text>                let [element, parent] = old_desc.required_detachables[eltid];
</xsl:text>
          <xsl:text>                parent.removeChild(element);
</xsl:text>
          <xsl:text>            }
</xsl:text>
          <xsl:text>        }
</xsl:text>
          <xsl:text>        for(let eltid in new_desc.required_detachables){
</xsl:text>
          <xsl:text>            if(!(eltid in old_desc.required_detachables)){
</xsl:text>
          <xsl:text>                let [element, parent] = new_desc.required_detachables[eltid];
</xsl:text>
          <xsl:text>                parent.appendChild(element);
</xsl:text>
          <xsl:text>            }
</xsl:text>
          <xsl:text>        }
</xsl:text>
          <xsl:text>    }else{
</xsl:text>
          <xsl:text>        for(let eltid in new_desc.required_detachables){
</xsl:text>
          <xsl:text>            let [element, parent] = new_desc.required_detachables[eltid];
</xsl:text>
          <xsl:text>            parent.appendChild(element);
</xsl:text>
          <xsl:text>        }
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    svg_root.setAttribute('viewBox',new_desc.bbox.join(" "));
</xsl:text>
          <xsl:text>    current_visible_page = page_name;
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>// Once connection established
</xsl:text>
          <xsl:text>ws.onopen = function (evt) {
</xsl:text>
          <xsl:text>    init_widgets();
</xsl:text>
          <xsl:text>    send_reset();
</xsl:text>
          <xsl:text>    // show main page
</xsl:text>
          <xsl:text>    prepare_svg();
</xsl:text>
          <xsl:text>    switch_page(default_page);
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>ws.onclose = function (evt) {
</xsl:text>
          <xsl:text>    // TODO : add visible notification while waiting for reload
</xsl:text>
          <xsl:text>    console.log("Connection closed. code:"+evt.code+" reason:"+evt.reason+" wasClean:"+evt.wasClean+" Reload in 10s.");
</xsl:text>
          <xsl:text>    // TODO : re-enable auto reload when not in debug
</xsl:text>
          <xsl:text>    //window.setTimeout(() =&gt; location.reload(true), 10000);
</xsl:text>
          <xsl:text>    alert("Connection closed. code:"+evt.code+" reason:"+evt.reason+" wasClean:"+evt.wasClean+".");
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>const xmlns = "http://www.w3.org/2000/svg";
</xsl:text>
          <xsl:text>var edit_callback;
</xsl:text>
          <xsl:text>const localtypes = {"PAGE_LOCAL":null, "HMI_LOCAL":null}
</xsl:text>
          <xsl:text>function edit_value(path, valuetype, callback, initial) {
</xsl:text>
          <xsl:text>    if(valuetype in localtypes){
</xsl:text>
          <xsl:text>        valuetype = (typeof initial) == "number" ? "HMI_REAL" : "HMI_STRING";
</xsl:text>
          <xsl:text>    }
</xsl:text>
          <xsl:text>    let [keypadid, xcoord, ycoord] = keypads[valuetype];
</xsl:text>
          <xsl:text>    edit_callback = callback;
</xsl:text>
          <xsl:text>    let widget = hmi_widgets[keypadid];
</xsl:text>
          <xsl:text>    widget.start_edit(path, valuetype, callback, initial);
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>var current_modal; /* TODO stack ?*/
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function show_modal() {
</xsl:text>
          <xsl:text>    let [element, parent] = detachable_elements[this.element.id];
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    tmpgrp = document.createElementNS(xmlns,"g");
</xsl:text>
          <xsl:text>    tmpgrpattr = document.createAttribute("transform");
</xsl:text>
          <xsl:text>    let [xcoord,ycoord] = this.coordinates;
</xsl:text>
          <xsl:text>    let [xdest,ydest] = page_desc[current_visible_page].bbox;
</xsl:text>
          <xsl:text>    tmpgrpattr.value = "translate("+String(xdest-xcoord)+","+String(ydest-ycoord)+")";
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    tmpgrp.setAttributeNode(tmpgrpattr);
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    tmpgrp.appendChild(element);
</xsl:text>
          <xsl:text>    parent.appendChild(tmpgrp);
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    current_modal = [this.element.id, tmpgrp];
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>function end_modal() {
</xsl:text>
          <xsl:text>    let [eltid, tmpgrp] = current_modal;
</xsl:text>
          <xsl:text>    let [element, parent] = detachable_elements[this.element.id];
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    parent.removeChild(tmpgrp);
</xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:text>    current_modal = undefined;
</xsl:text>
          <xsl:text>};
</xsl:text>
          <xsl:text>
</xsl:text>
        </script>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>
