jQuery(function()
{
  challengeButton()
  enterScoreButton()
});

var challengeButton = function() {
  $('a.challenge.btn').click(function(event) {
    event.stopPropagation();
    event.preventDefault();

    player_id = $(this).attr('data-player-id');
    $.ajax({
      type: "POST",
      url: "/player/" + player_id + "/challenge",
      dataType: 'script'
    });

    return false;
  });
}

var pollActivity = function() {
  setTimeout(function() {
    fetchActivities(function(data) {
      addActivities(data);
      pollActivity()
    });
  }, 5000);
}

var fetchActivities = function(successCallback) {
  $.ajax({
    url: '/activities.json',
    success: successCallback,
    dataType: 'json',
    ifModified: true,
  })
}

var addActivities = function(activities) {
  // Assume first activity is the most recent
  if (activities.length > 0) {
    $('#activities').data('latest', activities[0].created_at)
  }

  $.each(activities, function(index, activity) {
    $('#activities ul').append($('<li></li>').text(activity.message).slideDown());
    if ($('#activities ul li').length > 5) {
      $('#activities ul li:last-child').remove()
    }
  });

  $('#activities').addClass('visible-desktop');
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
    $.getScript("/games/" + challenge_id + "/complete")

    return false;
  });
}
var numbers_only = function(elem) {
    elem.val(elem.val().replace(/[^0-9]/gi, ""));
}

