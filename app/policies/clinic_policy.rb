class ClinicPolicy < ApplicationPolicy
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

  %i(toggle_service? set_service_cost?).each do |method|
    alias_method method, :update?
  end
  %i(services?).each do |method| 
    alias_method method, :show?
  end

  class Scope < Scope
  end
end

