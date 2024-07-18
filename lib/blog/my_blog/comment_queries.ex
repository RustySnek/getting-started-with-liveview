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
