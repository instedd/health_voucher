class MentorPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.admin? || user.auditor? || (user.site_manager? && record.site_id == user.site.id)
  end

  def create?
    user.admin? || (user.site_manager? && record.site_id == user.site.id)
  end

  def destroy?
    user.admin? || (user.site_manager? && record.site_id == user.site.id)
  end

  def update?
    user.admin? || (user.site_manager? && record.site_id == user.site.id)
  end

  %i(add_patients? auto_assign? move_patients? batch_validate?).each do |method|
    alias_method method, :update?
  end

  class Scope < Scope
    def resolve
      if user.site_manager?
        scope.where(site_id: user.site.id)
      else
        scope
      end
    end
  end
end

