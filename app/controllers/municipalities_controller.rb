class MunicipalitiesController < ApplicationController
  def index
    @target_id = params[:target_id]
    @state = State.find(params[:state_id])
    @municipalities = @state.municipalities
  end

  def show
    @state = State.find(params[:state_id])
    @municipality = @state.municipalities.find(params[:id])
  end
end
