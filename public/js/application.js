jQuery(function()
{
  challengeButton()
  enterScoreButton()
  //playerRankingHack()
});

var challengeButton = function() {
  $('a.challenge.btn').click(function(event) {
    event.stopPropagation();
    event.preventDefault();

    player_id = $(this).attr('data-player-id');
    $.getScript("/player/" + player_id + "/challenge")

    return false;
  });
}

var enterScoreButton = function() {
  $('#enter_score form').submit(function(event) {
    $(this).find('button').button('loading');
    return true;
  });

  $('a.enter_score.btn').click(function(event) {
    event.stopPropagation();
    event.preventDefault();

    challenge_id = $(this).attr('data-challenge-id');
    $.getScript("/challenge/" + challenge_id + "/complete")

    return false;
  });
}
var numbers_only = function(elem) {
    elem.val(elem.val().replace(/[^0-9]/gi, ""));
}

var playerRankingHack = function() {
  console.log('Fired')
  var resize_ranking = function() {
    $('.player .ranking-container').each(function(index, element) {
      $(element).height($(element).parent().find('.thumbnail img').height());
    });
  }

  resize_ranking()
  $(window).resize(resize_ranking)
}
