jQuery(function()
{
  challengeButton()
  enterScoreButton()
  watchButton()
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

var watchButton = function() {
  $('a#watch').click(function(event) {
    $(this).attr('href', null)
    event.stopPropagation();
    event.preventDefault();
    var player = $("<div class='modal' id='live_stream'>");
    var header = $("<div class='modal-header'>");
    header.append($("<button class='close' data-dismiss='modal'>x</button>"));
    header.append($("<h3>Live Stream</h3>"));

    player.append(header)

    var body = $("<div class='modal-body'></div>")

    player.append(body)

    body.append("<object type='application/x-shockwave-flash' height='400' width='530' id='jtv_flash' data='http://www.justin.tv/widgets/live_embed_player.swf?auto_play=false&amp;backgroundImage=&amp;channel=sudojosh&amp;hostname=www.justin.tv&amp;start_volume=0.0' bgcolor='#000000'>    <param name='allowFullScreen' value='true' />    <param name='allowScriptAccess' value='always' />    <param name='allowNetworking' value='all' />    <param name='movie' value='http://www.justin.tv/widgets/live_embed_player.swf' />    <param name='flashvars' value='auto_play=false&amp;backgroundImage=&amp;channel=sudojosh&amp;hostname=www.justin.tv&amp;start_volume=0.0' /></object>")

    player.on('hidden', function() {
      player.remove()
    });

    $('body').append(player)


    player.modal('show');


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

