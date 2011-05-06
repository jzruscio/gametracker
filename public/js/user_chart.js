$(function()
{

  $.get('/sm_data', {user_id: userId}, function(json){

    chart = new Highcharts.Chart({
    chart: {
      renderTo: 'smChart',
      defaultSeriesType: 'column'
    },
    title: {
      text: 'Game Results - Marshall Impact'
    },
    xAxis: {
      categories: json.opponents,
      labels: {
        rotation: -90    
      }
    },
    tooltip: {
      formatter: function() {
              return ''+
                  'vs '+ this.x +'';
      }
    },
    credits: {
      enabled: false
    },
    series: [{
      name: 'Opponents',
      data: json.data
    }]
    
    });
  }, "json");

});
