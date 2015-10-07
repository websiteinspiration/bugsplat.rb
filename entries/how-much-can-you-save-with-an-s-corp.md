---
title: 'How much can you save with an S-Corp?'
id: scrp
body_class: book hyb
skip_masthead: true
skip_footer: true
description: Check out this interactive calculator to determine how much an S-corp could save you.
thumbnail: https://d2s7foagexgnc2.cloudfront.net/files/d4de5b4d661c825d65d3/hyb_cover_3d_no_shadow.png
---

# How much can you save by starting an S-Corp?

If you have an LLC or a normal corporation, the IRS allows you to elect what they call "Subchapter S" taxation.

When you elect S-corp taxation, you agree to abide by a few rules: one class of stock, only individual owners, etc.

In exchange, you get to decide on a reasonable salary for owners, which lets you decide how much you want to pay for Medicare and Social Security.

Normally, you would pay the Self-Employment taxes (both employee and employer sides of Medicare and Social Security taxes) on all of your income, 15.4% up to $118,500 and 2.9% thereafter.

With an S-corp, however, you only pay Self-Employment taxes on your salary.

But how much is that?

----

Use the sliders below to calculate how much less you would pay by electing S-corp taxation.
**Net Income** is how much your business makes after business-related expenses. **Salary** is how much you want to pay yourself as a reasonable salary.

<label for="net-income">Net Income</label> <span id="net-income-val"></span>
<input type="range" id="net-income" min="50000" max="250000" step="1000" value="120000"> 

<label for="salary">Reasonable Salary</label> <span id="salary-val"></span>
<input type="range" id="salary" min="50000" max="250000" step="1000" value="90000">

Sole Prop: <span id="sole-prop-result"></span>

S-Corp: <span id="s-corp-result"></span>

Difference: <span id="difference"></span>

---

Want to go further? <a href="/handle-your-business"><strong>Handle Your Business</strong></a> will teach you everything you need to know about S-corps, LLCs, taxes, and more.

<div class="well">
<div class="center">
  <p>Get a <strong>FREE sample chapter</strong>.</p>
  <form action="https://www.getdrip.com/forms/8653666/submissions" method="POST" role="form" class="form-inline" style="margin-top: 0.5em;" data-drip-embedded-form="8653666">
    <div class="form-group">
      <label class="sr-only" for="first-name">First Name</label>
      <input id="first-name" type="text" class="sans" style="font-size: 17.5px; height: 36px; width: 12em; line-height: 22px;" name="fields[name]" placeholder="First Name"></input>
    </div>
    <div class="form-group">
      <label class="sr-only" for="email-address">Email Address</label>
      <input id="email-address" type="email" class="sans" style="font-size: 17.5px; height: 36px; width: 12em; line-height: 22px;" name="fields[email]" placeholder="you@example.com"></input>
    </div>
    <input class="btn btn-warning btn-large" type="submit" value="Send Me The Sample" />
  </form>
  <small>We won't send you spam. Unsubscribe at any time.</small>
</div>
</div>


<script type="text/javascript">
function numberWithCommas(x) {
    return '$' + x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}

function recalculate() {
  var netIncome = parseFloat($('#net-income').val());
  var salary = parseFloat($('#salary').val());

  $('#net-income-val').text(numberWithCommas(netIncome));
  $('#salary-val').text(numberWithCommas(salary));

  var solePropMedicare = netIncome * 0.029;
  var solePropSS = Math.min(netIncome, 118500) * 0.124;

  $("#sole-prop-result").text(numberWithCommas(Math.round(solePropMedicare + solePropSS)));

  var sCorpMedicare = salary * 0.029;
  var sCorpSS = Math.min(salary, 118500) * 0.124;

  $("#s-corp-result").text(numberWithCommas(Math.round(sCorpMedicare + sCorpSS)));

  var difference = Math.round((solePropMedicare + solePropSS) - (sCorpMedicare + sCorpSS));
  
  $("#difference").text(numberWithCommas(difference));
}

window.onload = function() {
  $('#net-income').on("input", recalculate);
  $('#salary').on("input", recalculate);
  recalculate();
};
</script>
