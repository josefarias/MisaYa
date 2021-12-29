class MunicipalitiesController < ApplicationController
  def index
    @target_id = params[:target_id]
    @state = State.find(params[:id])
    @municipalities = @state.municipalities
  end
end
