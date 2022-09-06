if @trip.persisted?
  json.form json.partial!("trips/form.html.erb", trip: @trip)
  json.inserted_item json.partial!("trips/name.html.erb", trip: @trip)
else
  json.form json.partial!("trips/form.html.erb", trip: @trip)
end
