<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:mods="http://www.loc.gov/mods/v3"
                xmlns:zs="http://www.loc.gov/zing/srw/"
                xmlns:pica="info:srw/schema/5/picaXML-v1.0">

  <xsl:output method="xml" indent="yes"/>


  <xsl:template match="/">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:variable name="sortTemp">
    <element name="typeOfResource"/>
    <element name="titleInfo"/>
    <element name="name"/>
    <element name="genre"/>
    <element name="originInfo"/>
    <element name="language"/>
    <element name="abstract"/>
    <element name="note"/>
    <element name="subject"/>
    <element name="classification"/>
    <element name="relatedItem"/>
    <element name="identifier"/>
    <element name="location"/>
    <element name="accessCondition"/>
  </xsl:variable>

  <xsl:template match="zs:searchRetrieveResponse">
    <xsl:variable name="modsDocs">
      <xsl:apply-templates select="zs:records/zs:record[zs:recordSchema='picaxml']/zs:recordData/pica:record"/>
    </xsl:variable>

    <xsl:for-each select="$modsDocs/mods:mods">
      <xsl:variable name="signatur" select="mods:location/mods:shelfLocator/text()"/>
      <xsl:if test="starts-with($signatur, 'WLMMA_CD') or starts-with($signatur, 'WLMMA_T')">
        <xsl:copy-of select="."/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="pica:record">
    <xsl:variable name="result">
      <xsl:apply-templates/>
    </xsl:variable>

    <mods:mods>
      <xsl:for-each select="$sortTemp/element">
        <xsl:variable name="elementName" select="@name"/>
        <xsl:copy-of select="$result/*[local-name()=$elementName]"/>
      </xsl:for-each>
    </mods:mods>
  </xsl:template>

  <xsl:template match="pica:datafield[@tag='021A']">
    <mods:titleInfo xlink:type="simple">
      <xsl:if test="./pica:subfield[@code='a']">
        <xsl:variable name="mainTitle" select="./pica:subfield[@code='a']"/>
        <xsl:choose>
          <xsl:when test="contains($mainTitle, '@')">
            <xsl:variable name="nonSort" select="normalize-space(substring-before($mainTitle, '@'))"/>
            <xsl:choose>
              <xsl:when test="string-length(nonSort) &lt; 9">
                <mods:nonSort>
                  <xsl:value-of select="$nonSort"/>
                </mods:nonSort>
                <mods:title>
                  <xsl:value-of select="substring-after($mainTitle, '@')"/>
                </mods:title>
              </xsl:when>
              <xsl:otherwise>
                <mods:title>
                  <xsl:value-of select="$mainTitle"/>
                </mods:title>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <mods:title>
              <xsl:value-of select="$mainTitle"/>
            </mods:title>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:if test="./pica:subfield[@code='d']">
        <mods:subTitle>
          <xsl:value-of select="./pica:subfield[@code='d']"/>
        </mods:subTitle>
      </xsl:if>
    </mods:titleInfo>
  </xsl:template>

  <!-- Ort und Verlag -->
  <xsl:template match="pica:datafield[@tag='033A']">
    <xsl:if test="count(pica:subfield[@code='p' or @code='n'])&gt;0">
      <mods:originInfo>
        <xsl:for-each select="distinct-values(pica:subfield[@code='p'])">
          <mods:place>
            <xsl:value-of select="."/>
          </mods:place>
        </xsl:for-each>
        <xsl:for-each select="distinct-values(pica:subfield[@code='n'])">
          <mods:publisher>
            <xsl:value-of select="."/>
          </mods:publisher>
        </xsl:for-each>
      </mods:originInfo>
    </xsl:if>

  </xsl:template>

  <!-- PPN -->
  <xsl:template match="pica:datafield[@tag='003@' and pica:subfield/@code='0']">
    <mods:identifier type="uri">
      <xsl:value-of select="concat('http://gso.gbv.de/DB=2.1/PPNSET?PPN=', pica:subfield[@code='0']/text())"/>
    </mods:identifier>
  </xsl:template>

  <!-- mods name -->
  <xsl:template match="pica:datafield[starts-with(@tag, '028')]">
    <xsl:variable name="picaRoles" select="./pica:subfield[@code='B']"/>

    <xsl:variable name="picaRolesString">
      <xsl:choose>
        <xsl:when test="count($picaRoles)&gt;1">
          <xsl:for-each select="picaRoles">
            <xsl:if test="position()&gt;1">
              <xsl:value-of select="','"/>
            </xsl:if>
            <xsl:value-of select="."/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$picaRoles"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="roles">
      <xsl:choose>
        <xsl:when test="string-length($picaRolesString) &gt; 0">
          <xsl:for-each select="tokenize($picaRolesString, ',')">
            <xsl:if test="position()&gt;1">
              <xsl:value-of select="','"/>
            </xsl:if>
            <xsl:variable name="role" select="lower-case(normalize-space(.))"/>
            <xsl:choose>
              <xsl:when test="string-length($role)=0"></xsl:when>
              <!--
              <xsl:when test="$role='sprechst.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='collector'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='musician'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentalist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentralist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='komp.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='bearb.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='hrsg.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='verf.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='ver.f'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='verf'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='übers.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='recording engineer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='mitarb.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='interpr.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='dir.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='singer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='producer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='red.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='writer of accompanying material'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='ed.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='prod.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='text'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='ill.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='recording enginner'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='ltg.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='gefeierter'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='vorr'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumantalist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentalmusikerin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='sängerin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instr.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='speaker'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='associated name'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='mitverf.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='verf.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='{verf.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='üers.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='conductor'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='widmungsempfänger'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='[verf.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='ver.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='komponistin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentalimusikerin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentalistin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='director'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='gsg.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='performer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='musikalischer leiterin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='textverf.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='researcher'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='vef.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='vorr.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='photogr'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentalmusikerin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='dirigentin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='photogr.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='produzentin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='hrsg.?'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='record. engineer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='mtarb'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='vocalist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentalmusiker'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='komponist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='interpret'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='intepr.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='komp.?'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='compiler'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='creator'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='verf:'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='muscian'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='sänger'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='gsg'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='verf:'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='recording rengineer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='nachr.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='berab.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='komp'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='produzent'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='indtrumentalist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='arr.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='musician]'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='musician]'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='[producer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='poducer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentelist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='sprechsst.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='ltg'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='asscociated name'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='prodcuer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='mitwirkender'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='writer of acompanying material'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='writer of accompanying material.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='verf..'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='pseud.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='diskogr.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='transcriber'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instumentalist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='sprechtst.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='fotogr.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='verfasserin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='hrrsg.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentlist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='ill'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='insrumentalist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='illustratorin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='recordind engineer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='schauspielerin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='bearb'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='rednerin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='interp.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentaliste'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='ld'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='bearb.]'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='writer of acccompanying material'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='mtarb.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='il.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='recordin engineer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='musik'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='writer of accompaying material'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='recording enginneer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='sammler'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='leitung'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='rezitator'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='hrsg'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='herausgeberin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='gastgeberin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='erzähler'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='verfasser'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='recording enginer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='sprechst.]'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='bass'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='verr.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='musican'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='dirignetin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='dirigent'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='interpr.]'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='transl.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='lll.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrummentalist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='sprecher'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='gef. person'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumenalmusikerin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='zusammenstellender'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='dir'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='isntrumentalist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='engineer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentalmusikern'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='intperpr.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='writer of accomanying material'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='recording engineers'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='singer. übers.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='sprechstimme'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='produced'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='writerof accompanying material'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='harmonica'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='regisseur'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentalmusikter'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='hrsg..'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='zensor'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='assistant'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='direcor'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='übers.-'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='sonstige person'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='familie und körperschaft'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='regie'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='srechst.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='bearb. dir.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='notes'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='vrf.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='übesr.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='nachw.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='mitarb'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='recroding engineer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='wirkl. name'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='arrangeurin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='regisseurin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='illl'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='hrg.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='übbrs.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='producing engineer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='über.s'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='samm.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='vorr.]'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='übers'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='bers.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instruementalmusikerin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='moderatorin'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='komponit'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='reasearcher'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='intper.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='recorded engineer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='hrsg. producer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentalist]'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='sprecht.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='interpr'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='writer off accompanying material'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='accociated name'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='muiscian'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='produktion'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='muisician'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='recording eingineer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='intrumentalist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='insturmentalist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumentlaist'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='writer of accomapanying material'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumental'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='recordimg engineer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='redactor'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='vioarǎ'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='maestru de sunet'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='redactor'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='asociated name'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='mutmaßl. komp.'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='autor'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='writer of acommpanying material'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='sprechst..'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='musisican'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='musiciann'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='choreographer'">
                <xsl:value-of select="."/>
              </xsl:when>
              <xsl:when test="$role='instrumenalist'">
                <xsl:value-of select="."/>
              </xsl:when>-->
              <xsl:otherwise>
                <xsl:message>Unknown person type found:
                  <xsl:value-of select="$role"/>
                </xsl:message>
                <xsl:value-of select="'ctb'"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'ctb'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="picaNode" select="."/>
    <xsl:for-each select="distinct-values(tokenize($roles, ','))">
      <mods:name type="personal">
        <mods:role>
          <mods:roleTerm authority="marcrelator" type="code">
            <xsl:value-of select="."/>
          </mods:roleTerm>
        </mods:role>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='0'])">
          <mods:nameIdentifier>
            <xsl:attribute name="type">
              <xsl:value-of select="substring-before(., '/')"/>
            </xsl:attribute>
            <xsl:value-of select="substring-after(., '/')"/>
          </mods:nameIdentifier>
        </xsl:for-each>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='a'])">
          <mods:namePart type="family">
            <xsl:value-of select="."/>
          </mods:namePart>
        </xsl:for-each>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='d'])">
          <mods:namePart type="given">
            <xsl:value-of select="."/>
          </mods:namePart>
        </xsl:for-each>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='P'])">
          <mods:namePart>
            <xsl:value-of select="."/>
          </mods:namePart>
        </xsl:for-each>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='n'])">
          <mods:namePart type="termsOfAddress">
            <xsl:value-of select="."/>
          </mods:namePart>
        </xsl:for-each>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='l'])">
          <mods:namePart type="termsOfAddress">
            <xsl:value-of select="."/>
          </mods:namePart>
        </xsl:for-each>
        <xsl:for-each select="distinct-values($picaNode/pica:subfield[@code='p'])">
          <mods:affiliation>
            <xsl:value-of select="."/>
          </mods:affiliation>
        </xsl:for-each>
      </mods:name>
    </xsl:for-each>
  </xsl:template>

  <!-- shelfLocator -->
  <xsl:template match="pica:datafield[@tag='209A' and pica:subfield/@code='a' and @occurrence='01']">
    <mods:location>
      <mods:shelfLocator>
        <xsl:value-of select="translate(pica:subfield[@code='a'], ' ','_')"/>
      </mods:shelfLocator>
    </mods:location>
  </xsl:template>


</xsl:stylesheet>
