$(document).ready(function(){
    $('#nav').onePageNav();

    $('a[href^="http"]').attr('target','_blank');
    
    $('.toggle').click(function(){
        $('.overview').toggleClass('open');
    });

    $('.toggle-collapsible').click(function() {
        $(this).toggleClass('active');
        $(this).next().toggle();
    });

    $.get("https://uhf.microsoft.com/en-US/shell/api/mscc?sitename=aksworkshop.io&domain=aksworkshop.io&country=euregion", function(data, status){
      if(data.IsConsentRequired) {
        $("#consent-container").html(data.Markup);
        $("#msccBanner").show();
      }
    });
});
