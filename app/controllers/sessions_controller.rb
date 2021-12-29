class SessionsController < ApplicationController
  def new
    @states = State.all
  end
end
