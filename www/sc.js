// detect jailbreak / debugger and EXIT!
window.watchForBreak = function() {
    cordova.exec(null, null, "SC", "watchForBreak", []);
};
// detect jailbreak
window.jailbreakCheck = function(jailBroken) {
    cordova.exec(null, jailBroken, "SC", "jailbreakCheck", []);    
};
// detect debugger
window.debuggerCheck = function(debuggerFound) {
    cordova.exec(null, debuggerFound, "SC", "debuggerCheck", []);
};
