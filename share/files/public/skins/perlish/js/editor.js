
var scale_w = 1.0;
var scale_h = 1.0;
var wf = 0;
var hf = 0;
var iw = 0;
var ih = 0;
var current_wid = '';
var current_oid = '';

function getTopPos(el) {
    for (var topPos = 0;
        el != null;
        topPos += el.offsetTop, el = el.offsetParent);
    return topPos;
}

// http://stackoverflow.com/questions/623172/how-to-get-image-size-height-width-using-javascript


$(document).ready(function() {
    // Featured editor
    $("#scan_image").load(function() {
        ih = $(this).height();
        iw = $(this).width();
        //ih = $(this).naturalHeight;
        //iw = $(this).naturalWidth;
        var arrf = $('#page_1').attr("title").match(/bbox\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)/);
        wf = arrf[3];
        hf = arrf[4];
        scale_w = iw / wf;
        scale_h = ih / hf;
    
        $('#scale-width').text(scale_w);
        $('#scale-height').text(scale_h);
        $('#frame-width').text(wf);
        $('#frame-height').text(hf);
        $('#image-width').text(iw);
        $('#image-height').text(ih);

    $('.ocrx_word').each( function(index, element) {
       var oid = 'o' + $(element).attr('id');
       $(element).attr('contenteditable','true');
       
       // add confidence class
       // $( "p" ).addClass( "myClass yourClass" );
       // $( "p" ).removeClass( "myClass noClass" ).addClass( "yourClass" );
       var conf = $(element).attr("title").match(/x_wconf (\d+)/);
       if (conf[1] < 80 && conf[1] >= 65) {
         $(element).addClass( "c2" );
       }
       if (conf[1] < 65 && conf[1] >= 50) {
         $(element).addClass( "c1" );
       }
       if (conf[1] < 50) {
         $(element).addClass( "c0" );
       }

       var e = $(document.createElement('div'));
       e.attr('id',oid);
       e.attr('class','bbox');
       var arr = $(element).attr("title").match(/bbox (\d+) (\d+) (\d+) (\d+)/);
       var x1 = arr[1] * scale_w -2;
       var y1 = arr[2] * scale_h -2;
       var x2 = arr[3] * scale_w +2;
       var y2 = arr[4] * scale_w +2; 
       
       var w = x2 - x1;
       var h = y2 - y1; 

       e.css('width',w+'px');
       e.css('height',h+'px');
       e.css('top',y1+'px');
       e.css('left',x1+'px');
       e.appendTo('#layer');      
    }) 
  $(".bbox").click(function(){
    var wid = $(this).attr('id').replace(/^o/, '');
    
    var oid = $(this).attr('id');
    if (current_wid != '') {
       $("#" + current_wid).css('border-color','transparent'); 
    }
    current_wid = wid;
    $('#current-wid').text(current_wid);
    $("#" + wid).css('border-color','red');
    if (current_oid != '') {
       $("#" + current_oid).css('border-color','transparent'); 
    }
    current_oid = oid;
    $('#current-oid').text(current_oid);
    $("#" + oid).css('border-color','red');
    
    //var el = $("#" + wid);
    var el = document.getElementById(wid);
    var itop = getTopPos(el);
    //alert('itop2 ' + itop);
    $('#page_1').scrollTop(itop-200);
  })    
 })
});


/* click into text */
$(document).ready(function() {
  //$(".ocrx_word").mouseover(function(){
  // addEventListener(element, 'click', clickHandler, false);
  //addEventListener($(".ocrx_word"), 'click', function(){
  // focusin  focusout
  $(".ocrx_word").focusin(function(){
    var wid = $(this).attr('id');
    var oid = 'o' + $(this).attr('id');
    if (current_wid != '') {
       $("#" + current_wid).css('border-color','transparent'); 
    }
    current_wid = wid;
    $('#current-wid').text(current_wid);
    // $("#" + wid).css('background-color','yellow'); 
    if (current_oid != '') {
       $("#" + current_oid).css('border-color','transparent'); 
    }
    current_oid = oid;
    $('#current-oid').text(current_oid);
    $("#" + oid).css('border-color','red');
    
    var ileft = $("#" + oid).css('left').replace(/px/,'');
    var itop = $("#" + oid).css('top').replace(/px/,'');
    //$(this).closest('.ocr_line'); // find closest parent line
    // Math.floor(e), .ceil, .round
    // alert('itop ileft '+ itop +' ' + ileft);
    $(".scan").scrollLeft(ileft);
    $(".scan").scrollTop(itop);    
  })
  
  $(".ocrx_word").on("keypress", function(e){
    if (e.which == 13) {
        return false;
    }
  })
  
});
