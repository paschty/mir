<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:mods="http://www.loc.gov/mods/v3" exclude-result-prefixes="i18n mods">
  <xsl:import href="xslImport:modsmeta:metadata/mir-abstract.xsl" />
  <xsl:template match="/">
    <xsl:variable name="mods" select="mycoreobject/metadata/def.modsContainer/modsContainer/mods:mods" />
    <div id="mir-abstract">
      <p data-toggle="tooltip" title="Publication date">
        <xsl:variable name="dateIssued">
          <xsl:apply-templates mode="mods.datePublished" select="$mods" />
        </xsl:variable>
        <time itemprop="datePublished" datetime="{$dateIssued}">
          <xsl:variable name="format">
            <xsl:choose>
              <xsl:when test="string-length(normalize-space($dateIssued))=4">
                <xsl:value-of select="i18n:translate('metaData.dateYear')" />
              </xsl:when>
              <xsl:when test="string-length(normalize-space($dateIssued))=7">
                <xsl:value-of select="i18n:translate('metaData.dateYearMonth')" />
              </xsl:when>
              <xsl:when test="string-length(normalize-space($dateIssued))=10">
                <xsl:value-of select="i18n:translate('metaData.dateYearMonthDay')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="i18n:translate('metaData.dateTime')" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <xsl:call-template name="formatISODate">
            <xsl:with-param name="date" select="$dateIssued" />
            <xsl:with-param name="format" select="$format" />
          </xsl:call-template>
        </time>
        <!-- TODO: Update badges -->
        <span class="pull-right">
          <xsl:call-template name="categorySearchLink">
            <xsl:with-param name="class" select="'label label-default'" />
            <xsl:with-param name="node" select="($mods/mods:genre[@type='kindof']|$mods/mods:genre[@type='intern'])[1]" />
          </xsl:call-template>
          <xsl:variable name="accessCondition" select="normalize-space($mods/mods:accessCondition[@type='use and reproduction'])" />
          <xsl:if test="$accessCondition">
            <xsl:variable name="linkText">
              <xsl:choose>
                <xsl:when test="contains($accessCondition, 'cc_by')">
                  <xsl:variable name="licenseString" select="substring-after(normalize-space(.),'cc_')" />
                  <img src="http://i.creativecommons.org/l/{$licenseString}/4.0/88x31.png" />
                </xsl:when>
                <xsl:when test="contains($accessCondition, 'rights_reserved')">
                  <xsl:value-of select="i18n:translate('component.mods.metaData.dictionary.rightsReserved')" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="." />
                </xsl:otherwise>
              </xsl:choose>
            </xsl:variable>
            <xsl:call-template name="searchLink">
              <xsl:with-param name="class" select="'label label-success'" />
              <xsl:with-param name="linkText" select="$linkText" />
              <xsl:with-param name="query" select="concat('%2BallMeta%3A&quot;',$accessCondition,'&quot;')" />
            </xsl:call-template>
          </xsl:if>
        </span>
      </p>
      <h1 itemprop="name">
        <xsl:apply-templates mode="mods.title" select="$mods" />
      </h1>
      <p id="authors_short">
        <xsl:for-each select="$mods/mods:name[mods:role/mods:roleTerm/text()='aut']">
          <xsl:if test="position()!=1">
            <xsl:value-of select="'; '" />
          </xsl:if>
          <xsl:apply-templates select="." mode="authors_short" />
        </xsl:for-each>
      </p>
      <p>
        <span itemprop="description">
          <xsl:value-of select="$mods/mods:abstract" />
        </span>
      </p>
    </div>
    <xsl:apply-imports />
  </xsl:template>

  <xsl:template match="mods:name" mode="authors_short">
    <!-- TODO: Link to search? -->
    <xsl:variable name="query">
      <xsl:choose>
        <xsl:when test="starts-with(@valueURI, 'http://d-nb.info/gnd/')">
          <xsl:variable name="gnd" select="substring-after(@valueURI, 'http://d-nb.info/gnd/')" />
          <xsl:value-of select="concat($ServletsBaseURL,'solr/mods_gnd?q=',$gnd)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($ServletsBaseURL,'solr/select?q=')" />
          <xsl:value-of select="concat('+mods.author:&quot;',mods:displayForm,'&quot;')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a itemprop="creator" href="{$query}">
      <span itemscope="itemscope" itemtype="http://schema.org/Person">
        <span itemprop="name">
          <xsl:value-of select="mods:displayForm" />
        </span>
      </span>
    </a>
  </xsl:template>

</xsl:stylesheet>