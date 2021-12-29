class SessionsController < ApplicationController
  def new
    municipality_id = session[:municipality_id]

    if municipality_id.present?
      municipality = Municipality.find(municipality_id)
      state = municipality.state
      redirect_to state_municipality_path(state, municipality_id)
    else
      @states = State.all
    end
  end

  def create
    state = params[:state]
    municipality = params[:municipality]
    session[:municipality_id] = municipality
    redirect_to state_municipality_path(state, municipality)
  end
end
