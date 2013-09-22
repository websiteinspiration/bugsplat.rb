Title: DRY your Rails CRUD with Simple Form and Inherited Resources
Id:    crud
Tags:  Programming, Rails
Show_upsell: true

[simple_form]: https://github.com/plataformatec/simple_form
[inherited_resources]: https://github.com/josevalim/inherited_resources
[rails_admin]: https://github.com/sferik/rails_admin
[active_admin]: https://github.com/gregbell/active_admin

When you're writing a Rails application you usually end up with a lot of CRUD-only controllers and views just for managing models as an admin. Your user-facing views and controllers should of course have a lot of thought and care put into their design, but for admin stuff you just want to put data in the database as simply as possible. Rails of course gives you scaffolds, but that's quite a bit of duplicated code. Instead, you could use the one-two-three combination of [Simple Form][simple_form],  [Inherited Resources][inherited_resources], and Rails' built-in template inheritance to DRY up most of the scaffolding while still preserving your ability to customize where appropriate. This lets you build your admin interface without having to resort to something heavy like [Rails Admin][rails_admin] or [ActiveAdmin][active_admin] while also not having to build from scratch every time.

--fold--

Inherited Resources consists of a base controller you can inherit from that implements all of the standard resourceful actions, plus a few convenience things for working with this controller. If you have a `Book` model, you could create a complete resourceful controller for it with the following code:

```ruby
class BooksController < InheritedResources::Base
  protected
  def permitted_params
    params.permit(book: {:title, :author, :isbn})
  end
end
```

As you can see, Inherited Resources has automatic integration with Rails 4's Strong Parameters.

## DRY up your CRUD

Rails 3.1 and further shipped with a thing called 'template inheritance'. This simply means that there's a default search path for templates that Rails will hunt through to find a suitable template. If there's no `index.html.erb` in `app/views/books`, for example, Rails will look in `app/views/application` because that's `BooksController`'s base class. We can use this to construct default views for our CRUD controllers. First, let's make a base class for our controllers to inherit from:

```ruby
class CrudController < InheritedResources::Base
  def attrs_for_index
    []
  end

  def attrs_for_form
    []
  end

  helper_method :attrs_for_index
  helper_method :attrs_for_form
end
```

And now we can set up default views. First, `app/views/crud/index.html.erb`:

```erb
<h1>
  <%= resource_class.to_s.pluralize %>&nbsp;
  <small>
  <%= link_to 'New', [:new, resource_class.to_s.downcase.to_sym] %>
</h1>
<table>
  <thead>
    <tr>
      <% attrs_for_index.each do |attr| %>
        <th><%= attr.to_s.titlecase %></th>
      <% end %>
      <th></th>
    </tr>
  </thead>
  <tbody>
    <% collection.each do |resource| %>
      <tr>
      <% attrs_for_index.each do |attr| %>
        <td><%= link_to resource.attributes[attr.to_s], resource %></td>
      <% end %>
      <td><%= link_to 'Edit', [:edit, resource] %></td>
      </tr>
    <% end %>
  </tbody>
</table>
```

Inherited Resources gives you a few helpers that make these views really easy:

* `collection` maps to the collection of objects in your controller. If it was `BooksController`, `collection` would return `@books`. This is only present in the index view.
* `resource_class` returns the class of the resource your controller is managing
* `resource` maps to `@book` and is available in every view except index.

Now we need a `show` view. Most of the time, all you want to see is a dump of the resource's attribute, which is exactly what we're going to do in `app/views/crud/show.html.erb`:

```erb
<h1>
  <%= resource_class %> <%= resource.id %>
  <small><%= link_to 'Edit', [:edit, resource] %></small>
</h1>
<table>
  <tr>
    <th>Key</th>
    <th>Value</th>
  </tr>
  <% resource.attributes.sort.each do |key, value| %>
  <tr>
    <td><%= key %></td>
    <td><%= value %></td>
  </tr>
  <% end %>
</table>
```

The edit and new views are super simple:

```erb
<h1>New <%= resource_class.to_s.titlecase %></h1>
<%= render 'form' %>
```

```erb
<h1>Editing <%= resource_class.to_s.titlecase %> <%= resource.id %></h1>
<%= render 'form' %>
```

Let's look at `app/views/crud/_form.html.erb`:

```erb
<%= simple_form_for resource do |f| %>
  <% attrs_for_form.each do |attr| %>
    <%= f.input attr %>
  <% end %>
  <%= f.button :submit %>
<% end %>
```

Here's where Simple Form really starts to shine. It auto-detects the proper form input to display by inspecting the attribute, so we don't have to do any work for a basic form. Of course, because we're using view inheritance, if you want to make a more complicated for you can just drop what you want into `app/views/<controller>/_form.html.erb` and it'll get picked up automatically. That also goes the same for any of the templates.

We should flesh out `BooksController` with overrides for those `attr` methods:

```ruby
class BooksController < CrudController
  def attrs_for_index
    [:title, :author, :isbn]
  end

  def attrs_for_form
    [:title, :author, :isbn]
  end
end
```

## Sorting, Paging, and Whatnot

You're probably thinking that this whole thing is great, but what if you need to, for example, sort or paginate the results on the index? Inherited Resources has you covered. Just override the `collection` method, like this:

```ruby
class BooksController < CrudController
  def collection
    @books ||= end_of_resource_chain.order('created_at DESC')
  end
end
```

The `end_of_resource_chain` method gives you your resource relation after applying all of the other neat things that Inherited Resources can do. Check out [the README][inherited_resources] for more details on that.

In the same vein, what if you want to limit the objects created and accessed by the rest of the CRUD actions? For example, let's say you want to limit the books available to the current user:

```ruby
class BooksController < CrudController
  def begin_of_association_chain
    current_user
  end
end
```

`begin_of_association_chain` is where Inherited Resources starts out building objects. If you don't provide it, it defaults to the resource class.

---

There's a lot more you can do with Inherited Resources and Simple Form, like build controllers that deal with multiple nested resources and forms that have automatically populated select dropdowns. You should check them out.
