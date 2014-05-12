google.load("visualization", "1", {packages:["corechart"]});
      google.setOnLoadCallback(drawChart);
      function drawChart() {
        console.log(jsData)
        var data = google.visualization.arrayToDataTable(jsData);

        var options = {
          title: 'Elo Distribution',
          legend: { position: 'none' },
          histogram: { bucketSize: 30}
        };

        var chart = new google.visualization.Histogram(document.getElementById('chart_div'));
        chart.draw(data, options);
      }