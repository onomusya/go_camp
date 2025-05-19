// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import "bootstrap"
import Rails from "@rails/ujs"
Rails.start()
import "reservation_total"
import "card"


document.addEventListener("turbo:load", function () {
  const carouselEl = document.querySelector('#topCarousel');
  if (carouselEl) {
    // すでにインスタンス化されていたら一度破棄
    if (bootstrap.Carousel.getInstance(carouselEl)) {
      bootstrap.Carousel.getInstance(carouselEl).dispose();
    }

    // BootstrapのCarouselを再初期化
    new bootstrap.Carousel(carouselEl, {
      interval: 3000,
      ride: 'carousel',
      pause: false
    });
  }
});