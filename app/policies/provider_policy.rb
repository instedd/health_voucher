class ProviderPolicy < ApplicationPolicy
  def create?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  def toggle?
    user.admin?
  end

  class Scope < Scope
  end
end

