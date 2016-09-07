<?xml version="1.0"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" 
        doctype-system="http://www.w3.org/TR/html4/loose.dtd" indent="yes"/>
<xsl:template name="priorityDiv">
<xsl:if test="string[2] = 'Unix API'">p1</xsl:if>
<xsl:if test="string[2] = 'API'">p2</xsl:if>
<xsl:if test="string[2] = 'Dead store'">p3</xsl:if>
<xsl:if test="string[2] = 'Logic error'">p4</xsl:if>
<xsl:if test="string[2] = 'Memory Error'">p5</xsl:if>
<xsl:if test="string[2] = 'Security'">p6</xsl:if>
</xsl:template>
<xsl:template match="/">
<html>
<head>
    <title>CLANG <xsl:value-of select="plist/dict/key/string"/> Report</title>
	<script type="text/javascript" src="sorttable.js"></script>
    <style type="text/css">
        body { margin-left: 2%; margin-right: 2%; font-family:helvetica neue,helvetica,arial; color:#000000; }
        table.sortable tr th { font-weight: bold; text-align:left; background:#a6caf0; }
        table.sortable tr td { background:#eeeee0; }
        table.classcount tr th { font-weight: bold; text-align:left; background:#a6caf0; }
        table.classcount tr td { background:#eeeee0; }
        table.summary tr th { font-weight: bold; text-align:left; background:#a6caf0; }
        table.summary tr td { background:#eeeee0; text-align:center;}
        .p1 { background:#FF9999; }
        .p2 { background:#FFCC66; }
        .p3 { background:#FFFF99; }
        .p6 { background:#99FF99; }
        .p5 { background:#9999FF; }
        .p4 { background:#99F9FF; }
		div.top{text-align:right;margin:1em 0;padding:0}
		div.top div{display:inline;white-space:nowrap}
		div.top div.left{float:left}
		#content>div.top{display:table;width:100%}
		#content>div.top div{display:table-cell}
		#content>div.top div.left{float:none;text-align:left}
		#content>div.top div.right{text-align:right}
    </style>
</head>
<body>
    <H2><xsl:value-of select="/plist/dict/string"/> Report</H2>
    <hr/>
    <h3>Summary</h3>
    <table border="0" class="summary">
      <tr>
        <th>Total</th>
        <th>API</th>
        <th>Dead store</th>
        <th>Logic error</th>
        <th>Memory Error</th>
        <th>Security</th>
        <th>Unix API</th>
      </tr>
      <tr>
        <td><xsl:value-of select="count(//plist/dict/array/dict/string[2])"/></td>
        <td><div class="p2"><xsl:value-of select="count(/plist/dict/array/dict[string[2]='API'] )"/></div></td>
        <td><div class="p3"><xsl:value-of select="count(/plist/dict/array/dict[string[2]='Dead store'] )"/></div></td>
        <td><div class="p4"><xsl:value-of select="count(/plist/dict/array/dict[string[2]='Logic error'] )"/></div></td>
        <td><div class="p5"><xsl:value-of select="count(/plist/dict/array/dict[string[2]='Memory Error'] )"/></div></td>
        <td><div class="p6"><xsl:value-of select="count(/plist/dict/array/dict[string[2]='Security'] )"/></div></td>
        <td><div class="p1"><xsl:value-of select="count(/plist/dict/array/dict[string[2]='Unix API'] )"/></div></td>
      </tr>
      </table>
    <xsl:if test="count(//plist/dict/array/dict/string[2]) > 0">
    <table border="0" width="100%" class="sortable"><xsl:attribute name="id">sortable_id_<xsl:value-of select="position()"/></xsl:attribute>
            <tr>
				<th>Category</th>
                <th>Context</th>
				<th>File</th>
                <th>Line</th>
                <th align="left">Message</th>
            </tr>
    <br/>
    <xsl:for-each select="plist/dict/array/dict">
        <xsl:sort data-type="text" order="ascending" select="string[2]"/>
        <tr>
        <td style="padding: 3px" align="left"><div><xsl:attribute name="class"><xsl:call-template name="priorityDiv"/></xsl:attribute><xsl:value-of disable-output-escaping="yes" select="string[2]"/></div></td>
        <td style="padding: 3px" align="left"><xsl:value-of disable-output-escaping="yes" select="string[3]"/></td>
        <td style="padding: 3px" align="left"><xsl:value-of disable-output-escaping="yes" select="/plist/dict/array/string"/></td>
        <td style="padding: 3px" align="left"><xsl:value-of disable-output-escaping="yes" select="dict/integer[1]"/></td>
        <td style="padding: 3px" align="left"><xsl:value-of disable-output-escaping="yes" select="string[1]"/></td>
        </tr>
        <!--
        <li><xsl:value-of select="location/@file"/>(<xsl:value-of select="location/@line"/>): (<xsl:value-of select="@severity"/>) <xsl:value-of select="@msg"/> </li>
        -->
    </xsl:for-each>
    </table>
    </xsl:if>
    <xsl:if test="count(//plist/dict/array/dict/string[2]) = 0">
    <h3>No bugs found.</h3>
    </xsl:if>
</body>
</html>
  </xsl:template>
</xsl:stylesheet>
