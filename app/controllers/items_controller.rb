class ItemsController < ApplicationController
  def index
    @rental_items = Item.rental
    @sale_items = Item.sale
  end
end
