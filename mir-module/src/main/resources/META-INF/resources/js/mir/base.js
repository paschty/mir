(function($) {
  $﻿(document).ready(function() {
    $('div.tagline h1').each(function() {
      var h = $(this).html();
      var i = h.indexOf(' ');
      if (i == -1) {
        return;
      }
      $(this).html(h.substring(0, i) + '<br/>' + h.substring(i, h.length));
    });
    var languageList = jQuery('#topnav .languageList');
    jQuery('#topnav .languageSelect').click(function() {
      languageList.toggleClass('hide');
    });
    // editor fix (to many tables)
    $('table.editorPanel td:has(table)').css('padding', '0');
  });
  $﻿(document).ready(function() {
    $('#confirm_deletion').click(function(d) {
      d.preventDefault();
      jConfirm('Wollen Sie dieses Dokument wirklich löschen?', 'Löschen bestätigen', function(r) {
        if (r)
          location.href = $('#confirm_deletion').attr('href');
      });
    });
  });
  $(document).ready(function() {
    // activate empty nav-bar search
    $('.navbar-search').find(':input[value=""]').attr('disabled', false);
  });
  window.fireMirSSQuery = function base_fireMirSSQuery(form) {
    $(form).find(':input[value=""]').attr('disabled', true);
    return true;
  };
  $(document).tooltip({
    selector : "[data-toggle=tooltip]",
    container : "body"
  });
  // Search
  $(document).ready(function() {
    var searchContainerSelector = "#navSearchContainer";
    var searchInputContainerSelector = "#searchInputBox";
    var searchInputSelector = "#searchInput";
    if ($(searchContainerSelector).length < 1) {
      return;
    }
    $(searchContainerSelector + " a").click(function(e){
      e.preventDefault();
      $(searchContainerSelector).click();
      return false;
    });
    $(searchContainerSelector).click(function(e) {
      if ($(searchContainerSelector).hasClass("opened")) {
        showSearchResult();
      } else {
        $(searchInputContainerSelector).stop(true, true);
        $(searchInputContainerSelector).animate({
          width : "222px"
        }, 200, function() {
          $(searchContainerSelector).addClass("opened");
          $(searchInputSelector).focus();
        });
      }
      e.stopPropagation();
      return false;
    });
    $(searchInputSelector).click(function(e) {
      e.stopPropagation();
      return false;
    });
    $(searchInputSelector).keypress(function(e) {
      var keyCode = e.keyCode || e.which;
      if (keyCode == 13) {
        showSearchResult();
      }
    });
    $(document).click(function(e) {
      closeSearchBox();
    });
    function showSearchResult() {
      closeSearchBox();
      var searchText = getSearchText();
      var url = $(searchInputSelector).data("url");
      if (searchText) {
        window.top.location = url.replace("{0}", encodeURIComponent(searchText));
      }
    }
    function getSearchText() {
      return $.trim($(searchInputSelector).val());
    }
    function closeSearchBox() {
      $(searchInputContainerSelector).animate({
        width : "0"
      }, 150, function() {
        $(searchContainerSelector).removeClass("opened");
      });
    }
  });
})(jQuery);