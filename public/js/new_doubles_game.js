$(function()
{

  p1 = $('#p1');
  p2 = $('#p2');
  p3 = $('#p3');
  p4 = $('#p4');

  p2.attr('selectedIndex', 1);
  p3.attr('selectedIndex', 2);
  p4.attr('selectedIndex', 3);

  $('#p1, #p2, #p3, #p4').change(function(){

//    $.each([p1, p2, p3, p4], function(index, player){
//      $("#p1 option[value='" + player.data('oldVal') + "']").removeAttr("disabled");
//      $("#p2 option[value='" + player.data('oldVal') + "']").removeAttr("disabled");
//      $("#p3 option[value='" + player.data('oldVal') + "']").removeAttr("disabled");
//      $("#p4 option[value='" + player.data('oldVal') + "']").removeAttr("disabled");
//  
//      $("#p1 option[value='" + player.val() + "']").attr("disabled","disabled");
//      $("#p2 option[value='" + player.val() + "']").attr("disabled","disabled");
//      $("#p3 option[value='" + player.val() + "']").attr("disabled","disabled");
//      $("#p4 option[value='" + player.val() + "']").attr("disabled","disabled");
//    });

    $.each(['#s1', '#s2'], function (i, op){
      $(op).empty()
        .append(new Option(p1.val(), p1.val()))
        .append(new Option(p2.val(), p2.val()))
        .append(new Option(p3.val(), p3.val()))
        .append(new Option(p4.val(), p4.val()));
    });
    $.each(['#s3'], function(i, op){
      $(op).empty()
        .append(new Option("", ""))
        .append(new Option(p1.val(), p1.val()))
        .append(new Option(p2.val(), p2.val()))
        .append(new Option(p3.val(), p3.val()))
        .append(new Option(p4.val(), p4.val()));
    });

    $.each(['#w1', '#w2'], function (i, op){
      $(op).empty()
        .append(new Option('Team 1', 'team1'))
        .append(new Option('Team 2', 'team2'));
    });
    $.each(['#w3'], function(i, op){
      $(op).empty()
        .append(new Option("", ""))
        .append(new Option('Team 1', 'team1'))
        .append(new Option('Team 2', 'team2'));
    });
    p1.data('oldVal',  p1.val() );
    p2.data('oldVal',  p2.val() );
    p3.data('oldVal',  p3.val() );
    p4.data('oldVal',  p4.val() );

  }).change();

});
