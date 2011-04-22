$(function()
{

  p1 = $('#p1');
  p2 = $('#p2');

  p2.attr('selectedIndex', 1);

  $('#p1,#p2').change(function(){

    $("#p1 option[value='" + p2.data('oldVal') + "']").removeAttr("disabled");
    $("#p2 option[value='" + p1.data('oldVal') + "']").removeAttr("disabled");

    $("#p1 option[value='" + p2.val() + "']").attr("disabled","disabled");
    $("#p2 option[value='" + p1.val() + "']").attr("disabled","disabled");

    $.each(['#s1', '#w1', '#s2', '#w2'], function (i, op){
      $(op).empty()
        .append(new Option(p1.val(), p1.val()))
        .append(new Option(p2.val(), p2.val()));
    });
    $.each(['#s3', '#w3'], function(i, op){
      $(op).empty()
        .append(new Option("", ""))
        .append(new Option(p1.val(), p1.val()))
        .append(new Option(p2.val(), p2.val()));
    });
    p1.data('oldVal',  p1.val() );
    p2.data('oldVal',  p2.val() );

  }).change();

});
