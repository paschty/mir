<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xed="http://www.mycore.de/xeditor"
  xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation" xmlns:mir="http://www.mycore.de/mir"
  exclude-result-prefixes="xsl mir">

  <xsl:include href="copynodes.xsl" />

  <xsl:template match="mir:textfield">
    <div class="form-group">
      <label class="col-md-3 control-label">
        <xed:output i18n="{@label}" />
      </label>
      <div class="col-md-6">
        <xed:bind xpath="{@xpath}">
          <input type="text">
            <xsl:attribute name="class">form-control {$xed-validation-marker}</xsl:attribute>
            <xsl:copy-of select="@placeholder" />
          </input>
        </xed:bind>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="mir:textarea">
    <div class="form-group">
      <label class="col-md-3 control-label">
        <xed:output i18n="{@label}" />
      </label>
      <div class="col-md-6">
        <xed:bind xpath="{@xpath}">
          <textarea>
            <xsl:attribute name="class">form-control {$xed-validation-marker}</xsl:attribute>
            <xsl:copy-of select="@rows" />
            <xsl:copy-of select="@placeholder" />
          </textarea>
        </xed:bind>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="mir:role.repeated">
    <div class="form-group">
      <label class="col-md-3 control-label">
        <xed:output i18n="{@label}" />
      </label>
      <xed:repeat xpath="mods:name[@type='personal']" min="1" max="100">
        <div class="col-md-6">
          <div class="controls">
            <xed:bind xpath="mods:role/mods:roleTerm[@authority='marcrelator'][@type='code']" default="{@role}" />
            <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="person.fields" />
          </div>
        </div>
        <xsl:call-template name="mir-pmud" />
      </xed:repeat>
    </div>
  </xsl:template>

  <xsl:template match="mir:person.repeated">
    <xed:repeat xpath="mods:name[@type='personal']" min="1" max="100">
      <div class="form-group">
        <div class="col-md-3" style="text-align:right; font-weight:bold;">
          <xed:bind xpath="mods:role/mods:roleTerm[@authority='marcrelator'][@type='code']">
            <select class="form-control form-control-inline">
              <xsl:apply-templates select="*" />
            </select>
          </xed:bind>
        </div>
        <div class="col-md-6">
          <xed:include uri="xslStyle:editor/mir2xeditor:webapp:editor/editor-includes.xed" ref="person.fields" />
        </div>
        <xsl:call-template name="mir-pmud" />
      </div>
    </xed:repeat>
  </xsl:template>

  <xsl:template match="mir:pmud">
    <xsl:call-template name="mir-pmud" />
  </xsl:template>

  <xsl:template name="mir-pmud">
    <div class="form-pmud">
      <span>
        <xed:controls>insert</xed:controls>
      </span>
      <span>
        <xed:controls>remove</xed:controls>
      </span>
      <span>
        <xed:controls>up</xed:controls>
      </span>
      <span>
        <xed:controls>down</xed:controls>
      </span>
    </div>
  </xsl:template>

</xsl:stylesheet>