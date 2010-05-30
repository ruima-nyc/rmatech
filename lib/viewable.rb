module Viewable
  protected
  def update_view_count(viewable)
    stack_name = viewable.class.to_s.underscore.downcase

    if cookies[stack_name].nil?
      cookies[stack_name] = viewable.id.to_s
      viewable.update_attribute(:hits, viewable.hits + 1)
    elsif !cookies[stack_name].to_s.split(',').include?(viewable.id.to_s)
      cookies[stack_name] = cookies[stack_name] << ",#{viewable.id.to_s}"
      viewable.update_attribute(:hits, viewable.hits + 1)
    else
      #already viewed it, do nothing
      return false
    end
  end
end