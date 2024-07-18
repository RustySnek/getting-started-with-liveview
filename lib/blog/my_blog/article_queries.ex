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
