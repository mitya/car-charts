//= require_tree .

document.addEventListener "DOMContentLoaded", (event) ->
  retina = window.devicePixelRatio >= 2
  suffix = if retina then '@2x' else ''

  figures = document.querySelectorAll("img.retina")
  for figure in figures
    image = figure.dataset.image
    figure.src = "#{image}#{suffix}.png"

  figures = document.querySelectorAll("figure.retina")
  for figure in figures
    image = figure.dataset.image
    figure.style['background-image'] = "url(#{image}#{suffix}.png)"
