(function($) {
  $﻿(document).ready(function() {
  	$(".mir-classification-select").each(function() {
  		var button = $(this);
  		
  		if(!!button.next().val()) {
	  		var label = button.next().val();
				var classi = button.next().next().val();
				if(classi != "") {
					button.parent().find("span").empty();
					button.parent().find("span").append(classi + "[" + label + "]");
				}
  		}
  		
  		button.click(function() {
  			work(button);
  		})
  	});
  	
  	function work(button){
  		initBody();
			loadClassifications(leftContent);
			
  		function leftContent(data) {
  			var mainBody = $(data).find("#main_content");
  			mainBody.filter("#main_content").addClass("list-group");
  			mainBody.filter("#main_content").attr("id", "main_left_content").attr("style" , "max-height: 560px; overflow: auto");
  			$("#modalFrame-body").html(mainBody);
  			
  			$("#main_left_content > a").each(function() {
  				var href = $(this).attr("href");
  				$(this).attr("data-href", href);
  				$(this).removeAttr("href");
  				
  				$(this).click(function() {
  					$(".list-group-item").removeClass("active");
  					$(this).addClass("active");
  					loadClassi(rightContent, $(this).attr("data-href"));
  				});
  			});
  		};
  		
  		function rightContent(data) {
  			$("#modalFrame-body > #main_right_content").remove();
  			var mainBody = $(data).find("#main_content");
  			mainBody.filter("#main_content").attr("id", "main_right_content").addClass("col-md-6 form-group").attr("style" , "max-height: 560px; overflow: auto");
  			mainBody.find(".classificationBrowser").removeAttr("class");
  			if(!$("#main_left_content").hasClass("col-md-6")) {
  				$("#main_left_content").addClass("col-md-6");
  			}
  			$("#modalFrame-body").append(mainBody);
  			
  			setTimeout(function() {
  				removeHrefCbList();
  			}, 400);
  		};
  		
  		function removeHrefCbList() {
  			$("#main_right_content .cbList > li > a").each(function() {
  				if($(this).attr("href") != "#" && !!$(this).attr("href")) {
  					var href = decodeURIComponent($(this).attr("href"));
  					var classi = href.substr(href.indexOf("@name=") + 6); 
  					classi = classi.split("&")[0];
  					var label = href.substr(href.indexOf("@text=") + 6); 
  					label = label.replace("+", " ");
  					$(this).removeAttr("href");
  					
  					$(this).click(function() {
  						button.next().val(label);
  						button.next().next().val(classi);
  						$("#modalFrame").modal("hide");
  						displayComplett();
  					});
  				}
  				
  				if($(this).attr("href") == "#") {
  					$(this).click(function() {
  						setTimeout(function() {
  							removeHrefCbList();
  						}, 400);
  					});
  				}
  			});
  		};
  		
  		function displayComplett() {
  			var label = button.next().val();
  			var classi = button.next().next().val();
  			if(classi != "") {
  				button.parent().find("span").empty();
  				button.parent().find("span").append(classi + "[" + label + "]");
  			}
  		}
  		
  		$("#modalFrame-cancel").click(function() {
  			$("#modalFrame").modal("hide");
  		});
  		
  		$("#modalFrame").on('hidden.bs.modal', function() {
  			$("#modalFrame-body").empty();
  		});
  		
  		function initBody() {
  			$("#modalFrame-title").text("Klassification Auswahl");
  			$("#modalFrame-cancel").text("Abbrechen");
  			$("#modalFrame-send").hide();
  			$("#modalFrame").modal("show");
  		};
  		
  		function loadClassifications(callback){
  			var session = $("input[name='_xed_session']").val();
  			$.ajax({
  				url: webApplicationBaseURL + "servlets/MIRClassificationServlet?_xed_subselect_session=" + session,
  				type: "GET",
  				dataType: "html",
  				success: function(data) {
  					callback(data);
  				},
  				error: function(error) {
  					alert(error);
  				}
  			});
  		};
  		
  		function loadClassi(callback, href){
  			$.ajax({
  				url: href,
  				type: "GET",
  				dataType: "html",
  				success: function(data) {
  					callback(data);
  				},
  				error: function(error) {
  					alert(error);
  				}
  			});
  		};
  	}
  });
})(jQuery);

