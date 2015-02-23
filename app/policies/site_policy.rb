class SitePolicy < ApplicationPolicy
  def index?
    user.admin? || user.auditor?
  end

  def show?
    user.admin? || user.auditor?
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def search?
    user.admin?
  end

  %w(assign_cards? batch_assign_cards? assign_individual_card? return_cards? 
     edit_manager? update_manager? set_manager? destroy_manager?).each do |method|
    alias_method method.to_sym, :update?
  end
  %w(patients? providers?).each do |method| 
    alias_method method.to_sym, :show?
  end

  class Scope < Scope
  end
end

