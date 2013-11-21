
startRecordWithSettings = function(id, src, options) {

	console.log("startRecordWithSettings");
	cordova.exec(null, null, "record_audio_testViewController","startAudioRecord", [src]);
};

stopRecordWithSettings = function() {

	console.log("stopRecordWithSettings");
	cordova.exec(null, null, "record_audio_testViewController","stopAudioRecord", []);
};

merge2wav = function( src ) {

	console.log("merge2wav");
	cordova.exec(null, null, "record_audio_testViewController","merge2wav", [src]);
};

playOutputAudio = function() {
	
	console.log("playRecordWithSettings");
	cordova.exec(null, null, "record_audio_testViewController","playOutputAudio", []);
};

stopOutputAudio = function() {
	
	console.log("stopRecordWithSettings");
	cordova.exec(null, null, "record_audio_testViewController","stopOutputAudio", []);
};

getCurrentTime = function(id) {

	cordova.exec(null, null, "record_audio_testViewController","getCurrentTime", [id]);
};

initPlayOpenAL = function(id) {

	console.log("initPlayOpenAL");
	cordova.exec(null, null, "record_audio_testViewController","initPlayOpenAL", [id]);
};

setRoomType = function( type_id ) {
	
	console.log("setRoomType =>" + type_id);
	cordova.exec(null, null, "record_audio_testViewController","setRoomType", [type_id]);
}