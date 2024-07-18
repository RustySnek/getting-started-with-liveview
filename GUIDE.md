


> Hey, this guide is meant to elaborate on [Phoenix LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html) that wasn't talked over in [Getting started with Elixir Phoenix](https://www.linkedin.com/pulse/unofficial-getting-started-elixir-phoenix-guide-andy-klimczak-uhllc/) by [Andy Klimczak](https://www.linkedin.com/in/andyklimczak/). This article will leverage itself  on Andy's which itself is based on the [Getting Started with Rails Guide](https://guides.rubyonrails.org/getting_started.html). All the credit goes to Andy and the writer of that Rails guide.

> This guide aims to go over starting a simple Article/Comments blog  from scratch using LiveView and it's rich functionality.
>
> If there are better/simpler ways to do something, please create an  [issue or PR](https://github.com/RustySnek/getting-started-with-liveview). You'll help me understand how to write better Phoenix, and others as well.

[Check out the finished repo here.](https://github.com/RustySnek/getting-started-with-liveview)  Thank you! Let's go.


## 1 Guide Assumptions

This guide is designed for beginners who want to get started with creating a Phoenix LiveView application from scratch. It does not assume that you have any prior experience with Phoenix or LiveView.

Phoenix is a web application framework running on the Elixir programming language, whilst LiveViews are processes that enable rich, real-time user experiences with server-rendered HTML. If you have no prior experience with Elixir, you will find a very steep learning curve diving straight into Phoenix. There are several curated lists of online resources for learning Phoenix:

- **[Elixir Introduction](https://hexdocs.pm/elixir/introduction.html)**
- **[Community Resources](https://elixir-lang.org/learning.html)**


##  2 What is Phoenix?
> Phoenix is a web development framework written in Elixir which implements the server-side Model View Controller (MVC) pattern. Many of its components and concepts will seem familiar to those of us with experience in other web frameworks like Ruby on Rails or Python's Django.
[source](https://hexdocs.pm/phoenix/overview.html)

## 3 What is a LiveView?

> LiveViews are processes that receive events, update their state, and render updates to a page as diffs.

> The LiveView programming model is declarative: instead of saying "once event X happens, change Y on the page", events in LiveView are regular messages which may cause changes to the state. Once the state changes, the LiveView will re-render the relevant parts of its HTML template and push it to the browser, which updates the page in the most efficient manner.

> LiveView state is nothing more than functional and immutable Elixir data structures. The events are either internal application messages (usually emitted by Phoenix.PubSub) or sent by the client/browser.

> Every LiveView is first rendered statically as part of a regular HTTP request, which provides quick times for "First Meaningful Paint", in addition to helping search and indexing engines. A persistent connection is then established between the client and server. This allows LiveView applications to react faster to user events as there is less work to be done and less data to be sent compared to stateless requests that have to authenticate, decode, load, and encode data on every request.

[source](https://hexdocs.pm/phoenix_live_view/welcome.html)

If you had any prior experience with Elixir you might notice that LiveView is essentialy built on top of Elixir's [GenServer](https://hexdocs.pm/elixir/1.17.2/GenServer.html).

A GenServer is a powerful tool in Elixir for building concurrent, stateful processes. It simplifies the creation of processes that manage state and handle messages, making it an essential component for building robust, real-time, and interactive applications.

For simplicity you can think of a LiveView as our controller.

### 3.1 What does LiveView bring to the table?
LiveView has many [Feature highlights](https://github.com/phoenixframework/phoenix_live_view?tab=readme-ov-file#feature-highlights). However what stands out the most for me are:
- Diffs over the wire - Instead of sending whole HTML whenever your template changes, the LiveView knows exactly which parts had changes, sending minimal diffs after the initial render.

- Rich integration API - LiveView provides API to interact with  the client, with `phx-click`, `phx-focus`, `phx-submit`, and `phx-hook` for cases where you have to write JavaScript.

- Live navigation - Clients load minimum amount of content needed as users navigate throghout your application, without any compromise on user experience.

- Latency simulator - Allows for emulation of how slow clients will interact with your app.
### 3.2 LiveView's Life-Cycle
Before diving into LiveView, it's important to understand the cycle that it goes through every time it's rendered.
> A LiveView begins as a regular HTTP request and HTML response, and then upgrades to a stateful view on client connect, guaranteeing a regular HTML page even if JavaScript is disabled. Any time a stateful view changes or updates its socket assigns, it is automatically re-rendered and the updates are pushed to the client.

>Socket assigns are stateful values kept on the server side in [`Phoenix.LiveView.Socket`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Socket.html). This is different from the common stateless HTTP pattern of sending the connection state to the client in the form of a token or cookie and rebuilding the state on the server to service every request.

> You begin by rendering a LiveView typically from your router. When LiveView is first rendered, the [`mount/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:mount/3) callback is invoked with the current params, the current session and the LiveView socket. As in a regular request, `params` contains public data that can be modified by the user. The `session` always contains private data set by the application itself. The [`mount/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:mount/3) callback wires up socket assigns necessary for rendering the view. After mounting, [`handle_params/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:handle_params/3) is invoked so uri and query params are handled. Finally, [`render/1`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:render/1) is invoked and the HTML is sent as a regular HTML response to the client.

> After rendering the static page, LiveView connects from the client to the server where stateful views are spawned to push rendered updates to the browser, and receive client events via `phx-` bindings. Just like the first rendering, [`mount/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:mount/3), is invoked with params, session, and socket state. However in the connected client case, a LiveView process is spawned on the server, runs [`handle_params/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:handle_params/3) again and then pushes the result of [`render/1`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:render/1) to the client and continues on for the duration of the connection. If at any point during the stateful life-cycle a crash is encountered, or the client connection drops, the client gracefully reconnects to the server, calling [`mount/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:mount/3) and [`handle_params/3`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#c:handle_params/3) again.

> LiveView also allows attaching hooks to specific life-cycle stages with [`attach_hook/4`](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#attach_hook/4).

[source](https://hexdocs.pm/phoenix_live_view/1.0.0-rc.6/Phoenix.LiveView.html#module-life-cycle)

## 4 Creating a new Phoenix LiveView project
 The best way to read this guide is to follow it step by step. All steps are essential to run this example application and no additional code or steps are needed.

By following along with this guide, you'll create a Phoenix project called blog, a (very) simple weblog. Before you can start building the application, you need to make sure that you have Phoenix itself installed. 

### 4.1 Installing Phoenix
 [Official Phoenix Install Guide](https://hexdocs.pm/phoenix/installation.html)

Prerequisites:
- elixir
- SQLite3

#### 4.1.1 Installing Elixir

Verify that you have a current version of Elixir installed:

```
$ elixir -v
Erlang/OTP 25 [erts-13.2.2.10] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit:ns]

Elixir 1.17.2 (compiled with Erlang/OTP 25)
```
#### 4.1.2 Installing SQLite3

You will also need an installation of SQLite3.

Verify that is correctly installed and in your load PATH:

```$ sqlite3 --version```

#### 4.1.3 Installing Phoenix

To install Phoenix, use the mix command:

```$ mix archive.install hex phx_new```

 To verify Phoenix was installed correctly, run the command:
 
 ```$ mix phx.new```
 
 ### 4.2 Creating the Blog Application
 
  Phoenix comes with a number of scripts called generators that are designed to make development easier and quicker by creating files with boilerplate code. One of these is the new application generator, which will provide you with a foundation of a fresh Phoenix application so that you don't have to write it yourself.

To use this generator, open a terminal, navigate to a directory, and run:

```$ mix phx.new blog --database sqlite3```

This will create a Phoenix application called Blog in a blog directory and install all dependencies that are already in the mix.exs file using mix deps.get.

> ⚠️ You can see all the command line options the Phoenix application generator accepts by running mix phx.new

 After you create the blog application, switch to its directory:
 
 ```$ cd blog```
 
  The blog directory will have a number of generated files and folder that make up a structure of a Phoenix application. Most of the work of this tutorial will happen in the lib folder, but here's a basic rundown of each of the files and folders that Phoenix creates by default:

File/Folder  Purpose 

- _build/ Contains compiled artifacts and build-related files

- assets/ Contains your css and javascript assets for your application. 

- config/ General and environment specific configuration for your application. 

- lib/ Contains your contexts, schemas, controllers, views of your application. You'll focus on this directory for the remainder of this guide. 

- priv/ Contains your I18n translations, database migrations, and static assets. 

- test/ Unit tests, fixtures, and other test files 

- .formatter.exs Config file for Elixir code formatting. See more here. 

- .gitignore Default .gitignore file for Phoenix applications to not commit generated files to git repositories. 

- mix.exs Used to specify the main configuration for the project, application, and dependencies. 

- README.md Standard README that details how to run a Phoenix application.

## 5 Hello Phoenix LiveView
To begin with, let's get some text on the screen quickly. TO do this, you'll need your Phoenix application server running.

### 5.1 Starting up the Web Server
You actually have a functional Phoenix application already. To see it, you need to start a web server on your development machine. But first we need to create and migrate the database. You can do this by running the following commands in the blog directory:

```
$ mix ecto.create
$ mix ecto.migrate
```

Then you can start the server with:

```$ mix phx.server```

However for debugging purposes I personally prefer to run:

```$ iex -S mix phx.server``` - this will run the server inside the interactive elixir shell allowing for easy debugging.

To see your application in action, open the browser window and navigate to http://localhost:4000. You should see the default Phoenix information page.

To stop the server, double hit the Ctrl-C in the terminal window. In the development environment, Phoenix does not generally require you to restart the server; changes you make in files will be automatically picked up by the server.

### 5.2 Say "Hello", LiveView
To get LiveView saying "Hello", you need to create at minimum a module that implements a series of functions as callbacks to our LiveView, and a Heex template. Then the LiveView has to be served inside the router.

Let's start by creating a directory that will hold all of our LiveViews and a dir for our blog LiveViews:

```
$ mkdir lib/blog_web/live
$ mkdir lib/blog_web/live/blog_live
```

Then we will create our `ArticleLive` LiveView and a template.
```elixir
# lib/blog_web/live/blog_live/article.ex
defmodule BlogWeb.BlogLive.Article do
  use BlogWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
```
Now for our template you can either use the `def render(assigns)` callback or create a template file with a snake_cased module name like `article.html.heex` (so for module name like ArticleFollowersLive, the template would be `article_followers.html.heex`):
``` elixir
# The render callback
def render(assigns) do
	~H"""
	<h1 class="text-lg text-brand">
	  Hello, LiveView!
	</h1>
	"""
end
```
```html
<!-- The template file: lib/blog_web/live/blog_live/article.html.heex -->
<h1 class="text-lg text-brand">
  Hello, LiveView!
</h1>
```
The render callback is preferred for smaller components, as to not clutter the directory, however for modules/bigger components, a template file should be used (and that's what we will work with).

Now let's route and serve our LiveView under `/articles` at the bottom of the `/` scope in the `lib/blog_web/router.ex` :

```elixir
  scope "/", BlogWeb do
    pipe_through :browser

    get "/", PageController, :home
    live "/articles", BlogLive.Article, :index
  end
```

Every route declared with `live` macro responds to `GET`. Here our route is also mapped to `:index` action, which we will later access via @live_action assign inside socket.

Visit  [http://localhost:4000/articles](http://localhost:4000/)  to see Phoenix display "Hello, LiveView"!

### 5.3 Setting the Application to Home Page
At the moment,  [http://localhost:4000](http://localhost:4000/)  still displays the default Phoenix page. Let's display our "Hello, LiveView!" text at  [http://localhost:4000](http://localhost:4000/)  as well. To do so, we will add a route that maps the root path of our application to the appropriate LiveView.

Let's open lib/blog_web/router.ex and add the live "/" path to map to the Article with index action:
```elixir
  scope "/", BlogWeb do
    pipe_through :browser

    live "/", BlogLive.Article, :index
    live "/articles", BlogLive.Article, :index
  end
  ```
## 6 MVC and you
So far, we've discussed routes, liveviews (our controllers), actions, and Heex templates (our views). All of these are typical pieces of a web application that follows the  [MVC (Model-View-Controller)](https://en.wikipedia.org/wiki/Model%E2%80%93view%E2%80%93controller)  pattern. MVC is a design pattern that divides the responsibilities of an application to make it easier to reason about. Phoenix follows this design pattern by convention.

Since we have a controller and a view to work with, let's generate the next piece: a model.

### 6.1 Generating a model

The  _model_  in Phoenix is actually an  [Ecto Schema](https://hexdocs.pm/ecto/Ecto.Schema.html). Schemas behave similarly to models from other frameworks, such as mapping external data into Elixir structs. But the difference to other frameworks is that schemas area much more solely focused on that mapping of external data.

To generate a schema, we'll use the  [schema generator](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.Schema.html)  to generate an article schema which contains title and body database fields.

```
mix phx.gen.schema MyBlog.Article articles title:string body:text

* creating lib/blog/my_blog/article.ex
* creating priv/repo/migrations/20240714093903_create_articles.exs

Remember to update your repository by running migrations:

    $ mix ecto.migrate
  ```
  This command will create two new files:
  1.   Schema file at `lib/blog/my_blog/article.ex` in the my_blog context.
  2.   Migration file at `priv/repo/migrations/<timestamp>_create_articles.exs`

### 6.2 Database Migrations

Migrations are used to alter the structure of an application's database. In Phoenix applications, migrations are written in Elixir so that they can be database-agnostic.

Let's take a look at the contents of our new migration file:
```elixir
defmodule Blog.Repo.Migrations.CreateArticles do
  use Ecto.Migration

  def change do
    create table(:articles) do
      add :title, :string
      add :body, :text

      timestamps(type: :utc_datetime)
    end
  end
end
```

The `create table(:articles)` do block specifies how the new `articles` table should be constructed. By default, the table is automatically created with an auto-incrementing primary key `id` field.

Inside the block for `create table(:articles)`, two columns are defined: `title` and `body`. These were added by the generator because we included them in our generate command.

On the last line of the block is `timestamps(type: :utc_datetime)`. This method defines two additional columns named `inserted_at` and `updated_at`. Phoenix will manage these for us, setting the values when we create or update a schema.

Let's run our migration with the following command:

```$ mix ecto.migrate```

The command will display output indicating that the table was created:
```
Compiling 1 file (.ex)
Generated blog app

11:43:45.737 [info] == Running 20240714093903 Blog.Repo.Migrations.CreateArticles.change/0 forward

11:43:45.740 [info] create table articles

11:43:45.747 [info] == Migrated 20240714093903 in 0.0s
```
### 6.3 Using the Model to Interact with the Database

Let's get back to our interactive shell we started with:

```iex -S mix phx.server```

You should be greeted by prompt like this:
```elixir
iex -S mix phx.server
Erlang/OTP 25 [erts-13.2.2.10] [source] [64-bit] [smp:16:16] [ds:16:16:10] [async-threads:1] [jit:ns]

[info] Migrations already up
[info] Running BlogWeb.Endpoint with Bandit 1.5.5 at 127.0.0.1:4000 (http)
[info] Access BlogWeb.Endpoint at http://localhost:4000
Interactive Elixir (1.17.2) - press Ctrl+C to exit (type h() ENTER for help)
[watch] build finished, watching for changes...
iex(1)> 
```

Using this prompt, we can initialize a new Article object:
```elixir
iex(2)> alias Blog.MyBlog.Article
Blog.MyBlog.Article
iex(3)> alias Blog.Repo
Blog.Repo
iex(4)> {:ok, article} = Repo.insert(%Article{title: "Hello, LiveView", body: "I am running a LiveView WebSocket!"})
[debug] QUERY OK source="articles" db=0.2ms idle=1654.0ms
INSERT INTO "articles" ("body","title","inserted_at","updated_at") VALUES (?,?,?,?) RETURNING "id" ["I am running a LiveView WebSocket!", "Hello, LiveView", ~U[2024-07-14 09:50:15Z], ~U[2024-07-14 09:50:15Z]]
↳ :elixir.eval_external_handler/3, at: elixir.erl:386
{:ok,
	%Blog.MyBlog.Article{
	    __meta__: #Ecto.Schema.Metadata<:loaded, "articles">,
	    id: 1,
	    body: "I am running a LiveView WebSocket!",
	    title: "Hello, LiveView",
	    inserted_at: ~U[2024-07-14 09:55:11Z],
	    updated_at: ~U[2024-07-14 09:55:11Z]
  }}
 
```

The above output shows an INSERT INTO "articles" ... database query. This indicates that the article has been inserted into our table. And if we take a look at the article object again, we see something interesting has happened:
```elixir
iex(5)> article              
%Blog.MyBlog.Article{
    __meta__: #Ecto.Schema.Metadata<:loaded, "articles">,
    id: 1,
    body: "I am running a LiveView WebSocket!",
    title: "Hello, LiveView",
    inserted_at: ~U[2024-07-14 09:55:11Z],
    updated_at: ~U[2024-07-14 09:55:11Z]
  }
```
The id, created_at, and updated_at attributes of the object are now set. Phoenix did this for us when we saved the object.

When we want to fetch this article from the database, we can call find on the model and pass the id as an argument:

```elixir
iex(6)> Repo.get!(Article, 1)
[debug] QUERY OK source="articles" db=0.1ms idle=1232.8ms
SELECT a0."id", a0."body", a0."title", a0."inserted_at", a0."updated_at" FROM "articles" AS a0 WHERE (a0."id" = ?) [1]
↳ :elixir.eval_external_handler/3, at: elixir.erl:386
%Blog.MyBlog.Article{
    __meta__: #Ecto.Schema.Metadata<:loaded, "articles">,
    id: 1,
    body: "I am running a LiveView WebSocket!",
    title: "Hello, LiveView",
    inserted_at: ~U[2024-07-14 09:55:11Z],
    updated_at: ~U[2024-07-14 09:55:11Z]
  }
```
And when we want to fetch all articles from the database, we can call all using the repo:
```elixir
iex(7)> Repo.all(Article)
[debug] QUERY OK source="articles" db=0.0ms idle=1505.7ms
SELECT a0."id", a0."body", a0."title", a0."inserted_at", a0."updated_at" FROM "articles" AS a0 []
↳ :elixir.eval_external_handler/3, at: elixir.erl:386
[
  %Blog.MyBlog.Article{
    __meta__: #Ecto.Schema.Metadata<:loaded, "articles">,
    id: 1,
    body: "I am running a LiveView WebSocket!",
    title: "Hello, LiveView",
    inserted_at: ~U[2024-07-14 09:55:11Z],
    updated_at: ~U[2024-07-14 09:55:11Z]
  }
]
```
Now we can leave the server running and get to actually show these articles on our web page.

### 6.4 Showing a List of Articles

Phoenix has a notion of organizing code into a domain-driven-design (DDD) style structure with the use of Contexts. Contexts are used as an abstraction layer between schemas and the rest of the application, by encapsulating data access and data validation.

Let's first create a module that will contain our queries at `lib/blog/my_blog/article_queries.ex`:
```elixir
defmodule Blog.MyBlog.ArticleQueries do
  import Ecto.Query
  alias Blog.MyBlog.Article
  
  def base() do
    from(Article, as: :article)
  end
end
```
For now we will just create a base query using `from()` macro. 
`as: :article`  binds name `:article` to the from, which lets us not worry about keeping track of bindings positioning when composing the query. 

You can read more about named bindings [here](https://hexdocs.pm/ecto/Ecto.Query.html#module-named-bindings)

Now let's create our MyBlog context at `lib/blog/my_blog.ex`:

```elixir
defmodule Blog.MyBlog do
  alias Blog.Repo
  alias Blog.MyBlog.ArticleQueries

  def list_articles() do
    ArticleQueries.base() |> Repo.all()
  end
end
```
Here we're using alias in order to more easily reference different modules. We've created a list_articles function that takes no params, and will return all the articles in the database by using the `Repo.all()` containing our base query which is basically `* FROM Article`. We will use this list_articles function in the LiveView, rather than using Repo directly.

Let's update our actual Article page at `lib/blog_web/live/blog_live/article.ex`:
```elixir
defmodule BlogWeb.BlogLive.Article do
  use BlogWeb, :live_view
  alias Blog.MyBlog

  def mount(_params, _session, socket) do
    articles = MyBlog.list_articles()
    socket = assign(socket, :articles, Enum.reverse(articles))
    {:ok, socket}
  end
end
```

We retrieved the articles from the database using our list_articles function, then assigned them reversed  to our socket's assigns, which we can later access in our template directly with @assigned_name like @articles.

Let's update our template to show the titles of our articles in `lib/blog_web/live/blog_live/article.html.heex`:
```elixir
<h1 class="text-lg text-brand">
  Hello, LiveView!
</h1>

<ul class="pt-5">
  <li :for={article <- @articles}>
    <span class="font-bold"><%= article.title %></span>
  </li>
</ul>
```

Here we use the `:for` which is a syntax sugar for `<%= for .. do %>` to loop over the @articles assign and display every article's title.

Navigate to  [http://localhost:4000](http://localhost:4000/)  and see the articles we've created so far.

## 7 CRUDit Where CRUDit Is Due

Almost all web applications involve CRUD (Create, Read, Update, and Delete) operations. You may even find that the majority of the work your application does is CRUD. If you have read Andy's guide you might know that Phoenix acknowledges this, and provides many features to help simplify code doing CRUD. 
LiveView is similar, however instead of rendering different template inside the same controller depending on the action, the action is instead saved inside the socket's assigns and can be used to alter template. You can think of it this way: When the page uses very similar "view", but slightly modified like `/edit` action would add some kind of field to the template, that's when you should use the `@live_action` assign. However, when the templates differ too much from each other and using `@live_action` would require a lot of logic inside the same LiveView, then you should rather go for breaking it down into a separate LiveView.

Let's begin exploring these features by adding more functionality to our application.

### 7.1 Showing a Single Article

We currently have an index view that list all of our articles in our database. Let's add a new view that shows the title and body of a single article.

We start by creating a separate LiveView and it's template, then adding a new route that maps to it.

```elixir
# lib/blog_web/live/blog_live/view_article.ex | view_article.html.heex
defmodule BlogWeb.BlogLive.ViewArticle do
  use BlogWeb, :live_view
  alias Blog.MyBlog

  def mount(%{"id" => article_id}, _session, socket) do
    {:ok, socket}
  end
end
```

```elixir
  scope "/", BlogWeb do
    pipe_through :browser

    live "/", BlogLive.Article, :index
    live "/articles", BlogLive.Article, :index
    live "/articles/:id", BlogLive.ViewArticle, :show # Our new route with :id param
  end
```

The new route is another get route, just like every live_view but it has something extra in its path: :id. This designates a route  _parameter_. A route parameter captures a segment of the request's path, and puts that value in the params map. For example, when handling a request like GET http://localhost:4000/articles/1, 1 would be captured as the value for :id.

Let's update our ArticleQueries and MyBlog context with a function that retrieves an Article based on its primary key id:
```elixir
# lib/blog/my_blog/article_queries.ex
defmodule Blog.MyBlog.ArticleQueries do
  import Ecto.Query
  alias Blog.MyBlog.Article

  def with_id(query \\ base(), id) do
    query |> where([article: article], article.id == ^id)
  end

  def base() do
    from(Article, as: :article)
  end
end
```
Here we have just passed in our base query as default for first argument. The second argument is id which is then used inside `where` macro. This would basically translate to `SELECT * FROM Article where Article.id == id`.

```elixir
# lib/blog/my_blog.ex
defmodule Blog.MyBlog do
  alias Blog.Repo
  alias Blog.MyBlog.ArticleQueries

  def list_articles() do
    ArticleQueries.base() |> Repo.all()
  end

  def get_article_by_id(id) do
    ArticleQueries.with_id(id) |> Repo.one()
  end
end
```
Now let's load the actual article inside our LiveView:
``` elixir
# lib/blog_web/blog_live/view_article.ex
defmodule BlogWeb.BlogLive.ViewArticle do
  use BlogWeb, :live_view
  alias Blog.MyBlog

  def mount(%{"id" => article_id}, _session, socket) do
    socket =
      case MyBlog.get_article_by_id(article_id) do
        %MyBlog.Article{} = article ->
          assign(socket, :article, article)

        nil ->
          socket
          |> put_flash(:error, "Article does not exist")
          |> push_navigate(to: ~p"/articles")
      end

    {:ok, socket}
  end
end
```
Then inside our empty template:
```html
<!-- lib/blog_web/blog_live/view_article.html.heex -->
<h1><%= @article.title %></h1>
<p><%= @article.body %></p>
```

Now we can see the article when we visit  [http://localhost:4000/articles/1](http://localhost:4000/articles/1)!

To finish up, let's add a convenient way to get to an article's page. We'll link each article's title to its page:
```html
<!-- The template file: lib/blog_web/live/blog_live/article.html.heex -->
<h1 class="text-lg text-brand">
  Hello, LiveView!
</h1>

<ul class="pt-5">
  <li :for={article <- @articles}>
    <.link navigate={~p"/articles/#{article.id}"} class="font-bold"><%= article.title %></.link>
  </li>
</ul>
```
The [<.link>](https://hexdocs.pm/phoenix_live_view/Phoenix.Component.html#link/1) generates a link to the given route. The navigate attribute is used to navigate across LiveViews using [live_navigation](https://hexdocs.pm/phoenix_live_view/1.0.0-rc.6/live-navigation.html). To use regular browser navigation you would pass in href instead.

### 7.3 Creating a New Article

In LiveView, the 'C' (Create) of CRUD is streamlined into a more fluid, real-time process. Unlike traditional web applications that often require multiple page loads, LiveView allows the entire creation process to occur within a single view, updating dynamically.

First let's add two new alias functions change_article and create_article to the context:
```elixir
# lib/blog/my_blog.ex
defmodule Blog.MyBlog do
  alias Blog.MyBlog.Article
  alias Blog.Repo
  alias Blog.MyBlog.ArticleQueries

  def list_articles() do
    ArticleQueries.base() |> Repo.all()
  end

  def get_article_by_id(id) do
    ArticleQueries.with_id(id) |> Repo.one()
  end

  defdelegate change_article(article, changes), to: Article, as: :changeset
  defdelegate create_article(changeset), to: Repo, as: :insert
end
```
Then we'll add two handle_params callbacks inside our article index. One that matches the `:new` live_action and the second one that just matches all other cases. Inside the `:new` handle_params we create an article changeset from params and assign it.

```elixir
# lib/blog_web/live/blog_live/article.ex
defmodule BlogWeb.BlogLive.Article do
  alias Blog.MyBlog.Article
  use BlogWeb, :live_view
  alias Blog.MyBlog

  def handle_params(params, _url, %{assigns: %{live_action: :new}} = socket) do
    changeset = MyBlog.change_article(%Article{}, params)
    form = to_form(changeset, action: :validate)
    socket = socket |> assign(:changeset, changeset) |> assign(:form, form)
    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def mount(_params, _session, socket) do
    articles = MyBlog.list_articles()
    socket = assign(socket, :articles, Enum.reverse(articles))
    {:ok, socket}
  end
end
```

Then let's create a form for adding new articles

```elixir
# lib/blog_web/live/blog_live/article.html.heex
<h1 class="text-lg text-brand">
  Hello, LiveView!
</h1>

<.form
  :if={@live_action == :new}
  for={@changeset}
  phx-submit="submit_article"
  phx-change="edit_article"
>
  <.input phx-debounce={150} field={@form[:title]} label="Title" />
  <.input phx-debounce={150} field={@form[:body]} label="Body" />
  <.button>Publish</.button>
</.form>

<ul class="pt-5">
  <li :for={article <- @articles}>
    <.link navigate={~p"/articles/#{article.id}"} class="font-bold"><%= article.title %></.link>
  </li>
</ul>
```
The `phx-debounce` on every input is a timeout value before event gets sent after user stops typing. Then, we use the `phx-submit` and `phx-change` events, that will trigger the appropriate callbacks. So let's add them:
```elixir
# lib/blog_web/live/blog_live/article.ex
defmodule BlogWeb.BlogLive.Article do
  alias Blog.MyBlog.Article
  use BlogWeb, :live_view
  alias Blog.MyBlog

  def handle_event("submit_article", _params, socket) do
    changeset = socket.assigns.changeset

    socket =
      case MyBlog.create_article(changeset) do
        {:ok, article} ->
          socket
          |> put_flash(:info, "Article created successfully.")
          |> assign(:articles, [article | socket.assigns.articles])
          |> push_patch(to: ~p"/articles")

        {:error, %Ecto.Changeset{} = _changeset} ->
          put_flash(socket, :error, "There was an error in publishing article")
      end

    {:noreply, socket}
  end

  def handle_event("edit_article", %{"article" => %{"title" => title, "body" => body}}, socket) do
    params = %{body: body, title: title}
    {:noreply, push_patch(socket, to: ~p"/articles/new?#{params}")}
  end

  def handle_params(params, _url, %{assigns: %{live_action: :new}} = socket) do
    changeset = MyBlog.change_article(%Article{}, params)
    form = to_form(changeset, action: :validate)
    socket = socket |> assign(:changeset, changeset) |> assign(:form, form)
    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def mount(_params, _session, socket) do
    articles = MyBlog.list_articles()
    socket = assign(socket, :articles, Enum.reverse(articles))
    {:ok, socket}
  end
end
```

The `edit_article` receives the params based on our input names and values. We match the title and body, then put them inside our url via `push_patch` which triggers the `handle_params` essentially creating and assigning a new article changeset. Then the `submit_article` which is triggered by form submit, attempts to create the article. In case of success it displays a [flash message](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html#put_flash/3) with success, prepends the new article to the articles assign without having to retrieve them from database again and returns us to the `:index` live_action. On failure we don't have to do much aside of displaying a failure message via flash.

#### 7.3.1 Validations and Displaying Error Messages
Try creating a new article without a title or body. You should see `can't be blank` error messages under the title input and body input. These validations for the article `title` and `body` field were created for us in the schema that was generated when we ran `mix phx.gen.schema`. Open `lib/blog/my_blog/article.ex` and notice the usage of `validate_required` in the `changeset` function:
```elixir
defmodule Blog.MyBlog.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :body, :string
    field :title, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end
```
Let's add an additional length check validation to the `body` field in `lib/blog/my_blog/article.ex`:
```elixir
defmodule Blog.MyBlog.Article do
  use Ecto.Schema
  import Ecto.Changeset

  schema "articles" do
    field :body, :string
    field :title, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> validate_length(:body, min: 10)
  end
end
```


#### 7.3.1 Finishing up
We can now create an article by visiting [http://localhost:4000/articles/new](http://localhost:4000/articles/new). To finish up, let's remove the max-w in the div encapsulating our inner content and link to articles pages from the application layout header:
```html
 <!-- lib/blog_web/components/layouts/app.html.heex -->
<header class="px-4 sm:px-6 lg:px-8">
  <div class="flex items-center justify-between border-b border-zinc-100 py-3 text-sm">
    <div class="flex items-center gap-4">
      <.link navigate="/">
        <img src={~p"/images/logo.svg"} width="36" />
      </.link>
      <.link class="m-4" patch={~p"/articles"}>Articles</.link>
      <.link class="m-4" patch={~p"/articles/new"}>New Article</.link>

      <p class="bg-brand/5 text-brand rounded-full px-2 font-medium leading-6">
        v<%= Application.spec(:phoenix, :vsn) %>
      </p>
    </div>
    <div class="flex items-center gap-4 font-semibold leading-6 text-zinc-900">
      <a href="https://twitter.com/elixirphoenix" class="hover:text-zinc-700">
        @elixirphoenix
      </a>
      <a href="https://github.com/phoenixframework/phoenix" class="hover:text-zinc-700">
        GitHub
      </a>
      <a
        href="https://hexdocs.pm/phoenix/overview.html"
        class="rounded-lg bg-zinc-100 px-2 py-1 hover:bg-zinc-200/80"
      >
        Get Started <span aria-hidden="true">&rarr;</span>
      </a>
    </div>
  </div>
</header>
<main class="px-4 py-20 sm:px-6 lg:px-8">
   <div class="mx-auto">
    <.flash_group flash={@flash} />
    <%= @inner_content %>
  </div>
</main>
```
## 7.4 Updating an Article

We've covered the "CR" of CRUD. Now let's move on to the "U" (Update). Updating a resource is very similar to creating a resource. The user opens a form, edits the data, and once it's validated, submits it.

Let's start by adding a simple update alias function to our context:
```elixir
# lib/blog/my_blog.ex
defmodule Blog.MyBlog do
  alias Blog.MyBlog.Article
  alias Blog.Repo
  alias Blog.MyBlog.ArticleQueries

  def list_articles() do
    ArticleQueries.base() |> Repo.all()
  end

  def get_article_by_id(id) do
    ArticleQueries.with_id(id) |> Repo.one()
  end

  defdelegate change_article(article, changes), to: Article, as: :changeset
  defdelegate create_article(changeset), to: Repo, as: :insert
  defdelegate update_article(changeset), to: Repo, as: :update
end
```

Now to get to actual editing let's add a new route action to our ViewArticle LiveView that will handle the editing:
```elixir
# lib/blog_web/router.ex
  scope "/", BlogWeb do
    pipe_through :browser

    live "/", BlogLive.Article, :index

    scope "/articles" do
      live "/", BlogLive.Article, :index
      live "/new", BlogLive.Article, :new
      live "/:id", BlogLive.ViewArticle, :show
      live "/:id/edit", BlogLive.ViewArticle, :edit
    end
  end
```
You might notice that we have also added scope for "/articles", this just lets us avoid adding the "/articles" to every route inside the scope.

Now adding edit option in our LiveView is very similar to what we did in create. Instead of calling `create_article` we do `update_article` and re-assign our article on success:
```elixir
# lib/blog_web/live/blog_live/view_article.ex
defmodule BlogWeb.BlogLive.ViewArticle do
  use BlogWeb, :live_view
  alias Blog.MyBlog

  def handle_event("submit_article", _params, socket) do
    changeset = socket.assigns.changeset

    socket =
      case MyBlog.update_article(changeset) do
        {:ok, article} ->
          socket
          |> put_flash(:info, "Article edited successfully.")
          |> assign(:article, article)
          |> push_patch(to: ~p"/articles/#{article.id}")

        {:error, %Ecto.Changeset{} = _changeset} ->
          put_flash(socket, :error, "There was an error in publishing the edit")
      end

    {:noreply, socket}
  end

  def handle_event("edit_article", %{"article" => %{"title" => title, "body" => body}}, socket) do
    params = %{body: body, title: title}
    {:noreply, push_patch(socket, to: ~p"/articles/#{socket.assigns.article.id}/edit?#{params}")}
  end

  def handle_params(params, _url, %{assigns: %{live_action: :edit, article: article}} = socket) do
    changeset = MyBlog.change_article(article, params)
    form = to_form(changeset, action: :validate)
    socket = socket |> assign(:changeset, changeset) |> assign(:form, form)
    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def mount(%{"id" => article_id}, _session, socket) do
    socket =
      case MyBlog.get_article_by_id(article_id) do
        %MyBlog.Article{} = article ->
          assign(socket, :article, article)

        nil ->
          socket
          |> put_flash(:error, "Article does not exist")
          |> push_navigate(to: ~p"/articles")
      end

    {:ok, socket}
  end
end
```
The form inside template stays exact same as inside the article index. I also added the edit button:
```html 
<!-- lib/blog_web/live/blog_live/view_article.html.heex -->
<.form
  :if={@live_action == :edit}
  for={@changeset}
  phx-submit="submit_article"
  phx-change="edit_article"
>
  <.input phx-debounce={150} field={@form[:title]} label="Title" />
  <.input phx-debounce={150} field={@form[:body]} label="Body" />
  <.button>Publish edit</.button>
</.form>

<h1><%= @article.title %></h1>
<p><%= @article.body %></p>
```
And that's it, as shrimple as that! We can now edit the article.

### 7.5 Deleting an Article
Finally, we arrive at the "D" (Delete) of CRUD. Deleting a resource is a simpler process than creating or updating. Let's begin by adding an alias to delete an article:
```elixir
# lib/blog/my_blog.ex
defmodule Blog.MyBlog do
  alias Blog.MyBlog.Article
  alias Blog.Repo
  alias Blog.MyBlog.ArticleQueries

  def list_articles() do
    ArticleQueries.base() |> Repo.all()
  end

  def get_article_by_id(id) do
    ArticleQueries.with_id(id) |> Repo.one()
  end

  defdelegate change_article(article, changes), to: Article, as: :changeset
  defdelegate create_article(changeset), to: Repo, as: :insert
  defdelegate update_article(changeset), to: Repo, as: :update
  defdelegate delete_article(article), to: Repo, as: :delete
end
```
Then we add a button with client-side confirmation using `data-confirm` and a handle_event callback:
```elixir
# lib/blog_web/live/blog_live/view_article.ex 
defmodule BlogWeb.BlogLive.ViewArticle do
  use BlogWeb, :live_view
  alias Blog.MyBlog

  def handle_event("delete_article", _params, socket) do
    article = socket.assigns.article
    {:ok, _article} = MyBlog.delete_article(article)

    socket =
      socket
      |> put_flash(:info, "Article successfully deleted")
      |> push_navigate(to: "/articles")

    {:noreply, socket}
  end

  def handle_event("submit_article", _params, socket) do
    changeset = socket.assigns.changeset

    socket =lib/blog_web/live/blog_live/view_article.ex
      case MyBlog.update_article(changeset) do
        {:ok, article} ->
          socket
          |> put_flash(:info, "Article edited successfully.")
          |> assign(:article, article)
          |> push_patch(to: ~p"/articles/#{article.id}")

        {:error, %Ecto.Changeset{} = _changeset} ->
          put_flash(socket, :error, "There was an error in publishing the edit")
      end

    {:noreply, socket}
  end

  def handle_event("edit_article", %{"article" => %{"title" => title, "body" => body}}, socket) do
    params = %{body: body, title: title}
    {:noreply, push_patch(socket, to: ~p"/articles/#{socket.assigns.article.id}/edit?#{params}")}
  end

  def handle_params(params, _url, %{assigns: %{live_action: :edit, article: article}} = socket) do
    changeset = MyBlog.change_article(article, params)
    form = to_form(changeset, action: :validate)
    socket = socket |> assign(:changeset, changeset) |> assign(:form, form)
    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def mount(%{"id" => article_id}, _session, socket) do
    socket =
      case MyBlog.get_article_by_id(article_id) do
        %MyBlog.Article{} = article ->
          assign(socket, :article, article)

        nil ->
          socket
          |> put_flash(:error, "Article does not exist")
          |> push_navigate(to: ~p"/articles")
      end

    {:ok, socket}
  end
end
```
```html
<!-- lib/blog_web/live/blog_live/view_article.html.heex -->
...

  <button phx-click="delete_article" data-confirm={"Deleting '#{@article.title}'! Are you sure?"}>
    Delete
  </button>

...
```
And that's it! We can now list, show, create, update, and delete articles! InCRUDable!

## 8 Adding a Second Model

It's time to add a second model to the application. The second model will handle comments on articles.

### 8.1 Generating a Model

We're going to see the same generator that we used before when creating the Article model. This time we'll create a Comment model to hold a reference to an article. Run this command in your terminal:
```
$ mix phx.gen.context MyBlog Comment comments commenter:string body:text article_id:references:articles
```

It will ask you if you want to add functions to the existing context:

You are generating into an existing context.

```
The Blog.MyBlog context currently has 6 functions and 1 file in its directory.

  * It's OK to have multiple resources in the same context as long as they are closely related. But if a context grows too large, consider breaking it apart
	* If they are not closely related, another context probably works better
The fact two entities are related in the database does not mean they belong to the same context.
If you are not sure, prefer creating a new context over adding to the existing one.
Would you like to proceed? [Yn] 
```
We want to put the new `Comments` model in the same context as the existing `Article` model. Press enter.
It will create new files and add to existing files:
```
* creating lib/blog/my_blog/comment.ex
* creating priv/repo/migrations/20240716162307_create_comments.exs
* injecting lib/blog/my_blog.ex
* creating test/blog/my_blog_test.exs
* injecting test/blog/my_blog_test.exs
* creating test/support/fixtures/my_blog_fixtures.ex
* injecting test/support/fixtures/my_blog_fixtures.ex

Remember to update your repository by running migrations:

    $ mix ecto.migrate
```
> ⚠️ See what files are generated for each of the `mix phx.gen` commands [in the docs here](https://hexdocs.pm/phoenix/Mix.Tasks.Phx.Gen.html).

First, take a look at the `Comment` model, located at `lib/blog/my_blog/comment.ex`:
```elixir
defmodule Blog.MyBlog.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :body, :string
    field :commenter, :string
    field :article_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:commenter, :body])
    |> validate_required([:commenter, :body])
    
  end
end
```
In addition to the model, Phoenix has also made a migration to create the corresponding database table:
```elixir
defmodule Blog.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :commenter, :string
      add :body, :text
      add :article_id, references(:articles, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:article_id])
  end
end
```
The `article_id` field is used to reference the `id` field on the `articles` table.

Let's make one small change to the `article_id` field for the `on_delete` and `null` options to keep data consistent.
```elixir
defmodule Blog.Repo.Migrations.CreateComments do
  use Ecto.Migration

  def change do
    create table(:comments) do
      add :commenter, :string
      add :body, :text
      add :article_id, references(:articles, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create index(:comments, [:article_id])
  end
end
```
This will help keep out database clean, so when an article gets deleted, the associated comments for that article also gets deleted. The `delete_all` option will prevent comments from existing in the database without an article existing and the `null: false` prevents from adding a comment without article.

Go ahead and run the migration:
```mix ecto.migrate```
Phoenix is smart enough to only execute the migrations that have not already been run against the current database, so in this case you will just see:
```elixir
19:34:36.984 [info] == Running 20240714093903 Blog.Repo.Migrations.CreateArticles.change/0 forward

19:34:36.986 [info] create table articles

19:34:36.993 [info] == Migrated 20240714093903 in 0.0s

19:34:37.020 [info] == Running 20240716162307 Blog.Repo.Migrations.CreateComments.change/0 forward

19:34:37.020 [info] create table comments

19:34:37.020 [info] create index comments_article_id_index

19:34:37.020 [info] == Migrated 20240716162307 in 0.0s
```
### 8.2 Associating Models

Ecto associations let you easily declare the relationship between two models. In the case of comments and articles, you could write out the relationships this way:

-   Each comment belongs to one article.
-   One article can have many comments.

In fact, this is very close to the syntax that Ecto uses to declare this association. Let's modify the `Comment` model to make each comment belong_to an `Article`:

Update the `Comment` model located at `lib/blog/my_blog/comment.ex` with this:
```elixir
defmodule Blog.MyBlog.Comment do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.MyBlog.Article

  schema "comments" do
    field :body, :string
    field :commenter, :string
    belongs_to :article, Article

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(comment, attrs) do
    comment
	  |> cast(attrs, [:commenter, :body, :article_id])
    |> validate_required([:commenter, :body, :article_id])
    |> assoc_constraint(:article)
  end
end
```
You'll need to edit `lib/blog/my_blog/article.ex` to add the other side of the association:
```elixir
defmodule Blog.MyBlog.Article do
  use Ecto.Schema
  import Ecto.Changeset
  alias Blog.MyBlog.Comment

  schema "articles" do
    field :title, :string
    field :body, :string
    has_many :comments, Comment

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(article, attrs) do
    article
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
    |> validate_length(:body, min: 10)
  end
end
```
> ⚠️ For more information on Ecto associations, see the [Ecto Assocations](https://hexdocs.pm/ecto/2.2.11/associations.html#one-to-many) guide.

Let's test the relationship in `iex`:
```elixir
iex(8)> alias Blog.MyBlog.Article
Blog.MyBlog.Article
iex(9)> article = %Article{title: "test article", body: "has many comments"}
%Blog.MyBlog.Article{
  __meta__: #Ecto.Schema.Metadata<:built, "articles">,
  id: nil,
  body: "has many comments",
  title: "test article",
  comments: #Ecto.Association.NotLoaded<association :comments is not loaded>,
  inserted_at: nil,
  updated_at: nil
}
iex(10)> alias Blog.Repo
Blog.Repo
iex(11)> article = Repo.insert!(article)
[debug] QUERY OK source="articles" db=0.2ms idle=1632.2ms
INSERT INTO "articles" ("body","title","inserted_at","updated_at") VALUES (?,?,?,?) RETURNING "id" ["has many comments", "test article", ~U[2024-07-16 17:46:38Z], ~U[2024-07-16 17:46:38Z]]
↳ :elixir.eval_external_handler/3, at: elixir.erl:386
%Blog.MyBlog.Article{
  __meta__: #Ecto.Schema.Metadata<:loaded, "articles">,
  id: 2,
  body: "has many comments",
  title: "test article",
  comments: #Ecto.Association.NotLoaded<association :comments is not loaded>,
  inserted_at: ~U[2024-07-16 17:46:38Z],
  updated_at: ~U[2024-07-16 17:46:38Z]
}
```
Then let's create a comment for the article we just created:
```elixir
iex(13)> comment = Ecto.build_assoc(article, :comments, %{commenter: "First commenter", body: "Sweet article"})
%Blog.MyBlog.Comment{
  __meta__: #Ecto.Schema.Metadata<:built, "comments">,
  id: nil,
  body: "Sweet article",
  commenter: "First commenter",
  article_id: 2,
  article: #Ecto.Association.NotLoaded<association :article is not loaded>,
  inserted_at: nil,
  updated_at: nil
}
iex(14)>  Repo.insert!(comment)
[debug] QUERY OK source="comments" db=0.2ms idle=1034.2ms
INSERT INTO "comments" ("article_id","body","commenter","inserted_at","updated_at") VALUES (?,?,?,?,?) RETURNING "id" [2, "Sweet article", "First commenter", ~U[2024-07-16 17:47:29Z], ~U[2024-07-16 17:47:29Z]]
↳ :elixir.eval_external_handler/3, at: elixir.erl:386
%Blog.MyBlog.Comment{
  __meta__: #Ecto.Schema.Metadata<:loaded, "comments">,
  id: 1,
  body: "Sweet article",
  commenter: "First commenter",
  article_id: 2,
  article: #Ecto.Association.NotLoaded<association :article is not loaded>,
  inserted_at: ~U[2024-07-16 17:47:29Z],
  updated_at: ~U[2024-07-16 17:47:29Z]
}
```
Let's see if it worked:
```elixir
iex(16)> Repo.get(Article, article.id) |> Repo.preload(:comments)
[debug] QUERY OK source="articles" db=0.0ms idle=1531.9ms
SELECT a0."id", a0."body", a0."title", a0."inserted_at", a0."updated_at" FROM "articles" AS a0 WHERE (a0."id" = ?) [2]
↳ :elixir.eval_external_handler/3, at: elixir.erl:386
[debug] QUERY OK source="comments" db=0.0ms idle=1532.3ms
SELECT c0."id", c0."body", c0."commenter", c0."article_id", c0."inserted_at", c0."updated_at", c0."article_id" FROM "comments" AS c0 WHERE (c0."article_id" = ?) ORDER BY c0."article_id" [2]
↳ :elixir.eval_external_handler/3, at: elixir.erl:386
%Blog.MyBlog.Article{
  __meta__: #Ecto.Schema.Metadata<:loaded, "articles">,
  id: 2,
  body: "has many comments",
  title: "test article",
  comments: [
    %Blog.MyBlog.Comment{
      __meta__: #Ecto.Schema.Metadata<:loaded, "comments">,
      id: 1,
      body: "Sweet article",
      commenter: "First commenter",
      article_id: 2,
      article: #Ecto.Association.NotLoaded<association :article is not loaded>,
      inserted_at: ~U[2024-07-16 17:47:29Z],
      updated_at: ~U[2024-07-16 17:47:29Z]
    }
  ],
  inserted_at: ~U[2024-07-16 17:46:38Z],
  updated_at: ~U[2024-07-16 17:46:38Z]
}
```
In the example above, Ecto.build_assoc received an existing article struct, that was already persisted to the database, and built a Comment struct, based on its :comments association, with the article_id foreign key field properly set to the ID in the article struct.

### 8.3 Adding Comments to our Articles

Let's begin by adding simple queries for our comments in `lib/blog/my_blog/comment_queries.ex`:
```elixir
defmodule Blog.MyBlog.CommentQueries do
  import Ecto.Query
  alias Blog.MyBlog.Comment

  def with_id(query \\ base(), id) do
    query |> where([comment: comment], comment.id == ^id)
  end

  def with_article_id(query \\ base(), article_id) do
    query |> where([comment: comment], comment.article_id == ^article_id)
  end

  def base() do
    from(Comment, as: :comment)
  end
end
```
then declare the functions/aliases in our context:
```elixir
# lib/blog/my_blog.ex
defmodule Blog.MyBlog do
  alias Blog.Repo
  alias Blog.MyBlog.Article
  alias Blog.MyBlog.Comment
  alias Blog.MyBlog.CommentQueries
  alias Blog.MyBlog.ArticleQueries

  def list_articles(limit \\ 10) do
    ArticleQueries.base() |> Repo.all(limit: limit)
  end

  def get_article_by_id(id) do
    ArticleQueries.with_id(id) |> Repo.one()
  end

  defdelegate change_article(article, changes), to: Article, as: :changeset
  defdelegate create_article(changeset), to: Repo, as: :insert
  defdelegate update_article(changeset), to: Repo, as: :update
  defdelegate delete_article(article), to: Repo, as: :delete

  def list_comments(limit \\ 10) do
    CommentQueries.base() |> Repo.all(limit: limit)
  end

  def get_comment_by_id(id) do
    CommentQueries.with_id(id) |> Repo.one()
  end

  def get_article_comments(article_id, limit \\ 10) do
    CommentQueries.with_article_id(article_id) |> Repo.all(limit: limit)
  end

  defdelegate change_comment(comment, changes), to: Comment, as: :changeset
  defdelegate create_comment(changeset), to: Repo, as: :insert
  defdelegate update_comment(changeset), to: Repo, as: :update
  defdelegate delete_comment(comment), to: Repo, as: :delete
end
```
Now let's add comments live_action to our ViewArticle LiveView:
```elixir
# lib/blog_web/router.ex
...

  scope "/articles" do
    live "/", BlogLive.Article, :index
    live "/new", BlogLive.Article, :new
    live "/:id", BlogLive.ViewArticle, :show
    live "/:id/edit", BlogLive.ViewArticle, :edit
    live "/:id/comments", BlogLive.ViewArticle, :comments
  end
 
 ...
```
Now we'll add handle_params for our `:comments` action and events needed to handle creating/loading comments:
```elixir
# lib/blog_web/live/blog_live/view_article.ex
defmodule BlogWeb.BlogLive.ViewArticle do
  alias Blog.MyBlog.Comment
  use BlogWeb, :live_view
  alias Blog.MyBlog

 ...
  def handle_event("delete_comment", %{"value" => id}, socket) do
    comments =
      socket.assigns.comments
      |> Enum.reject(fn comment ->
        unless to_string(comment.id) != id, do: MyBlog.delete_comment(comment)
      end)

    {:noreply, assign(socket, :comments, comments)}
  end

  def handle_event("submit_comment", _params, socket) do
    article = socket.assigns.article
    changeset = socket.assigns.changeset

    socket =
      case MyBlog.create_comment(changeset) do
        {:ok, comment} ->
          socket
          |> put_flash(:info, "Comment created!")
          |> assign(:comments, [comment | socket.assigns.comments])
          |> push_patch(to: ~p"/articles/#{article.id}/comments")

        {:error, %Ecto.Changeset{} = _changeset} ->
          put_flash(socket, :error, "There was an error in publishing the comment")
      end

    {:noreply, socket}
  end

  def handle_event(
        "change_comment",
        %{"comment" => %{"commenter" => commenter, "body" => body}},
        socket
      ) do
    params = %{body: body, commenter: commenter}

    {:noreply,
     push_patch(socket, to: ~p"/articles/#{socket.assigns.article.id}/comments?#{params}")}
  end

  def handle_params(params, _url, %{assigns: %{live_action: :edit, article: article}} = socket) do
    changeset = MyBlog.change_article(article, params)
    form = to_form(changeset, action: :validate)
    socket = socket |> assign(:changeset, changeset) |> assign(:form, form)
    {:noreply, socket}
  end

  def handle_params(
        params,
        url,
        %{assigns: %{live_action: :comments, comments: nil, article: article}} = socket
      ) do
    comments = article.id |> MyBlog.get_article_comments() |> Enum.reverse()
    handle_params(params, url, assign(socket, :comments, comments))
  end

  def handle_params(
        params,
        _url,
        %{assigns: %{live_action: :comments, article: article}} = socket
      ) do
    changeset =
      MyBlog.change_comment(%Comment{}, Map.put(params, "article_id", article.id))

    form = to_form(changeset, action: :validate)

    socket =
      socket
      |> assign(:changeset, changeset)
      |> assign(:form, form)

    {:noreply, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def mount(%{"id" => article_id}, _session, socket) do
    socket =
      case MyBlog.get_article_by_id(article_id) do
        %MyBlog.Article{} = article ->
          socket
          |> assign(:comments, nil)
          |> assign(:article, article)

        nil ->
          socket
          |> put_flash(:error, "Article does not exist")
          |> push_navigate(to: ~p"/articles")
      end

    {:ok, socket}
  end
end
```

Now all we have to do is render our comments/form and add a `.link` for viewing comments:
```html

<!-- lib/blog_web/live/blog_live/view_article.ex -->
<.form
  :if={@live_action == :edit}
  for={@changeset}
  phx-submit="submit_article"
  phx-change="edit_article"
>
  <.input phx-debounce={150} field={@form[:title]} label="Title" />
  <.input phx-debounce={150} field={@form[:body]} label="Body" />
  <.button>Publish edit</.button>
</.form>
<div :if={@live_action in [:show, :comments]} class="flex flex-row items-center my-4 gap-x-4">
  <.link patch={~p"/articles/#{@article.id}/comments"}>Comments</.link>
  <.link patch={~p"/articles/#{@article.id}/edit"}>Edit</.link>
  <button phx-click="delete_article" data-confirm={"Deleting '#{@article.title}'! Are you sure?"}>
    Delete
  </button>
</div>
<h1><%= @article.title %></h1>
<p><%= @article.body %></p>

<div :if={@live_action == :comments}>
  <.form for={@changeset} phx-submit="submit_comment" phx-change="change_comment">
    <.input phx-debounce={150} field={@form[:commenter]} label="Nickname" />
    <.input phx-debounce={150} field={@form[:body]} label="Body" />
    <.button>Publish</.button>
  </.form>
  <ul>
    <li :for={comment <- @comments}>
	    <button phx-click="delete_comment" value={comment.id} class="absolute right-2 top-1">
	    X
      </button>

      <h3 class="font-semibold">by: <%= comment.commenter %></h3>
      <p><%= comment.body %></p>
    </li>
  </ul>
</div>
```
Now we are able to view, create and delete comments under our Article.

## 9 Cleanup
Now that we have articles and comments working, let's make it less-awful looking.
```html
<!-- The template file: lib/blog_web/live/blog_live/article.html.heex -->
<h1 class="text-3xl text-brand mb-8 -mt-8">
  Hello, LiveView!
</h1>
<div class="flex flex-row justify-between gap-x-10">
  <div :if={@live_action == :new} class="flex flex-col gap-y-8 w-2/3 flex-wrap">
    <h1 class="text-lg text-brand">Preview</h1>
    <h2 class="font-bold text-2xl"><%= @changeset.changes[:title] %></h2>
    <p class="text-lg whitespace-pre-line"><%= @changeset.changes[:body] %></p>
  </div>
  <ul
    :if={@live_action == :index}
    class="flex flex-col gap-y-4 overflow-y-auto h-full duration-100 transition-all w-full"
  >
    <li
      :for={article <- @articles}
      class="rounded border-gray-300 border h-12 flex items-center justify-between px-4 gap-x-5"
    >
      <span class="font-bold flex-1 line-clamp-2"><%= article.title %></span>
      <.link
        navigate={~p"/articles/#{article.id}"}
        class="text-gray-600 hover:text-gray-300 transition italic"
      >
        Read more
      </.link>
    </li>
  </ul>
  <.form
    :if={@live_action == :new}
    for={@changeset}
    class="w-1/3 flex flex-col gap-y-2 mt-8"
    phx-submit="submit_article"
    phx-change="edit_article"
  >
    <.input phx-debounce={150} field={@form[:title]} placeholder="Title" />
    <.input type="textarea" phx-debounce={150} field={@form[:body]} placeholder="Body" />
    <.button class="transition w-1/5 mx-auto">Publish</.button>
  </.form>
</div>
```
```html
<!-- The template file: lib/blog_web/live/blog_live/view_article.html.heex -->
<div class="flex flex-row justify-between">
  <div class="flex flex-col gap-y-8 w-3/4 mx-auto">
    <div :if={@live_action in [:show, :comments]} class="flex flex-row justify-between">
      <div class="flex flex-row gap-x-4">
        <.link
          class="rounded border px-2 py-1 border-gray-300 text-lg hover:bg-purple-300 transition duration-300"
          patch={~p"/articles/#{@article.id}/edit"}
        >
          Edit
        </.link>
        <button
          class="rounded border px-2 py-1 border-gray-300 text-lg hover:bg-red-300 transition duration-300"
          phx-click="delete_article"
          data-confirm={"Deleting '#{@article.title}'! Are you sure?"}
        >
          Delete
        </button>
      </div>
      <.link
        :if={!@comments}
        class="rounded border px-2 py-1 border-gray-300 text-lg hover:bg-blue-300 transition duration-300"
        patch={~p"/articles/#{@article.id}/comments"}
      >
        Comments
      </.link>
    </div>

    <article
      :if={@live_action == :edit}
      class="flex flex-col gap-y-4 border border-gray-300 rounded p-4 w-fit min-w-96"
    >
      <h1 class="font-bold text-xl"><%= @changeset.changes[:title] || @article.title %></h1>
      <p class="whitespace-pre-line text-lg"><%= @changeset.changes[:body] || @article.body %></p>
    </article>
    <article
      :if={@live_action != :edit}
      class="flex flex-col gap-y-4 border border-gray-300 rounded p-4 "
    >
      <h1 class="font-bold text-xl"><%= @article.title %></h1>
      <p class="whitespace-pre-line text-lg"><%= @article.body %></p>
    </article>
  </div>
  <.form
    :if={@live_action == :edit}
    for={@changeset}
    class="flex flex-col gap-y-4 w-1/3 ml-8"
    phx-submit="submit_article"
    phx-change="edit_article"
  >
    <.input phx-debounce={150} field={@form[:title]} placeholder="Title" />
    <.input phx-debounce={150} type="textarea" field={@form[:body]} placeholder="Body" />
    <div class="flex flex-row gap-x-2 justify-center items-center">
      <.button>Publish edit</.button>
      <.link
        class="rounded-lg border-gray-300 border hover:bg-red-300 transition px-4 py-1.5 bg-red-100"
        patch={~p"/articles/#{@article.id}"}
      >
        Cancel
      </.link>
    </div>
  </.form>

  <div
    :if={@comments && @live_action in [:show, :comments]}
    class="ml-8 w-1/4 gap-y-4 flex flex-col"
  >
    <.form
      for={@changeset}
      class="flex flex-col gap-y-2"
      phx-submit="submit_comment"
      phx-change="change_comment"
    >
      <.input phx-debounce={150} field={@form[:commenter]} placeholder="Nickname" />
      <.input phx-debounce={150} type="textarea" field={@form[:body]} placeholder="Body" />
      <.button class="w-1/4 self-center transition">Comment</.button>
    </.form>
    <ul class="gap-y-4 flex flex-col">
      <li
        :for={comment <- @comments}
        class="min-h-12 rounded border border-gray-300 px-4 py-2 relative"
      >
        <button phx-click="delete_comment" value={comment.id} class="absolute right-2 top-1">
          X
        </button>
        <h3 class="font-semibold"><%= comment.commenter %></h3>
        <hr />
        <p class="whitespace-pre-line"><%= comment.body %></p>
      </li>
    </ul>
  </div>
</div>
```

## 10 Handle Asyncs
But what if the data that we load comes from an external API that's really slow and we want to load the whole page without waiting for it? This is where LiveViews `start_async` and `async_assign` come in hand.
Let's use the `start_async` which uses `handle_async` callback first. In our main `article.ex` instead of loading articles directly inside mount, we will call the `start_async` and add a 2 second delay to simulate slow loading:
```elixir
	defmodule BlogWeb.BlogLive.Article do
  alias Phoenix.LiveView.AsyncResult
  alias Blog.MyBlog.Article
  use BlogWeb, :live_view
  alias Blog.MyBlog

  ...
	
  def handle_async(:load_articles, {:ok, articles}, socket) do
    articles = articles |> Enum.reverse() |> AsyncResult.ok()
    {:noreply, assign(socket, :articles, articles)}
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:articles, AsyncResult.loading())
      |> start_async(:load_articles, fn ->
        :timer.sleep(2_000)
        MyBlog.list_articles()
      end)

    {:ok, socket}
  end
end
```
Now let's update the article list in our template to handle the AsyncResult struct properly:
```html
...

 <ul
    :if={@live_action == :index && @articles.ok?}
    class="flex flex-col gap-y-4 overflow-y-auto h-full duration-100 transition-all w-full"
  >
    <li
      :for={article <- @articles.result}
      class="rounded border-gray-300 border h-12 flex items-center justify-between px-4 gap-x-5"
    >
      <span class="font-bold flex-1 line-clamp-2"><%= article.title %></span>
      <.link
        navigate={~p"/articles/#{article.id}"}
        class="text-gray-600 hover:text-gray-300 transition italic"
      >
        Read more
      </.link>
    </li>
</ul>


...
```

You can now see that page loads and socket connects right away. After 2 seconds all of our articles pop-up.

A different approach to this would be using the `assign_async`. This doesn't trigger any callbacks and should be used when you don't need to do anything else with data but just assign it. Let's remove the `handle_async` and `start_async` and use the `assign_async` in our mount instead:

```elixir
  defp list_with_delay() do
    :timer.sleep(2_000)
    MyBlog.list_articles()
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:articles, AsyncResult.loading())
      |> assign_async(:articles, fn -> {:ok, %{articles: list_with_delay()}} end)

    {:ok, socket}
  end

```
The assign_async creates AsyncResult struct itself. So we don't have to declare it ourselves. The values get assigned based on the returned Map. So when you would like to return and assign multiple values, all you have to do is:
```elixir
assign_async([:articles, :images], fn -> {:ok, %{articles: list_with_delay(), images: load_images()}} end)
```

