---
title: 'How much can you save with an S-Corp?'
id: scrp
body_class: book hyb
skip_masthead: true
skip_footer: true
description: Check out this interactive calculator to determine how much an S-corp could save you.
thumbnail: https://d2s7foagexgnc2.cloudfront.net/files/d4de5b4d661c825d65d3/hyb_cover_3d_no_shadow.png
---

<label for="net-income">Net Income</label>
<input type="range" id="net-income" min="50000" max="250000" step="1000" value="120000"> <span id="net-income-val"></span>

<label for="salary">Reasonable Salary</label>
<input type="range" id="salary" min="50000" max="250000" step="1000" value="90000"> <span id="salary-val"></span>

Sole Prop: <span id="sole-prop-result"></span>

S-Corp: <span id="s-corp-result"></span>

Difference: <span id="difference"></span>

<script type="text/javascript">
function recalculate() {
  var netIncome = parseFloat($('#net-income').val());
  var salary = parseFloat($('#salary').val());

  $('#net-income-val').text(netIncome);
  $('#salary-val').text(salary);

  var solePropMedicare = netIncome * 0.029;
  var solePropSS = Math.min(netIncome, 118500) * 0.124;

  $("#sole-prop-result").text(Math.round(solePropMedicare + solePropSS));

  var sCorpMedicare = salary * 0.029;
  var sCorpSS = Math.min(salary, 118500) * 0.124;

  $("#s-corp-result").text(Math.round(sCorpMedicare + sCorpSS));

  var difference = Math.round((solePropMedicare + solePropSS) - (sCorpMedicare + sCorpSS));
  
  $("#difference").text(difference);
}

window.onload = function() {
  $('#net-income').on("input", recalculate);
  $('#salary').on("input", recalculate);
  recalculate();
};
</script>
