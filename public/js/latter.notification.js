/* Latter Notification Engine
    Author: Josh McArthur 
    Requirements: jQuery > 1.2
*/

(function($) {
    $.fn.lNotification = function(options) {
        var options = $.extend({'klass': '', 'delay': 3000}, options);
        return this.each(function()
        {
            obj = $(this);
            if($('.notification').length > 0) 
            {
                $('.notification').hide();
                $('.notification').remove();
            }
            var notification = $("<div class='notification' class='" + options.klass + "'></div>");
            notification.innerText(obj.html());
            notification.appendTo($('body')).slideDown(200).delay(options.delay).slideUp(200, function() { $(this).remove(); });
        });
    };
})(jQuery);
