# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  

  def distance_of_time_in_words(from_time, to_time = 0, include_seconds = false)
    from_time = from_time.to_time if from_time.respond_to?(:to_time)
    to_time = to_time.to_time if to_time.respond_to?(:to_time)
    distance_in_minutes = (((to_time - from_time).abs)/60).round

    case distance_in_minutes
    when 0..1           then (distance_in_minutes==0) ? '就刚才' : '一分钟前'
    when 2..59          then "#{distance_in_minutes}"+'分钟前'
    when 60..90         then '几小时前'
    when 90..1440       then "#{(distance_in_minutes.to_f / 60.0).round}"+'小时前'
    when 1440..2160     then '一天前' # 1 day to 1.5 days
    when 2160..2880     then "#{(distance_in_minutes.to_f / 1440.0).round} "+'天前' # 1.5 days to 2 days
    else from_time.strftime("%Y年%m月%d日").gsub(/([AP]M)/) { |x| x.downcase }
    end
  end

  def page_title
		app_base = SITE_NAME
		tagline = "#{SITE_DESC} - "

		title = app_base
		case @controller.controller_name


    when 'posts'
      if @post and @post.title

        title = @post.title+" - "+app_base
      else
        title = tagline + app_base
      end
    when 'tags'
      if @tag and @tag.name
        title = @tag.name+" - "+app_base
      end
    when 'users'
      if @user and @user.login
        title = @user.login+"的个人页 - "+app_base
      end
    end
		title
	end


  def url_with_protocol(original_url)
      if original_url
        if (original_url =~ /[a-zA-Z]*\:/) != 0
          return 'http://' + original_url
        end
        original_url
      end
    end
end
