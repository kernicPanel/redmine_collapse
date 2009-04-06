require_dependency 'application_helper'

module CollapseApplicationHelperPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)

    base.send(:include, InstanceMethods)
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    
    ###
    # Compatibility validations
    ###
    
    # Redmine Core 0.8-stable@r2229 (0.8.1)
    # Returns true if the method is defined, else it returns false
    def jump_to_current_view_implemented
      if Redmine::MenuManager::MenuController.method_defined? "redirect_to_project_menu_item"
        return true
      else
        return false
      end
    end
    
    # Redmine Core 0.8-stable@r2230 (0.8.1)
    # Returns true if the method is defined, else it returns false
    def render_flash_messages_implemented 
      if ApplicationHelper.method_defined? "render_flash_messages" 
        return true
      else
        return false
      end
    end
    
    # Redmine Core trunk@r2304
    # Returns true if the method is defined, else it returns false
    def render_project_hierarchy_implemented 
      if ProjectsHelper.method_defined? "render_project_hierarchy" 
        return true
      else
        return false
      end
    end
    
    # Redmine Core trunk@r2485
    # Returns true if the method is defined, else it returns false
    def page_header_title_implemented
      if ApplicationHelper.method_defined? "page_header_title" 
        return true
      else
        return false
      end
    end
    
    ###
    # Tab helpers
    ###
    
    # Renders a tree of projects as a nested set of unordered lists
    # The given collection may be a subset of the whole project tree
    # (eg. some intermediate nodes are private and can not be seen)
    def render_involved_projects_list(projects)
      s = ''
      if projects.any?
        ancestors = []
        projects.each do |project|
          if (ancestors.empty? || project.is_descendant_of?(ancestors.last))
            s << "<ul class='projects #{ ancestors.empty? ? 'root' : nil}'>\n"
          else
            ancestors.pop
            s << "</li>"
            while (ancestors.any? && !project.is_descendant_of?(ancestors.last)) 
              ancestors.pop
              s << "</ul></li>\n"
            end
          end
          classes = (ancestors.empty? ? 'root' : 'child')
          s << "<li>" +
                       if !@project.nil?
                link_to_if (project.identifier != @project.identifier), h(project), {:controller => 'projects', :action => 'show', :id => project, :jump => current_menu_item}
                       else
                link_to (h(project), {:controller => 'projects', :action => 'show', :id => project})
			           end
                ancestors << project
        end
        s << ("</li></ul>\n" * ancestors.size)
      end
      s
    end

    # Left-menu tabs renderer
    # Returns the tabs-variable containing an array of the left-menu tabs to render
    def left_menu_tabs
      # Don't render the projects-tab unless specifically configured
      if Setting.plugin_redmine_collapse['show_projects_tab'] == '1'
        # => Redmine trunk@r2493?
        if Redmine.const_defined?(:I18n)
          tabs = [ { :name => 'actions-tab', :label => :label_actions_tab, :partial => 'left_menu/actions.rhtml' },
                   { :name => 'projects-tab', :label => :label_projects_tab, :partial => 'left_menu/projects.rhtml' } ]
        else
          tabs = [ { :name => 'actions-tab', :label => l(:label_actions_tab), :partial => 'left_menu/actions.rhtml' },
                   { :name => 'projects-tab', :label => l(:label_projects_tab), :partial => 'left_menu/projects.rhtml' } ]
        end
      # Always render the actions-tab
      else
        # => Redmine trunk@r2493?
        if Redmine.const_defined?(:I18n)
          tabs = [ { :name => 'actions-tab', :label => :label_actions_tab, :partial => 'left_menu/actions.rhtml' } ]
        else
          tabs = [ { :name => 'actions-tab', :label => l(:label_actions_tab), :partial => 'left_menu/actions.rhtml' } ]
        end
      end
      return tabs
    end
    
    # Left-menu selected-tab based on active controller and activated-tabs settings
    # Returns a string containing the name of the selected tab
    def left_menu_selected_tab
      # The controllers on which the projects-tab should be activated by default
      projecttab_controllers = [ 'welcome', 'account', 'admin', 'users', 'roles', 'trackers', 'issue_statuses', 'workflows', 'custom_fields', 'enumerations', 'settings' ]
      
      if (Setting.plugin_redmine_collapse['show_projects_tab'] == '1' ) && (projecttab_controllers.include?(params[:controller]))
        selectedtab = 'projects-tab'
      else
        selectedtab = 'actions-tab'
      end
      return selectedtab
    end
    
    # Currently used Redmine Theme based on the global setting
    # Returns a string containing the name of the current theme
    def current_redmine_theme
      if (Setting.ui_theme == '')
        currenttheme = 'default'
      elsif (Setting.ui_theme == 'alternate')
        currenttheme = 'alternate'
      elsif (Setting.ui_theme == 'classic')
        currenttheme = 'classic'
      elsif (Setting.ui_theme == 'basecamp')
        currenttheme = 'basecamp'
      elsif (Setting.ui_theme == 'squeejee')
        currenttheme = 'squeejee'
      else
        currenttheme = 'default'
      end
      return currenttheme
    end
    
  end
end

ApplicationHelper.send(:include, CollapseApplicationHelperPatch)
