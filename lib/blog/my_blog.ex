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
end
