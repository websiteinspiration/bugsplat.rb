Title: Payment Integration: Using Stripe with Rails by Pete Keen
Id: payment-123
Layout: book_layout
View: book
Skip_title_suffix: true

[Stripe]: https://www.stripe.com
[ror]: http://rubyonrails.org

# Want to make sure your Stripe integration is right?

<p>
<img style="float: right; margin-left: 20px;" src="http://files.bugsplatcdn.com/files/e1aa9b6c8960a1012ce2/stripe_rails.png">
Over the past two years I've written four web applications from scratch using <a href="http://rubyonrails.org">Ruby on Rails</a>. Every single one of these applications uses <a href="https://www.stripe.com">Stripe</a> to process recurring or one-time payments. With each new implmentation I've learned new things and realized new mistakes that my previous implementations had.
</p>

I want to share what I've learned, so I've started writing an eBook called <strong><em>Payment Integration: Using Stripe with Rails</em></strong>. In this book you'll learn:

* Why a simple, 10 minute integration **isn't enough**
* How to build **maintainable** payment forms that convert
* How, where, and why to use Stripe's `stripe.js` and `checkout.js`
* Why you should always structure payments as state machines
* Why and how you should write an admin interface from the start
* How to handle subscription billing
* What "dunning" is and how to use it to **put thousands of dollars in
  your pocket**
* How and why you should process payments using a background worker

### Sign up to get updates and 20% off the published price

<div class="pricing">
  <div class="row">
    <div class="span2">
      <h4>Deluxe Package</h4>
      <ul>
        <li><span class="price">$399</span></li>
        <li>75 page ebook in PDF, ePub, and mobi format</li>
        <li>Access to a full example Rails/Stripe application implementing every one of these best practices</li>
        <li>One hour of consulting time with me to work out any problems with your integration</li>
      </ul>
    </div>
    <div class="span2">
      <h4>Mini Package</h4>
      <ul>
        <li><span class="price">$89</span></li>
        <li>75 page ebook in PDF, ePub, and mobi format</li>
        <li>Access to a full example Rails/Stripe application implementing every one of these best practices</li>
      </ul>
    </div>
    <div class="span2">
      <h4>Just the Book</h4>
      <ul>
        <li><span class="price">$29</span></li>
        <li>75 page ebook in PDF, ePub, and mobi format</li>
      </ul>
    </div>
  </div>
</div>

<div class="well">
<p>Just put your email address in below and I'll send you updates on my progress, preview chapters, and a <em><strong>20% off discount code</strong></em> when I publish the book.</p>

<form action="http://bugsplat.us6.list-manage.com/subscribe/post?u=4d4742d4ee66f8c62af747acb&amp;id=1920a1a25a" method="post" class="form form-inline" target="_blank">
    <div class="input-append">
	<input type="email" value="" name="EMAIL" id="mce-EMAIL" placeholder="Email address">
	<input type="submit" value="Subscribe" name="subscribe" id="mc-embedded-subscribe" class="btn btn-primary">
    </div>
</form>
</div>