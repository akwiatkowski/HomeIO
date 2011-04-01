# Configures your navigation
SimpleNavigation::Configuration.run do |navigation|
  # Specify a custom renderer if needed.
  # The default renderer is SimpleNavigation::Renderer::List which renders HTML lists.
  # The renderer can also be specified as option in the render_navigation call.
  # navigation.renderer = Your::Custom::Renderer

  # Specify the class that will be applied to active navigation items. Defaults to 'selected'
  # navigation.selected_class = 'your_selected_class'

  # Item keys are normally added to list items as id.
  # This setting turns that off
  # navigation.autogenerate_item_ids = false

  # You can override the default logic that is used to autogenerate the item ids.
  # To do this, define a Proc which takes the key of the current item as argument.
  # The example below would add a prefix to each key.
  # navigation.id_generator = Proc.new {|key| "my-prefix-#{key}"}

  # The auto highlight feature is turned on by default.
  # This turns it off globally (for the whole plugin)
  # navigation.auto_highlight = false

  # Define the primary navigation
  navigation.items do |primary|
    # Add an item to the primary navigation. The following params apply:
    # key - a symbol which uniquely defines your navigation item in the scope of the primary_navigation
    # name - will be displayed in the rendered navigation. This can also be a call to your I18n-framework.
    # url - the address that the generated item links to. You can also use url_helpers (named routes, restful routes helper, url_for etc.)
    # options - can be used to specify attributes that will be included in the rendered navigation item (e.g. id, class etc.)
    #           some special options that can be set:
    #           :if - Specifies a proc to call to determine if the item should
    #                 be rendered (e.g. <tt>:if => Proc.new { current_user.admin? }</tt>). The
    #                 proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :unless - Specifies a proc to call to determine if the item should not
    #                     be rendered (e.g. <tt>:unless => Proc.new { current_user.admin? }</tt>). The
    #                     proc should evaluate to a true or false value and is evaluated in the context of the view.
    #           :method - Specifies the http-method for the generated link - default is :get.
    #           :highlights_on - if autohighlighting is turned off and/or you want to explicitly specify
    #                            when the item should be highlighted, you can set a regexp which is matched
    #                            against the current URI.
    #
    primary.item :meas, 'Measurements', meas_types_path do |sec|
      sec.item :meas_current, 'Current values', current_meas_types_path
      sec.item :meas_current, 'Detailed by type', meas_types_path do |ter|
        MeasType.all.each do |t|
          ter.item "meas_types_#{t.id}".to_sym, t.type, meas_type_meas_archives_path(t.id)
        end
      end

      #sec.item :meas_current, 'Current', meas_type_meas_archives_path(0)
      ##sec.item :meas_archived, 'Archived', meas_archives_path
      ##sec.item :meas_stats, 'Statistics', meas_archives_path
    end

    primary.item :cities, 'Cities', cities_path do |sec|
      sec.item :cities_a, 'Weather', cities_path
      sec.item :cities_b, 'METAR', cities_path
    end

    # Add an item which has a sub navigation (same params, but with block)
    #primary.item :key_2, 'name', url, options do |sub_nav|
    # Add an item to the sub navigation (same params again)
    #sub_nav.item :key_2_1, 'name', url, options
    #end

    # You can also specify a condition-proc that needs to be fullfilled to display an item.
    # Conditions are part of the options. They are evaluated in the context of the views,
    # thus you can use all the methods and vars you have available in the views.
    #primary.item :key_3, 'Admin', user_session_path, :class => 'special' #, :if => Proc.new { current_user.admin? }
    primary.item :account, 'Sign in', user_session_path, :if => Proc.new { not current_user } #:unless => Proc.new { logged_in? }
    primary.item :account, 'Register', new_user_path, :if => Proc.new { not current_user } #:unless => Proc.new { logged_in? }
    primary.item :account, 'Account', user_session_path, :if => Proc.new { current_user } do |sec| #:unless => Proc.new { logged_in? }
      sec.item :account_logout, 'Logout', user_session_path, :method => :delete, :if => Proc.new { current_user }
    end

    # you can also specify a css id or class to attach to this particular level
    # works for all levels of the menu
    # primary.dom_id = 'menu-id'
    # primary.dom_class = 'menu-class'

    # You can turn off auto highlighting for a specific level
    # primary.auto_highlight = false

  end

end