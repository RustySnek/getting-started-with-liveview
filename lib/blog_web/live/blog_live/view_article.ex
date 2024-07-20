defmodule BlogWeb.BlogLive.ViewArticle do
  alias Blog.MyBlog.Comment
  use BlogWeb, :live_view
  alias Blog.MyBlog
  alias Blog.Repo

  def handle_event("delete_article", _params, socket) do
    article = socket.assigns.article
    {:ok, _article} = Repo.delete(article)

    socket =
      socket
      |> put_flash(:info, "Article successfully deleted")
      |> push_navigate(to: "/articles")

    {:noreply, socket}
  end

  def handle_event("submit_article", _params, socket) do
    changeset = Map.put(socket.assigns.form.source, :action, :update)

    socket =
      case Repo.update(changeset) do
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

  def handle_event("delete_comment", %{"value" => id}, socket) do
    case MyBlog.get_comment_by_id(id) do
      nil -> :ok
      comment -> Repo.delete(comment)
    end

    comments =
      socket.assigns.comments |> Enum.reject(&(to_string(Map.get(&1, :id)) == id)) |> dbg

    {:noreply, assign(socket, :comments, comments)}
  end

  def handle_event("submit_comment", _params, socket) do
    article = socket.assigns.article
    changeset = Map.put(socket.assigns.form.source, :action, :insert)

    socket =
      case Repo.insert(changeset) do
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
    form =
      article
      |> MyBlog.change_article(params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, :form, form)}
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
    form =
      %Comment{}
      |> MyBlog.change_comment(Map.put(params, "article_id", article.id))
      |> to_form(action: :validate)

    {:noreply, assign(socket, :form, form)}
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
