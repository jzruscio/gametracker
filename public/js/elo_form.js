$(function() {

 $("select#p2").attr('selectedIndex', 1);

 $(".elo_button").click(function() {

    var p1 = $("select#p1").val()
    var p2 = $("select#p2").val()

    $.get('/elo_ratings', {p1: p1, p2: p2}, function(data){
      results = p1 + " wins: elo increases from " + data.p1_cur + " to " + data.p1_wins + "\n"
      results = results + p1 + " loses: elo decreases from " + data.p1_cur + " to " + data.p1_loses + "\n"
      results = results + p2 + " wins: elo increases from " + data.p2_cur + " to " + data.p2_wins + "\n"
      results = results + p2 + " loses: elo decreases from " + data.p2_cur + " to " + data.p2_loses + "\n"
      alert(results);
    }, "json");
	
  });
});

