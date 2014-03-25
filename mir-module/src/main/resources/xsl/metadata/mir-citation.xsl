<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:mcr="xalan://org.mycore.common.xml.MCRXMLFunctions"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mods="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink"
  exclude-result-prefixes="i18n mcr mods xlink">
  <xsl:import href="xslImport:modsmeta:metadata/mir-citation.xsl" />
  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <div id="mir-citation">
      <p>
        <xsl:apply-templates select="$mods" mode="authorList" />
        <xsl:apply-templates select="$mods" mode="year" />
        <xsl:apply-templates mode="mods.title" select="$mods" />
        <xsl:value-of select="'.'" />
      </p>
      <!-- 
      <p>
        <small>
          Further citation formats:
          <a href="http://crosscite.org/citeproc/">DOI Citation Formatter</a>
          .
        </small>
      </p>
       -->
    </div>
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template match="mods:mods" mode="authorList">
    <xsl:choose>
      <xsl:when test="mods:name[mods:role/mods:roleTerm/text()='aut']">
        <xsl:for-each select="mods:name[mods:role/mods:roleTerm/text()='aut']">
          <xsl:choose>
            <xsl:when test="position()=1">
              <strong>
                <xsl:value-of select="mods:displayForm" />
              </strong>
            </xsl:when>
            <xsl:when test="position()=2">
              <em>et al</em>
            </xsl:when>
            <xsl:otherwise>
              <!-- other authors -->
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'N.N.'" />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:value-of select="' '" />
  </xsl:template>

  <xsl:template match="mods:mods" mode="year">
    <xsl:variable name="dateIssued">
      <xsl:apply-templates mode="mods.datePublished" select="." />
    </xsl:variable>
    <xsl:if test="string-length($dateIssued) &gt; 0">
      <xsl:value-of select="'('" />
      <xsl:call-template name="formatISODate">
        <xsl:with-param name="date" select="$dateIssued" />
        <xsl:with-param name="format" select="i18n:translate('metaData.dateYear')" />
      </xsl:call-template>
      <xsl:value-of select="'). '" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>