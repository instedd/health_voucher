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

  %w(toggle_service? set_service_cost?).each do |method|
    alias_method method.to_sym, :update?
  end
  %w(services?).each do |method| 
    alias_method method.to_sym, :show?
  end

  class Scope < Scope
  end
end

