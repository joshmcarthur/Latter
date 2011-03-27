jQuery(function()
{
    $('input[type=text]').focus(function() { $(this).focus(); $(this).select(); });  
});

var numbers_only = function(elem) {
    elem.val(elem.val().replace(/[^0-9]/gi, ""));
}

var set_result = function(from_player_name, to_player_name)
{
    var from_score = $('section#scores input#from_player_score');
    var to_score = $('section#scores input#to_player_score');
    var result = $('section#scores span.result');
    numbers_only(from_score);
    numbers_only(to_score);
    
    if(parseInt(from_score.val()) > parseInt(to_score.val()))
    {
        result.text("= " + from_player_name + " won!");
    }
    else if(parseInt(from_score.val()) < parseInt(to_score.val()))
    {
        result.text("= " + to_player_name + " won!");
    }
    else if(parseInt(from_score.val()) == parseInt(to_score.val())) 
    { 
        result.text("= It's a draw!"); 
    }  
}
