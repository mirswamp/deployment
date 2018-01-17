<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

<!--
    This file is subject to the terms and conditions defined in
    'LICENSE.txt', which is part of this source code distribution.

    Copyright 2012-2018 Software Assurance Marketplace
-->

<xsl:template match="/">
    <h3><a id="nobuild"><pre><xsl:value-of select="/source-compiles/package-short-name"/>-<xsl:value-of select="/source-compiles/package-version"/> no-build errors</pre></a></h3>
    <xsl:if test="count(//source-file) > 0">
    <table border="0" width="100%" class="sortable"><xsl:attribute name="id">sortable_id_<xsl:value-of select="position()"/></xsl:attribute>
            <tr>
				<th align="left"><pre>File</pre></th>
                <th align="left"><pre>Message</pre></th>
            </tr>
    <br/>
    <xsl:for-each select="//source-compile">
        <tr>
        <td style="padding: 3px" align="left"><pre><xsl:value-of select="//source-file"/></pre></td>
        <td style="padding: 3px" align="left"><pre><xsl:value-of select="//output"/></pre></td>
        </tr>
    </xsl:for-each>
    </table>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>
