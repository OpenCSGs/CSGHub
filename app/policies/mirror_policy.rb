class MirrorPolicy < ApplicationPolicy
  def index?
    true
  end

  def new?
    user.admin?
  end

  def create?
    user.admin?
  end

  def show?
    true
  end

  def edit?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.super_user?
  end

  class Scope < Scope
    def resolve
      Mirror.all
    end
  end
end
