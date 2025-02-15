defmodule BlogWeb.BlogLive.Article do
  alias Blog.Repo
  alias Phoenix.LiveView.AsyncResult
  alias Blog.MyBlog.Article
  use BlogWeb, :live_view
  alias Blog.MyBlog

  def handle_event("submit_article", _params, socket) do
    changeset = Map.put(socket.assigns.form.source, :action, :insert)

    socket =
      case Repo.insert(changeset) do
        {:ok, article} ->
          socket
          |> put_flash(:info, "Article created successfully.")
          |> assign(:articles, AsyncResult.ok([article | socket.assigns.articles.result]))
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
    form =
      %Article{}
      |> MyBlog.change_article(params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, :form, form)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_async(:load_articles, {:ok, articles}, socket) do
    articles = articles |> Enum.reverse() |> AsyncResult.ok()
    {:noreply, assign(socket, :articles, articles)}
  end

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(:articles, AsyncResult.ok([]) |> AsyncResult.loading())
      |> start_async(:load_articles, fn ->
        :timer.sleep(2_000)
        MyBlog.list_articles()
      end)

    # |> assign_async(:articles, fn -> {:ok, %{articles: MyBlog.list_articles()}} end)

    {:ok, socket}
  end
end
