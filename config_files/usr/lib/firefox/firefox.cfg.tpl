// Do not remove this line

Components.classes["@mozilla.org/observer-service;1"].getService(Components.interfaces.nsIObserverService ).addObserver({
    observe : function(subject, topic, data) {
        var channel = subject.QueryInterface(Components.interfaces.nsIHttpChannel);

        channel.setRequestHeader("EXAM-VERSION", "%exam_version%", false);
        channel.setRequestHeader("EXAM-IP", "%exam_ip%", false);
        channel.setRequestHeader("EXAM-NETWORK", "%exam_network%", false);
    }
},"http-on-modify-request",false);

