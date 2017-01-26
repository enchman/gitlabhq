module Search
  class GlobalService
    attr_accessor :current_user, :params

    def initialize(user, params)
      @current_user, @params = user, params.dup
    end

    def execute
      group = Group.find_by(id: params[:group_id]) if params[:group_id].present?
      projects = ProjectsFinder.new.execute(current_user)

      if group
        ids = group.descendants.push(group.id)
        projects = projects.in_namespace(ids)
      end

      Gitlab::SearchResults.new(current_user, projects, params[:search])
    end
  end
end
