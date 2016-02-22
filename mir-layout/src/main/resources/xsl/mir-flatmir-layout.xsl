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
  <xsl:param name="MIR.DefaultLayout.CSS" select="'flatly.min'" />
  <xsl:param name="MIR.CustomLayout.CSS" select="''" />
  <xsl:param name="MIR.CustomLayout.JS" select="''" />
  <xsl:param name="MIR.Layout.Theme" select="'flatmir'" />

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
        <link href="{$WebApplicationBaseURL}assets/font-awesome/css/font-awesome.min.css" rel="stylesheet" />
        <script type="text/javascript" src="{$WebApplicationBaseURL}mir-layout/assets/jquery/jquery.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}mir-layout/assets/jquery/plugins/jquery-migrate/jquery-migrate.min.js"></script>
        <xsl:copy-of select="head/*" />
        <link href="{$WebApplicationBaseURL}mir-layout/css/{$MIR.Layout.Theme}/{$MIR.DefaultLayout.CSS}.css" rel="stylesheet" />
        <xsl:if test="string-length($MIR.CustomLayout.CSS) &gt; 0">
          <link href="{$WebApplicationBaseURL}css/{$MIR.CustomLayout.CSS}" rel="stylesheet" />
        </xsl:if>
        <xsl:if test="string-length($MIR.CustomLayout.JS) &gt; 0">
          <script type="text/javascript" src="{$WebApplicationBaseURL}js/{$MIR.CustomLayout.JS}"></script>
        </xsl:if>
        <xsl:call-template name="mir.prop4js" />
      </head>

      <body>

        <header>
            <xsl:call-template name="mir.navigation" />
        </header>

        <!-- show only on startpage -->
        <xsl:if test="//div/@class='jumbotwo'">
          <div class="jumbotron">
             <div class="container">
               <h1>Mit MIR wird alles gut!</h1>
               <h2>your repository - just out of the box</h2>
             </div>
          </div>
        </xsl:if>

        <div class="container" id="page">
          <div id="main_content">
            <xsl:call-template name="print.writeProtectionMessage" />
            <xsl:choose>
              <xsl:when test="$readAccess='true'">
                <xsl:if test="breadcrumb/ul[@class='breadcrumb']">
                  <div class="row detail_row bread_plus">
                    <div class="col-xs-12">
                      <ul itemprop="breadcrumb" class="breadcrumb">
                        <li>
                          <a class="navtrail" href="{$WebApplicationBaseURL}"><xsl:value-of select="i18n:translate('mir.breadcrumb.home')" /></a>
                        </li>
                        <xsl:copy-of select="breadcrumb/ul[@class='breadcrumb']/*" />
                      </ul>
                    </div>
                  </div>
                </xsl:if>
                <xsl:copy-of select="*[not(name()='head')][not(name()='breadcrumb')] " />
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="printNotLoggedIn" />
              </xsl:otherwise>
            </xsl:choose>
          </div>
        </div>

        <footer class="panel-footer flatmir-footer" role="contentinfo">
          <div class="container">
            <div class="row">
              <div class="col-xs-12 col-sm-6 col-md-4">
                <h4>Über uns</h4>
                  <p>
                      MIR ein klassicher institutioneller Publikations- bzw.
                      Dokumentenserver. Es basiert auf dem Repository-Framework
                      MyCoRe und dem Metadata Object Description Schema (MODS).
                      <span class="read_more">
                        <a href="http://mycore.de/generated/mir/">Mehr erfahren ...</a>
                      </span>
                  </p>
                </div>
                <div class="col-xs-6 col-sm-3 col-md-2">
                  <h4>Navigation</h4>
                  <ul class="internal_links">
                    <xsl:apply-templates select="$loaded_navigation_xml/menu[@id='brand']/*" />
                  </ul>
                </div>
                <div class="col-xs-6 col-sm-3 col-md-2">
                  <h4>Netzwerke</h4>
                  <ul class="social_links">
                      <li><a href="#"><button type="button" class="social_icons social_icon_fb"></button>Facebook</a></li>
                      <li><a href="#"><button type="button" class="social_icons social_icon_tw"></button>Twitter</a></li>
                      <li><a href="#"><button type="button" class="social_icons social_icon_gg"></button>Google+</a></li>
                  </ul>
                </div>
                <div class="col-xs-6 col-sm-3 col-md-2">
                  <h4>Layout based on</h4>
                  <ul class="internal_links">
                    <li><a href="{$WebApplicationBaseURL}mir-layout/template/flatmir.xml">flatmir</a></li>
                    <li><a href="http://getbootstrap.com/">Bootstrap</a></li>
                    <li><a href="http://bootswatch.com/">Bootswatch</a></li>
                  </ul>
                </div>
            </div>
          </div>
        </footer>


        <xsl:variable name="mcr_version" select="concat('MyCoRe ',mcrver:getCompleteVersion())" />
        <div id="powered_by">
          <a href="http://www.mycore.de">
            <img src="{$WebApplicationBaseURL}mir-layout/images/mycore_logo_small_invert.png" title="{$mcr_version}" alt="powered by MyCoRe" />
          </a>
        </div>

        <script type="text/javascript">
          <!-- Bootstrap & Query-Ui button conflict workaround  -->
          if (jQuery.fn.button){jQuery.fn.btn = jQuery.fn.button.noConflict();}
        </script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}assets/bootstrap/js/bootstrap.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}assets/jquery/plugins/jquery-confirm/jquery.confirm.min.js"></script>
        <script type="text/javascript" src="{$WebApplicationBaseURL}js/mir/base.js"></script>
        <script>
          $( document ).ready(function() {
            $('.overtext').tooltip();
            $.confirm.options = {
              title: "<xsl:value-of select="i18n:translate('mir.confirm.title')" />",
              confirmButton: "<xsl:value-of select="i18n:translate('mir.confirm.confirmButton')" />",
              cancelButton: "<xsl:value-of select="i18n:translate('mir.confirm.cancelButton')" />",
              post: false,
              confirmButtonClass: "btn-danger",
              cancelButtonClass: "btn-default",
              dialogClass: "modal-dialog modal-lg" // Bootstrap classes for large modal
            }
          });
        </script>
        <!-- alco add placeholder for older browser -->
        <script src="{$WebApplicationBaseURL}assets/jquery/plugins/jquery-placeholder/jquery.placeholder.min.js"></script>
        <script>
          jQuery("input[placeholder]").placeholder();
          jQuery("textarea[placeholder]").placeholder();
        </script>
      </body>
    </html>
  </xsl:template>
  <xsl:template match="/*[not(local-name()='site')]">
    <xsl:message terminate="yes">This is not a site document, fix your properties.</xsl:message>
  </xsl:template>
</xsl:stylesheet>