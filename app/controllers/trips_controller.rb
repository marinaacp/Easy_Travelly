class TripsController < ApplicationController
  include Apitude

  def new
    list_hotels('2022-12-15', '2022-12-16')
  end

  def create
  end

  def edit
  end

  def update
  end

  def index
  end

  def show
  end

  def destroy
  end

end
