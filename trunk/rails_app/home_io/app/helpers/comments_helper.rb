module CommentsHelper
  def new_ancestor_comment_path
    eval("new_#{@ancestor.class.to_s.underscore}_comment_path(#{@ancestor.id})")
  end
end
