<?xml version="1.0" encoding="utf-8"?>
  <!-- ============================================== -->
  <!-- $Revision$ $Date$ -->
  <!-- ============================================== -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:basket="xalan://org.mycore.frontend.basket.MCRBasketManager" xmlns:mcr="http://www.mycore.org/" xmlns:i18n="xalan://org.mycore.services.i18n.MCRTranslation"
  xmlns:actionmapping="xalan://org.mycore.wfc.actionmapping.MCRURLRetriever" xmlns:mcrver="xalan://org.mycore.common.MCRCoreVersion"
  xmlns:mcrxsl="xalan://org.mycore.common.xml.MCRXMLFunctions" exclude-result-prefixes="xlink basket actionmapping mcr mcrver mcrxsl i18n">
  <xsl:output method="html" doctype-system="about:legacy-compat" indent="yes" omit-xml-declaration="yes" media-type="text/html"
    version="5" />
  <xsl:strip-space elements="*" />
  <xsl:include href="resource:xsl/mir-flatmir-layout-utils.xsl"/>
  <!-- Various versions -->
  <xsl:variable name="bootstrap.version" select="'3.0.3'" />
  <xsl:variable name="bootswatch.version" select="$bootstrap.version" />
  <xsl:variable name="fontawesome.version" select="'4.0.3'" />
  <xsl:variable name="jquery.version" select="'1.10.2'" />
  <xsl:variable name="jquery.migrate.version" select="'1.2.1'" />
  <!-- End of various versions -->
  <xsl:variable name="PageTitle" select="/*/@title" />
  <xsl:template match="/site">
    <html lang="{$CurrentLang}" class="no-js">
      <head>
        <meta charset="utf-8" />
        <title>
          <xsl:value-of select="$PageTitle" />
        </title>
        <xsl:comment>
          Mobile viewport optimisation
        </xsl:comment>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <link href="{$WebApplicationBaseURL}mir-flatmir-layout/css/layout.css" rel="stylesheet" />
        <script type="text/javascript" src="//code.jquery.com/jquery-{$jquery.version}.min.js"></script>
        <script type="text/javascript" src="//code.jquery.com/jquery-migrate-{$jquery.migrate.version}.min.js"></script>
      </head>

      <body>

        <header>
            <xsl:call-template name="mir.navigation" />
        </header>

        <!-- show only on startpage -->
        <xsl:if test="//div/@class='container jumbotwo'">
          <div class="jumbotron">
             <div class="container">
               <h1>Mit MIR wird alles gut!</h1>
               <h2>your repository - just out of the box</h2>
             </div>
          </div>
        </xsl:if>

        <div class="container" id="page">
          <div class="row">
            <div class="col-md-12" id="main_content">
              <xsl:call-template name="print.writeProtectionMessage" />
              <xsl:choose>
                <xsl:when test="$readAccess='true'">
                  <xsl:copy-of select="*" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="printNotLoggedIn" />
                </xsl:otherwise>
              </xsl:choose>
            </div>
          </div>
        </div>

        <footer class="panel-footer flatmir-footer" role="contentinfo">
          <div class="container">
            <div class="row">
              <div class="col-md-4">
                <h4>Über uns</h4>
                  <p>
                      MIR ist die Vorlage für klassiche Publikations- bzw.
                      Dokumentenserver. Es basiert auf dem Repository-Framework
                      MyCoRe und dem Metadata Object Description Schema (MODS).
                      <span class="read_more">
                        <a href="#">Mehr erfahren ...</a>
                      </span>
                  </p>
                </div>
                <div class="col-md-2">
                  <h4>Navigation</h4>
                  <ul class="internal_links">
                    <xsl:call-template name="mir.legacy-navigation">
                      <xsl:with-param name="rootNode" select="$loaded_navigation_xml/navi-below" />
                      <xsl:with-param name="topNav" select="true()" />
                    </xsl:call-template>
                  </ul>
                </div>
                <div class="col-md-2">
                  <h4>Netzwerke</h4>
                  <ul class="social_links">
                      <li><a href="#"><button type="button" class="social_icons social_icon_fb"></button>Facebook</a></li>
                      <li><a href="#"><button type="button" class="social_icons social_icon_tw"></button>Twitter</a></li>
                      <li><a href="#"><button type="button" class="social_icons social_icon_gg"></button>Google+</a></li>
                  </ul>
                </div>
                <div class="col-md-2">
                  <h4>Lorem ipsum</h4>
                  <ul class="internal_links">
                    <li><a href="#">Stet</a></li>
                    <li><a href="#">Lorem</a></li>
                    <li><a href="#">Accusam</a></li>
                  </ul>
                </div>
                <div class="col-md-2">
                  <h4>Layout based on</h4>
                  <ul class="internal_links">
                    <li><a href="http://getbootstrap.com/">Bootstrap</a></li>
                    <li><a href="#">Lorem</a></li>
                    <li><a href="#">Accusam</a></li>
                  </ul>
                </div>
            </div>
            <div class="row">
              <div id="powered_by"  class="pull-right"><a href="http://www.mycore.de"><img src="{$WebApplicationBaseURL}mir-flatmir-layout/images/mycore_logo_small_invert.png" /></a></div>
              <div id="mcr_version"><xsl:value-of select="concat('MyCoRe ',mcrver:getCompleteVersion())" /></div>
            </div>
          </div>
        </footer>

        <script type="text/javascript">
          <!-- Bootstrap & Query-Ui button conflict workaround  -->
          if (jQuery.fn.button){jQuery.fn.btn = jQuery.fn.button.noConflict();}
        </script>
        <script type="text/javascript" src="//netdna.bootstrapcdn.com/bootstrap/{$bootstrap.version}/js/bootstrap.min.js"></script>
<!--         <script src="{$WebApplicationBaseURL}mir-flatmir-layout/datepicker/js/bootstrap-datepicker.js"></script> -->
        <script>
          $( document ).ready(function() {
            $('.overtext').tooltip();
    //        $('#start_date').datepicker();
    //        $('#end_date').datepicker();
          });
        </script>
      </body>
    </html>
  </xsl:template>
</xsl:stylesheet>