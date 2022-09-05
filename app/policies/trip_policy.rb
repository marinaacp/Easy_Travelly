class TripPolicy < ApplicationPolicy
  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      scope.where(user: user).where.not(booking: nil).order(:id)
    end
  end

  def show?
    owner?
  end

  def new?
    true
  end

  def create?
    true
  end

  def destroy?
    owner?
  end

  def update?
    owner?
  end

  private

  def owner?
    record.user == user
  end
end
