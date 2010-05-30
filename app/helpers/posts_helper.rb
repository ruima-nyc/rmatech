module PostsHelper

  def is_unread(post)

    if current_user and current_user.last_login_at > post.created_at
      ""
    else
      "unread"
    end
  end

end
