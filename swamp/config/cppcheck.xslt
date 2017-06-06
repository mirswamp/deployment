<?xml version="1.0"?>

<!--
    This file is subject to the terms and conditions defined in
    'LICENSE.txt', which is part of this source code distribution.

    Copyright 2012-2017 Software Assurance Marketplace
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:output method="html" encoding="UTF-8" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN" 
        doctype-system="http://www.w3.org/TR/html4/loose.dtd" indent="yes"/>
<xsl:template name="priorityDiv">
<xsl:if test="@severity = 'error'">p1</xsl:if>
<xsl:if test="@severity = 'warning'">p2</xsl:if>
<xsl:if test="@severity = 'style'">p3</xsl:if>
<xsl:if test="@severity = 'performance'">p4</xsl:if>
<xsl:if test="@severity = 'portability'">p5</xsl:if>
<xsl:if test="@severity = 'information'">p6</xsl:if>
</xsl:template>
<xsl:template match="/">
<html>
<head>
    <title>cppcheck <xsl:value-of select="//cppcheck/@version"/> Report</title>
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
    <H2>cppcheck <xsl:value-of select="//cppcheck/@version"/> Report</H2>
    <hr/>
    <h3>Summary</h3>
    <table border="0" class="summary">
      <tr>
        <th >Total</th>
        <th>error</th>
        <th>warning</th>
        <th>style</th>
        <th>performance</th>
        <th>portability</th>
        <th>information</th>
      </tr>
      <tr>
        <td><xsl:value-of select="count(//error)"/></td>
        <td><div class="p1"><xsl:value-of select="count(//error[@severity='error'])"/></div></td>
        <td><div class="p2"><xsl:value-of select="count(//error[@severity='warning'])"/></div></td>
        <td><div class="p3"><xsl:value-of select="count(//error[@severity='style'])"/></div></td>
        <td><div class="p4"><xsl:value-of select="count(//error[@severity='performance'])"/></div></td>
        <td><div class="p5"><xsl:value-of select="count(//error[@severity='portability'])"/></div></td>
        <td><div class="p6"><xsl:value-of select="count(//error[@severity='information'])"/></div></td>
      </tr>
      </table>
    <xsl:if test="count(//error) > 0">
    <table border="0" width="100%" class="sortable"><xsl:attribute name="id">sortable_id_<xsl:value-of select="position()"/></xsl:attribute>
            <tr>
				<th>Severity</th>
				<th>File</th>
                <th>Line</th>
                <th align="left">Message</th>
            </tr>
    <br/>
    <xsl:for-each select="results//error">
        <!--
        <xsl:sort data-type="text" order="ascending" select="@severity"/>
        -->
        <tr>
        <td style="padding: 3px" align="left"><div><xsl:attribute name="class"><xsl:call-template name="priorityDiv"/></xsl:attribute><xsl:value-of disable-output-escaping="yes" select="@severity"/></div></td>
        <td style="padding: 3px" align="left"><xsl:value-of disable-output-escaping="yes" select="location/@file"/></td>
        <td style="padding: 3px" align="left"><xsl:value-of disable-output-escaping="yes" select="location/@line"/></td>
        <td style="padding: 3px" align="left"><xsl:value-of disable-output-escaping="yes" select="@msg"/></td>
        </tr>
        <!--
        <li><xsl:value-of select="location/@file"/>(<xsl:value-of select="location/@line"/>): (<xsl:value-of select="@severity"/>) <xsl:value-of select="@msg"/> </li>
        -->
    </xsl:for-each>
    </table>
    </xsl:if>
    <xsl:if test="count(//error) = 0">
    <h3>No errors found</h3>
    </xsl:if>
</body>
</html>
  </xsl:template>
</xsl:stylesheet>
